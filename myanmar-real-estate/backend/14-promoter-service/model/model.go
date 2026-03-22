package model

import (
	"time"

	"gorm.io/gorm"
)

// Promoter 地推员
type Promoter struct {
	ID                int64          `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID            int64          `gorm:"uniqueIndex;not null" json:"user_id"`
	Code              string         `gorm:"size:20;uniqueIndex;not null" json:"code"` // unique invite code
	QRCodeURL         string         `gorm:"size:500" json:"qr_code_url"`
	Status            string         `gorm:"size:20;default:'active'" json:"status"` // active/suspended
	TotalReferrals    int64          `gorm:"default:0" json:"total_referrals"`
	ValidReferrals    int64          `gorm:"default:0" json:"valid_referrals"` // registered users
	TotalCommission   int64          `gorm:"default:0" json:"total_commission"` // in MMK
	PaidCommission    int64          `gorm:"default:0" json:"paid_commission"`
	PendingWithdrawal int64          `gorm:"default:0" json:"pending_withdrawal"`
	CreatedAt         time.Time      `json:"created_at"`
	UpdatedAt         time.Time      `json:"updated_at"`
	DeletedAt         gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Promoter) TableName() string { return "promoters" }

// ReferralRecord 推荐记录
type ReferralRecord struct {
	ID             int64     `gorm:"primaryKey;autoIncrement" json:"id"`
	PromoterID     int64     `gorm:"not null;index" json:"promoter_id"`
	PromoterCode   string    `gorm:"size:20;not null" json:"promoter_code"`
	ReferredUserID int64     `gorm:"not null" json:"referred_user_id"`
	UserPhone      string    `gorm:"size:20" json:"user_phone"` // masked
	Commission     int64     `json:"commission"`                // 50 MMK per valid registration
	Status         string    `gorm:"size:20;default:'pending'" json:"status"` // pending/confirmed/cancelled
	CreatedAt      time.Time `json:"created_at"`
	UpdatedAt      time.Time `json:"updated_at"`
}

func (ReferralRecord) TableName() string { return "referral_records" }

// WithdrawalRecord 提现记录
type WithdrawalRecord struct {
	ID          int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	PromoterID  int64      `gorm:"not null;index" json:"promoter_id"`
	Amount      int64      `gorm:"not null" json:"amount"`    // in MMK
	Method      string     `gorm:"size:50" json:"method"`     // kbzpay/wavepay/bank
	AccountInfo string     `gorm:"size:200" json:"account_info"` // account number/name
	Status      string     `gorm:"size:20;default:'pending'" json:"status"` // pending/processing/completed/failed
	FailReason  string     `gorm:"size:500" json:"fail_reason,omitempty"`
	ProcessedAt *time.Time `json:"processed_at,omitempty"`
	CreatedAt   time.Time  `json:"created_at"`
	UpdatedAt   time.Time  `json:"updated_at"`
}

func (WithdrawalRecord) TableName() string { return "withdrawal_records" }
