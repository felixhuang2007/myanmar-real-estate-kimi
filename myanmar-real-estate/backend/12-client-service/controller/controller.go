package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	"myanmar-property/backend/07-common"
	clientSvc "myanmar-property/backend/12-client-service/service"
)

// ClientController 客户控制器
type ClientController struct {
	service clientSvc.ClientService
}

// NewClientController 创建客户控制器
func NewClientController(svc clientSvc.ClientService) *ClientController {
	return &ClientController{service: svc}
}

// RegisterRoutes 注册路由
func (c *ClientController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	auth := userController.AuthMiddleware(jwtSvc, rdb)
	clients := r.Group("/clients")
	clients.Use(auth)
	{
		clients.GET("", c.GetClients)
		clients.POST("", c.CreateClient)
		clients.GET("/:id", c.GetClient)
		clients.PUT("/:id", c.UpdateClient)
		clients.DELETE("/:id", c.DeleteClient)
		clients.GET("/:id/followups", c.GetFollowUps)
		clients.POST("/:id/followups", c.AddFollowUp)
	}
}

// GetClients 获取客户列表
func (c *ClientController) GetClients(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	status := ctx.DefaultQuery("status", "")
	search := ctx.DefaultQuery("search", "")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetClients(ctx, agentID, status, search, page, pageSize)
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

// CreateClient 创建客户
func (c *ClientController) CreateClient(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	var req clientSvc.CreateClientRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	client, err := c.service.CreateClient(ctx, agentID, &req)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, client)
}

// GetClient 获取客户详情
func (c *ClientController) GetClient(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的客户ID")
		return
	}

	client, err := c.service.GetClient(ctx, id, agentID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, client)
}

// UpdateClient 更新客户信息
func (c *ClientController) UpdateClient(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的客户ID")
		return
	}

	var req clientSvc.UpdateClientRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.service.UpdateClient(ctx, id, agentID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// DeleteClient 删除客户
func (c *ClientController) DeleteClient(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的客户ID")
		return
	}

	if err := c.service.DeleteClient(ctx, id, agentID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// GetFollowUps 获取跟进记录列表
func (c *ClientController) GetFollowUps(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的客户ID")
		return
	}

	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetFollowUps(ctx, id, agentID, page, pageSize)
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

// AddFollowUp 添加跟进记录
func (c *ClientController) AddFollowUp(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	idStr := ctx.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的客户ID")
		return
	}

	var req clientSvc.AddFollowUpRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.service.AddFollowUp(ctx, id, agentID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}
