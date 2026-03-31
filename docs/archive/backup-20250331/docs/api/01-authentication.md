# 认证接口文档

**模块**: 用户认证 (User Authentication)
**基础路径**: `/v1/auth`

---

## 1. 接口概览

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/send-verification-code` | 发送验证码 | 否 |
| POST | `/register` | 用户注册 | 否 |
| POST | `/login` | 验证码登录 | 否 |
| POST | `/login-with-password` | 密码登录 | 否 |
| POST | `/refresh-token` | 刷新Token | 否 |
| POST | `/reset-password` | 重置密码 | 否 |

---

## 2. 接口详情

### 2.1 发送验证码

**请求**:
```http
POST /v1/auth/send-verification-code
Content-Type: application/json

{
  "phone": "+95123456789",
  "type": "register"
}
```

**参数说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，缅甸格式 +95开头 |
| type | string | 是 | 类型: register/login/reset_password |

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "expired_at": 300
  },
  "timestamp": 1773798324,
  "request_id": "uuid"
}
```

**错误码**:
| 错误码 | 说明 |
|--------|------|
| 1001 | 手机号格式错误 |
| 1002 | 发送过于频繁 |
| 1003 | 手机号已注册（注册时）|
| 1004 | 手机号未注册（登录时）|

**Mock模式**:
开发环境下，验证码固定为 `123456`，不实际发送短信。

---

### 2.2 用户注册

**请求**:
```http
POST /v1/auth/register
Content-Type: application/json

{
  "phone": "+95123456789",
  "code": "123456",
  "password": "password123",
  "name": "张三",
  "user_type": "buyer"
}
```

**参数说明**:
| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号 |
| code | string | 是 | 短信验证码 |
| password | string | 是 | 密码，6-20位 |
| name | string | 是 | 用户名 |
| user_type | string | 是 | 类型: buyer/agent |

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 86400,
    "user": {
      "id": 1,
      "uuid": "usr_abc123",
      "phone": "+95123456789",
      "name": "张三",
      "user_type": "buyer",
      "status": "active",
      "created_at": "2026-03-18T10:00:00Z"
    }
  }
}
```

---

### 2.3 验证码登录

**请求**:
```http
POST /v1/auth/login
Content-Type: application/json

{
  "phone": "+95123456789",
  "code": "123456"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 86400,
    "user": {
      "id": 1,
      "uuid": "usr_abc123",
      "phone": "+95123456789",
      "name": "张三",
      "user_type": "buyer",
      "status": "active"
    }
  }
}
```

---

### 2.4 密码登录

**请求**:
```http
POST /v1/auth/login-with-password
Content-Type: application/json

{
  "phone": "+95123456789",
  "password": "password123"
}
```

**错误码**:
| 错误码 | 说明 |
|--------|------|
| 1101 | 密码错误 |
| 1102 | 账号已被锁定 |
| 1103 | 账号未激活 |

---

### 2.5 刷新Token

**请求**:
```http
POST /v1/auth/refresh-token
Content-Type: application/json

{
  "refresh_token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIs...",
    "refresh_token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_in": 86400
  }
}
```

---

### 2.6 重置密码

**请求**:
```http
POST /v1/auth/reset-password
Content-Type: application/json

{
  "phone": "+95123456789",
  "code": "123456",
  "new_password": "newpassword123"
}
```

**响应**:
```json
{
  "code": 200,
  "message": "success",
  "data": null
}
```

---

## 3. 认证机制

### 3.1 JWT Token说明

**Access Token**:
- 有效期: 24小时
- 用途: 访问受保护接口
- 传递方式: `Authorization: Bearer {token}`

**Refresh Token**:
- 有效期: 30天
- 用途: 刷新Access Token
- 存储要求: 安全存储，建议加密

### 3.2 Token刷新策略
```
1. 检查Access Token是否过期
2. 如过期，使用Refresh Token换取新的Access Token
3. 如Refresh Token也过期，需重新登录
```

### 3.3 请求示例
```bash
# 带认证的请求
curl -X GET http://localhost:8080/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

---

## 4. 错误响应格式

```json
{
  "code": 401,
  "message": "未授权，请先登录",
  "timestamp": 1773798324,
  "request_id": "uuid"
}
```

**通用错误码**:
| 错误码 | HTTP状态 | 说明 |
|--------|----------|------|
| 0 | 200 | 成功 |
| 1 | 500 | 服务器内部错误 |
| 2 | 400 | 请求参数错误 |
| 3 | 401 | 未授权 |
| 4 | 403 | 禁止访问 |
| 5 | 404 | 资源不存在 |
| 6 | 429 | 请求过于频繁 |

---

## 5. 测试用例

### 5.1 cURL示例

```bash
# 1. 发送验证码
curl -X POST http://localhost:8080/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d '{"phone": "+95123456789", "type": "register"}'

# 2. 注册
curl -X POST http://localhost:8080/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+95123456789",
    "code": "123456",
    "password": "password123",
    "name": "Test User",
    "user_type": "buyer"
  }'

# 3. 登录
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+95123456789", "code": "123456"}'

# 4. 获取用户信息（需认证）
curl -X GET http://localhost:8080/v1/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## 6. 前端集成示例

### 6.1 Flutter集成
```dart
class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<AuthResponse> login(String phone, String code) async {
    final response = await _dio.post(
      '/v1/auth/login',
      data: {'phone': phone, 'code': code},
    );

    final auth = AuthResponse.fromJson(response.data['data']);

    // 保存Token
    await LocalStorage.saveAccessToken(auth.accessToken);
    await LocalStorage.saveRefreshToken(auth.refreshToken);

    return auth;
  }

  Future<void> logout() async {
    await LocalStorage.clearTokens();
  }
}
```

---

## 7. 安全建议

1. **密码强度**: 最少6位，建议包含字母+数字
2. **验证码安全**: 5分钟内有效，最多重试3次
3. **Token存储**: 移动设备使用Keychain/Keystore
4. **HTTPS**: 生产环境必须启用HTTPS
5. **限流**: 登录接口防暴力破解（5分钟内最多5次）
