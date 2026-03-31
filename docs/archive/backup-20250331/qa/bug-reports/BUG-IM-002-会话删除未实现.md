# Bug-20260317-005: 会话删除功能未实现

## Bug基本信息

| 字段 | 内容 |
|------|------|
| Bug ID | BUG-IM-002 |
| 报告日期 | 2026-03-17 |
| 报告人 | AI测试工程师 |
| 模块 | IM消息模块 |
| 功能 | 删除会话 |
| 严重程度 | ⬜ 致命 ⬜ 严重 ⬜ 一般 ⬜ 轻微 |
| 优先级 | ⬜ P0 ⬜ P1 ⬜ P2 ⬜ P3 |
| Bug类型 | ⬜ 功能 ⬜ 性能 ⬜ 兼容性 ⬜ UI ⬜ 安全 |

---

## Bug描述

### 问题概述
`DeleteConversation`方法为空实现，用户删除会话后，会话仍然存在。

### 问题代码
```go
// DeleteConversation 删除会话
func (s *imService) DeleteConversation(ctx context.Context, userID int64, conversationID int64) error {
    conversation, err := s.imRepo.GetConversationByID(ctx, conversationID)
    if err != nil {
        return common.NewError(common.ErrCodeInternalServer, err.Error())
    }
    if conversation == nil {
        return common.NewError(common.ErrCodeNotFound, "会话不存在")
    }
    
    // 检查权限
    if conversation.UserID != userID && conversation.AgentID != userID {
        return common.NewError(common.ErrCodeForbidden, "无权操作该会话")
    }
    
    // 软删除或标记删除
    // 简化实现，实际可以标记为删除状态  // ❌ 未实现
    return nil
}
```

### 建议实现
```go
// DeleteConversation 删除会话（软删除）
func (s *imService) DeleteConversation(ctx context.Context, userID int64, conversationID int64) error {
    conversation, err := s.imRepo.GetConversationByID(ctx, conversationID)
    // ... 权限检查 ...
    
    now := time.Now()
    
    // 区分用户删除和经纪人删除
    if conversation.UserID == userID {
        conversation.DeletedByUser = true
        conversation.UserDeletedAt = &now
    } else if conversation.AgentID == userID {
        conversation.DeletedByAgent = true
        conversation.AgentDeletedAt = &now
    }
    
    // 如果双方都删除，则物理删除或标记为完全删除
    if conversation.DeletedByUser && conversation.DeletedByAgent {
        conversation.IsFullyDeleted = true
    }
    
    return s.imRepo.UpdateConversation(ctx, conversation)
}
```

### 查询时需要过滤
```go
func (r *imRepository) GetConversationsByUser(ctx context.Context, userID int64, page, pageSize int) ([]*model.Conversation, int64, error) {
    var conversations []*model.Conversation
    
    db := r.db.WithContext(ctx).
        Where("user_id = ?", userID).
        Where("deleted_by_user = ? OR deleted_by_user IS NULL", false)  // 过滤已删除
    
    // ...
}
```
