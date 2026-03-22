package service

import (
	"context"
	"fmt"
	"math/rand"

	"myanmar-property/backend/07-common"
	"myanmar-property/backend/14-promoter-service/model"
	"myanmar-property/backend/14-promoter-service/repository"
)

// WithdrawalRequest 提现请求
type WithdrawalRequest struct {
	Amount      int64  `json:"amount" binding:"required,gt=0"`
	Method      string `json:"method" binding:"required"`
	AccountInfo string `json:"account_info" binding:"required"`
}

// PromoterService 地推员服务接口
type PromoterService interface {
	Register(ctx context.Context, userID int64) (*model.Promoter, error)
	GetMyInfo(ctx context.Context, userID int64) (*model.Promoter, error)
	GetReferrals(ctx context.Context, userID int64, page, pageSize int) ([]*model.ReferralRecord, int64, error)
	GetWithdrawals(ctx context.Context, userID int64, page, pageSize int) ([]*model.WithdrawalRecord, int64, error)
	RequestWithdrawal(ctx context.Context, userID int64, req *WithdrawalRequest) error
	TrackReferral(ctx context.Context, code string, referredUserID int64, userPhone string) error
}

type promoterService struct {
	repo   repository.PromoterRepository
	config *common.Config
}

// NewPromoterService 创建地推员服务
func NewPromoterService(repo repository.PromoterRepository, config *common.Config) PromoterService {
	return &promoterService{repo: repo, config: config}
}

// Register 注册成为地推员
func (s *promoterService) Register(ctx context.Context, userID int64) (*model.Promoter, error) {
	// Check if already registered
	existing, err := s.repo.FindByUserID(ctx, userID)
	if err == nil && existing != nil {
		return existing, nil
	}

	// Generate unique invite code
	code := fmt.Sprintf("P%07d", rand.Intn(9999999))

	promoter := &model.Promoter{
		UserID:    userID,
		Code:      code,
		QRCodeURL: "",
		Status:    "active",
	}

	if err := s.repo.Create(ctx, promoter); err != nil {
		return nil, err
	}
	return promoter, nil
}

// GetMyInfo 获取地推员自己的信息
func (s *promoterService) GetMyInfo(ctx context.Context, userID int64) (*model.Promoter, error) {
	promoter, err := s.repo.FindByUserID(ctx, userID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeNotFound, "地推员不存在")
	}
	return promoter, nil
}

// GetReferrals 获取推荐记录列表
func (s *promoterService) GetReferrals(ctx context.Context, userID int64, page, pageSize int) ([]*model.ReferralRecord, int64, error) {
	promoter, err := s.repo.FindByUserID(ctx, userID)
	if err != nil {
		return nil, 0, common.NewError(common.ErrCodeNotFound, "地推员不存在")
	}
	return s.repo.GetReferrals(ctx, promoter.ID, page, pageSize)
}

// GetWithdrawals 获取提现记录列表
func (s *promoterService) GetWithdrawals(ctx context.Context, userID int64, page, pageSize int) ([]*model.WithdrawalRecord, int64, error) {
	promoter, err := s.repo.FindByUserID(ctx, userID)
	if err != nil {
		return nil, 0, common.NewError(common.ErrCodeNotFound, "地推员不存在")
	}
	return s.repo.GetWithdrawals(ctx, promoter.ID, page, pageSize)
}

// RequestWithdrawal 申请提现
func (s *promoterService) RequestWithdrawal(ctx context.Context, userID int64, req *WithdrawalRequest) error {
	promoter, err := s.repo.FindByUserID(ctx, userID)
	if err != nil {
		return common.NewError(common.ErrCodeNotFound, "地推员不存在")
	}

	// Check available balance
	available := promoter.TotalCommission - promoter.PaidCommission - promoter.PendingWithdrawal
	if available < req.Amount {
		return common.NewError(common.ErrCodeInsufficientFunds)
	}

	// Create withdrawal record
	record := &model.WithdrawalRecord{
		PromoterID:  promoter.ID,
		Amount:      req.Amount,
		Method:      req.Method,
		AccountInfo: req.AccountInfo,
		Status:      "pending",
	}
	if err := s.repo.CreateWithdrawal(ctx, record); err != nil {
		return err
	}

	// Update pending withdrawal amount
	promoter.PendingWithdrawal += req.Amount
	return s.repo.Update(ctx, promoter)
}

// TrackReferral 记录推荐关系
func (s *promoterService) TrackReferral(ctx context.Context, code string, referredUserID int64, userPhone string) error {
	promoter, err := s.repo.FindByCode(ctx, code)
	if err != nil {
		return common.NewError(common.ErrCodeNotFound, "推荐码不存在")
	}

	const commissionAmount int64 = 50000

	record := &model.ReferralRecord{
		PromoterID:     promoter.ID,
		PromoterCode:   code,
		ReferredUserID: referredUserID,
		UserPhone:      userPhone,
		Commission:     commissionAmount,
		Status:         "confirmed",
	}
	if err := s.repo.CreateReferral(ctx, record); err != nil {
		return err
	}

	return s.repo.UpdateBalance(ctx, promoter.ID, commissionAmount)
}
