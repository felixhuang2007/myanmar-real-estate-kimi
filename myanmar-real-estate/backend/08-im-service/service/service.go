package service

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"myanmar-property/backend/08-im-service"
	"myanmar-property/backend/08-im-service/repository"
	"myanmar-property/backend/07-common"
)

// IMService IM服务接口
type IMService interface {
	// 会话管理
	GetOrCreateConversation(ctx context.Context, userID, agentID int64, houseID *int64) (*model.Conversation, error)
	GetConversations(ctx context.Context, userID int64, userType string, page, pageSize int) ([]*model.Conversation, int64, error)
	GetConversation(ctx context.Context, conversationID int64) (*model.Conversation, error)
	PinConversation(ctx context.Context, userID int64, conversationID int64, isPinned bool) error
	DeleteConversation(ctx context.Context, userID int64, conversationID int64) error
	
	// 消息管理
	SendMessage(ctx context.Context, senderID int64, senderType string, conversationID int64, msgType, content string, extraData map[string]interface{}) (*model.Message, error)
	SendImageMessage(ctx context.Context, senderID int64, senderType string, conversationID int64, imageURL string) (*model.Message, error)
	SendHouseCard(ctx context.Context, senderID int64, senderType string, conversationID int64, houseID int64, houseTitle string, houseImage string, housePrice int64) (*model.Message, error)
	GetMessages(ctx context.Context, conversationID int64, beforeID int64, limit int) ([]*model.Message, error)
	RecallMessage(ctx context.Context, senderID int64, senderType string, messageID int64) error
	MarkAsRead(ctx context.Context, userID int64, userType string, conversationID int64) error
	
	// 快捷话术
	GetQuickReplies(ctx context.Context, agentID int64, category string) ([]*model.QuickReply, error)
	CreateQuickReply(ctx context.Context, agentID int64, category, content string) (*model.QuickReply, error)
	UpdateQuickReply(ctx context.Context, agentID int64, replyID int64, category, content string) error
	DeleteQuickReply(ctx context.Context, agentID int64, replyID int64) error
	
	// 第三方IM集成
	GetIMToken(ctx context.Context, userID int64, userType string) (string, error)
}

// imService 实现
type imService struct {
	imRepo repository.IMRepository
	config *common.Config
}

// NewIMService 创建IM服务
func NewIMService(imRepo repository.IMRepository, config *common.Config) IMService {
	return &imService{
		imRepo: imRepo,
		config: config,
	}
}

// GetOrCreateConversation 获取或创建会话
func (s *imService) GetOrCreateConversation(ctx context.Context, userID, agentID int64, houseID *int64) (*model.Conversation, error) {
	// 查找现有会话
	conversation, err := s.imRepo.GetConversationByParticipants(ctx, userID, agentID, houseID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if conversation != nil {
		return conversation, nil
	}
	
	// 创建新会话
	conversationCode := fmt.Sprintf("CONV%s%d%d", time.Now().Format("20060102"), userID, agentID)
	
	conversation = &model.Conversation{
		ConversationCode: conversationCode,
		Type:             "single",
		UserID:           userID,
		AgentID:          agentID,
		HouseID:          houseID,
		UserUnreadCount:  0,
		AgentUnreadCount: 0,
		IsBlocked:        false,
		IsPinned:         false,
	}
	
	if err := s.imRepo.CreateConversation(ctx, conversation); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return conversation, nil
}

// GetConversations 获取会话列表
func (s *imService) GetConversations(ctx context.Context, userID int64, userType string, page, pageSize int) ([]*model.Conversation, int64, error) {
	if userType == "agent" {
		return s.imRepo.GetConversationsByAgent(ctx, userID, page, pageSize)
	}
	return s.imRepo.GetConversationsByUser(ctx, userID, page, pageSize)
}

// GetConversation 获取会话详情
func (s *imService) GetConversation(ctx context.Context, conversationID int64) (*model.Conversation, error) {
	conversation, err := s.imRepo.GetConversationByID(ctx, conversationID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if conversation == nil {
		return nil, common.NewError(common.ErrCodeNotFound, "会话不存在")
	}
	return conversation, nil
}

// PinConversation 置顶/取消置顶会话
func (s *imService) PinConversation(ctx context.Context, userID int64, conversationID int64, isPinned bool) error {
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
	
	conversation.IsPinned = isPinned
	if isPinned {
		now := time.Now()
		conversation.PinnedAt = &now
	} else {
		conversation.PinnedAt = nil
	}
	
	return s.imRepo.UpdateConversation(ctx, conversation)
}

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
	
	// 软删除会话
	return s.imRepo.DeleteConversation(ctx, userID, conversationID)
}

// SendMessage 发送消息
func (s *imService) SendMessage(ctx context.Context, senderID int64, senderType string, conversationID int64, msgType, content string, extraData map[string]interface{}) (*model.Message, error) {
	conversation, err := s.imRepo.GetConversationByID(ctx, conversationID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if conversation == nil {
		return nil, common.NewError(common.ErrCodeNotFound, "会话不存在")
	}
	
	if conversation.IsBlocked {
		return nil, common.NewError(common.ErrCodeForbidden, "会话已被屏蔽")
	}
	
	// 生成消息编码
	messageCode := fmt.Sprintf("MSG%s%d", time.Now().Format("20060102150405"), senderID)
	
	message := &model.Message{
		ConversationID: conversationID,
		MessageCode:    messageCode,
		SenderType:     senderType,
		SenderID:       senderID,
		MessageType:    msgType,
		Status:         model.MessageStatusSent,
		SentAt:         time.Now(),
	}
	
	if content != "" {
		message.Content = &content
	}
	
	if extraData != nil {
		extraJSON, _ := json.Marshal(extraData)
		extraStr := string(extraJSON)
		message.ExtraData = &extraStr
	}
	
	if err := s.imRepo.CreateMessage(ctx, message); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 更新会话最后消息
	conversation.LastMessageID = &message.ID
	conversation.LastMessagePreview = &content
	now := time.Now()
	conversation.LastMessageAt = &now
	
	// 更新未读数
	if senderType == "user" {
		conversation.AgentUnreadCount++
	} else {
		conversation.UserUnreadCount++
	}
	
	if err := s.imRepo.UpdateConversation(ctx, conversation); err != nil {
		common.Error("更新会话失败", common.ErrorField(err))
	}
	
	return message, nil
}

// SendImageMessage 发送图片消息
func (s *imService) SendImageMessage(ctx context.Context, senderID int64, senderType string, conversationID int64, imageURL string) (*model.Message, error) {
	return s.SendMessage(ctx, senderID, senderType, conversationID, model.MessageTypeImage, "[图片]", map[string]interface{}{
		"image_url": imageURL,
	})
}

// SendHouseCard 发送房源卡片
func (s *imService) SendHouseCard(ctx context.Context, senderID int64, senderType string, conversationID int64, houseID int64, houseTitle string, houseImage string, housePrice int64) (*model.Message, error) {
	return s.SendMessage(ctx, senderID, senderType, conversationID, model.MessageTypeHouseCard, houseTitle, map[string]interface{}{
		"house_id":    houseID,
		"house_title": houseTitle,
		"house_image": houseImage,
		"house_price": housePrice,
	})
}

// GetMessages 获取消息列表
func (s *imService) GetMessages(ctx context.Context, conversationID int64, beforeID int64, limit int) ([]*model.Message, error) {
	if limit <= 0 {
		limit = 20
	}
	if limit > 100 {
		limit = 100
	}
	
	messages, err := s.imRepo.GetMessagesByConversation(ctx, conversationID, beforeID, limit)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return messages, nil
}

// RecallMessage 撤回消息
func (s *imService) RecallMessage(ctx context.Context, senderID int64, senderType string, messageID int64) error {
	message, err := s.imRepo.GetMessageByID(ctx, messageID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if message == nil {
		return common.NewError(common.ErrCodeNotFound, "消息不存在")
	}
	
	// 检查权限
	if message.SenderID != senderID || message.SenderType != senderType {
		return common.NewError(common.ErrCodeForbidden, "无权撤回该消息")
	}
	
	// 检查是否在2分钟内
	if time.Since(message.SentAt) > 2*time.Minute {
		return common.NewError(common.ErrCodeValidation, "消息已超过2分钟，无法撤回")
	}
	
	return s.imRepo.RecallMessage(ctx, messageID)
}

// MarkAsRead 标记已读
func (s *imService) MarkAsRead(ctx context.Context, userID int64, userType string, conversationID int64) error {
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
	
	// 标记消息为已读
	if err := s.imRepo.MarkMessagesAsRead(ctx, conversationID, userType); err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 更新会话未读数
	if userType == "user" {
		conversation.UserUnreadCount = 0
	} else {
		conversation.AgentUnreadCount = 0
	}
	
	return s.imRepo.UpdateConversation(ctx, conversation)
}

// GetQuickReplies 获取快捷话术
func (s *imService) GetQuickReplies(ctx context.Context, agentID int64, category string) ([]*model.QuickReply, error) {
	return s.imRepo.GetQuickRepliesByAgent(ctx, agentID, category)
}

// CreateQuickReply 创建快捷话术
func (s *imService) CreateQuickReply(ctx context.Context, agentID int64, category, content string) (*model.QuickReply, error) {
	reply := &model.QuickReply{
		AgentID:   agentID,
		Category:  category,
		Content:   content,
		IsActive:  true,
	}
	
	if err := s.imRepo.CreateQuickReply(ctx, reply); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return reply, nil
}

// UpdateQuickReply 更新快捷话术
func (s *imService) UpdateQuickReply(ctx context.Context, agentID int64, replyID int64, category, content string) error {
	reply, err := s.imRepo.GetQuickReplyByID(ctx, replyID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if reply == nil {
		return common.NewError(common.ErrCodeNotFound, "快捷话术不存在")
	}
	
	if reply.AgentID != agentID {
		return common.NewError(common.ErrCodeForbidden, "无权修改")
	}
	
	reply.Category = category
	reply.Content = content
	
	return s.imRepo.UpdateQuickReply(ctx, reply)
}

// DeleteQuickReply 删除快捷话术
func (s *imService) DeleteQuickReply(ctx context.Context, agentID int64, replyID int64) error {
	reply, err := s.imRepo.GetQuickReplyByID(ctx, replyID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if reply == nil {
		return common.NewError(common.ErrCodeNotFound, "快捷话术不存在")
	}
	
	if reply.AgentID != agentID {
		return common.NewError(common.ErrCodeForbidden, "无权删除")
	}
	
	return s.imRepo.DeleteQuickReply(ctx, replyID)
}

// GetIMToken 获取IM Token（环信 Easemob REST API集成）
func (s *imService) GetIMToken(ctx context.Context, userID int64, userType string) (string, error) {
	// 如果未配置环信凭证，优雅降级返回空token
	if s.config.IM.OrgName == "" || s.config.IM.AppName == "" {
		return "", nil
	}

	// Step 1: 使用 client_credentials 获取 App Token
	appTokenURL := fmt.Sprintf("https://a1.easemob.com/%s/%s/token",
		s.config.IM.OrgName, s.config.IM.AppName)
	appTokenBody := map[string]string{
		"grant_type":    "client_credentials",
		"client_id":     s.config.IM.ClientID,
		"client_secret": s.config.IM.ClientSecret,
	}
	bodyBytes, _ := json.Marshal(appTokenBody)

	httpClient := &http.Client{Timeout: 10 * time.Second}
	resp, err := httpClient.Post(appTokenURL, "application/json", bytes.NewReader(bodyBytes))
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var appTokenResp struct {
		AccessToken string `json:"access_token"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&appTokenResp); err != nil {
		return "", err
	}

	// Step 2: 使用 App Token 获取用户 Token（autoCreateUser=true 自动注册用户）
	imUsername := fmt.Sprintf("%s_%d", userType, userID)
	userTokenURL := fmt.Sprintf("https://a1.easemob.com/%s/%s/users/%s/token",
		s.config.IM.OrgName, s.config.IM.AppName, imUsername)

	req, _ := http.NewRequestWithContext(ctx, "POST", userTokenURL, strings.NewReader(
		fmt.Sprintf(`{"grant_type":"inherit","username":"%s","autoCreateUser":true}`, imUsername),
	))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+appTokenResp.AccessToken)

	resp2, err := httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp2.Body.Close()

	var userTokenResp struct {
		AccessToken string `json:"access_token"`
	}
	if err := json.NewDecoder(resp2.Body).Decode(&userTokenResp); err != nil {
		return "", err
	}

	return userTokenResp.AccessToken, nil
}
