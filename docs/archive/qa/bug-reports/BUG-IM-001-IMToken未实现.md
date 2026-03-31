# Bug-20260317-004: IM Token获取未实现

## Bug基本信息

| 字段 | 内容 |
|------|------|
| Bug ID | BUG-IM-001 |
| 报告日期 | 2026-03-17 |
| 报告人 | AI测试工程师 |
| 模块 | IM消息模块 |
| 功能 | 第三方IM集成 |
| 严重程度 | ⬜ 致命 ⬜ 严重 ⬜ 一般 ⬜ 轻微 |
| 优先级 | ⬜ P0 ⬜ P1 ⬜ P2 ⬜ P3 |
| Bug类型 | ⬜ 功能 ⬜ 性能 ⬜ 兼容性 ⬜ UI ⬜ 安全 |

---

## Bug描述

### 问题概述
`GetIMToken`方法返回空字符串，第三方IM（环信/融云）集成未完成，导致客户端无法连接IM服务。

### 问题代码
```go
// GetIMToken 获取IM Token（第三方IM集成）
func (s *imService) GetIMToken(ctx context.Context, userID int64, userType string) (string, error) {
    // 这里集成环信/融云等第三方IM
    // 简化实现，实际应调用第三方SDK
    return "", nil  // ❌ 返回空字符串
}
```

### 预期结果
返回有效的第三方IM Token，客户端可用此Token连接IM服务器。

### 实际结果
返回空字符串，客户端无法连接IM服务。

---

## 修复建议

### 方案1：环信集成
```go
func (s *imService) GetIMToken(ctx context.Context, userID int64, userType string) (string, error) {
    // 构建环信API请求
    url := fmt.Sprintf("%s/%s/token", s.config.IM.EasemobHost, s.config.IM.AppKey)
    
    reqBody := map[string]interface{}{
        "grant_type": "client_credentials",
        "client_id":  s.config.IM.ClientID,
        "client_secret": s.config.IM.ClientSecret,
    }
    
    // 获取App Token
    appToken, err := s.getEasemobAppToken(ctx)
    if err != nil {
        return "", err
    }
    
    // 获取用户Token
    userToken, err := s.getEasemobUserToken(ctx, userID, userType, appToken)
    if err != nil {
        return "", err
    }
    
    return userToken, nil
}
```

### 方案2：融云集成
```go
func (s *imService) GetIMToken(ctx context.Context, userID int64, userType string) (string, error) {
    // 融云Token生成
    userIDStr := fmt.Sprintf("%s_%d", userType, userID)
    
    // 调用融云SDK或API获取Token
    token, err := s.rongcloudClient.User.GetToken(
        userIDStr,
        fmt.Sprintf("User%d", userID),
        "",
    )
    
    return token.Token, err
}
```

---

## 注意事项

1. **Token缓存**：IM Token通常有有效期，建议缓存避免频繁请求
2. **用户同步**：首次获取Token前需要将用户同步到IM服务器
3. **多端登录**：考虑是否支持多设备同时登录
