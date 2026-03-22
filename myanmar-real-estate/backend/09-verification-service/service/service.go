package service

import (
	"context"
	"encoding/json"
	"fmt"
	"time"
	
	model "myanmar-property/backend/09-verification-service"
	"myanmar-property/backend/09-verification-service/repository"
	common "myanmar-property/backend/07-common"
)

// VerificationService 验真服务接口
type VerificationService interface {
	// 任务管理
	CreateTask(ctx context.Context, houseID int64, taskType string) (*model.VerificationTask, error)
	GetTask(ctx context.Context, taskID int64) (*model.VerificationTask, error)
	GetTasksByHouse(ctx context.Context, houseID int64) ([]*model.VerificationTask, error)
	GetMyTasks(ctx context.Context, assigneeID int64, status string, page, pageSize int) ([]*model.VerificationTask, int64, error)
	
	// 任务分配
	ClaimTask(ctx context.Context, assigneeID, taskID int64) error
	AssignTask(ctx context.Context, taskID, assigneeID int64, deadline time.Time) error
	
	// 验真执行
	SubmitVerification(ctx context.Context, assigneeID, taskID int64, result string, score int, report string, items []VerificationItemInput) error
	GetVerificationReport(ctx context.Context, taskID int64) (*VerificationReport, error)
	
	// 照片
	UploadPhoto(ctx context.Context, taskID int64, photoType, photoURL string, lat, lng float64) error
	GetPhotos(ctx context.Context, taskID int64) ([]*model.VerificationPhoto, error)
}

// VerificationItemInput 检查项输入
type VerificationItemInput struct {
	ItemName string   `json:"item_name"`
	Status   string   `json:"status"`
	Remark   string   `json:"remark,omitempty"`
	Photos   []string `json:"photos,omitempty"`
}

// VerificationReport 验真报告
type VerificationReport struct {
	TaskID     int64                  `json:"task_id"`
	HouseID    int64                  `json:"house_id"`
	Status     string                 `json:"status"`
	Result     string                 `json:"result,omitempty"`
	Score      int                    `json:"score,omitempty"`
	Report     string                 `json:"report,omitempty"`
	Items      []*model.VerificationItem `json:"items"`
	Photos     []*model.VerificationPhoto `json:"photos"`
	CreatedAt  time.Time              `json:"created_at"`
	CompletedAt *time.Time            `json:"completed_at,omitempty"`
}

// verificationService 实现
type verificationService struct {
	verificationRepo repository.VerificationRepository
	config           *common.Config
}

// NewVerificationService 创建验真服务
func NewVerificationService(verificationRepo repository.VerificationRepository, config *common.Config) VerificationService {
	return &verificationService{
		verificationRepo: verificationRepo,
		config:           config,
	}
}

// CreateTask 创建验真任务
func (s *verificationService) CreateTask(ctx context.Context, houseID int64, taskType string) (*model.VerificationTask, error) {
	// 生成任务编码
	taskCode := fmt.Sprintf("VER%s%d", time.Now().Format("20060102"), houseID)
	
	task := &model.VerificationTask{
		TaskCode: taskCode,
		HouseID:  houseID,
		Type:     taskType,
		Status:   model.VerificationStatusPending,
	}
	
	if taskType == "" {
		task.Type = model.VerificationTypeBasic
	}
	
	if err := s.verificationRepo.CreateTask(ctx, task); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 创建默认检查项
	for _, config := range model.VerificationItemConfigs {
		item := &model.VerificationItem{
			TaskID:     task.ID,
			Category:   config.Category,
			ItemName:   config.ItemName,
			IsRequired: config.IsRequired,
			Status:     "pending",
		}
		if err := s.verificationRepo.CreateItem(ctx, item); err != nil {
			common.Error("创建检查项失败", common.ErrorField(err))
		}
	}
	
	return task, nil
}

// GetTask 获取任务详情
func (s *verificationService) GetTask(ctx context.Context, taskID int64) (*model.VerificationTask, error) {
	task, err := s.verificationRepo.GetTaskByID(ctx, taskID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if task == nil {
		return nil, common.NewError(common.ErrCodeNotFound, "验真任务不存在")
	}
	return task, nil
}

// GetTasksByHouse 获取房源的验真任务
func (s *verificationService) GetTasksByHouse(ctx context.Context, houseID int64) ([]*model.VerificationTask, error) {
	return s.verificationRepo.GetTasksByHouse(ctx, houseID)
}

// GetMyTasks 获取我的验真任务
func (s *verificationService) GetMyTasks(ctx context.Context, assigneeID int64, status string, page, pageSize int) ([]*model.VerificationTask, int64, error) {
	return s.verificationRepo.GetTasksByAssignee(ctx, assigneeID, status, page, pageSize)
}

// ClaimTask 领取任务
func (s *verificationService) ClaimTask(ctx context.Context, assigneeID, taskID int64) error {
	task, err := s.verificationRepo.GetTaskByID(ctx, taskID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if task == nil {
		return common.NewError(common.ErrCodeNotFound, "验真任务不存在")
	}
	
	if !task.IsPending() {
		return common.NewError(common.ErrCodeValidation, "任务已被领取或已完成")
	}
	
	task.Status = model.VerificationStatusAssigned
	task.AssigneeID = &assigneeID
	now := time.Now()
	task.AssignedAt = &now
	deadline := now.Add(48 * time.Hour)
	task.DeadlineAt = &deadline
	
	return s.verificationRepo.UpdateTask(ctx, task)
}

// AssignTask 分配任务（管理员）
func (s *verificationService) AssignTask(ctx context.Context, taskID, assigneeID int64, deadline time.Time) error {
	task, err := s.verificationRepo.GetTaskByID(ctx, taskID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if task == nil {
		return common.NewError(common.ErrCodeNotFound, "验真任务不存在")
	}
	
	task.Status = model.VerificationStatusAssigned
	task.AssigneeID = &assigneeID
	now := time.Now()
	task.AssignedAt = &now
	task.DeadlineAt = &deadline
	
	return s.verificationRepo.UpdateTask(ctx, task)
}

// SubmitVerification 提交验真结果
func (s *verificationService) SubmitVerification(ctx context.Context, assigneeID, taskID int64, result string, score int, report string, items []VerificationItemInput) error {
	task, err := s.verificationRepo.GetTaskByID(ctx, taskID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if task == nil {
		return common.NewError(common.ErrCodeNotFound, "验真任务不存在")
	}
	
	if task.AssigneeID == nil || *task.AssigneeID != assigneeID {
		return common.NewError(common.ErrCodeForbidden, "无权提交该任务")
	}
	
	if task.IsCompleted() {
		return common.NewError(common.ErrCodeValidation, "任务已完成")
	}
	
	// 更新检查项
	for _, itemInput := range items {
		// 查找对应的检查项
		existingItems, _ := s.verificationRepo.GetItemsByTask(ctx, taskID)
		for _, existingItem := range existingItems {
			if existingItem.ItemName == itemInput.ItemName {
				existingItem.Status = itemInput.Status
				if itemInput.Remark != "" {
					existingItem.Remark = &itemInput.Remark
				}
				if len(itemInput.Photos) > 0 {
					photosJSON, _ := json.Marshal(itemInput.Photos)
					photosStr := string(photosJSON)
					existingItem.Photos = &photosStr
				}
				existingItem.CheckedAt = func() *time.Time { t := time.Now(); return &t }()
				s.verificationRepo.UpdateItem(ctx, existingItem)
				break
			}
		}
	}
	
	// 更新任务
	task.Status = model.VerificationStatusCompleted
	task.Result = &result
	task.Score = &score
	if report != "" {
		task.Report = &report
	}
	now := time.Now()
	task.CompletedAt = &now
	
	return s.verificationRepo.UpdateTask(ctx, task)
}

// GetVerificationReport 获取验真报告
func (s *verificationService) GetVerificationReport(ctx context.Context, taskID int64) (*VerificationReport, error) {
	task, err := s.verificationRepo.GetTaskByID(ctx, taskID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if task == nil {
		return nil, common.NewError(common.ErrCodeNotFound, "验真任务不存在")
	}
	
	items, err := s.verificationRepo.GetItemsByTask(ctx, taskID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	photos, err := s.verificationRepo.GetPhotosByTask(ctx, taskID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	report := &VerificationReport{
		TaskID:      task.ID,
		HouseID:     task.HouseID,
		Status:      task.Status,
		Items:       items,
		Photos:      photos,
		CreatedAt:   task.CreatedAt,
	}
	
	if task.Result != nil {
		report.Result = *task.Result
	}
	if task.Score != nil {
		report.Score = *task.Score
	}
	if task.Report != nil {
		report.Report = *task.Report
	}
	if task.CompletedAt != nil {
		report.CompletedAt = task.CompletedAt
	}
	
	return report, nil
}

// UploadPhoto 上传验真照片
func (s *verificationService) UploadPhoto(ctx context.Context, taskID int64, photoType, photoURL string, lat, lng float64) error {
	task, err := s.verificationRepo.GetTaskByID(ctx, taskID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	if task == nil {
		return common.NewError(common.ErrCodeNotFound, "验真任务不存在")
	}
	
	photo := &model.VerificationPhoto{
		TaskID:    taskID,
		PhotoType: photoType,
		PhotoURL:  photoURL,
		TakenAt:   func() *time.Time { t := time.Now(); return &t }(),
	}
	
	if lat != 0 && lng != 0 {
		photo.Latitude = &lat
		photo.Longitude = &lng
	}
	
	return s.verificationRepo.CreatePhoto(ctx, photo)
}

// GetPhotos 获取验真照片
func (s *verificationService) GetPhotos(ctx context.Context, taskID int64) ([]*model.VerificationPhoto, error) {
	return s.verificationRepo.GetPhotosByTask(ctx, taskID)
}
