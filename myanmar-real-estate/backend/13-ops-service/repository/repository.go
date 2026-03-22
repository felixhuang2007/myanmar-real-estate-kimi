package repository

import (
	"context"

	"gorm.io/gorm"

	model "myanmar-property/backend/13-ops-service"
)

// BannerRepository 横幅广告数据访问接口
type BannerRepository interface {
	List(ctx context.Context, position, status string, page, pageSize int) ([]*model.Banner, int64, error)
	GetByID(ctx context.Context, id int64) (*model.Banner, error)
	Create(ctx context.Context, banner *model.Banner) error
	Update(ctx context.Context, banner *model.Banner) error
	Delete(ctx context.Context, id int64) error
	UpdateStatus(ctx context.Context, id int64, status string) error
}

type bannerRepository struct {
	db *gorm.DB
}

func NewBannerRepository(db *gorm.DB) BannerRepository {
	return &bannerRepository{db: db}
}

func (r *bannerRepository) List(ctx context.Context, position, status string, page, pageSize int) ([]*model.Banner, int64, error) {
	query := r.db.WithContext(ctx).Model(&model.Banner{})
	if position != "" {
		query = query.Where("position = ?", position)
	}
	if status != "" {
		query = query.Where("status = ?", status)
	}
	var total int64
	query.Count(&total)
	var banners []*model.Banner
	offset := (page - 1) * pageSize
	err := query.Order("sort_order ASC, created_at DESC").Offset(offset).Limit(pageSize).Find(&banners).Error
	return banners, total, err
}

func (r *bannerRepository) GetByID(ctx context.Context, id int64) (*model.Banner, error) {
	var banner model.Banner
	err := r.db.WithContext(ctx).First(&banner, id).Error
	if err != nil {
		return nil, err
	}
	return &banner, nil
}

func (r *bannerRepository) Create(ctx context.Context, banner *model.Banner) error {
	return r.db.WithContext(ctx).Create(banner).Error
}

func (r *bannerRepository) Update(ctx context.Context, banner *model.Banner) error {
	return r.db.WithContext(ctx).Save(banner).Error
}

func (r *bannerRepository) Delete(ctx context.Context, id int64) error {
	return r.db.WithContext(ctx).Delete(&model.Banner{}, id).Error
}

func (r *bannerRepository) UpdateStatus(ctx context.Context, id int64, status string) error {
	return r.db.WithContext(ctx).Model(&model.Banner{}).Where("id = ?", id).Update("status", status).Error
}
