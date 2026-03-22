package model

import (
	"time"
)

// ACNRole ACN角色
type ACNRole struct {
	ID          int     `gorm:"primaryKey" json:"id"`
	Code        string  `gorm:"column:code;uniqueIndex;size:20" json:"code"`
	Name        string  `gorm:"column:name;size:50" json:"name"`
	NameEn      *string `gorm:"column:name_en;size:50" json:"name_en,omitempty"`
	Description *string `gorm:"column:description" json:"description,omitempty"`
	DefaultRatio float64 `gorm:"column:default_ratio" json:"default_ratio"` // 百分比，如15.00代表15%
	RoleType    string  `gorm:"column:role_type;size:20" json:"role_type"`
	SortOrder   int     `gorm:"column:sort_order;default:0" json:"sort_order"`
}

func (ACNRole) TableName() string {
	return "acn_roles"
}

// ACNTransaction ACN成交单
type ACNTransaction struct {
	ID              int64      `gorm:"primaryKey" json:"transaction_id"`
	TransactionCode string     `gorm:"column:transaction_code;uniqueIndex;size:50" json:"transaction_code"`
	HouseID         int64      `gorm:"column:house_id;index" json:"house_id"`
	
	// 成交信息
	DealPrice       int64      `gorm:"column:deal_price" json:"deal_price"`
	CommissionAmount int64     `gorm:"column:commission_amount" json:"commission_amount"`
	DealDate        time.Time  `gorm:"column:deal_date" json:"deal_date"`
	ContractImage   *string    `gorm:"column:contract_image;size:500" json:"contract_image,omitempty"`
	
	// 房源方
	EntrantID       *int64     `gorm:"column:entrant_id" json:"entrant_id,omitempty"`
	EntrantRatio    int64      `gorm:"column:entrant_ratio;default:1500" json:"entrant_ratio"` // 存储为百分比*100
	EntrantAmount   int64      `gorm:"column:entrant_amount" json:"entrant_amount"`
	
	MaintainerID    *int64     `gorm:"column:maintainer_id" json:"maintainer_id,omitempty"`
	MaintainerRatio int64      `gorm:"column:maintainer_ratio;default:2000" json:"maintainer_ratio"` // 存储为百分比*100
	MaintainerAmount int64     `gorm:"column:maintainer_amount" json:"maintainer_amount"`
	
	// 客源方
	IntroducerID    *int64     `gorm:"column:introducer_id" json:"introducer_id,omitempty"`
	IntroducerRatio int64      `gorm:"column:introducer_ratio;default:1000" json:"introducer_ratio"` // 存储为百分比*100
	IntroducerAmount int64     `gorm:"column:introducer_amount" json:"introducer_amount"`
	
	AccompanierID   *int64     `gorm:"column:accompanier_id" json:"accompanier_id,omitempty"`
	AccompanierRatio int64     `gorm:"column:accompanier_ratio;default:1500" json:"accompanier_ratio"` // 存储为百分比*100
	AccompanierAmount int64    `gorm:"column:accompanier_amount" json:"accompanier_amount"`
	
	CloserID        int64      `gorm:"column:closer_id" json:"closer_id"`
	CloserRatio     int64      `gorm:"column:closer_ratio;default:4000" json:"closer_ratio"` // 存储为百分比*100
	CloserAmount    int64      `gorm:"column:closer_amount" json:"closer_amount"`
	
	// 平台服务费
	PlatformRatio   int64      `gorm:"column:platform_ratio;default:1000" json:"platform_ratio"` // 存储为百分比*100
	PlatformAmount  int64      `gorm:"column:platform_amount" json:"platform_amount"`
	
	// 状态
	Status          string     `gorm:"column:status;size:20" json:"status"`
	
	// 确认信息
	ConfirmedAt     *time.Time `gorm:"column:confirmed_at" json:"confirmed_at,omitempty"`
	ConfirmedBy     *string    `gorm:"column:confirmed_by" json:"confirmed_by,omitempty"`
	
	// 结算信息
	SettledAt       *time.Time `gorm:"column:settled_at" json:"settled_at,omitempty"`
	SettlementNotes *string    `gorm:"column:settlement_notes" json:"settlement_notes,omitempty"`
	
	// 申报人
	ReporterID      int64      `gorm:"column:reporter_id" json:"reporter_id"`
	
	CreatedAt       time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt       time.Time  `gorm:"column:updated_at" json:"updated_at"`
	
	// 关联
	CommissionDetails []ACNCommissionDetail `gorm:"foreignKey:TransactionID" json:"commission_details,omitempty"`
}

func (ACNTransaction) TableName() string {
	return "acn_transactions"
}

// IsConfirmed 是否已确认
func (t *ACNTransaction) IsConfirmed() bool {
	return t.Status == "confirmed" || t.Status == "settled"
}

// IsSettled 是否已结算
func (t *ACNTransaction) IsSettled() bool {
	return t.Status == "settled"
}

// CanConfirm 是否可以确认
func (t *ACNTransaction) CanConfirm() bool {
	return t.Status == "pending_confirm"
}

// ACNCommissionDetail 分佣明细
type ACNCommissionDetail struct {
	ID             int64      `gorm:"primaryKey" json:"id"`
	TransactionID  int64      `gorm:"column:transaction_id;index" json:"transaction_id"`
	AgentID        int64      `gorm:"column:agent_id;index" json:"agent_id"`
	RoleCode       string     `gorm:"column:role_code;size:20" json:"role_code"`
	Ratio          int64      `gorm:"column:ratio" json:"ratio"` // 存储为百分比*100
	Amount         int64      `gorm:"column:amount" json:"amount"`
	Status         string     `gorm:"column:status;size:20" json:"status"`
	ConfirmedAt    *time.Time `gorm:"column:confirmed_at" json:"confirmed_at,omitempty"`
	PaidAt         *time.Time `gorm:"column:paid_at" json:"paid_at,omitempty"`
	PaymentMethod  *string    `gorm:"column:payment_method;size:50" json:"payment_method,omitempty"`
	PaymentReference *string  `gorm:"column:payment_reference;size:100" json:"payment_reference,omitempty"`
	CreatedAt      time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt      time.Time  `gorm:"column:updated_at" json:"updated_at"`
}

func (ACNCommissionDetail) TableName() string {
	return "acn_commission_details"
}

// ACNDispute ACN争议
type ACNDispute struct {
	ID            int64      `gorm:"primaryKey" json:"id"`
	TransactionID int64      `gorm:"column:transaction_id;index" json:"transaction_id"`
	DisputantID   int64      `gorm:"column:disputant_id" json:"disputant_id"`
	DisputeType   string     `gorm:"column:dispute_type;size:50" json:"dispute_type"`
	Reason        string     `gorm:"column:reason" json:"reason"`
	Evidence      *string    `gorm:"column:evidence" json:"evidence,omitempty"`
	Status        string     `gorm:"column:status;size:20" json:"status"`
	Resolution    *string    `gorm:"column:resolution" json:"resolution,omitempty"`
	ResolvedBy    *int64     `gorm:"column:resolved_by" json:"resolved_by,omitempty"`
	ResolvedAt    *time.Time `gorm:"column:resolved_at" json:"resolved_at,omitempty"`
	CreatedAt     time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt     time.Time  `gorm:"column:updated_at" json:"updated_at"`
}

func (ACNDispute) TableName() string {
	return "acn_disputes"
}

// Participant 参与者信息
type Participant struct {
	Role    string `json:"role"`
	AgentID int64  `json:"agent_id"`
	Ratio   int64 `json:"ratio"` // 存储为百分比*100，如30.5%存为3050
}

// CommissionCalculationResult 分佣计算结果
type CommissionCalculationResult struct {
	TransactionID  int64
	CommissionAmount int64
	PlatformAmount int64
	Participants   []ParticipantResult
}

// ParticipantResult 参与者分佣结果
type ParticipantResult struct {
	AgentID  int64
	RoleCode string
	Ratio    int64  // 存储为百分比*100，如30.5%存为3050
	Amount   int64
}
