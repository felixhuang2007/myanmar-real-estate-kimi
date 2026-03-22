package service

import (
	"context"
	"fmt"
	"time"

	"myanmar-property/backend/06-appointment-service"
	"myanmar-property/backend/06-appointment-service/repository"
	"myanmar-property/backend/07-common"
)

// AppointmentService 预约服务接口
type AppointmentService interface {
	// 预约管理
	CreateAppointment(ctx context.Context, userID int64, req *model.CreateAppointmentRequest) (*model.Appointment, error)
	GetAppointment(ctx context.Context, appointmentID int64) (*model.Appointment, error)
	GetAppointments(ctx context.Context, userID int64, role string, status string, page, pageSize int) ([]*model.Appointment, int64, error)
	ConfirmAppointment(ctx context.Context, agentID, appointmentID int64) error
	RejectAppointment(ctx context.Context, agentID, appointmentID int64, reason string, suggestedTime string) error
	CancelAppointment(ctx context.Context, userID int64, appointmentID int64, reason string) error
	CompleteAppointment(ctx context.Context, agentID, appointmentID int64, result, feedback string) error

	// 日程管理
	GetAvailableSlots(ctx context.Context, agentID int64, date string) ([]*model.TimeSlotInfo, error)
	UpdateSchedule(ctx context.Context, agentID int64, req *model.UpdateScheduleRequest) error
}

// appointmentService 实现
type appointmentService struct {
	appointmentRepo repository.AppointmentRepository
	config          *common.Config
}

// NewAppointmentService 创建预约服务
func NewAppointmentService(appointmentRepo repository.AppointmentRepository, config *common.Config) AppointmentService {
	return &appointmentService{
		appointmentRepo: appointmentRepo,
		config:          config,
	}
}

// CreateAppointment 创建预约
func (s *appointmentService) CreateAppointment(ctx context.Context, userID int64, req *model.CreateAppointmentRequest) (*model.Appointment, error) {
	// 解析日期
	appointmentDate, err := time.Parse("2006-01-02", req.AppointmentDate)
	if err != nil {
		return nil, common.NewError(common.ErrCodeValidation, "日期格式错误")
	}

	// 检查日期是否过期
	if appointmentDate.Before(time.Now().Truncate(24 * time.Hour)) {
		return nil, common.NewError(common.ErrCodeValidation, "不能预约过去的日期")
	}

	// 检查时段是否可用
	schedule, err := s.appointmentRepo.GetSchedule(ctx, req.AgentID, appointmentDate, req.AppointmentTimeStart)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if schedule == nil {
		// 创建默认时段
		schedule = &model.AgentSchedule{
			AgentID:         req.AgentID,
			WorkDate:        appointmentDate,
			TimeSlot:        req.AppointmentTimeStart,
			IsAvailable:     true,
			MaxAppointments: 3,
			BookedCount:     0,
		}
		if err := s.appointmentRepo.CreateSchedule(ctx, schedule); err != nil {
			return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
		}
	}

	if !schedule.IsAvailable {
		return nil, common.NewError(common.ErrCodeSlotNotAvailable, "该时段不可用")
	}

	if schedule.IsFullyBooked() {
		return nil, common.NewError(common.ErrCodeSlotNotAvailable, "该时段已约满")
	}

	// 检查是否有冲突预约
	exists, err := s.appointmentRepo.CheckConflict(ctx, req.AgentID, appointmentDate, req.AppointmentTimeStart)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if exists {
		return nil, common.NewError(common.ErrCodeAppointmentConflict, "该时段已有预约")
	}

	// 生成预约编码
	appointmentCode := fmt.Sprintf("AP%s%06d", time.Now().Format("20060102"), generateRandom(999999))

	appointment := &model.Appointment{
		AppointmentCode:      appointmentCode,
		HouseID:              req.HouseID,
		AgentID:              req.AgentID,
		AppointmentDate:      appointmentDate,
		AppointmentTimeStart: req.AppointmentTimeStart,
		AppointmentTimeEnd:   req.AppointmentTimeEnd,
		Status:               "pending",
		ClientName:           &req.ClientName,
		ClientPhone:          &req.ClientPhone,
		CreatedBy:            userID,
	}

	if req.ClientNote != "" {
		appointment.ClientNote = &req.ClientNote
	}

	// 保存预约
	if err := s.appointmentRepo.CreateAppointment(ctx, appointment); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 更新时段预约数
	schedule.BookedCount++
	if err := s.appointmentRepo.UpdateSchedule(ctx, schedule); err != nil {
		common.Error("更新时段预约数失败", common.ErrorField(err))
	}

	return appointment, nil
}

// GetAppointment 获取预约详情
func (s *appointmentService) GetAppointment(ctx context.Context, appointmentID int64) (*model.Appointment, error) {
	appointment, err := s.appointmentRepo.GetAppointmentByID(ctx, appointmentID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if appointment == nil {
		return nil, common.NewError(common.ErrCodeAppointmentNotFound)
	}

	return appointment, nil
}

// GetAppointments 获取预约列表
func (s *appointmentService) GetAppointments(ctx context.Context, userID int64, role string, status string, page, pageSize int) ([]*model.Appointment, int64, error) {
	if role == "agent" {
		// 查询经纪人的预约
		// 简化实现，实际需要根据agentID查询
		return s.appointmentRepo.GetAppointmentsByAgent(ctx, userID, status, page, pageSize)
	}

	// 查询用户的预约
	return s.appointmentRepo.GetAppointmentsByUser(ctx, userID, status, page, pageSize)
}

// ConfirmAppointment 确认预约
func (s *appointmentService) ConfirmAppointment(ctx context.Context, agentID, appointmentID int64) error {
	appointment, err := s.appointmentRepo.GetAppointmentByID(ctx, appointmentID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if appointment == nil {
		return common.NewError(common.ErrCodeAppointmentNotFound)
	}

	if appointment.AgentID != agentID {
		return common.NewError(common.ErrCodeForbidden, "无权操作该预约")
	}

	if !appointment.IsPending() {
		return common.NewError(common.ErrCodeValidation, "只能确认待处理的预约")
	}

	appointment.Status = "confirmed"
	return s.appointmentRepo.UpdateAppointment(ctx, appointment)
}

// RejectAppointment 拒绝预约
func (s *appointmentService) RejectAppointment(ctx context.Context, agentID, appointmentID int64, reason string, suggestedTime string) error {
	appointment, err := s.appointmentRepo.GetAppointmentByID(ctx, appointmentID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if appointment == nil {
		return common.NewError(common.ErrCodeAppointmentNotFound)
	}

	if appointment.AgentID != agentID {
		return common.NewError(common.ErrCodeForbidden, "无权操作该预约")
	}

	if !appointment.IsPending() {
		return common.NewError(common.ErrCodeValidation, "只能拒绝待处理的预约")
	}

	appointment.Status = "rejected"
	cancelledBy := "agent"
	appointment.CancelledBy = &cancelledBy
	appointment.CancelReason = &reason

	if err := s.appointmentRepo.UpdateAppointment(ctx, appointment); err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 释放时段
	schedule, _ := s.appointmentRepo.GetSchedule(ctx, agentID, appointment.AppointmentDate, appointment.AppointmentTimeStart)
	if schedule != nil && schedule.BookedCount > 0 {
		schedule.BookedCount--
		s.appointmentRepo.UpdateSchedule(ctx, schedule)
	}

	return nil
}

// CancelAppointment 取消预约
func (s *appointmentService) CancelAppointment(ctx context.Context, userID int64, appointmentID int64, reason string) error {
	appointment, err := s.appointmentRepo.GetAppointmentByID(ctx, appointmentID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if appointment == nil {
		return common.NewError(common.ErrCodeAppointmentNotFound)
	}

	// 检查权限
	if appointment.CreatedBy != userID {
		return common.NewError(common.ErrCodeForbidden, "无权取消该预约")
	}

	if !appointment.CanCancel() {
		return common.NewError(common.ErrCodeValidation, "该预约状态不能取消")
	}

	appointment.Status = "cancelled"
	cancelledBy := "client"
	appointment.CancelledBy = &cancelledBy
	appointment.CancelReason = &reason

	if err := s.appointmentRepo.UpdateAppointment(ctx, appointment); err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 释放时段
	schedule, _ := s.appointmentRepo.GetSchedule(ctx, appointment.AgentID, appointment.AppointmentDate, appointment.AppointmentTimeStart)
	if schedule != nil && schedule.BookedCount > 0 {
		schedule.BookedCount--
		s.appointmentRepo.UpdateSchedule(ctx, schedule)
	}

	return nil
}

// CompleteAppointment 完成带看
func (s *appointmentService) CompleteAppointment(ctx context.Context, agentID, appointmentID int64, result, feedback string) error {
	appointment, err := s.appointmentRepo.GetAppointmentByID(ctx, appointmentID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if appointment == nil {
		return common.NewError(common.ErrCodeAppointmentNotFound)
	}

	if appointment.AgentID != agentID {
		return common.NewError(common.ErrCodeForbidden, "无权操作该预约")
	}

	if !appointment.IsConfirmed() {
		return common.NewError(common.ErrCodeValidation, "只能完成已确认的预约")
	}

	appointment.Status = "completed"
	now := time.Now()
	appointment.ActualShowingAt = &now
	appointment.ShowingResult = &result
	if feedback != "" {
		appointment.ShowingFeedback = &feedback
	}

	return s.appointmentRepo.UpdateAppointment(ctx, appointment)
}

// GetAvailableSlots 获取可用时段
func (s *appointmentService) GetAvailableSlots(ctx context.Context, agentID int64, date string) ([]*model.TimeSlotInfo, error) {
	workDate, err := time.Parse("2006-01-02", date)
	if err != nil {
		return nil, common.NewError(common.ErrCodeValidation, "日期格式错误")
	}

	schedules, err := s.appointmentRepo.GetSchedulesByDate(ctx, agentID, workDate)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 生成默认时段列表
	timeSlots := generateDefaultTimeSlots()

	// 填充实际预约数据
	for i := range timeSlots {
		for _, schedule := range schedules {
			if schedule.TimeSlot == timeSlots[i].Time {
				timeSlots[i].IsAvailable = schedule.IsAvailable
				timeSlots[i].MaxAppointments = schedule.MaxAppointments
				timeSlots[i].BookedCount = schedule.BookedCount
				break
			}
		}
	}

	result := make([]*model.TimeSlotInfo, len(timeSlots))
	for i := range timeSlots {
		slot := timeSlots[i]
		result[i] = &slot
	}
	return result, nil
}

// UpdateSchedule 更新日程
func (s *appointmentService) UpdateSchedule(ctx context.Context, agentID int64, req *model.UpdateScheduleRequest) error {
	for _, item := range req.Schedules {
		workDate, err := time.Parse("2006-01-02", item.WorkDate)
		if err != nil {
			continue
		}

		for _, slot := range item.TimeSlots {
			schedule, _ := s.appointmentRepo.GetSchedule(ctx, agentID, workDate, slot.Time)
			if schedule == nil {
				schedule = &model.AgentSchedule{
					AgentID:     agentID,
					WorkDate:    workDate,
					TimeSlot:    slot.Time,
					IsAvailable: slot.IsAvailable,
				}
			} else {
				schedule.IsAvailable = slot.IsAvailable
			}

			if err := s.appointmentRepo.UpdateSchedule(ctx, schedule); err != nil {
				return common.NewError(common.ErrCodeInternalServer, err.Error())
			}
		}
	}

	return nil
}

// 辅助函数

func generateDefaultTimeSlots() []model.TimeSlotInfo {
	slots := []string{
		"09:00-09:30", "09:30-10:00",
		"10:00-10:30", "10:30-11:00",
		"11:00-11:30", "11:30-12:00",
		"13:00-13:30", "13:30-14:00",
		"14:00-14:30", "14:30-15:00",
		"15:00-15:30", "15:30-16:00",
		"16:00-16:30", "16:30-17:00",
		"17:00-17:30", "17:30-18:00",
	}

	result := make([]model.TimeSlotInfo, len(slots))
	for i, slot := range slots {
		result[i] = model.TimeSlotInfo{
			Time:            slot,
			IsAvailable:     true,
			MaxAppointments: 3,
			BookedCount:     0,
		}
	}

	return result
}

func generateRandom(max int) int {
	return int(time.Now().UnixNano() % int64(max))
}
