# Bug-20260317-003: 用户登出功能未实现

## Bug基本信息

| 字段 | 内容 |
|------|------|
| Bug ID | BUG-USER-001 |
| 报告日期 | 2026-03-17 |
| 报告人 | AI测试工程师 |
| 模块 | 用户模块 |
| 功能 | 退出登录 |
| 严重程度 | ⬜ 致命 ⬜ 严重 ⬜ 一般 ⬜ 轻微 |
| 优先级 | ⬜ P0 ⬜ P1 ⬜ P2 ⬜ P3 |
| Bug类型 | ⬜ 功能 ⬜ 性能 ⬜ 兼容性 ⬜ UI ⬜ 安全 |

---

## 环境信息

| 字段 | 内容 |
|------|------|
| 代码版本 | main @ 2026-03-17 |
| 文件位置 | `backend/03-user-service/service.go` |

---

## Bug描述

### 问题概述
`Logout`方法为空实现，退出登录后Token仍然有效，存在安全风险。

### 问题代码
```go
// Logout 退出登录
func (s *userService) Logout(ctx context.Context, userID int64) error {
    // 实际实现可将token加入黑名单
    return nil  // ❌ 空实现
}
```

### 预期结果
退出登录后，当前Token应立即失效，无法继续访问受保护资源。

### 实际结果
退出登录后Token仍然有效，可以继续调用API。

---

## 修复方案

```go
// Logout 退出登录
func (s *userService) Logout(ctx context.Context, userID int64, token string) error {
    // 解析token获取过期时间
    claims, err := s.jwtService.ParseToken(token)
    if err != nil {
        return common.NewError(common.ErrCodeUnauthorized, "无效的token")
    }
    
    // 计算token剩余有效期
    ttl := claims.ExpiresAt - time.Now().Unix()
    if ttl > 0 {
        // 将token加入黑名单，有效期与token剩余时间一致
        blacklistKey := fmt.Sprintf("token:blacklist:%s", claims.UUID)
        if err := s.redisClient.Set(ctx, blacklistKey, "1", time.Duration(ttl)*time.Second).Err(); err != nil {
            return common.NewError(common.ErrCodeInternalServer, "登出失败")
        }
    }
    
    return nil
}
```

**AuthMiddleware也需要更新**:
```go
func AuthMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := c.GetHeader("Authorization")
        // ...
        
        // 检查token是否在黑名单
        claims, _ := jwtService.ParseToken(token)
        blacklistKey := fmt.Sprintf("token:blacklist:%s", claims.UUID)
        if exists, _ := redisClient.Exists(c, blacklistKey).Result(); exists > 0 {
            common.Unauthorized(c)
            c.Abort()
            return
        }
        
        c.Set("user_id", claims.UserID)
        c.Next()
    }
}
```

---

## 安全影响

- 用户在公共设备登录后退出，Token仍可能被他人利用
- 建议与前端配合，登出后立即清除本地存储的Token
