package service

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"time"

	"myanmar-property/backend/05-acn-service"
	"myanmar-property/backend/05-acn-service/repository"
	"myanmar-property/backend/07-common"
)

// ACNService ACN分佣服务接口
type ACNService interface {
	// 角色管理
	GetRoles(ctx context.Context) ([]*model.ACNRole, error)

	// 成交单管理
	CreateTransaction(ctx context.Context, req *CreateTransactionRequest) (*model.ACNTransaction, error)
	GetTransaction(ctx context.Context, transactionID int64) (*model.ACNTransaction, error)
	GetTransactions(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNTransaction, int64, error)
	ConfirmTransaction(ctx context.Context, agentID, transactionID int64) error
	RejectTransaction(ctx context.Context, agentID, transactionID int64, reason string) error

	// 争议处理
	CreateDispute(ctx context.Context, req *CreateDisputeRequest) error
	GetDisputes(ctx context.Context, agentID int64, status string) ([]*model.ACNDispute, error)

	// 分佣统计
	GetCommissionStatistics(ctx context.Context, agentID int64, startDate, endDate time.Time) (*CommissionStatistics, error)
	GetCommissionDetails(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNCommissionDetail, int64, error)

	// 结算
	ProcessSettlement(ctx context.Context, transactionID int64) error
}

// 请求/响应结构
type CreateTransactionRequest struct {
	HouseID          int64         `json:"house_id" binding:"required"`
	DealPrice        int64         `json:"deal_price" binding:"required,gt=0"`
	CommissionAmount int64         `json:"commission_amount" binding:"required,gt=0"`
	DealDate         string        `json:"deal_date" binding:"required"`
	ContractImage    string        `json:"contract_image" binding:"required"`
	Participants     []ParticipantInput `json:"participants" binding:"required,min=1"`
}

type ParticipantInput struct {
	Role    string  `json:"role" binding:"required,oneof=ENTRANT MAINTAINER INTRODUCER ACCOMPANIER CLOSER"`
	AgentID int64   `json:"agent_id" binding:"required"`
	Ratio   int64   `json:"ratio" binding:"required,gt=0"` // 存储为百分比*100，如30.5%存为3050
}

type CreateDisputeRequest struct {
	TransactionID int64    `json:"transaction_id" binding:"required"`
	DisputantID   int64    `json:"disputant_id"`
	DisputeType   string   `json:"dispute_type" binding:"required"`
	Reason        string   `json:"reason" binding:"required"`
	Evidence      []string `json:"evidence,omitempty"`
}

type CommissionStatistics struct {
	TotalCommission  int64          `json:"total_commission"`
	PendingAmount    int64          `json:"pending_amount"`
	ConfirmedAmount  int64          `json:"confirmed_amount"`
	PaidAmount       int64          `json:"paid_amount"`
	ThisMonth        int64          `json:"this_month"`
	LastMonth        int64          `json:"last_month"`
	ByRole           map[string]int64 `json:"by_role"`
}

// acnService 实现
type acnService struct {
	acnRepo  repository.ACNRepository
	config   *common.Config
}

// NewACNService 创建ACN服务
func NewACNService(acnRepo repository.ACNRepository, config *common.Config) ACNService {
	return &acnService{
		acnRepo: acnRepo,
		config:  config,
	}
}

// GetRoles 获取ACN角色列表
func (s *acnService) GetRoles(ctx context.Context) ([]*model.ACNRole, error) {
	return s.acnRepo.GetRoles(ctx)
}

// CreateTransaction 创建成交单
func (s *acnService) CreateTransaction(ctx context.Context, req *CreateTransactionRequest) (*model.ACNTransaction, error) {
	// 解析成交日期
	dealDate, err := time.Parse("2006-01-02", req.DealDate)
	if err != nil {
		return nil, common.NewError(common.ErrCodeValidation, "成交日期格式错误")
	}

	// 验证分佣比例总和 - 使用整数运算，总和必须等于10000（即100%）
	totalRatio := int64(math.Round(s.config.ACN.PlatformRatio * 100)) // 平台比例转为整数
	var closerID int64
	hasCloser := false

	for _, p := range req.Participants {
		totalRatio += p.Ratio
		if p.Role == "CLOSER" {
			closerID = p.AgentID
			hasCloser = true
		}
	}

	// 验证总和必须等于10000（100%）
	if totalRatio != 10000 {
		return nil, common.NewError(common.ErrCodeInvalidCommissionRatio,
			fmt.Sprintf("分佣比例总和必须为100%%，当前为%.2f%%", float64(totalRatio)/100.0))
	}

	if !hasCloser {
		return nil, common.NewError(common.ErrCodeValidation, "必须指定成交人(CLOSER)")
	}

	// 计算各方分佣金额
	calcResult := s.calculateCommission(req.CommissionAmount, req.Participants)

	// 生成成交单编码
	transactionCode := fmt.Sprintf("TX%s%06d", time.Now().Format("20060102"), generateRandom(999999))

	// 获取平台比例（转为整数）
	platformRatio := int64(math.Round(s.config.ACN.PlatformRatio * 100))

	transaction := &model.ACNTransaction{
		TransactionCode:  transactionCode,
		HouseID:          req.HouseID,
		DealPrice:        req.DealPrice,
		CommissionAmount: req.CommissionAmount,
		DealDate:         dealDate,
		ContractImage:    &req.ContractImage,
		CloserID:         closerID,
		CloserRatio:      getRatioByRole(req.Participants, "CLOSER"),
		CloserAmount:     getAmountByRole(calcResult.Participants, "CLOSER"),
		PlatformRatio:    platformRatio,
		PlatformAmount:   calcResult.PlatformAmount,
		Status:           "pending_confirm",
		ReporterID:       closerID, // 成交人申报
	}

	// 设置可选参与者
	for _, p := range req.Participants {
		switch p.Role {
		case "ENTRANT":
			transaction.EntrantID = &p.AgentID
			transaction.EntrantRatio = p.Ratio
			transaction.EntrantAmount = getAmountByRole(calcResult.Participants, p.Role)
		case "MAINTAINER":
			transaction.MaintainerID = &p.AgentID
			transaction.MaintainerRatio = p.Ratio
			transaction.MaintainerAmount = getAmountByRole(calcResult.Participants, p.Role)
		case "INTRODUCER":
			transaction.IntroducerID = &p.AgentID
			transaction.IntroducerRatio = p.Ratio
			transaction.IntroducerAmount = getAmountByRole(calcResult.Participants, p.Role)
		case "ACCOMPANIER":
			transaction.AccompanierID = &p.AgentID
			transaction.AccompanierRatio = p.Ratio
			transaction.AccompanierAmount = getAmountByRole(calcResult.Participants, p.Role)
		}
	}

	// 保存成交单
	if err := s.acnRepo.CreateTransaction(ctx, transaction); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 创建分佣明细
	for _, p := range calcResult.Participants {
		detail := &model.ACNCommissionDetail{
			TransactionID: transaction.ID,
			AgentID:       p.AgentID,
			RoleCode:      p.RoleCode,
			Ratio:         p.Ratio,
			Amount:        p.Amount,
			Status:        "pending",
		}
		if err := s.acnRepo.CreateCommissionDetail(ctx, detail); err != nil {
			common.Error("创建分佣明细失败", common.ErrorField(err))
		}
	}

	return transaction, nil
}

// calculateCommission 计算分佣 - 使用纯整数运算避免浮点数精度问题
func (s *acnService) calculateCommission(totalCommission int64, participants []ParticipantInput) *model.CommissionCalculationResult {
	platformRatio := int64(math.Round(s.config.ACN.PlatformRatio * 100)) // 转为整数
	// 纯整数运算: amount = totalCommission * ratio / 10000
	platformAmount := totalCommission * platformRatio / 10000

	remainingAmount := totalCommission - platformAmount
	_ = remainingAmount // 预留，用于后续分配校验

	var results []model.ParticipantResult
	var totalAllocated int64 = platformAmount

	for i, p := range participants {
		// 纯整数运算: amount = totalCommission * ratio / 10000
		amount := totalCommission * p.Ratio / 10000

		// 最后一个参与者，分配剩余金额，避免舍入误差
		if i == len(participants)-1 {
			amount = totalCommission - totalAllocated
		}
		totalAllocated += amount

		results = append(results, model.ParticipantResult{
			AgentID:  p.AgentID,
			RoleCode: p.Role,
			Ratio:    p.Ratio,
			Amount:   amount,
		})
	}

	return &model.CommissionCalculationResult{
		CommissionAmount: totalCommission,
		PlatformAmount:   platformAmount,
		Participants:     results,
	}
}

// GetTransaction 获取成交单详情
func (s *acnService) GetTransaction(ctx context.Context, transactionID int64) (*model.ACNTransaction, error) {
	transaction, err := s.acnRepo.GetTransactionByID(ctx, transactionID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if transaction == nil {
		return nil, common.NewError(common.ErrCodeACNTransactionNotFound)
	}

	return transaction, nil
}

// GetTransactions 获取成交单列表
func (s *acnService) GetTransactions(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNTransaction, int64, error) {
	return s.acnRepo.GetTransactionsByAgent(ctx, agentID, status, page, pageSize)
}

// ConfirmTransaction 确认成交单
func (s *acnService) ConfirmTransaction(ctx context.Context, agentID, transactionID int64) error {
	transaction, err := s.acnRepo.GetTransactionByID(ctx, transactionID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if transaction == nil {
		return common.NewError(common.ErrCodeACNTransactionNotFound)
	}

	if !transaction.CanConfirm() {
		return common.NewError(common.ErrCodeACNTransactionConfirmed)
	}

	// 检查是否是参与方
	isParticipant := false
	if transaction.EntrantID != nil && *transaction.EntrantID == agentID {
		isParticipant = true
	}
	if transaction.MaintainerID != nil && *transaction.MaintainerID == agentID {
		isParticipant = true
	}
	if transaction.IntroducerID != nil && *transaction.IntroducerID == agentID {
		isParticipant = true
	}
	if transaction.AccompanierID != nil && *transaction.AccompanierID == agentID {
		isParticipant = true
	}
	if transaction.CloserID == agentID {
		isParticipant = true
	}

	if !isParticipant {
		return common.NewError(common.ErrCodeForbidden, "无权确认该成交单")
	}

	// 更新确认状态
	detail, err := s.acnRepo.GetCommissionDetail(ctx, transactionID, agentID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if detail != nil {
		detail.Status = "confirmed"
		now := time.Now()
		detail.ConfirmedAt = &now
		if err := s.acnRepo.UpdateCommissionDetail(ctx, detail); err != nil {
			return common.NewError(common.ErrCodeInternalServer, err.Error())
		}
	}

	// 检查是否所有参与方都已确认
	allConfirmed, err := s.checkAllConfirmed(ctx, transactionID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if allConfirmed {
		transaction.Status = "confirmed"
		now := time.Now()
		transaction.ConfirmedAt = &now

		confirmedBy := make(map[int64]bool)
		confirmedByJSON, _ := json.Marshal(confirmedBy)
		confirmedByStr := string(confirmedByJSON)
		transaction.ConfirmedBy = &confirmedByStr

		if err := s.acnRepo.UpdateTransaction(ctx, transaction); err != nil {
			return common.NewError(common.ErrCodeInternalServer, err.Error())
		}
	}

	return nil
}

// checkAllConfirmed 检查是否所有参与方都已确认
func (s *acnService) checkAllConfirmed(ctx context.Context, transactionID int64) (bool, error) {
	details, err := s.acnRepo.GetCommissionDetailsByTransaction(ctx, transactionID)
	if err != nil {
		return false, err
	}

	for _, d := range details {
		if d.Status != "confirmed" && d.Status != "paid" {
			return false, nil
		}
	}

	return true, nil
}

// RejectTransaction 拒绝成交单
func (s *acnService) RejectTransaction(ctx context.Context, agentID, transactionID int64, reason string) error {
	transaction, err := s.acnRepo.GetTransactionByID(ctx, transactionID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if transaction == nil {
		return common.NewError(common.ErrCodeACNTransactionNotFound)
	}

	// 创建争议
	dispute := &model.ACNDispute{
		TransactionID: transactionID,
		DisputantID:   agentID,
		DisputeType:   "reject_transaction",
		Reason:        reason,
		Status:        "pending",
	}

	if err := s.acnRepo.CreateDispute(ctx, dispute); err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 更新成交单状态
	transaction.Status = "disputed"
	return s.acnRepo.UpdateTransaction(ctx, transaction)
}

// CreateDispute 创建争议
func (s *acnService) CreateDispute(ctx context.Context, req *CreateDisputeRequest) error {
	transaction, err := s.acnRepo.GetTransactionByID(ctx, req.TransactionID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if transaction == nil {
		return common.NewError(common.ErrCodeACNTransactionNotFound)
	}

	if transaction.Status == "settled" {
		return common.NewError(common.ErrCodeValidation, "已结算的成交单不能发起争议")
	}

	evidenceJSON, _ := json.Marshal(req.Evidence)

	dispute := &model.ACNDispute{
		TransactionID: req.TransactionID,
		DisputantID:   req.DisputantID,
		DisputeType:   req.DisputeType,
		Reason:        req.Reason,
		Evidence:      func() *string { s := string(evidenceJSON); return &s }(),
		Status:        "pending",
	}

	if err := s.acnRepo.CreateDispute(ctx, dispute); err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 更新成交单状态
	transaction.Status = "disputed"
	return s.acnRepo.UpdateTransaction(ctx, transaction)
}

// GetDisputes 获取争议列表
func (s *acnService) GetDisputes(ctx context.Context, agentID int64, status string) ([]*model.ACNDispute, error) {
	return s.acnRepo.GetDisputesByAgent(ctx, agentID, status)
}

// GetCommissionStatistics 获取分佣统计
func (s *acnService) GetCommissionStatistics(ctx context.Context, agentID int64, startDate, endDate time.Time) (*CommissionStatistics, error) {
	stats := &CommissionStatistics{
		ByRole: make(map[string]int64),
	}

	details, err := s.acnRepo.GetCommissionDetailsByAgent(ctx, agentID, "")
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	now := time.Now()
	thisMonth := now.Month()
	thisYear := now.Year()
	lastMonth := thisMonth - 1
	lastYear := thisYear
	if lastMonth == 0 {
		lastMonth = 12
		lastYear--
	}

	for _, d := range details {
		stats.TotalCommission += d.Amount

		switch d.Status {
		case "pending":
			stats.PendingAmount += d.Amount
		case "confirmed":
			stats.ConfirmedAmount += d.Amount
		case "paid":
			stats.PaidAmount += d.Amount
		}

		// 按角色统计
		stats.ByRole[d.RoleCode] += d.Amount

		// 获取成交单日期
		transaction, _ := s.acnRepo.GetTransactionByID(ctx, d.TransactionID)
		if transaction != nil {
			dealMonth := transaction.DealDate.Month()
			dealYear := transaction.DealDate.Year()

			if dealMonth == thisMonth && dealYear == thisYear {
				stats.ThisMonth += d.Amount
			}
			if dealMonth == lastMonth && dealYear == lastYear {
				stats.LastMonth += d.Amount
			}
		}
	}

	return stats, nil
}

// GetCommissionDetails 获取分佣明细
func (s *acnService) GetCommissionDetails(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*model.ACNCommissionDetail, int64, error) {
	return s.acnRepo.GetCommissionDetailsByAgentWithPagination(ctx, agentID, status, page, pageSize)
}

// ProcessSettlement 处理结算
func (s *acnService) ProcessSettlement(ctx context.Context, transactionID int64) error {
	transaction, err := s.acnRepo.GetTransactionByID(ctx, transactionID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if transaction == nil {
		return common.NewError(common.ErrCodeACNTransactionNotFound)
	}

	if transaction.Status != "confirmed" {
		return common.NewError(common.ErrCodeValidation, "只有已确认的成交单才能结算")
	}

	// 更新所有分佣明细状态
	details, err := s.acnRepo.GetCommissionDetailsByTransaction(ctx, transactionID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	now := time.Now()

	for _, d := range details {
		d.Status = "paid"
		d.PaidAt = &now
		if err := s.acnRepo.UpdateCommissionDetail(ctx, d); err != nil {
			return common.NewError(common.ErrCodeInternalServer, err.Error())
		}
	}

	// 更新成交单状态
	transaction.Status = "settled"
	transaction.SettledAt = &now
	return s.acnRepo.UpdateTransaction(ctx, transaction)
}

// 辅助函数

func getRatioByRole(participants []ParticipantInput, role string) int64 {
	for _, p := range participants {
		if p.Role == role {
			return p.Ratio
		}
	}
	return 0
}

func getAmountByRole(results []model.ParticipantResult, role string) int64 {
	for _, r := range results {
		if r.RoleCode == role {
			return r.Amount
		}
	}
	return 0
}

func generateRandom(max int) int {
	return int(time.Now().UnixNano() % int64(max))
}

