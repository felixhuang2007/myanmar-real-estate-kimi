package service

import (
	"context"
	"time"

	model "myanmar-property/backend/13-ops-service"
	"myanmar-property/backend/13-ops-service/repository"
)

// BannerService 横幅广告服务接口
type BannerService interface {
	ListBanners(ctx context.Context, position, status string, page, pageSize int) ([]*model.Banner, int64, error)
	GetBanner(ctx context.Context, id int64) (*model.Banner, error)
	CreateBanner(ctx context.Context, req *CreateBannerRequest) (*model.Banner, error)
	UpdateBanner(ctx context.Context, id int64, req *UpdateBannerRequest) (*model.Banner, error)
	DeleteBanner(ctx context.Context, id int64) error
	UpdateBannerStatus(ctx context.Context, id int64, status string) error
}

// CreateBannerRequest 创建横幅请求
type CreateBannerRequest struct {
	Title     string     `json:"title" binding:"required"`
	ImageURL  string     `json:"image_url" binding:"required"`
	LinkValue string     `json:"link_value"`
	LinkType  string     `json:"link_type"`
	Position  string     `json:"position"`
	SortOrder int        `json:"sort_order"`
	IsActive  *bool      `json:"is_active"`
	StartAt   *time.Time `json:"start_at"`
	EndAt     *time.Time `json:"end_at"`
}

// UpdateBannerRequest 更新横幅请求
type UpdateBannerRequest struct {
	Title     string     `json:"title"`
	ImageURL  string     `json:"image_url"`
	LinkValue string     `json:"link_value"`
	LinkType  string     `json:"link_type"`
	Position  string     `json:"position"`
	SortOrder *int       `json:"sort_order"`
	IsActive  *bool      `json:"is_active"`
	StartAt   *time.Time `json:"start_at"`
	EndAt     *time.Time `json:"end_at"`
}

type bannerService struct {
	repo repository.BannerRepository
}

func NewBannerService(repo repository.BannerRepository) BannerService {
	return &bannerService{repo: repo}
}

func (s *bannerService) ListBanners(ctx context.Context, position, status string, page, pageSize int) ([]*model.Banner, int64, error) {
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}
	return s.repo.List(ctx, position, status, page, pageSize)
}

func (s *bannerService) GetBanner(ctx context.Context, id int64) (*model.Banner, error) {
	return s.repo.GetByID(ctx, id)
}

func (s *bannerService) CreateBanner(ctx context.Context, req *CreateBannerRequest) (*model.Banner, error) {
	linkType := req.LinkType
	if linkType == "" {
		linkType = "none"
	}
	position := req.Position
	if position == "" {
		position = "home"
	}
	isActive := true
	if req.IsActive != nil {
		isActive = *req.IsActive
	}

	banner := &model.Banner{
		Title:     req.Title,
		ImageURL:  req.ImageURL,
		LinkValue: req.LinkValue,
		LinkType:  linkType,
		Position:  position,
		SortOrder: req.SortOrder,
		IsActive:  isActive,
		StartAt:   req.StartAt,
		EndAt:     req.EndAt,
	}
	if err := s.repo.Create(ctx, banner); err != nil {
		return nil, err
	}
	return banner, nil
}

func (s *bannerService) UpdateBanner(ctx context.Context, id int64, req *UpdateBannerRequest) (*model.Banner, error) {
	banner, err := s.repo.GetByID(ctx, id)
	if err != nil {
		return nil, err
	}

	if req.Title != "" {
		banner.Title = req.Title
	}
	if req.ImageURL != "" {
		banner.ImageURL = req.ImageURL
	}
	if req.LinkValue != "" {
		banner.LinkValue = req.LinkValue
	}
	if req.LinkType != "" {
		banner.LinkType = req.LinkType
	}
	if req.Position != "" {
		banner.Position = req.Position
	}
	if req.SortOrder != nil {
		banner.SortOrder = *req.SortOrder
	}
	if req.IsActive != nil {
		banner.IsActive = *req.IsActive
	}
	if req.StartAt != nil {
		banner.StartAt = req.StartAt
	}
	if req.EndAt != nil {
		banner.EndAt = req.EndAt
	}

	if err := s.repo.Update(ctx, banner); err != nil {
		return nil, err
	}
	return banner, nil
}

func (s *bannerService) DeleteBanner(ctx context.Context, id int64) error {
	return s.repo.Delete(ctx, id)
}

func (s *bannerService) UpdateBannerStatus(ctx context.Context, id int64, status string) error {
	return s.repo.UpdateStatus(ctx, id, status)
}
