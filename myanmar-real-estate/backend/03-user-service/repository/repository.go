package repository

import (
	"context"
	"time"

	"gorm.io/gorm"
	
	"myanmar-property/backend/03-user-service/model"
)

// UserRepository 用户数据访问接口
type UserRepository interface {
	// 基础CRUD
	Create(ctx context.Context, user *model.User) error
	FindByID(ctx context.Context, id int64) (*model.User, error)
	FindByUUID(ctx context.Context, uuid string) (*model.User, error)
	FindByPhone(ctx context.Context, phone string) (*model.User, error)
	Update(ctx context.Context, user *model.User) error
	UpdateLoginInfo(ctx context.Context, userID int64) error
	
	// 用户资料
	GetProfile(ctx context.Context, userID int64) (*model.UserProfile, error)
	CreateOrUpdateProfile(ctx context.Context, profile *model.UserProfile) error
	
	// 实名认证
	GetVerification(ctx context.Context, userID int64) (*model.UserVerification, error)
	CreateVerification(ctx context.Context, verification *model.UserVerification) error
	UpdateVerification(ctx context.Context, verification *model.UserVerification) error
	
	// 验证码
	CreateSMSCode(ctx context.Context, code *model.SMSVerificationCode) error
	GetLatestSMSCode(ctx context.Context, phone, codeType string) (*model.SMSVerificationCode, error)
	MarkSMSCodeUsed(ctx context.Context, id int64) error
	IncrementAttemptCount(ctx context.Context, id int64) error
}

// userRepository 实现
type userRepository struct {
	db *gorm.DB
}

// NewUserRepository 创建用户仓储实例
func NewUserRepository(db *gorm.DB) UserRepository {
	return &userRepository{db: db}
}

// Create 创建用户
func (r *userRepository) Create(ctx context.Context, user *model.User) error {
	return r.db.WithContext(ctx).Create(user).Error
}

// FindByID 根据ID查找用户
func (r *userRepository) FindByID(ctx context.Context, id int64) (*model.User, error) {
	var user model.User
	err := r.db.WithContext(ctx).
		Preload("Profile").
		Preload("Verification").
		First(&user, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &user, err
}

// FindByUUID 根据UUID查找用户
func (r *userRepository) FindByUUID(ctx context.Context, uuid string) (*model.User, error) {
	var user model.User
	err := r.db.WithContext(ctx).
		Preload("Profile").
		Preload("Verification").
		Where("uuid = ?", uuid).
		First(&user).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &user, err
}

// FindByPhone 根据手机号查找用户
func (r *userRepository) FindByPhone(ctx context.Context, phone string) (*model.User, error) {
	var user model.User
	err := r.db.WithContext(ctx).
		Preload("Profile").
		Preload("Verification").
		Where("phone = ?", phone).
		First(&user).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &user, err
}

// Update 更新用户
func (r *userRepository) Update(ctx context.Context, user *model.User) error {
	return r.db.WithContext(ctx).Save(user).Error
}

// UpdateLoginInfo 更新登录信息
func (r *userRepository) UpdateLoginInfo(ctx context.Context, userID int64) error {
	return r.db.WithContext(ctx).
		Model(&model.User{}).
		Where("id = ?", userID).
		Updates(map[string]interface{}{
			"last_login_at": time.Now(),
			"login_count":   gorm.Expr("login_count + 1"),
		}).Error
}

// GetProfile 获取用户资料
func (r *userRepository) GetProfile(ctx context.Context, userID int64) (*model.UserProfile, error) {
	var profile model.UserProfile
	err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		First(&profile).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &profile, err
}

// CreateOrUpdateProfile 创建或更新用户资料
func (r *userRepository) CreateOrUpdateProfile(ctx context.Context, profile *model.UserProfile) error {
	var existing model.UserProfile
	err := r.db.WithContext(ctx).
		Where("user_id = ?", profile.UserID).
		First(&existing).Error
	
	if err == gorm.ErrRecordNotFound {
		return r.db.WithContext(ctx).Create(profile).Error
	}
	
	if err != nil {
		return err
	}
	
	profile.ID = existing.ID
	return r.db.WithContext(ctx).Save(profile).Error
}

// GetVerification 获取实名认证信息
func (r *userRepository) GetVerification(ctx context.Context, userID int64) (*model.UserVerification, error) {
	var verification model.UserVerification
	err := r.db.WithContext(ctx).
		Where("user_id = ?", userID).
		First(&verification).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &verification, err
}

// CreateVerification 创建实名认证
func (r *userRepository) CreateVerification(ctx context.Context, verification *model.UserVerification) error {
	return r.db.WithContext(ctx).Create(verification).Error
}

// UpdateVerification 更新实名认证
func (r *userRepository) UpdateVerification(ctx context.Context, verification *model.UserVerification) error {
	return r.db.WithContext(ctx).Save(verification).Error
}

// CreateSMSCode 创建验证码
func (r *userRepository) CreateSMSCode(ctx context.Context, code *model.SMSVerificationCode) error {
	return r.db.WithContext(ctx).Create(code).Error
}

// GetLatestSMSCode 获取最新验证码
func (r *userRepository) GetLatestSMSCode(ctx context.Context, phone, codeType string) (*model.SMSVerificationCode, error) {
	var code model.SMSVerificationCode
	err := r.db.WithContext(ctx).
		Where("phone = ? AND type = ?", phone, codeType).
		Order("created_at DESC").
		First(&code).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &code, err
}

// MarkSMSCodeUsed 标记验证码已使用
func (r *userRepository) MarkSMSCodeUsed(ctx context.Context, id int64) error {
	now := time.Now()
	return r.db.WithContext(ctx).
		Model(&model.SMSVerificationCode{}).
		Where("id = ?", id).
		Update("used_at", now).Error
}

// IncrementAttemptCount 增加尝试次数
func (r *userRepository) IncrementAttemptCount(ctx context.Context, id int64) error {
	return r.db.WithContext(ctx).
		Model(&model.SMSVerificationCode{}).
		Where("id = ?", id).
		UpdateColumn("attempt_count", gorm.Expr("attempt_count + 1")).Error
}
