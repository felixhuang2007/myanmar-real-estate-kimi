package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	"myanmar-property/backend/07-common"
	promoterService "myanmar-property/backend/14-promoter-service/service"
)

// PromoterController 地推员控制器
type PromoterController struct {
	service promoterService.PromoterService
}

// NewPromoterController 创建地推员控制器
func NewPromoterController(svc promoterService.PromoterService) *PromoterController {
	return &PromoterController{service: svc}
}

// RegisterRoutes 注册路由
func (c *PromoterController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	auth := userController.AuthMiddleware(jwtSvc, rdb)
	promoter := r.Group("/promoter")
	promoter.Use(auth)
	{
		promoter.POST("/register", c.Register)
		promoter.GET("/me", c.GetMyInfo)
		promoter.GET("/referrals", c.GetReferrals)
		promoter.GET("/withdrawals", c.GetWithdrawals)
		promoter.POST("/withdraw", c.RequestWithdrawal)
		promoter.POST("/track", c.TrackReferral)
	}
}

// Register 注册成为地推员
func (c *PromoterController) Register(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	promoter, err := c.service.Register(ctx, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, promoter)
}

// GetMyInfo 获取地推员信息
func (c *PromoterController) GetMyInfo(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	promoter, err := c.service.GetMyInfo(ctx, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, promoter)
}

// GetReferrals 获取推荐记录列表
func (c *PromoterController) GetReferrals(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetReferrals(ctx, userID, page, pageSize)
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

// GetWithdrawals 获取提现记录列表
func (c *PromoterController) GetWithdrawals(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetWithdrawals(ctx, userID, page, pageSize)
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

// RequestWithdrawal 申请提现
func (c *PromoterController) RequestWithdrawal(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	var req promoterService.WithdrawalRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.service.RequestWithdrawal(ctx, userID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// TrackReferralRequest 追踪推荐请求
type TrackReferralRequest struct {
	Code           string `json:"code" binding:"required"`
	ReferredUserID int64  `json:"referred_user_id" binding:"required"`
	UserPhone      string `json:"user_phone"`
}

// TrackReferral 追踪推荐关系
func (c *PromoterController) TrackReferral(ctx *gin.Context) {
	var req TrackReferralRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.service.TrackReferral(ctx, req.Code, req.ReferredUserID, req.UserPhone); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}
