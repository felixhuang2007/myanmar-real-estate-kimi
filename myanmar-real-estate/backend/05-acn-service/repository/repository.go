package repository

import (
	"context"

	"gorm.io/gorm"

	"myanmar-property/backend/05-acn-service"
)

// ACNRepository ACN数据访问接口
type ACNRepository interface {
	// 角色
	GetRoles(ctx context.Context) ([]*model.ACNRole, error)

	// 成交单
	CreateTransaction(ctx context.Context, transaction *model.ACNTransaction) error
	GetTransactionByID(ctx context.Context, id int64) (*model.ACNTransaction, error)
	GetTransactionByCode(ctx context.Context, code string) (*model.ACNTransaction, error)
	UpdateTransaction(ctx context.Context, transaction *model.ACNTransaction) error
	GetTransactionsByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNTransaction, int64, error)

	// 分佣明细
	CreateCommissionDetail(ctx context.Context, detail *model.ACNCommissionDetail) error
	UpdateCommissionDetail(ctx context.Context, detail *model.ACNCommissionDetail) error
	GetCommissionDetail(ctx context.Context, transactionID, agentID int64) (*model.ACNCommissionDetail, error)
	GetCommissionDetailsByTransaction(ctx context.Context, transactionID int64) ([]*model.ACNCommissionDetail, error)
	GetCommissionDetailsByAgent(ctx context.Context, agentID int64, status string) ([]*model.ACNCommissionDetail, error)
	GetCommissionDetailsByAgentWithPagination(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNCommissionDetail, int64, error)

	// 争议
	CreateDispute(ctx context.Context, dispute *model.ACNDispute) error
	GetDisputeByID(ctx context.Context, id int64) (*model.ACNDispute, error)
	GetDisputesByAgent(ctx context.Context, agentID int64, status string) ([]*model.ACNDispute, error)
	UpdateDispute(ctx context.Context, dispute *model.ACNDispute) error
}

// acnRepository 实现
type acnRepository struct {
	db *gorm.DB
}

// NewACNRepository 创建ACN仓储
func NewACNRepository(db *gorm.DB) ACNRepository {
	return &acnRepository{db: db}
}

// GetRoles 获取角色列表
func (r *acnRepository) GetRoles(ctx context.Context) ([]*model.ACNRole, error) {
	var roles []*model.ACNRole
	err := r.db.WithContext(ctx).
		Order("sort_order ASC").
		Find(&roles).Error
	return roles, err
}

// CreateTransaction 创建成交单
func (r *acnRepository) CreateTransaction(ctx context.Context, transaction *model.ACNTransaction) error {
	return r.db.WithContext(ctx).Create(transaction).Error
}

// GetTransactionByID 根据ID获取成交单
func (r *acnRepository) GetTransactionByID(ctx context.Context, id int64) (*model.ACNTransaction, error) {
	var transaction model.ACNTransaction
	err := r.db.WithContext(ctx).
		Preload("CommissionDetails").
		First(&transaction, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &transaction, err
}

// GetTransactionByCode 根据编码获取成交单
func (r *acnRepository) GetTransactionByCode(ctx context.Context, code string) (*model.ACNTransaction, error) {
	var transaction model.ACNTransaction
	err := r.db.WithContext(ctx).
		Where("transaction_code = ?", code).
		First(&transaction).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &transaction, err
}

// UpdateTransaction 更新成交单
func (r *acnRepository) UpdateTransaction(ctx context.Context, transaction *model.ACNTransaction) error {
	return r.db.WithContext(ctx).Save(transaction).Error
}

// GetTransactionsByAgent 获取经纪人的成交单
func (r *acnRepository) GetTransactionsByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNTransaction, int64, error) {
	var transactions []*model.ACNTransaction
	var total int64

	db := r.db.WithContext(ctx).Model(&model.ACNTransaction{}).
		Where("entrant_id = ? OR maintainer_id = ? OR introducer_id = ? OR accompanier_id = ? OR closer_id = ?",
			agentID, agentID, agentID, agentID, agentID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("created_at DESC").
		Offset(offset).Limit(pageSize).
		Find(&transactions).Error

	return transactions, total, err
}

// CreateCommissionDetail 创建分佣明细
func (r *acnRepository) CreateCommissionDetail(ctx context.Context, detail *model.ACNCommissionDetail) error {
	return r.db.WithContext(ctx).Create(detail).Error
}

// UpdateCommissionDetail 更新分佣明细
func (r *acnRepository) UpdateCommissionDetail(ctx context.Context, detail *model.ACNCommissionDetail) error {
	return r.db.WithContext(ctx).Save(detail).Error
}

// GetCommissionDetail 获取分佣明细
func (r *acnRepository) GetCommissionDetail(ctx context.Context, transactionID, agentID int64) (*model.ACNCommissionDetail, error) {
	var detail model.ACNCommissionDetail
	err := r.db.WithContext(ctx).
		Where("transaction_id = ? AND agent_id = ?", transactionID, agentID).
		First(&detail).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &detail, err
}

// GetCommissionDetailsByTransaction 获取成交单的分佣明细
func (r *acnRepository) GetCommissionDetailsByTransaction(ctx context.Context, transactionID int64) ([]*model.ACNCommissionDetail, error) {
	var details []*model.ACNCommissionDetail
	err := r.db.WithContext(ctx).
		Where("transaction_id = ?", transactionID).
		Find(&details).Error
	return details, err
}

// GetCommissionDetailsByAgent 获取经纪人的分佣明细
func (r *acnRepository) GetCommissionDetailsByAgent(ctx context.Context, agentID int64, status string) ([]*model.ACNCommissionDetail, error) {
	var details []*model.ACNCommissionDetail
	db := r.db.WithContext(ctx).Where("agent_id = ?", agentID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	err := db.Order("created_at DESC").Find(&details).Error
	return details, err
}

// GetCommissionDetailsByAgentWithPagination 分页获取经纪人的分佣明细
func (r *acnRepository) GetCommissionDetailsByAgentWithPagination(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNCommissionDetail, int64, error) {
	var details []*model.ACNCommissionDetail
	var total int64

	db := r.db.WithContext(ctx).Model(&model.ACNCommissionDetail{}).Where("agent_id = ?", agentID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("created_at DESC").
		Offset(offset).Limit(pageSize).
		Find(&details).Error

	return details, total, err
}

// CreateDispute 创建争议
func (r *acnRepository) CreateDispute(ctx context.Context, dispute *model.ACNDispute) error {
	return r.db.WithContext(ctx).Create(dispute).Error
}

// GetDisputeByID 根据ID获取争议
func (r *acnRepository) GetDisputeByID(ctx context.Context, id int64) (*model.ACNDispute, error) {
	var dispute model.ACNDispute
	err := r.db.WithContext(ctx).First(&dispute, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &dispute, err
}

// GetDisputesByAgent 获取经纪人的争议
func (r *acnRepository) GetDisputesByAgent(ctx context.Context, agentID int64, status string) ([]*model.ACNDispute, error) {
	var disputes []*model.ACNDispute
	db := r.db.WithContext(ctx).Where("disputant_id = ?", agentID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	err := db.Order("created_at DESC").Find(&disputes).Error
	return disputes, err
}

// UpdateDispute 更新争议
func (r *acnRepository) UpdateDispute(ctx context.Context, dispute *model.ACNDispute) error {
	return r.db.WithContext(ctx).Save(dispute).Error
}
