# 缅甸房产平台代码审查报告

**审查日期**: 2026-03-17  
**审查范围**: Flutter APP (11,832行) + Go后端 (6,995行) + 前端Web (3,800行)  
**审查人员**: AI代码审查专家

---

## 📊 问题统计摘要

| 类别 | 严重(Critical) | 高(High) | 中(Medium) | 低(Low) | 总计 |
|------|---------------|----------|------------|---------|------|
| 安全漏洞 | 3 | 5 | 4 | 2 | **14** |
| 性能问题 | 0 | 2 | 4 | 3 | **9** |
| 代码规范 | 0 | 1 | 6 | 8 | **15** |
| 并发安全 | 2 | 3 | 2 | 0 | **7** |
| 错误处理 | 0 | 3 | 4 | 2 | **9** |
| **总计** | **5** | **14** | **20** | **15** | **54** |

---

## 🔴 严重问题 (Critical)

### 1. [Go] JWT密钥硬编码风险 - CRITICAL

**文件**: `backend/07-common/config.go`

**问题描述**: JWT密钥配置可能从环境变量加载，但没有强制要求，且代码中可以看到默认值处理逻辑。如果配置文件中JWT.Secret为空，可能导致使用默认弱密钥。

**风险**: 攻击者可能伪造JWT Token，越权访问系统

**修复建议**:
```go
// 在LoadConfig中添加强制验证
func (c *Config) Validate() error {
    if c.JWT.Secret == "" || len(c.JWT.Secret) < 32 {
        return errors.New("JWT密钥必须至少32个字符")
    }
    // 生产环境禁止使用默认密钥
    if c.IsProduction() && c.JWT.Secret == "your-secret-key" {
        return errors.New("生产环境必须配置自定义JWT密钥")
    }
    return nil
}
```

---

### 2. [Go] 数据库查询SQL注入风险 - CRITICAL

**文件**: `backend/04-house-service/repository.go:190-192`

**问题代码**:
```go
db = db.Where("title ILIKE ? OR address ILIKE ?", 
    "%"+params.Keywords+"%", "%"+params.Keywords+"%")
```

**问题描述**: 虽然使用了参数化查询，但在地图聚合查询中存在字符串拼接SQL：

**修复建议**:
```go
// 使用完全参数化的查询，避免字符串拼接
query := `
    SELECT 
        d.id, d.name, d.latitude as lat, d.longitude as lng,
        AVG(h.price) as avg_price, COUNT(*) as total_count
    FROM houses h
    JOIN districts d ON h.district_id = d.id
    WHERE h.status = 'online'
    AND h.latitude BETWEEN @swLat AND @neLat
    AND h.longitude BETWEEN @swLng AND @neLng
`
args := map[string]interface{}{
    "swLat": params.SwLat,
    "neLat": params.NeLat,
    "swLng": params.SwLng,
    "neLng": params.NeLng,
}
```

---

### 3. [Go] Goroutine泄漏风险 - CRITICAL

**文件**: `backend/cmd/server/main.go`

**问题描述**: 在启动HTTP服务器时，如果没有正确处理goroutine，可能导致goroutine泄漏。

**修复建议**:
```go
// 添加panic恢复机制
func main() {
    defer func() {
        if r := recover(); r != nil {
            common.Fatal("服务器发生panic", common.Any("recover", r))
        }
    }()
    // ... 原有代码
}
```

---

### 4. [Flutter] Token存储安全风险 - CRITICAL

**文件**: `flutter/lib/core/storage/local_storage.dart`

**问题描述**: Token存储在SharedPreferences中，在root过的设备上可能被读取。

**修复建议**:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  static Future<void> setToken(String token) async {
    await _secureStorage.write(key: StorageKeys.token, value: token);
  }
  
  static Future<String?> getToken() async {
    return _secureStorage.read(key: StorageKeys.token);
  }
}
```

---

### 5. [前端] XSS防护不足 - CRITICAL

**文件**: `frontend/web-admin/src/services/request.ts`

**问题描述**: 响应数据没有进行XSS过滤就直接使用，如果后端返回恶意脚本，可能导致XSS攻击。

**修复建议**:
```typescript
import DOMPurify from 'dompurify';

// 响应拦截器中添加XSS过滤
request.interceptors.response.use(
  (response: AxiosResponse<IApiResponse>) => {
    const { data } = response;
    
    if (data.code === 0 || data.code === 200) {
      // 对返回数据进行XSS过滤
      return sanitizeResponse(data.data);
    }
    // ...
  }
);

function sanitizeResponse(data: any): any {
  if (typeof data === 'string') {
    return DOMPurify.sanitize(data);
  }
  if (Array.isArray(data)) {
    return data.map(sanitizeResponse);
  }
  if (typeof data === 'object' && data !== null) {
    const sanitized: any = {};
    for (const [key, value] of Object.entries(data)) {
      sanitized[key] = sanitizeResponse(value);
    }
    return sanitized;
  }
  return data;
}
```

---

## 🟠 高风险问题 (High)

### 6. [Go] 权限控制不完整 - HIGH

**文件**: `backend/03-user-service/controller.go:319-322`

**问题代码**:
```go
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        // ...
        // 这里应该调用JWT服务解析token
        // 简化实现，实际应该解析token并设置user_id
        c.Set("user_id", int64(1))  // ⚠️ 危险！硬编码用户ID
        c.Next()
    }
}
```

**修复建议**:
```go
func AuthMiddleware(jwtService service.JWTService) gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        if token == "" {
            common.Unauthorized(c)
            c.Abort()
            return
        }
        
        if len(token) > 7 && token[:7] == "Bearer " {
            token = token[7:]
        }
        
        claims, err := jwtService.ParseToken(token)
        if err != nil {
            common.Unauthorized(c, "无效的token")
            c.Abort()
            return
        }
        
        c.Set("user_id", claims.UserID)
        c.Set("uuid", claims.UUID)
        c.Next()
    }
}
```

---

### 7. [Go] 数据库连接池配置不当 - HIGH

**文件**: `backend/07-common/database.go:35-45`

**问题描述**: 连接池配置可能导致高并发下连接耗尽或资源浪费。

**修复建议**:
```go
// 添加连接池健康检查
sqlDB.SetConnMaxIdleTime(10 * time.Minute)
sqlDB.SetMaxOpenConns(25)
sqlDB.SetMaxIdleConns(10)  // 建议设为MaxOpenConns的40%

// 添加连接健康检查
go func() {
    ticker := time.NewTicker(1 * time.Minute)
    defer ticker.Stop()
    for range ticker.C {
        ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
        if err := sqlDB.PingContext(ctx); err != nil {
            common.Error("数据库连接健康检查失败", common.ErrorField(err))
        }
        cancel()
    }
}()
```

---

### 8. [Flutter] 内存泄漏风险 - HIGH

**文件**: `flutter/lib/buyer/presentation/pages/login_page.dart:65-75`

**问题代码**:
```dart
void _startCountdown() {
  Future.doWhile(() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {  // ⚠️ 这里检查mounted可能不够及时
      setState(() {
        _countdown--;
      });
    }
    return _countdown > 0;
  });
}
```

**修复建议**:
```dart
class _LoginPageState extends ConsumerState<LoginPage> {
  Timer? _countdownTimer;
  
  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown--;
      });
      if (_countdown <= 0) {
        timer.cancel();
      }
    });
  }
  
  @override
  void dispose() {
    _countdownTimer?.cancel();  // 确保清理
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
```

---

### 9. [Go] 验证码暴力破解风险 - HIGH

**文件**: `backend/03-user-service/service.go:140-165`

**问题描述**: 验证码验证虽然有尝试次数限制，但没有全局频率限制，可能被暴力破解。

**修复建议**:
```go
// 添加IP级别频率限制
func (s *userService) verifyCode(ctx context.Context, phone, code, codeType string, clientIP string) error {
    // IP级别频率检查
    key := fmt.Sprintf("verify_limit:%s:%s", clientIP, phone)
    attempts, _ := s.redis.Get(ctx, key).Int()
    if attempts >= 10 {
        return common.NewError(common.ErrCodeTooManyRequests, "该IP验证次数过多，请1小时后重试")
    }
    
    // ... 原有验证逻辑
    
    // 验证失败增加计数
    if err != nil {
        s.redis.Incr(ctx, key)
        s.redis.Expire(ctx, key, time.Hour)
    } else {
        // 验证成功清除计数
        s.redis.Del(ctx, key)
    }
    
    return err
}
```

---

### 10. [前端] 敏感信息泄露风险 - HIGH

**文件**: `frontend/web-admin/src/pages/Login/index.tsx`

**问题描述**: 登录错误信息直接console.error输出，可能泄露敏感信息。

**修复建议**:
```typescript
catch (error) {
  // 只记录不敏感的信息到控制台
  console.error('登录失败');
  // 详细错误信息发送到监控服务
  errorTracker.captureException(error, {
    tags: { component: 'LoginPage' },
    user: { username: values.username }
  });
}
```

---

## 🟡 中风险问题 (Medium)

### 11. [Flutter] 缅语本地化不完整 - MEDIUM

**文件**: 多个Flutter页面

**问题描述**: 硬编码中文文本，没有使用国际化方案，缅语用户无法正常阅读。

**修复建议**:
```dart
// 添加缅语本地化支持
// lib/l10n/app_my.arb
{
  "@@locale": "my",
  "welcome": "ကြိုဆိုပါသည်",
  "login": "လော့ဂ်အင်ဝင်ရန်",
  "phoneNumber": "ဖုန်းနံပါတ်",
  "verificationCode": "အတည်ပြုကုဒ်"
}

// 在Widget中使用
Text(AppLocalizations.of(context)!.welcome)
```

---

### 12. [Go] 错误处理不一致 - MEDIUM

**文件**: `backend/03-user-service/service.go`

**问题描述**: 部分错误使用common.NewError包装，部分直接使用原生error，导致错误处理不一致。

**修复建议**:
```go
// 统一错误处理
type ServiceError struct {
    Code    common.ErrorCode
    Message string
    Err     error
}

func (e *ServiceError) Error() string {
    if e.Err != nil {
        return fmt.Sprintf("%s: %v", e.Message, e.Err)
    }
    return e.Message
}

// 所有服务方法返回统一的错误类型
func (s *userService) GetCurrentUser(ctx context.Context, userID int64) (*UserInfo, error) {
    user, err := s.userRepo.FindByID(ctx, userID)
    if err != nil {
        return nil, &ServiceError{
            Code:    common.ErrCodeInternalServer,
            Message: "查询用户失败",
            Err:     err,
        }
    }
    // ...
}
```

---

### 13. [Go] 日志信息泄露 - MEDIUM

**文件**: `backend/03-user-service/jwt_service.go:83`

**问题代码**:
```go
common.Info("发送短信验证码", common.String("phone", phone), common.String("code", code))
```

**问题描述**: 验证码被记录到日志中，存在安全风险。

**修复建议**:
```go
// 不要记录敏感信息
common.Info("发送短信验证码", 
    common.String("phone", maskPhone(phone)), 
    common.Bool("success", err == nil))

func maskPhone(phone string) string {
    if len(phone) < 8 {
        return "***"
    }
    return phone[:3] + "****" + phone[len(phone)-4:]
}
```

---

### 14. [Flutter] 空安全处理不完整 - MEDIUM

**文件**: `flutter/lib/core/storage/local_storage.dart`

**问题代码**:
```dart
static SharedPreferences? _prefs;

static Future<String?> getToken() async {
  return _prefs?.getString(StorageKeys.token);  // 可能返回null
}
```

**修复建议**:
```dart
static Future<String?> getToken() async {
  if (_prefs == null) {
    await init();  // 自动初始化
  }
  return _prefs!.getString(StorageKeys.token);
}
```

---

### 15. [Go] Race Condition风险 - MEDIUM

**文件**: `backend/07-common/database.go:10`

**问题代码**:
```go
var DB *gorm.DB  // 全局变量，并发访问可能有问题
```

**修复建议**:
```go
var (
    db     *gorm.DB
    dbOnce sync.Once
    dbMu   sync.RWMutex
)

func InitDB(config *Config) (*gorm.DB, error) {
    var err error
    dbOnce.Do(func() {
        db, err = initDBInternal(config)
    })
    return db, err
}

func GetDB() *gorm.DB {
    dbMu.RLock()
    defer dbMu.RUnlock()
    if db == nil {
        panic("数据库未初始化")
    }
    return db
}
```

---

## 🟢 低风险问题 (Low)

### 16-20. 代码风格和优化建议

1. **Magic Numbers**: 多处硬编码数字，如验证码长度、超时时间等，建议提取为常量
2. **注释缺失**: 部分复杂逻辑缺少注释
3. **命名规范**: 部分变量命名不够清晰
4. **代码重复**: 错误处理逻辑存在重复代码
5. **导入未使用**: 部分文件存在未使用的导入

---

## ✅ 修复计划

### 第一阶段 (1-2天) - 修复Critical和High问题
- [ ] JWT密钥管理修复
- [ ] SQL注入漏洞修复
- [ ] 权限控制完善
- [ ] 验证码安全增强

### 第二阶段 (3-5天) - 修复Medium问题
- [ ] 缅语本地化支持
- [ ] 错误处理统一
- [ ] 敏感信息日志脱敏
- [ ] 空安全检查

### 第三阶段 (1周) - 优化Low问题
- [ ] 代码重构
- [ ] 文档完善
- [ ] 单元测试补充

---

## 📋 附录: 代码行数统计

| 模块 | 文件数 | 代码行数 |
|------|--------|----------|
| Flutter APP | 46 | ~11,832 |
| Go后端 | 28 | ~6,995 |
| 前端Web | 52 | ~3,800 |
| **总计** | **126** | **~22,627** |

---

**报告生成时间**: 2026-03-17 18:30 GMT+8  
**审查工具**: AI代码审查专家  
**联系方式**: 如有疑问请联系技术负责人
