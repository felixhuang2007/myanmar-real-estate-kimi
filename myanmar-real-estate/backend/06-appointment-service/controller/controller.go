package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	appointmentModel "myanmar-property/backend/06-appointment-service"
	appointmentService "myanmar-property/backend/06-appointment-service/service"
	"myanmar-property/backend/07-common"
)

// AppointmentController 预约控制器
type AppointmentController struct {
	service appointmentService.AppointmentService
}

// NewAppointmentController 创建预约控制器
func NewAppointmentController(svc appointmentService.AppointmentService) *AppointmentController {
	return &AppointmentController{service: svc}
}

// RegisterRoutes 注册路由
func (c *AppointmentController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	group := r.Group("/appointments")
	group.Use(userController.AuthMiddleware(jwtSvc, rdb))
	{
		group.POST("", c.CreateAppointment)
		group.GET("", c.GetMyAppointments)
		group.GET("/slots", c.GetAvailableSlots)
		group.GET("/:id", c.GetAppointment)
		group.POST("/:id/confirm", c.ConfirmAppointment)
		group.POST("/:id/cancel", c.CancelAppointment)
		group.POST("/:id/complete", c.CompleteAppointment)
	}
}

// CreateAppointment 创建预约
func (c *AppointmentController) CreateAppointment(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	var req appointmentModel.CreateAppointmentRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	result, err := c.service.CreateAppointment(ctx, userID, &req)
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

// GetMyAppointments 获取我的预约列表
func (c *AppointmentController) GetMyAppointments(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	role := ctx.DefaultQuery("role", "user")
	status := ctx.DefaultQuery("status", "")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetAppointments(ctx, userID, role, status, page, pageSize)
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

// GetAppointment 获取预约详情
func (c *AppointmentController) GetAppointment(ctx *gin.Context) {
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的预约ID")
		return
	}

	result, err := c.service.GetAppointment(ctx, id)
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

// ConfirmAppointment 确认预约
func (c *AppointmentController) ConfirmAppointment(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的预约ID")
		return
	}

	if err := c.service.ConfirmAppointment(ctx, userID, id); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// CancelAppointmentRequest 取消预约请求
type CancelAppointmentRequest struct {
	Reason string `json:"reason"`
}

// CancelAppointment 取消预约
func (c *AppointmentController) CancelAppointment(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的预约ID")
		return
	}

	var req CancelAppointmentRequest
	_ = ctx.ShouldBindJSON(&req)

	if err := c.service.CancelAppointment(ctx, userID, id, req.Reason); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// CompleteAppointmentRequest 完成带看请求
type CompleteAppointmentRequest struct {
	Result   string `json:"result"`
	Feedback string `json:"feedback"`
}

// CompleteAppointment 完成带看
func (c *AppointmentController) CompleteAppointment(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的预约ID")
		return
	}

	var req CompleteAppointmentRequest
	_ = ctx.ShouldBindJSON(&req)

	if err := c.service.CompleteAppointment(ctx, userID, id, req.Result, req.Feedback); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// GetAvailableSlots 获取可用时段
func (c *AppointmentController) GetAvailableSlots(ctx *gin.Context) {
	agentIDStr := ctx.Query("agentId")
	if agentIDStr == "" {
		common.BadRequest(ctx, "agentId不能为空")
		return
	}
	agentID, err := strconv.ParseInt(agentIDStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的agentId")
		return
	}

	date := ctx.Query("date")
	if date == "" {
		common.BadRequest(ctx, "date不能为空")
		return
	}

	slots, err := c.service.GetAvailableSlots(ctx, agentID, date)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, slots)
}
