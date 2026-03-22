package repository

import (
	"context"
	"time"

	"gorm.io/gorm"

	"myanmar-property/backend/06-appointment-service"
)

// AppointmentRepository 预约数据访问接口
type AppointmentRepository interface {
	// 预约
	CreateAppointment(ctx context.Context, appointment *model.Appointment) error
	GetAppointmentByID(ctx context.Context, id int64) (*model.Appointment, error)
	GetAppointmentByCode(ctx context.Context, code string) (*model.Appointment, error)
	UpdateAppointment(ctx context.Context, appointment *model.Appointment) error
	GetAppointmentsByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.Appointment, int64, error)
	GetAppointmentsByUser(ctx context.Context, userID int64, status string, page, pageSize int) ([]*model.Appointment, int64, error)
	CheckConflict(ctx context.Context, agentID int64, date time.Time, timeSlot string) (bool, error)

	// 日程
	CreateSchedule(ctx context.Context, schedule *model.AgentSchedule) error
	UpdateSchedule(ctx context.Context, schedule *model.AgentSchedule) error
	GetSchedule(ctx context.Context, agentID int64, workDate time.Time, timeSlot string) (*model.AgentSchedule, error)
	GetSchedulesByDate(ctx context.Context, agentID int64, workDate time.Time) ([]*model.AgentSchedule, error)
}

// appointmentRepository 实现
type appointmentRepository struct {
	db *gorm.DB
}

// NewAppointmentRepository 创建预约仓储
func NewAppointmentRepository(db *gorm.DB) AppointmentRepository {
	return &appointmentRepository{db: db}
}

// CreateAppointment 创建预约
func (r *appointmentRepository) CreateAppointment(ctx context.Context, appointment *model.Appointment) error {
	return r.db.WithContext(ctx).Create(appointment).Error
}

// GetAppointmentByID 根据ID获取预约
func (r *appointmentRepository) GetAppointmentByID(ctx context.Context, id int64) (*model.Appointment, error) {
	var appointment model.Appointment
	err := r.db.WithContext(ctx).First(&appointment, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &appointment, err
}

// GetAppointmentByCode 根据编码获取预约
func (r *appointmentRepository) GetAppointmentByCode(ctx context.Context, code string) (*model.Appointment, error) {
	var appointment model.Appointment
	err := r.db.WithContext(ctx).
		Where("appointment_code = ?", code).
		First(&appointment).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &appointment, err
}

// UpdateAppointment 更新预约
func (r *appointmentRepository) UpdateAppointment(ctx context.Context, appointment *model.Appointment) error {
	return r.db.WithContext(ctx).Save(appointment).Error
}

// GetAppointmentsByAgent 获取经纪人的预约
func (r *appointmentRepository) GetAppointmentsByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.Appointment, int64, error) {
	var appointments []*model.Appointment
	var total int64

	db := r.db.WithContext(ctx).Model(&model.Appointment{}).Where("agent_id = ?", agentID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("appointment_date DESC, appointment_time_start ASC").
		Offset(offset).Limit(pageSize).
		Find(&appointments).Error

	return appointments, total, err
}

// GetAppointmentsByUser 获取用户的预约
func (r *appointmentRepository) GetAppointmentsByUser(ctx context.Context, userID int64, status string, page, pageSize int) ([]*model.Appointment, int64, error) {
	var appointments []*model.Appointment
	var total int64

	db := r.db.WithContext(ctx).Model(&model.Appointment{}).Where("created_by = ?", userID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("appointment_date DESC, appointment_time_start ASC").
		Offset(offset).Limit(pageSize).
		Find(&appointments).Error

	return appointments, total, err
}

// CheckConflict 检查时段冲突
func (r *appointmentRepository) CheckConflict(ctx context.Context, agentID int64, date time.Time, timeSlot string) (bool, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Model(&model.Appointment{}).
		Where("agent_id = ? AND appointment_date = ? AND appointment_time_start = ? AND status IN (?)",
			agentID, date, timeSlot, []string{"pending", "confirmed"}).
		Count(&count).Error

	return count > 0, err
}

// CreateSchedule 创建日程
func (r *appointmentRepository) CreateSchedule(ctx context.Context, schedule *model.AgentSchedule) error {
	return r.db.WithContext(ctx).Create(schedule).Error
}

// UpdateSchedule 更新日程
func (r *appointmentRepository) UpdateSchedule(ctx context.Context, schedule *model.AgentSchedule) error {
	return r.db.WithContext(ctx).Save(schedule).Error
}

// GetSchedule 获取日程
func (r *appointmentRepository) GetSchedule(ctx context.Context, agentID int64, workDate time.Time, timeSlot string) (*model.AgentSchedule, error) {
	var schedule model.AgentSchedule
	err := r.db.WithContext(ctx).
		Where("agent_id = ? AND work_date = ? AND time_slot = ?", agentID, workDate, timeSlot).
		First(&schedule).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &schedule, err
}

// GetSchedulesByDate 获取日期的所有日程
func (r *appointmentRepository) GetSchedulesByDate(ctx context.Context, agentID int64, workDate time.Time) ([]*model.AgentSchedule, error) {
	var schedules []*model.AgentSchedule
	err := r.db.WithContext(ctx).
		Where("agent_id = ? AND work_date = ?", agentID, workDate).
		Find(&schedules).Error
	return schedules, err
}
