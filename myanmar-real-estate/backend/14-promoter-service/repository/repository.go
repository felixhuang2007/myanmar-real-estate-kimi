package repository

import (
	"context"

	"gorm.io/gorm"

	"myanmar-property/backend/14-promoter-service/model"
)

// PromoterRepository 地推员数据访问接口
type PromoterRepository interface {
	Create(ctx context.Context, promoter *model.Promoter) error
	FindByUserID(ctx context.Context, userID int64) (*model.Promoter, error)
	FindByCode(ctx context.Context, code string) (*model.Promoter, error)
	Update(ctx context.Context, promoter *model.Promoter) error
	GetStats(ctx context.Context, promoterID int64) (*model.Promoter, error)
	CreateReferral(ctx context.Context, record *model.ReferralRecord) error
	GetReferrals(ctx context.Context, promoterID int64, page, pageSize int) ([]*model.ReferralRecord, int64, error)
	CountReferralsByCode(ctx context.Context, code string) (int64, error)
	CreateWithdrawal(ctx context.Context, record *model.WithdrawalRecord) error
	GetWithdrawals(ctx context.Context, promoterID int64, page, pageSize int) ([]*model.WithdrawalRecord, int64, error)
	UpdateBalance(ctx context.Context, promoterID int64, earnedAmount int64) error
}

type promoterRepository struct {
	db *gorm.DB
}

// NewPromoterRepository 创建地推员Repository
func NewPromoterRepository(db *gorm.DB) PromoterRepository {
	return &promoterRepository{db: db}
}

func (r *promoterRepository) Create(ctx context.Context, promoter *model.Promoter) error {
	return r.db.WithContext(ctx).Create(promoter).Error
}

func (r *promoterRepository) FindByUserID(ctx context.Context, userID int64) (*model.Promoter, error) {
	var promoter model.Promoter
	err := r.db.WithContext(ctx).Where("user_id = ?", userID).First(&promoter).Error
	if err != nil {
		return nil, err
	}
	return &promoter, nil
}

func (r *promoterRepository) FindByCode(ctx context.Context, code string) (*model.Promoter, error) {
	var promoter model.Promoter
	err := r.db.WithContext(ctx).Where("code = ?", code).First(&promoter).Error
	if err != nil {
		return nil, err
	}
	return &promoter, nil
}

func (r *promoterRepository) Update(ctx context.Context, promoter *model.Promoter) error {
	return r.db.WithContext(ctx).Save(promoter).Error
}

func (r *promoterRepository) GetStats(ctx context.Context, promoterID int64) (*model.Promoter, error) {
	var promoter model.Promoter
	err := r.db.WithContext(ctx).Where("id = ?", promoterID).First(&promoter).Error
	if err != nil {
		return nil, err
	}
	return &promoter, nil
}

func (r *promoterRepository) CreateReferral(ctx context.Context, record *model.ReferralRecord) error {
	return r.db.WithContext(ctx).Create(record).Error
}

func (r *promoterRepository) GetReferrals(ctx context.Context, promoterID int64, page, pageSize int) ([]*model.ReferralRecord, int64, error) {
	var total int64
	r.db.WithContext(ctx).Model(&model.ReferralRecord{}).Where("promoter_id = ?", promoterID).Count(&total)
	var records []*model.ReferralRecord
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).Where("promoter_id = ?", promoterID).Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&records).Error
	return records, total, err
}

func (r *promoterRepository) CountReferralsByCode(ctx context.Context, code string) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&model.ReferralRecord{}).Where("promoter_code = ?", code).Count(&count).Error
	return count, err
}

func (r *promoterRepository) CreateWithdrawal(ctx context.Context, record *model.WithdrawalRecord) error {
	return r.db.WithContext(ctx).Create(record).Error
}

func (r *promoterRepository) GetWithdrawals(ctx context.Context, promoterID int64, page, pageSize int) ([]*model.WithdrawalRecord, int64, error) {
	var total int64
	r.db.WithContext(ctx).Model(&model.WithdrawalRecord{}).Where("promoter_id = ?", promoterID).Count(&total)
	var records []*model.WithdrawalRecord
	offset := (page - 1) * pageSize
	err := r.db.WithContext(ctx).Where("promoter_id = ?", promoterID).Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&records).Error
	return records, total, err
}

func (r *promoterRepository) UpdateBalance(ctx context.Context, promoterID int64, earnedAmount int64) error {
	return r.db.WithContext(ctx).Model(&model.Promoter{}).Where("id = ?", promoterID).Updates(map[string]interface{}{
		"total_commission": gorm.Expr("total_commission + ?", earnedAmount),
		"valid_referrals":  gorm.Expr("valid_referrals + 1"),
		"total_referrals":  gorm.Expr("total_referrals + 1"),
	}).Error
}
