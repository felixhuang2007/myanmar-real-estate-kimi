# 开发规范与代码标准

**版本**: 1.0
**适用范围**: 缅甸房产平台所有模块

---

## 1. 代码仓库规范

### 1.1 分支策略
```
main (生产分支)
  ↑
release/v1.x (预发布分支)
  ↑
develop (开发主分支)
  ↑
feature/xxx (功能分支)
hotfix/xxx (热修复分支)
```

### 1.2 提交规范
**格式**: `<type>(<scope>): <subject>`

**类型说明**:
| 类型 | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug修复 |
| docs | 文档更新 |
| style | 代码格式（不影响功能）|
| refactor | 重构 |
| test | 测试相关 |
| chore | 构建/工具/配置 |

**示例**:
```
feat(user): 添加用户实名认证接口

- 实现身份证OCR识别
- 添加实名认证状态机
- 补充单元测试

fix(acn): 修复分佣计算精度问题

docs(api): 更新ACN接口文档
```

### 1.3 代码审查清单
- [ ] 代码符合规范
- [ ] 有单元测试
- [ ] 通过CI检查
- [ ] 文档已更新
- [ ] 无敏感信息泄露

---

## 2. Go后端规范

### 2.1 项目结构
```
backend/
├── cmd/
│   └── server/
│       └── main.go          # 入口文件
├── 03-user-service/         # 用户模块
│   ├── controller/          # HTTP处理器
│   ├── service/             # 业务逻辑
│   ├── repository/          # 数据访问
│   └── model/               # 数据模型
├── 07-common/               # 公共组件
│   ├── config.go            # 配置管理
│   ├── database.go          # 数据库连接
│   ├── logger.go            # 日志
│   └── errors.go            # 错误定义
└── pkg/                     # 可复用包
    └── utils/
```

### 2.2 命名规范
**文件命名**:
- 全小写，下划线分隔
- 测试文件: `xxx_test.go`
- 示例: `user_controller.go`

**变量命名**:
```go
// 包级变量（驼峰式）
var globalConfig *Config

// 局部变量（驼峰式）
userID := 123

// 常量（大写下划线）
const MaxRetryCount = 3

// 接口名（动词+er）
type UserService interface{}
type HouseRepository interface{}

// 结构体名（名词）
type User struct{}
type HouseController struct{}
```

### 2.3 代码风格
**错误处理**:
```go
// ✅ 正确：逐层返回错误
user, err := s.repo.FindByID(ctx, id)
if err != nil {
    return nil, fmt.Errorf("查找用户失败: %w", err)
}

// ❌ 错误：忽略错误
user, _ := s.repo.FindByID(ctx, id)

// ✅ 正确：自定义错误类型
if user == nil {
    return nil, common.NewAppError(common.CodeUserNotFound, "用户不存在")
}
```

**日志规范**:
```go
// ✅ 正确：结构化日志
common.Info("用户登录成功",
    common.String("user_id", user.ID),
    common.String("phone", user.Phone),
)

// ✅ 正确：不同级别
common.Debug("调试信息", common.String("detail", "xxx"))
common.Info("业务信息")
common.Warn("警告信息", common.ErrorField(err))
common.Error("错误信息", common.ErrorField(err))

// ❌ 错误：使用fmt.Println
fmt.Println("user login")
```

**上下文传递**:
```go
// ✅ 正确：context作为第一个参数
func (s *UserService) GetUser(ctx context.Context, id int64) (*User, error)

// ✅ 正确：超时控制
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()

// ✅ 正确：传递context
user, err := s.repo.FindByID(ctx, id)
```

### 2.4 接口设计
**路由注册**:
```go
func (c *UserController) RegisterRoutes(r *gin.RouterGroup) {
    // 公开接口
    auth := r.Group("/auth")
    {
        auth.POST("/login", c.Login)
        auth.POST("/register", c.Register)
    }

    // 需要认证
    users := r.Group("/users")
    users.Use(c.AuthMiddleware())
    {
        users.GET("/me", c.GetCurrentUser)
        users.PUT("/me", c.UpdateProfile)
    }
}
```

**请求响应**:
```go
// 请求结构体
type LoginRequest struct {
    Phone    string `json:"phone" binding:"required,phone"`
    Password string `json:"password" binding:"required,min=6"`
}

// 响应结构体
type LoginResponse struct {
    AccessToken  string `json:"access_token"`
    RefreshToken string `json:"refresh_token"`
    ExpiresIn    int64  `json:"expires_in"`
    User         *User  `json:"user"`
}
```

### 2.5 数据库操作
**GORM规范**:
```go
// ✅ 正确：使用事务
err := common.Transaction(ctx, func(tx *gorm.DB) error {
    if err := tx.Create(user).Error; err != nil {
        return err
    }
    if err := tx.Create(profile).Error; err != nil {
        return err
    }
    return nil
})

// ✅ 正确：软删除
func (r *UserRepository) Delete(ctx context.Context, id int64) error {
    return r.db.WithContext(ctx).Model(&User{}).
        Where("id = ?", id).
        Update("deleted_at", time.Now()).Error
}

// ✅ 正确：预加载
users, err := r.db.WithContext(ctx).
    Preload("Profile").
    Preload("Company").
    Find(&users).Error
```

---

## 3. Flutter前端规范

### 3.1 项目结构
```
lib/
├── core/                    # 核心层
│   ├── api/                 # API客户端
│   ├── constants/           # 常量
│   ├── models/              # 数据模型
│   ├── router/              # 路由
│   ├── storage/             # 本地存储
│   ├── theme/               # 主题
│   └── utils/               # 工具
├── features/                # 功能模块
│   ├── auth/                # 认证
│   ├── home/                # 首页
│   └── profile/             # 个人中心
└── shared/                  # 共享组件
    └── widgets/
```

### 3.2 命名规范
**文件命名**:
- 小写下划线: `user_profile_page.dart`
- 页面后缀: `_page.dart`
- Widget后缀: `_widget.dart`

**类命名**:
```dart
// 页面：名词+Page
class UserProfilePage extends StatelessWidget {}

// Widget：描述性名词
class HouseCard extends StatelessWidget {}

// Controller：名词+Controller/Provider
class AuthController extends StateNotifier<AuthState> {}

// Model：名词
class UserModel {}
```

### 3.3 状态管理
**Riverpod规范**:
```dart
// ✅ 正确：定义State
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    User? user,
    String? error,
  }) = _AuthState;
}

// ✅ 正确：定义Provider
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  Future<void> login(String phone, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await ref.read(authRepositoryProvider).login(phone, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ✅ 正确：使用Provider
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    if (state.isLoading) {
      return const LoadingWidget();
    }

    return LoginForm(
      onSubmit: (phone, password) {
        ref.read(authControllerProvider.notifier).login(phone, password);
      },
    );
  }
}
```

### 3.4 UI规范
**组件设计**:
```dart
// ✅ 正确：组件参数化
class HouseCard extends StatelessWidget {
  const HouseCard({
    Key? key,
    required this.house,
    this.onTap,
    this.showFavorite = true,
  }) : super(key: key);

  final House house;
  final VoidCallback? onTap;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            HouseImage(imageUrl: house.coverImage),
            HouseInfo(
              title: house.title,
              price: house.price,
            ),
            if (showFavorite) FavoriteButton(houseId: house.id),
          ],
        ),
      ),
    );
  }
}
```

**常量定义**:
```dart
// core/constants/app_constants.dart
class AppConstants {
  static const String appName = '缅甸房产';
  static const String apiBaseUrl = 'http://localhost:8080';
  static const int pageSize = 20;
  static const Duration apiTimeout = Duration(seconds: 30);
}

class AppColors {
  static const Color primary = Color(0xFF1890FF);
  static const Color success = Color(0xFF52C41A);
  static const Color warning = Color(0xFFFAAD14);
  static const Color error = Color(0xFFF5222D);
}
```

---

## 4. 测试规范

### 4.1 单元测试（Go）
```go
func TestUserService_Login(t *testing.T) {
    // Arrange
    mockRepo := new(mockUserRepository)
    service := NewUserService(mockRepo, nil, nil, nil)

    mockRepo.On("FindByPhone", mock.Anything, "1234567890").
        Return(&User{ID: 1, Phone: "1234567890"}, nil)

    // Act
    user, err := service.Login(context.Background(), &LoginRequest{
        Phone:    "1234567890",
        Password: "password123",
    })

    // Assert
    assert.NoError(t, err)
    assert.NotNil(t, user)
    assert.Equal(t, "1234567890", user.Phone)
    mockRepo.AssertExpectations(t)
}
```

### 4.2 Widget测试（Flutter）
```dart
void main() {
  group('LoginPage', () {
    testWidgets('should show login form', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
```

---

## 5. 文档规范

### 5.1 代码注释
**Go**:
```go
// UserService 用户服务接口
type UserService interface {
    // Login 用户登录
    // @param ctx 上下文
    // @param req 登录请求
    // @return 登录响应
    // @return 错误信息
    Login(ctx context.Context, req *LoginRequest) (*LoginResponse, error)
}
```

**Flutter**:
```dart
/// 用户认证控制器
///
/// 管理用户登录、注册、登出等状态
///
/// 使用示例:
/// ```dart
/// final auth = ref.read(authControllerProvider.notifier);
/// await auth.login(phone, password);
/// ```
@riverpod
class AuthController extends _$AuthController {
  /// 用户登录
  ///
  /// [phone] 手机号
  /// [password] 密码
  ///
  /// 登录成功后会自动保存token到本地存储
  Future<void> login(String phone, String password) async {
    // ...
  }
}
```

### 5.2 API文档
使用Swagger注释:
```go
// Login godoc
// @Summary 用户登录
// @Description 使用手机号和密码登录
// @Tags 认证
// @Accept json
// @Produce json
// @Param request body LoginRequest true "登录参数"
// @Success 200 {object} Response{data=LoginResponse}
// @Failure 400 {object} Response
// @Router /v1/auth/login [post]
func (c *UserController) Login(ctx *gin.Context) {
    // ...
}
```

---

## 6. 安全检查清单

### 6.1 代码提交前
- [ ] 无硬编码密码/密钥
- [ ] 无调试用的print/console.log
- [ ] SQL语句使用参数化查询
- [ ] 敏感接口已添加权限检查

### 6.2 发布前
- [ ] 配置文件使用环境变量
- [ ] 日志不包含敏感信息
- [ ] 错误信息不暴露内部细节
- [ ] 依赖已更新到安全版本

---

## 7. 工具推荐

### 7.1 Go开发工具
- **IDE**: GoLand / VS Code + Go插件
- **Linter**: golangci-lint
- **Formatter**: gofmt
- **Testing**: testify + gomock

### 7.2 Flutter开发工具
- **IDE**: Android Studio / VS Code
- **Linter**: flutter_lints
- **Formatter**: dart format
- **Testing**: mockito + bloc_test

### 7.3 代码质量
- **Git Hooks**: husky + lint-staged
- **CI/CD**: GitHub Actions / GitLab CI
- **Code Review**: Gerrit / GitHub PR

---

## 8. 参考资源

- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Effective Go](https://golang.org/doc/effective_go.html)
- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [Conventional Commits](https://www.conventionalcommits.org/)
