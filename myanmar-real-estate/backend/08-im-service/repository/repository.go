package repository

import (
	"context"
	"time"
	
	"gorm.io/gorm"
	
	"myanmar-property/backend/08-im-service"
)

// IMRepository IM数据访问接口
type IMRepository interface {
	// 会话
	CreateConversation(ctx context.Context, conversation *model.Conversation) error
	GetConversationByID(ctx context.Context, id int64) (*model.Conversation, error)
	GetConversationByCode(ctx context.Context, code string) (*model.Conversation, error)
	GetConversationByParticipants(ctx context.Context, userID, agentID int64, houseID *int64) (*model.Conversation, error)
	GetConversationsByUser(ctx context.Context, userID int64, page, pageSize int) ([]*model.Conversation, int64, error)
	GetConversationsByAgent(ctx context.Context, agentID int64, page, pageSize int) ([]*model.Conversation, int64, error)
	UpdateConversation(ctx context.Context, conversation *model.Conversation) error
	DeleteConversation(ctx context.Context, userID int64, conversationID int64) error

	// 消息
	CreateMessage(ctx context.Context, message *model.Message) error
	GetMessageByID(ctx context.Context, id int64) (*model.Message, error)
	GetMessagesByConversation(ctx context.Context, conversationID int64, beforeID int64, limit int) ([]*model.Message, error)
	UpdateMessage(ctx context.Context, message *model.Message) error
	MarkMessagesAsRead(ctx context.Context, conversationID int64, senderType string) error
	RecallMessage(ctx context.Context, messageID int64) error
	
	// 快捷话术
	CreateQuickReply(ctx context.Context, reply *model.QuickReply) error
	GetQuickReplyByID(ctx context.Context, id int64) (*model.QuickReply, error)
	GetQuickRepliesByAgent(ctx context.Context, agentID int64, category string) ([]*model.QuickReply, error)
	UpdateQuickReply(ctx context.Context, reply *model.QuickReply) error
	DeleteQuickReply(ctx context.Context, id int64) error
}

// imRepository 实现
type imRepository struct {
	db *gorm.DB
}

// NewIMRepository 创建IM仓储
func NewIMRepository(db *gorm.DB) IMRepository {
	return &imRepository{db: db}
}

// CreateConversation 创建会话
func (r *imRepository) CreateConversation(ctx context.Context, conversation *model.Conversation) error {
	return r.db.WithContext(ctx).Create(conversation).Error
}

// GetConversationByID 根据ID获取会话
func (r *imRepository) GetConversationByID(ctx context.Context, id int64) (*model.Conversation, error) {
	var conversation model.Conversation
	err := r.db.WithContext(ctx).First(&conversation, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &conversation, err
}

// GetConversationByCode 根据编码获取会话
func (r *imRepository) GetConversationByCode(ctx context.Context, code string) (*model.Conversation, error) {
	var conversation model.Conversation
	err := r.db.WithContext(ctx).
		Where("conversation_code = ?", code).
		First(&conversation).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &conversation, err
}

// GetConversationByParticipants 根据参与方获取会话
func (r *imRepository) GetConversationByParticipants(ctx context.Context, userID, agentID int64, houseID *int64) (*model.Conversation, error) {
	var conversation model.Conversation
	
	db := r.db.WithContext(ctx).
		Where("user_id = ? AND agent_id = ?", userID, agentID)
	
	if houseID != nil {
		db = db.Where("house_id = ?", *houseID)
	} else {
		db = db.Where("house_id IS NULL")
	}
	
	err := db.First(&conversation).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &conversation, err
}

// GetConversationsByUser 获取用户的会话列表
func (r *imRepository) GetConversationsByUser(ctx context.Context, userID int64, page, pageSize int) ([]*model.Conversation, int64, error) {
	var conversations []*model.Conversation
	var total int64
	
	db := r.db.WithContext(ctx).Model(&model.Conversation{}).Where("user_id = ?", userID)

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("is_pinned DESC, last_message_at DESC NULLS LAST").
		Offset(offset).Limit(pageSize).
		Find(&conversations).Error

	return conversations, total, err
}

// GetConversationsByAgent 获取经纪人的会话列表
func (r *imRepository) GetConversationsByAgent(ctx context.Context, agentID int64, page, pageSize int) ([]*model.Conversation, int64, error) {
	var conversations []*model.Conversation
	var total int64

	db := r.db.WithContext(ctx).Model(&model.Conversation{}).Where("agent_id = ?", agentID)

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	
	offset := (page - 1) * pageSize
	err := db.Order("is_pinned DESC, last_message_at DESC NULLS LAST").
		Offset(offset).Limit(pageSize).
		Find(&conversations).Error
	
	return conversations, total, err
}

// UpdateConversation 更新会话
func (r *imRepository) UpdateConversation(ctx context.Context, conversation *model.Conversation) error {
	return r.db.WithContext(ctx).Save(conversation).Error
}

// DeleteConversation 软删除会话（按参与方鉴权后删除）
func (r *imRepository) DeleteConversation(ctx context.Context, userID int64, conversationID int64) error {
	return r.db.WithContext(ctx).
		Where("id = ? AND (user_id = ? OR agent_id = ?)", conversationID, userID, userID).
		Delete(&model.Conversation{}).Error
}

// CreateMessage 创建消息
func (r *imRepository) CreateMessage(ctx context.Context, message *model.Message) error {
	return r.db.WithContext(ctx).Create(message).Error
}

// GetMessageByID 根据ID获取消息
func (r *imRepository) GetMessageByID(ctx context.Context, id int64) (*model.Message, error) {
	var message model.Message
	err := r.db.WithContext(ctx).First(&message, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &message, err
}

// GetMessagesByConversation 获取会话的消息
func (r *imRepository) GetMessagesByConversation(ctx context.Context, conversationID int64, beforeID int64, limit int) ([]*model.Message, error) {
	var messages []*model.Message
	
	db := r.db.WithContext(ctx).
		Where("conversation_id = ?", conversationID)
	
	if beforeID > 0 {
		db = db.Where("id < ?", beforeID)
	}
	
	err := db.Order("id DESC").
		Limit(limit).
		Find(&messages).Error
	
	return messages, err
}

// UpdateMessage 更新消息
func (r *imRepository) UpdateMessage(ctx context.Context, message *model.Message) error {
	return r.db.WithContext(ctx).Save(message).Error
}

// MarkMessagesAsRead 标记消息为已读
func (r *imRepository) MarkMessagesAsRead(ctx context.Context, conversationID int64, senderType string) error {
	now := time.Now()
	
	// 更新对方发送的消息为已读
	oppositeType := "user"
	if senderType == "user" {
		oppositeType = "agent"
	}
	
	return r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("conversation_id = ? AND sender_type = ? AND read_at IS NULL", conversationID, oppositeType).
		Update("read_at", now).Error
}

// RecallMessage 撤回消息
func (r *imRepository) RecallMessage(ctx context.Context, messageID int64) error {
	now := time.Now()
	return r.db.WithContext(ctx).
		Model(&model.Message{}).
		Where("id = ?", messageID).
		Updates(map[string]interface{}{
			"status":      model.MessageStatusRecalled,
			"recalled_at": now,
		}).Error
}

// CreateQuickReply 创建快捷话术
func (r *imRepository) CreateQuickReply(ctx context.Context, reply *model.QuickReply) error {
	return r.db.WithContext(ctx).Create(reply).Error
}

// GetQuickReplyByID 根据ID获取快捷话术
func (r *imRepository) GetQuickReplyByID(ctx context.Context, id int64) (*model.QuickReply, error) {
	var reply model.QuickReply
	err := r.db.WithContext(ctx).First(&reply, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &reply, err
}

// GetQuickRepliesByAgent 获取经纪人的快捷话术
func (r *imRepository) GetQuickRepliesByAgent(ctx context.Context, agentID int64, category string) ([]*model.QuickReply, error) {
	var replies []*model.QuickReply
	
	db := r.db.WithContext(ctx).
		Where("agent_id = ? AND is_active = ?", agentID, true)
	
	if category != "" {
		db = db.Where("category = ?", category)
	}
	
	err := db.Order("sort_order ASC, created_at DESC").Find(&replies).Error
	return replies, err
}

// UpdateQuickReply 更新快捷话术
func (r *imRepository) UpdateQuickReply(ctx context.Context, reply *model.QuickReply) error {
	return r.db.WithContext(ctx).Save(reply).Error
}

// DeleteQuickReply 删除快捷话术
func (r *imRepository) DeleteQuickReply(ctx context.Context, id int64) error {
	return r.db.WithContext(ctx).Delete(&model.QuickReply{}, id).Error
}
