package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	imService "myanmar-property/backend/08-im-service/service"
	"myanmar-property/backend/07-common"
)

// IMController IM控制器
type IMController struct {
	service imService.IMService
}

// NewIMController 创建IM控制器
func NewIMController(svc imService.IMService) *IMController {
	return &IMController{service: svc}
}

// RegisterRoutes 注册路由
func (c *IMController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	group := r.Group("/im")
	group.Use(userController.AuthMiddleware(jwtSvc, rdb))
	{
		group.POST("/token", c.GetIMToken)
		group.GET("/conversations", c.GetConversations)
		group.POST("/conversations", c.GetOrCreateConversation)
		group.DELETE("/conversations/:conversationId", c.DeleteConversation)
		group.POST("/messages", c.SendMessage)
		group.POST("/messages/:id/recall", c.RecallMessage)
		group.POST("/conversations/:id/read", c.MarkAsRead)
		group.PUT("/conversations/:id/pin", c.PinConversation)
		group.GET("/messages", c.GetMessages)
	}

	// 添加根路径路由别名，兼容测试用例
	auth := r.Group("")
	auth.Use(userController.AuthMiddleware(jwtSvc, rdb))
	{
		auth.GET("/conversations", c.GetConversations)
		auth.POST("/conversations", c.GetOrCreateConversation)
		auth.GET("/conversations/:id/messages", c.GetMessagesByConversationID)
		auth.POST("/messages/send", c.SendMessage)
	}
}

// GetIMToken 获取IM Token
func (c *IMController) GetIMToken(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	userType := ctx.DefaultQuery("user_type", "user")

	token, err := c.service.GetIMToken(ctx, userID, userType)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, gin.H{"token": token})
}

// GetConversations 获取会话列表
func (c *IMController) GetConversations(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	userType := ctx.DefaultQuery("user_type", "user")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("pageSize", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	list, total, err := c.service.GetConversations(ctx, userID, userType, page, pageSize)
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

// DeleteConversation 删除会话
func (c *IMController) DeleteConversation(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	convIDStr := ctx.Param("conversationId")
	convID, err := strconv.ParseInt(convIDStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的会话ID")
		return
	}

	if err := c.service.DeleteConversation(ctx, userID, convID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// GetOrCreateConversation 获取或创建会话
func (c *IMController) GetOrCreateConversation(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	var req struct {
		AgentID int64  `json:"agent_id" binding:"required"`
		HouseID *int64 `json:"house_id"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	conv, err := c.service.GetOrCreateConversation(ctx, userID, req.AgentID, req.HouseID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, conv)
}

// SendMessage 发送消息
func (c *IMController) SendMessage(ctx *gin.Context) {
	senderID := ctx.GetInt64("user_id")
	var req struct {
		ConversationID int64  `json:"conversation_id" binding:"required"`
		MessageType    string `json:"message_type" binding:"required"`
		Content        string `json:"content"`
		MediaURL       string `json:"media_url"`
		ExtraData      string `json:"extra_data"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	// Determine sender_type from context (default to "user")
	senderType := "user"
	var extraData map[string]interface{}
	if req.ExtraData != "" {
		extraData = map[string]interface{}{"raw": req.ExtraData}
	}
	if req.MediaURL != "" {
		if extraData == nil {
			extraData = make(map[string]interface{})
		}
		extraData["media_url"] = req.MediaURL
	}
	msg, err := c.service.SendMessage(ctx, senderID, senderType, req.ConversationID, req.MessageType, req.Content, extraData)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, msg)
}

// RecallMessage 撤回消息
func (c *IMController) RecallMessage(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	msgID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的消息ID")
		return
	}
	if err := c.service.RecallMessage(ctx, userID, "user", msgID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// MarkAsRead 标记会话消息已读
func (c *IMController) MarkAsRead(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	convID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的会话ID")
		return
	}
	userType := "user" // default
	if err := c.service.MarkAsRead(ctx, userID, userType, convID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// PinConversation 置顶/取消置顶会话
func (c *IMController) PinConversation(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	convID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的会话ID")
		return
	}
	var req struct {
		IsPinned bool `json:"is_pinned"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	if err := c.service.PinConversation(ctx, userID, convID, req.IsPinned); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, nil)
}

// GetMessages 获取消息列表
func (c *IMController) GetMessages(ctx *gin.Context) {
	convIDStr := ctx.Query("conversationId")
	if convIDStr == "" {
		common.BadRequest(ctx, "conversationId不能为空")
		return
	}
	convID, err := strconv.ParseInt(convIDStr, 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的conversationId")
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

	messages, err := c.service.GetMessages(ctx, convID, 0, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, gin.H{
		"list": messages,
		"pagination": gin.H{
			"page":      page,
			"page_size": pageSize,
		},
	})
}

// GetMessagesByConversationID 从URL路径参数获取会话ID查询消息
func (c *IMController) GetMessagesByConversationID(ctx *gin.Context) {
	convID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的会话ID")
		return
	}

	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("page_size", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	messages, err := c.service.GetMessages(ctx, convID, 0, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	common.Success(ctx, gin.H{
		"list": messages,
		"pagination": gin.H{
			"page":       page,
			"page_size":  pageSize,
			"has_more":   len(messages) == pageSize,
		},
	})
}
