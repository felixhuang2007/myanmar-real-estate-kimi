package repository

import (
	"context"

	"gorm.io/gorm"

	model "myanmar-property/backend/09-verification-service"
)

// VerificationRepository 验真数据访问接口
type VerificationRepository interface {
	// 任务
	CreateTask(ctx context.Context, task *model.VerificationTask) error
	GetTaskByID(ctx context.Context, id int64) (*model.VerificationTask, error)
	GetTaskByCode(ctx context.Context, code string) (*model.VerificationTask, error)
	GetTasksByHouse(ctx context.Context, houseID int64) ([]*model.VerificationTask, error)
	GetTasksByAssignee(ctx context.Context, assigneeID int64, status string, page, pageSize int) ([]*model.VerificationTask, int64, error)
	GetPendingTasks(ctx context.Context, page, pageSize int) ([]*model.VerificationTask, int64, error)
	UpdateTask(ctx context.Context, task *model.VerificationTask) error
	
	// 检查项
	CreateItem(ctx context.Context, item *model.VerificationItem) error
	GetItemsByTask(ctx context.Context, taskID int64) ([]*model.VerificationItem, error)
	UpdateItem(ctx context.Context, item *model.VerificationItem) error
	
	// 照片
	CreatePhoto(ctx context.Context, photo *model.VerificationPhoto) error
	GetPhotosByTask(ctx context.Context, taskID int64) ([]*model.VerificationPhoto, error)
}

// verificationRepository 实现
type verificationRepository struct {
	db *gorm.DB
}

// NewVerificationRepository 创建验真仓储
func NewVerificationRepository(db *gorm.DB) VerificationRepository {
	return &verificationRepository{db: db}
}

// CreateTask 创建验真任务
func (r *verificationRepository) CreateTask(ctx context.Context, task *model.VerificationTask) error {
	return r.db.WithContext(ctx).Create(task).Error
}

// GetTaskByID 根据ID获取任务
func (r *verificationRepository) GetTaskByID(ctx context.Context, id int64) (*model.VerificationTask, error) {
	var task model.VerificationTask
	err := r.db.WithContext(ctx).First(&task, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &task, err
}

// GetTaskByCode 根据编码获取任务
func (r *verificationRepository) GetTaskByCode(ctx context.Context, code string) (*model.VerificationTask, error) {
	var task model.VerificationTask
	err := r.db.WithContext(ctx).
		Where("task_code = ?", code).
		First(&task).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &task, err
}

// GetTasksByHouse 获取房源的验真任务
func (r *verificationRepository) GetTasksByHouse(ctx context.Context, houseID int64) ([]*model.VerificationTask, error) {
	var tasks []*model.VerificationTask
	err := r.db.WithContext(ctx).
		Where("house_id = ?", houseID).
		Order("created_at DESC").
		Find(&tasks).Error
	return tasks, err
}

// GetTasksByAssignee 获取分配给验真员的任务
func (r *verificationRepository) GetTasksByAssignee(ctx context.Context, assigneeID int64, status string, page, pageSize int) ([]*model.VerificationTask, int64, error) {
	var tasks []*model.VerificationTask
	var total int64
	
	db := r.db.WithContext(ctx).Model(&model.VerificationTask{}).Where("assignee_id = ?", assigneeID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	
	offset := (page - 1) * pageSize
	err := db.Order("deadline_at ASC, created_at DESC").
		Offset(offset).Limit(pageSize).
		Find(&tasks).Error
	
	return tasks, total, err
}

// GetPendingTasks 获取待分配的任务
func (r *verificationRepository) GetPendingTasks(ctx context.Context, page, pageSize int) ([]*model.VerificationTask, int64, error) {
	var tasks []*model.VerificationTask
	var total int64
	
	db := r.db.WithContext(ctx).Model(&model.VerificationTask{}).Where("status = ?", model.VerificationStatusPending)

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}
	
	offset := (page - 1) * pageSize
	err := db.Order("created_at DESC").
		Offset(offset).Limit(pageSize).
		Find(&tasks).Error
	
	return tasks, total, err
}

// UpdateTask 更新任务
func (r *verificationRepository) UpdateTask(ctx context.Context, task *model.VerificationTask) error {
	return r.db.WithContext(ctx).Save(task).Error
}

// CreateItem 创建检查项
func (r *verificationRepository) CreateItem(ctx context.Context, item *model.VerificationItem) error {
	return r.db.WithContext(ctx).Create(item).Error
}

// GetItemsByTask 获取任务的检查项
func (r *verificationRepository) GetItemsByTask(ctx context.Context, taskID int64) ([]*model.VerificationItem, error) {
	var items []*model.VerificationItem
	err := r.db.WithContext(ctx).
		Where("task_id = ?", taskID).
		Order("id ASC").
		Find(&items).Error
	return items, err
}

// UpdateItem 更新检查项
func (r *verificationRepository) UpdateItem(ctx context.Context, item *model.VerificationItem) error {
	return r.db.WithContext(ctx).Save(item).Error
}

// CreatePhoto 创建照片
func (r *verificationRepository) CreatePhoto(ctx context.Context, photo *model.VerificationPhoto) error {
	return r.db.WithContext(ctx).Create(photo).Error
}

// GetPhotosByTask 获取任务的照片
func (r *verificationRepository) GetPhotosByTask(ctx context.Context, taskID int64) ([]*model.VerificationPhoto, error) {
	var photos []*model.VerificationPhoto
	err := r.db.WithContext(ctx).
		Where("task_id = ?", taskID).
		Order("created_at ASC").
		Find(&photos).Error
	return photos, err
}
