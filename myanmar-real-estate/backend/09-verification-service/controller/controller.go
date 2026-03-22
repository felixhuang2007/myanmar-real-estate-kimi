package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	"myanmar-property/backend/07-common"
	verificationService "myanmar-property/backend/09-verification-service/service"
)

// VerificationController 验真控制器
type VerificationController struct {
	service verificationService.VerificationService
}

// NewVerificationController 创建验真控制器
func NewVerificationController(svc verificationService.VerificationService) *VerificationController {
	return &VerificationController{service: svc}
}

// RegisterRoutes 注册路由
func (c *VerificationController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	group := r.Group("/verification")

	// 无需认证
	group.GET("/reports/:houseId", c.GetReport)

	// 需要认证
	auth := group.Group("")
	auth.Use(userController.AuthMiddleware(jwtSvc, rdb))
	{
		auth.GET("/tasks", c.GetTasks)
		auth.GET("/my-tasks", c.GetMyTasks)
		auth.POST("/tasks/:id/accept", c.AcceptTask)
		auth.POST("/tasks/:id/submit", c.SubmitTask)
		auth.GET("/tasks/:id", c.GetTask)
	}
}

// GetTasks 获取验真任务列表
func (c *VerificationController) GetTasks(ctx *gin.Context) {
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

	list, total, err := c.service.GetMyTasks(ctx, userID, status, page, pageSize)
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

// GetMyTasks 获取我的验真任务
func (c *VerificationController) GetMyTasks(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	status := ctx.DefaultQuery("status", "")

	list, _, err := c.service.GetMyTasks(ctx, userID, status, 1, 100)
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

// AcceptTask 领取/接受验真任务
func (c *VerificationController) AcceptTask(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的任务ID")
		return
	}

	if err := c.service.ClaimTask(ctx, userID, id); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// SubmitTaskRequest 提交验真任务请求
type SubmitTaskRequest struct {
	Result string                                  `json:"result" binding:"required"`
	Score  int                                     `json:"score"`
	Report string                                  `json:"report"`
	Items  []verificationService.VerificationItemInput `json:"items"`
}

// SubmitTask 提交验真任务
func (c *VerificationController) SubmitTask(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的任务ID")
		return
	}

	var req SubmitTaskRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.service.SubmitVerification(ctx, userID, id, req.Result, req.Score, req.Report, req.Items); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// GetTask 获取验真任务详情
func (c *VerificationController) GetTask(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的任务ID")
		return
	}

	task, err := c.service.GetTask(ctx, id)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, task)
}

// GetReport 获取房源验真报告（无需认证）
func (c *VerificationController) GetReport(ctx *gin.Context) {
	houseIDStr := ctx.Param("houseId")
	houseID, err := strconv.ParseInt(houseIDStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	tasks, err := c.service.GetTasksByHouse(ctx, houseID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	if len(tasks) == 0 {
		common.Success(ctx, nil)
		return
	}

	latestTask := tasks[len(tasks)-1]
	report, err := c.service.GetVerificationReport(ctx, latestTask.ID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, report)
}
