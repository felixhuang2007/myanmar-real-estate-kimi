package model

import (
	"time"
)

// Appointment 预约带看模型
type Appointment struct {
	ID                   int64      `gorm:"primaryKey" json:"appointment_id"`
	AppointmentCode      string     `gorm:"column:appointment_code;uniqueIndex;size:50" json:"appointment_code"`
	
	// 关联
	HouseID              int64      `gorm:"column:house_id;index" json:"house_id"`
	ClientID             *int64     `gorm:"column:client_id" json:"client_id,omitempty"`
	AgentID              int64      `gorm:"column:agent_id;index" json:"agent_id"`
	
	// 预约时间
	AppointmentDate      time.Time  `gorm:"column:appointment_date" json:"appointment_date"`
	AppointmentTimeStart string     `gorm:"column:appointment_time_start;size:10" json:"appointment_time_start"`
	AppointmentTimeEnd   string     `gorm:"column:appointment_time_end;size:10" json:"appointment_time_end"`
	
	// 状态
	Status               string     `gorm:"column:status;size:20" json:"status"`
	
	// 客户信息（快照）
	ClientName           *string    `gorm:"column:client_name;size:100" json:"client_name,omitempty"`
	ClientPhone          *string    `gorm:"column:client_phone;size:20" json:"client_phone,omitempty"`
	ClientNote           *string    `gorm:"column:client_note" json:"client_note,omitempty"`
	
	// 带看反馈
	ActualShowingAt      *time.Time `gorm:"column:actual_showing_at" json:"actual_showing_at,omitempty"`
	ShowingResult        *string    `gorm:"column:showing_result;size:20" json:"showing_result,omitempty"`
	ShowingFeedback      *string    `gorm:"column:showing_feedback" json:"showing_feedback,omitempty"`
	
	// 取消信息
	CancelledBy          *string    `gorm:"column:cancelled_by;size:20" json:"cancelled_by,omitempty"`
	CancelReason         *string    `gorm:"column:cancel_reason" json:"cancel_reason,omitempty"`
	
	// 创建信息
	CreatedBy            int64      `gorm:"column:created_by" json:"created_by"`
	CreatedAt            time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt            time.Time  `gorm:"column:updated_at" json:"updated_at"`
}

func (Appointment) TableName() string {
	return "appointments"
}

// IsPending 是否待确认
func (a *Appointment) IsPending() bool {
	return a.Status == "pending"
}

// IsConfirmed 是否已确认
func (a *Appointment) IsConfirmed() bool {
	return a.Status == "confirmed"
}

// IsCompleted 是否已完成
func (a *Appointment) IsCompleted() bool {
	return a.Status == "completed"
}

// IsCancelled 是否已取消
func (a *Appointment) IsCancelled() bool {
	return a.Status == "cancelled"
}

// CanCancel 是否可以取消
func (a *Appointment) CanCancel() bool {
	return a.Status == "pending" || a.Status == "confirmed"
}

// AgentSchedule 经纪人日程
type AgentSchedule struct {
	ID               int64     `gorm:"primaryKey" json:"id"`
	AgentID          int64     `gorm:"column:agent_id;index" json:"agent_id"`
	WorkDate         time.Time `gorm:"column:work_date" json:"work_date"`
	TimeSlot         string    `gorm:"column:time_slot;size:20" json:"time_slot"`
	IsAvailable      bool      `gorm:"column:is_available;default:true" json:"is_available"`
	MaxAppointments  int       `gorm:"column:max_appointments;default:3" json:"max_appointments"`
	BookedCount      int       `gorm:"column:booked_count;default:0" json:"booked_count"`
	CreatedAt        time.Time `gorm:"column:created_at" json:"created_at"`
}

func (AgentSchedule) TableName() string {
	return "agent_schedules"
}

// IsFullyBooked 是否已满
func (s *AgentSchedule) IsFullyBooked() bool {
	return s.BookedCount >= s.MaxAppointments
}

// TimeSlotInfo 时段信息
type TimeSlotInfo struct {
	Time            string `json:"time"`
	IsAvailable     bool   `json:"is_available"`
	MaxAppointments int    `json:"max_appointments"`
	BookedCount     int    `json:"booked_count"`
}

// CreateAppointmentRequest 创建预约请求
type CreateAppointmentRequest struct {
	HouseID             int64   `json:"house_id" binding:"required"`
	AgentID             int64   `json:"agent_id" binding:"required"`
	AppointmentDate     string  `json:"appointment_date" binding:"required"`
	AppointmentTimeStart string `json:"appointment_time_start" binding:"required"`
	AppointmentTimeEnd   string `json:"appointment_time_end" binding:"required"`
	ClientName          string  `json:"client_name,omitempty"`
	ClientPhone         string  `json:"client_phone,omitempty"`
	ClientNote          string  `json:"client_note,omitempty"`
}

// UpdateScheduleRequest 更新日程请求
type UpdateScheduleRequest struct {
	Schedules []ScheduleItem `json:"schedules" binding:"required"`
}

type ScheduleItem struct {
	WorkDate   string       `json:"work_date" binding:"required"`
	TimeSlots  []TimeSlotInput `json:"time_slots" binding:"required"`
}

type TimeSlotInput struct {
	Time          string `json:"time" binding:"required"`
	IsAvailable   bool   `json:"is_available"`
}
