package model

import (
	"time"
)

// Conversation 会话模型
type Conversation struct {
	ID                int64      `gorm:"primaryKey" json:"conversation_id"`
	ConversationCode  string     `gorm:"column:conversation_code;uniqueIndex;size:50" json:"conversation_code"`
	Type              string     `gorm:"column:type;size:20;default:single" json:"type"`
	
	// 参与方
	UserID            int64      `gorm:"column:user_id;index" json:"user_id"`
	AgentID           int64      `gorm:"column:agent_id;index" json:"agent_id"`
	HouseID           *int64     `gorm:"column:house_id" json:"house_id,omitempty"`
	
	// 最后消息
	LastMessageID     *int64     `gorm:"column:last_message_id" json:"last_message_id,omitempty"`
	LastMessageAt     *time.Time `gorm:"column:last_message_at" json:"last_message_at,omitempty"`
	LastMessagePreview *string   `gorm:"column:last_message_preview;size:200" json:"last_message_preview,omitempty"`
	
	// 未读数
	UserUnreadCount   int        `gorm:"column:user_unread_count;default:0" json:"user_unread_count"`
	AgentUnreadCount  int        `gorm:"column:agent_unread_count;default:0" json:"agent_unread_count"`
	
	// 状态
	IsBlocked         bool       `gorm:"column:is_blocked;default:false" json:"is_blocked"`
	BlockedBy         *int64     `gorm:"column:blocked_by" json:"blocked_by,omitempty"`
	BlockedReason     *string    `gorm:"column:blocked_reason" json:"blocked_reason,omitempty"`
	
	IsPinned          bool       `gorm:"column:is_pinned;default:false" json:"is_pinned"`
	PinnedAt          *time.Time `gorm:"column:pinned_at" json:"pinned_at,omitempty"`
	
	CreatedAt         time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt         time.Time  `gorm:"column:updated_at" json:"updated_at"`
}

func (Conversation) TableName() string {
	return "conversations"
}

// Message 消息模型
type Message struct {
	ID              int64      `gorm:"primaryKey" json:"message_id"`
	ConversationID  int64      `gorm:"column:conversation_id;index" json:"conversation_id"`
	MessageCode     string     `gorm:"column:message_code;uniqueIndex;size:50" json:"message_code"`
	
	SenderType      string     `gorm:"column:sender_type;size:20" json:"sender_type"`
	SenderID        int64      `gorm:"column:sender_id" json:"sender_id"`
	
	MessageType     string     `gorm:"column:message_type;size:20" json:"message_type"`
	Content         *string    `gorm:"column:content" json:"content,omitempty"`
	MediaURL        *string    `gorm:"column:media_url;size:500" json:"media_url,omitempty"`
	MediaDuration   *int       `gorm:"column:media_duration" json:"media_duration,omitempty"`
	MediaSize       *int       `gorm:"column:media_size" json:"media_size,omitempty"`
	
	// 扩展数据
	ExtraData       *string    `gorm:"column:extra_data" json:"extra_data,omitempty"`
	
	// 状态
	Status          string     `gorm:"column:status;size:20;default:sent" json:"status"`
	SentAt          time.Time  `gorm:"column:sent_at" json:"sent_at"`
	DeliveredAt     *time.Time `gorm:"column:delivered_at" json:"delivered_at,omitempty"`
	ReadAt          *time.Time `gorm:"column:read_at" json:"read_at,omitempty"`
	RecalledAt      *time.Time `gorm:"column:recalled_at" json:"recalled_at,omitempty"`
	
	CreatedAt       time.Time  `gorm:"column:created_at" json:"created_at"`
}

func (Message) TableName() string {
	return "messages"
}

// IsRecalled 是否已撤回
func (m *Message) IsRecalled() bool {
	return m.RecalledAt != nil
}

// QuickReply 快捷话术
type QuickReply struct {
	ID         int64     `gorm:"primaryKey" json:"id"`
	AgentID    int64     `gorm:"column:agent_id;index" json:"agent_id"`
	Category   string    `gorm:"column:category;size:50" json:"category"`
	Content    string    `gorm:"column:content" json:"content"`
	SortOrder  int       `gorm:"column:sort_order;default:0" json:"sort_order"`
	IsActive   bool      `gorm:"column:is_active;default:true" json:"is_active"`
	CreatedAt  time.Time `gorm:"column:created_at" json:"created_at"`
	UpdatedAt  time.Time `gorm:"column:updated_at" json:"updated_at"`
}

func (QuickReply) TableName() string {
	return "quick_replies"
}

// 消息类型常量
const (
	MessageTypeText      = "text"
	MessageTypeImage     = "image"
	MessageTypeVoice     = "voice"
	MessageTypeVideo     = "video"
	MessageTypeLocation  = "location"
	MessageTypeHouseCard = "house_card"
	MessageTypeSystem    = "system"
)

// 消息状态常量
const (
	MessageStatusSending  = "sending"
	MessageStatusSent     = "sent"
	MessageStatusDelivered = "delivered"
	MessageStatusRead     = "read"
	MessageStatusFailed   = "failed"
	MessageStatusRecalled = "recalled"
)
