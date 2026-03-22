# 测试指南

**版本**: 1.0
**适用范围**: 开发、测试人员

---

## 1. 测试策略

### 1.1 测试金字塔
```
        /\
       /  \      E2E测试 (少量)
      /----\
     /      \    集成测试 (中等)
    /--------\
   /          \  单元测试 (大量)
  /------------\
```

### 1.2 测试目标
- 单元测试覆盖率: ≥ 60%
- 核心业务流程: 100%覆盖
- 接口测试: 全部接口
- E2E测试: 主流程覆盖

---

## 2. 单元测试

### 2.1 Go后端测试

**运行测试**:
```bash
cd backend

# 运行所有测试
go test ./...

# 运行指定包测试
go test ./03-user-service/...

# 运行并查看覆盖率
go test -cover ./...

# 生成覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

**测试文件命名**:
- 测试文件: `xxx_test.go`
- Mock文件: `xxx_mock.go`

**测试示例**:
```go
// user_service_test.go
package service

import (
    "context"
    "testing"
    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/mock"
)

// Mock Repository
type mockUserRepository struct {
    mock.Mock
}

func (m *mockUserRepository) FindByID(ctx context.Context, id int64) (*User, error) {
    args := m.Called(ctx, id)
    if args.Get(0) == nil {
        return nil, args.Error(1)
    }
    return args.Get(0).(*User), args.Error(1)
}

func TestUserService_GetUser(t *testing.T) {
    // Arrange
    mockRepo := new(mockUserRepository)
    service := NewUserService(mockRepo, nil, nil, nil)

    expectedUser := &User{
        ID:   1,
        Name: "Test User",
        Phone: "+95123456789",
    }

    mockRepo.On("FindByID", mock.Anything, int64(1)).
        Return(expectedUser, nil)

    // Act
    user, err := service.GetUser(context.Background(), 1)

    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, expectedUser.Name, user.Name)
    mockRepo.AssertExpectations(t)
}

func TestUserService_GetUser_NotFound(t *testing.T) {
    // Arrange
    mockRepo := new(mockUserRepository)
    service := NewUserService(mockRepo, nil, nil, nil)

    mockRepo.On("FindByID", mock.Anything, int64(999)).
        Return(nil, nil)

    // Act
    user, err := service.GetUser(context.Background(), 999)

    // Assert
    assert.NoError(t, err)
    assert.Nil(t, user)
}
```

### 2.2 Flutter测试

**运行测试**:
```bash
cd flutter

# 运行所有测试
flutter test

# 运行指定文件
flutter test test/user_service_test.dart

# 查看覆盖率
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Widget测试**:
```dart
// login_page_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('LoginPage', () {
    testWidgets('should show login form', (WidgetTester tester) async {
      // Build widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Verify
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.text('登录'), findsOneWidget);
    });

    testWidgets('should validate phone number', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: LoginPage(),
          ),
        ),
      );

      // Enter invalid phone
      await tester.enterText(
        find.byType(TextField).first,
        'invalid',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify error message
      expect(find.text('手机号格式错误'), findsOneWidget);
    });
  });
}
```

---

## 3. 接口测试

### 3.1 自动化接口测试

**测试脚本**: `backend/scripts/api_test.go`

```go
package main

import (
    "bytes"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"

    "github.com/gin-gonic/gin"
    "github.com/stretchr/testify/assert"
)

func TestAuthAPI(t *testing.T) {
    gin.SetMode(gin.TestMode)
    router := setupRouter()

    tests := []struct {
        name       string
        method     string
        path       string
        body       interface{}
        wantStatus int
        wantCode   int
    }{
        {
            name:   "发送验证码-成功",
            method: "POST",
            path:   "/v1/auth/send-verification-code",
            body: map[string]string{
                "phone": "+95123456789",
                "type":  "register",
            },
            wantStatus: http.StatusOK,
            wantCode:   200,
        },
        {
            name:   "发送验证码-缺少参数",
            method: "POST",
            path:   "/v1/auth/send-verification-code",
            body: map[string]string{
                "phone": "+95123456789",
            },
            wantStatus: http.StatusBadRequest,
            wantCode:   2,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            body, _ := json.Marshal(tt.body)
            req := httptest.NewRequest(tt.method, tt.path, bytes.NewBuffer(body))
            req.Header.Set("Content-Type", "application/json")

            w := httptest.NewRecorder()
            router.ServeHTTP(w, req)

            assert.Equal(t, tt.wantStatus, w.Code)

            var resp map[string]interface{}
            json.Unmarshal(w.Body.Bytes(), &resp)
            assert.Equal(t, float64(tt.wantCode), resp["code"])
        })
    }
}
```

### 3.2 Postman测试集

**创建测试集合**: `docs/testing/postman/myanmar-property-api.json`

环境变量:
```json
{
  "base_url": "http://localhost:8080",
  "access_token": ""
}
```

测试脚本示例:
```javascript
// 登录成功后保存token
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.data.access_token);
}

// 验证响应
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

pm.test("Response has correct code", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.code).to.eql(200);
});
```

---

## 4. E2E测试

### 4.1 测试场景

**场景1: 用户注册→登录→查看房源**
```
1. 发送注册验证码
2. 使用验证码注册
3. 使用验证码登录
4. 获取用户信息
5. 搜索房源列表
6. 查看房源详情
```

**场景2: 经纪人发布房源**
```
1. 经纪人登录
2. 创建房源
3. 上传房源图片
4. 提交审核
5. 查看房源状态
```

### 4.2 Flutter集成测试

```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myanmarhome/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    test('complete user journey', () async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('登录'));
      await tester.pumpAndSettle();

      // Enter phone
      await tester.enterText(
        find.byType(TextField).first,
        '+95123456789',
      );

      // Get verification code
      await tester.tap(find.text('获取验证码'));
      await tester.pump(Duration(seconds: 2));

      // Enter code (mock: 123456)
      await tester.enterText(
        find.byType(TextField).last,
        '123456',
      );

      // Login
      await tester.tap(find.text('登录'));
      await tester.pumpAndSettle();

      // Verify home page
      expect(find.text('首页'), findsOneWidget);
    });
  });
}
```

**运行E2E测试**:
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

---

## 5. 性能测试

### 5.1 API压力测试

**使用k6**:
```javascript
// load_test.js
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '2m', target: 100 },  // Ramp up
    { duration: '5m', target: 100 },  // Stay at 100 users
    { duration: '2m', target: 200 },  // Ramp up to 200
    { duration: '5m', target: 200 },  // Stay at 200
    { duration: '2m', target: 0 },    // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95%请求<500ms
    http_req_failed: ['rate<0.01'],   // 错误率<1%
  },
};

export default function() {
  let response = http.get('http://localhost:8080/health');

  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
```

**运行**:
```bash
k6 run load_test.js
```

### 5.2 数据库性能测试

```bash
# 使用pgbench
pgbench -h localhost -U myanmar_property -d myanmarhome \
  -c 10 -j 2 -t 1000 \
  -f custom_query.sql
```

---

## 6. 测试数据管理

### 6.1 种子数据

**SQL文件**: `backend/scripts/seed_data.sql`

```sql
-- 测试用户
INSERT INTO users (uuid, phone, password_hash, name, user_type, status, created_at)
VALUES
('usr_test_001', '+95111111111', '$2a$10$...', '测试买家1', 'buyer', 'active', NOW()),
('usr_test_002', '+95222222222', '$2a$10$...', '测试买家2', 'buyer', 'active', NOW()),
('usr_test_003', '+95333333333', '$2a$10$...', '测试经纪人1', 'agent', 'active', NOW());

-- 测试房源
INSERT INTO houses (house_code, title, price, area, status, created_at)
VALUES
('HS001', '仰光市中心公寓', 500000000, 120, 'active', NOW()),
('HS002', '曼德勒别墅', 1200000000, 300, 'active', NOW());
```

**Go代码生成**:
```go
// testdata/generator.go
package testdata

import (
    "context"
    "fmt"
    "math/rand"
)

func GenerateTestUsers(ctx context.Context, count int) ([]*User, error) {
    users := make([]*User, count)
    for i := 0; i < count; i++ {
        users[i] = &User{
            Phone:    fmt.Sprintf("+95%d", 100000000+i),
            Name:     fmt.Sprintf("Test User %d", i),
            UserType: []string{"buyer", "agent"}[rand.Intn(2)],
            Status:   "active",
        }
    }
    return users, nil
}
```

### 6.2 数据清理

```bash
# 测试后清理数据
cd backend
psql -h localhost -U myanmar_property -d myanmarhome -f scripts/cleanup_test_data.sql
```

---

## 7. CI/CD集成

### 7.1 GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_USER: test
          POSTGRES_PASSWORD: test
          POSTGRES_DB: test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - name: Setup Go
        uses: actions/setup-go@v4
        with:
          go-version: '1.21'

      - name: Run tests
        run: go test -v -race -coverprofile=coverage.out ./...
        env:
          DATABASE_URL: postgres://test:test@localhost:5432/test?sslmode=disable

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.out

  test-flutter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test
```

---

## 8. 测试检查清单

### 8.1 提交前检查
- [ ] 单元测试全部通过
- [ ] 新增代码有对应的测试
- [ ] 覆盖率不下降
- [ ] 无race condition（Go: -race）

### 8.2 发布前检查
- [ ] 集成测试通过
- [ ] 性能测试达标
- [ ] 安全测试通过（SQL注入/XSS）
- [ ] 兼容性测试（多浏览器/多设备）

---

## 9. 常见问题

### 9.1 测试数据库
```bash
# 创建测试数据库
createdb -h localhost -U postgres myanmarhome_test

# 运行迁移
migrate -path ./migrations \
  -database "postgresql://postgres:password@localhost:5432/myanmarhome_test?sslmode=disable" \
  up
```

### 9.2 Mock数据
```dart
// Flutter测试中使用mock数据
class MockHouseRepository implements HouseRepository {
  @override
  Future<List<House>> getHouses() async {
    return [
      House(id: '1', title: 'Mock House 1', price: 100000),
      House(id: '2', title: 'Mock House 2', price: 200000),
    ];
  }
}
```

---

## 10. 参考资源

- [Go Testing](https://golang.org/pkg/testing/)
- [Flutter Testing](https://flutter.dev/docs/testing)
- [Postman Testing](https://learning.postman.com/docs/running-collections/intro-to-collection-runs/)
- [k6 Documentation](https://k6.io/docs/)
