package controller

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	acnService "myanmar-property/backend/05-acn-service/service"
	"myanmar-property/backend/07-common"
)

// ACNController ACN分佣控制器
type ACNController struct {
	service acnService.ACNService
}

// NewACNController 创建ACN控制器
func NewACNController(svc acnService.ACNService) *ACNController {
	return &ACNController{service: svc}
}

// RegisterRoutes 注册路由
func (c *ACNController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	group := r.Group("/acn")

	// 无需认证
	group.GET("/roles", c.GetRoles)

	// 需要认证
	auth := group.Group("")
	auth.Use(userController.AuthMiddleware(jwtSvc, rdb))
	{
		auth.POST("/transactions", c.CreateTransaction)
		auth.GET("/transactions", c.GetTransactions)
		auth.GET("/transactions/:id", c.GetTransaction)
		auth.POST("/transactions/:id/confirm", c.ConfirmTransaction)
		auth.POST("/transactions/:id/reject", c.RejectTransaction)
		auth.POST("/disputes", c.CreateDispute)
		auth.GET("/disputes", c.GetDisputes)
		auth.GET("/commission/statistics", c.GetCommissionStatistics)
		auth.GET("/commission/details", c.GetCommissionDetails)
		auth.GET("/commission/logs", c.GetCommissionDetails) // 别名，兼容前端调用
		auth.GET("/commission/balance", c.GetCommissionBalance)
		auth.GET("/deals", c.GetDeals)
	}

	// 根路径路由别名，兼容API文档定义
	rootAuth := r.Group("")
	rootAuth.Use(userController.AuthMiddleware(jwtSvc, rdb))
	{
		rootAuth.GET("/deals", c.GetDeals)
	}
}

// GetRoles 获取ACN角色列表
func (c *ACNController) GetRoles(ctx *gin.Context) {
	roles, err := c.service.GetRoles(ctx)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, roles)
}

// CreateTransaction 创建成交单
func (c *ACNController) CreateTransaction(ctx *gin.Context) {
	var req acnService.CreateTransactionRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	result, err := c.service.CreateTransaction(ctx, &req)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, result)
}

// GetTransactions 获取成交单列表
func (c *ACNController) GetTransactions(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	status := ctx.DefaultQuery("status", "")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetTransactions(ctx, userID, status, page, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, gin.H{
		"list": list,
		"pagination": gin.H{
			"page":      page,
			"page_size": pageSize,
			"total":     total,
			"has_more":  total > int64(page*pageSize),
		},
	})
}

// GetTransaction 获取成交单详情
func (c *ACNController) GetTransaction(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的成交单ID")
		return
	}

	result, err := c.service.GetTransaction(ctx, id)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, result)
}

// ConfirmTransaction 确认成交单
func (c *ACNController) ConfirmTransaction(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的成交单ID")
		return
	}

	if err := c.service.ConfirmTransaction(ctx, userID, id); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// RejectTransactionRequest 拒绝成交单请求
type RejectTransactionRequest struct {
	Reason string `json:"reason" binding:"required"`
}

// RejectTransaction 拒绝成交单
func (c *ACNController) RejectTransaction(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的成交单ID")
		return
	}

	var req RejectTransactionRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.service.RejectTransaction(ctx, userID, id, req.Reason); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// CreateDispute 创建争议
func (c *ACNController) CreateDispute(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	var req acnService.CreateDisputeRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	req.DisputantID = userID

	if err := c.service.CreateDispute(ctx, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// GetDisputes 获取争议列表
func (c *ACNController) GetDisputes(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	status := ctx.DefaultQuery("status", "")

	list, err := c.service.GetDisputes(ctx, userID, status)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, list)
}

// GetCommissionStatistics 获取分佣统计
func (c *ACNController) GetCommissionStatistics(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	startDateStr := ctx.DefaultQuery("startDate", "")
	endDateStr := ctx.DefaultQuery("endDate", "")

	var startDate, endDate time.Time
	var parseErr error

	if startDateStr != "" {
		startDate, parseErr = time.Parse("2006-01-02", startDateStr)
		if parseErr != nil {
			common.BadRequest(ctx, "startDate格式错误，应为YYYY-MM-DD")
			return
		}
	} else {
		startDate = time.Now().AddDate(0, -1, 0)
	}

	if endDateStr != "" {
		endDate, parseErr = time.Parse("2006-01-02", endDateStr)
		if parseErr != nil {
			common.BadRequest(ctx, "endDate格式错误，应为YYYY-MM-DD")
			return
		}
	} else {
		endDate = time.Now()
	}

	stats, err := c.service.GetCommissionStatistics(ctx, userID, startDate, endDate)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, stats)
}

// GetCommissionDetails 获取分佣明细
func (c *ACNController) GetCommissionDetails(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	status := ctx.DefaultQuery("status", "")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetCommissionDetails(ctx, userID, status, page, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, gin.H{
		"list": list,
		"pagination": gin.H{
			"page":      page,
			"page_size": pageSize,
			"total":     total,
			"has_more":  total > int64(page*pageSize),
		},
	})
}

// GetDeals C端获取成交列表（简化版）
func (c *ACNController) GetDeals(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	status := ctx.DefaultQuery("status", "")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	// 调用service获取成交列表
	list, total, err := c.service.GetTransactions(ctx, userID, status, page, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	// 转换为C端简化格式
	deals := make([]gin.H, 0, len(list))
	for _, tx := range list {
		deal := gin.H{
			"id":          tx.ID,
			"house_id":    tx.HouseID,
			"deal_price":  tx.DealPrice,
			"deal_date":   tx.DealDate,
			"status":      tx.Status,
			"created_at":  tx.CreatedAt,
		}
		deals = append(deals, deal)
	}

	common.Success(ctx, gin.H{
		"list": deals,
		"pagination": gin.H{
			"page":      page,
			"page_size": pageSize,
			"total":     total,
			"has_more":  total > int64(page*pageSize),
		},
	})
}

// GetCommissionBalance 获取当前佣金余额
func (c *ACNController) GetCommissionBalance(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	// 调用service获取统计数据
	startDate := time.Now().AddDate(0, -12, 0) // 查询近12个月
	endDate := time.Now()

	stats, err := c.service.GetCommissionStatistics(ctx, userID, startDate, endDate)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	// 返回余额（已确认但未支付的金额）
	common.Success(ctx, gin.H{
		"balance":  stats.ConfirmedAmount - stats.PaidAmount,
		"currency": "MMK",
	})
}
