package model

import (
	"time"

	"gorm.io/gorm"
)

// Client 客户
type Client struct {
	ID           int64          `gorm:"primaryKey;autoIncrement" json:"id"`
	AgentID      int64          `gorm:"column:owner_id;not null;index" json:"agent_id"`
	Name         string         `gorm:"size:100;not null" json:"name"`
	Phone        string         `gorm:"size:20" json:"phone"`
	Source       string         `gorm:"size:50" json:"source"` // referral/walk_in/online/acn
	Status       string         `gorm:"size:20;default:'new'" json:"status"` // new/following/high_intent/deal/lost
	Budget       int64          `json:"budget"`        // 预算（缅元）
	BudgetMax    int64          `json:"budget_max"`
	Requirement  string         `gorm:"type:text" json:"requirement"` // 需求描述
	PreferArea   string         `gorm:"size:200" json:"prefer_area"`  // 意向区域
	HouseType    string         `gorm:"size:50" json:"house_type"`
	Tags         string         `gorm:"type:text" json:"tags"`         // JSON array of strings
	NextFollowAt *time.Time     `json:"next_follow_at"`
	LastFollowAt *time.Time     `json:"last_follow_at"`
	Remark       string         `gorm:"type:text" json:"remark"`
	CreatedAt    time.Time      `json:"created_at"`
	UpdatedAt    time.Time      `json:"updated_at"`
	DeletedAt    gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Client) TableName() string { return "clients" }

// FollowUpRecord 跟进记录
type FollowUpRecord struct {
	ID            int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	ClientID      int64      `gorm:"not null;index" json:"client_id"`
	AgentID       int64      `gorm:"not null;index" json:"agent_id"`
	ContactMethod string     `gorm:"size:20" json:"contact_method"` // call/sms/wechat/visit
	Content       string     `gorm:"type:text" json:"content"`
	StatusChange  string     `gorm:"size:20" json:"status_change"` // new status after follow-up
	NextFollowAt  *time.Time `json:"next_follow_at"`
	CreatedAt     time.Time  `json:"created_at"`
}

func (FollowUpRecord) TableName() string { return "client_follow_up_records" }

// Client status constants
const (
	ClientStatusNew        = "new"
	ClientStatusFollowing  = "following"
	ClientStatusHighIntent = "high_intent"
	ClientStatusDeal       = "deal"
	ClientStatusLost       = "lost"
)
