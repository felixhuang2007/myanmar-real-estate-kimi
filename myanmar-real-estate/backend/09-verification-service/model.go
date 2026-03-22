package model

import (
	"time"
)

// VerificationTask 验真任务
type VerificationTask struct {
	ID               int64      `gorm:"primaryKey" json:"task_id"`
	TaskCode         string     `gorm:"column:task_code;uniqueIndex;size:50" json:"task_code"`
	HouseID          int64      `gorm:"column:house_id;index" json:"house_id"`
	Type             string     `gorm:"column:type;size:20;default:basic" json:"type"`
	Status           string     `gorm:"column:status;size:20;default:pending" json:"status"`
	
	AssigneeID       *int64     `gorm:"column:assignee_id" json:"assignee_id,omitempty"`
	AssignedAt       *time.Time `gorm:"column:assigned_at" json:"assigned_at,omitempty"`
	DeadlineAt       *time.Time `gorm:"column:deadline_at" json:"deadline_at,omitempty"`
	
	CompletedAt      *time.Time `gorm:"column:completed_at" json:"completed_at,omitempty"`
	Result           *string    `gorm:"column:result;size:20" json:"result,omitempty"`
	Score            *int       `gorm:"column:score" json:"score,omitempty"`
	Report           *string    `gorm:"column:report" json:"report,omitempty"`
	
	CommissionAmount *int64     `gorm:"column:commission_amount" json:"commission_amount,omitempty"`
	CommissionStatus string     `gorm:"column:commission_status;size:20;default:pending" json:"commission_status"`
	CommissionPaidAt *time.Time `gorm:"column:commission_paid_at" json:"commission_paid_at,omitempty"`
	
	CreatedAt        time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt        time.Time  `gorm:"column:updated_at" json:"updated_at"`
}

func (VerificationTask) TableName() string {
	return "verification_tasks"
}

// IsPending 是否待处理
func (t *VerificationTask) IsPending() bool {
	return t.Status == "pending"
}

// IsProcessing 是否处理中
func (t *VerificationTask) IsProcessing() bool {
	return t.Status == "processing"
}

// IsCompleted 是否已完成
func (t *VerificationTask) IsCompleted() bool {
	return t.Status == "completed"
}

// VerificationItem 验真检查项
type VerificationItem struct {
	ID         int64      `gorm:"primaryKey" json:"id"`
	TaskID     int64      `gorm:"column:task_id;index" json:"task_id"`
	Category   string     `gorm:"column:category;size:20" json:"category"`
	ItemName   string     `gorm:"column:item_name;size:100" json:"item_name"`
	IsRequired bool       `gorm:"column:is_required;default:true" json:"is_required"`
	Status     string     `gorm:"column:status;size:20;default:pending" json:"status"`
	Remark     *string    `gorm:"column:remark" json:"remark,omitempty"`
	Photos     *string    `gorm:"column:photos" json:"photos,omitempty"`
	CheckedAt  *time.Time `gorm:"column:checked_at" json:"checked_at,omitempty"`
	CreatedAt  time.Time  `gorm:"column:created_at" json:"created_at"`
}

func (VerificationItem) TableName() string {
	return "verification_items"
}

// VerificationPhoto 验真照片
type VerificationPhoto struct {
	ID         int64      `gorm:"primaryKey" json:"id"`
	TaskID     int64      `gorm:"column:task_id;index" json:"task_id"`
	PhotoType  string     `gorm:"column:photo_type;size:50" json:"photo_type"`
	PhotoURL   string     `gorm:"column:photo_url;size:500" json:"photo_url"`
	Latitude   *float64   `gorm:"column:latitude" json:"latitude,omitempty"`
	Longitude  *float64   `gorm:"column:longitude" json:"longitude,omitempty"`
	TakenAt    *time.Time `gorm:"column:taken_at" json:"taken_at,omitempty"`
	UploadedBy *int64     `gorm:"column:uploaded_by" json:"uploaded_by,omitempty"`
	CreatedAt  time.Time  `gorm:"column:created_at" json:"created_at"`
}

func (VerificationPhoto) TableName() string {
	return "verification_photos"
}

// 验真类型常量
const (
	VerificationTypeBasic        = "basic"
	VerificationTypeProperty     = "property"
	VerificationTypeComprehensive = "comprehensive"
)

// 验真状态常量
const (
	VerificationStatusPending    = "pending"
	VerificationStatusAssigned   = "assigned"
	VerificationStatusProcessing = "processing"
	VerificationStatusCompleted  = "completed"
	VerificationStatusCancelled  = "cancelled"
)

// 验真结果常量
const (
	VerificationResultPass       = "pass"
	VerificationResultFail       = "fail"
	VerificationResultConditional = "conditional"
)

// 验真检查项配置
var VerificationItemConfigs = []struct {
	Category   string
	ItemName   string
	IsRequired bool
}{
	{"basic", "房源存在性", true},
	{"basic", "地址一致性", true},
	{"basic", "面积核实", true},
	{"basic", "图片真实性", true},
	{"property", "产权类型确认", true},
	{"property", "产权人核实", true},
	{"property", "抵押查封情况", true},
	{"property", "产权纠纷", false},
	{"transaction", "出售意愿确认", true},
	{"transaction", "价格确认", true},
	{"transaction", "看房便利性", false},
}
