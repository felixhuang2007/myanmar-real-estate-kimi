package controller

import (
	"context"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"

	"myanmar-property/backend/03-user-service/service"
	"myanmar-property/backend/07-common"
)

// UserController 用户控制器
type UserController struct {
	userService service.UserService
	jwtService  service.JWTService
	redisClient *redis.Client
	db          *gorm.DB
}

// NewUserController 创建控制器
func NewUserController(userService service.UserService, jwtService service.JWTService, redisClient *redis.Client, db ...*gorm.DB) *UserController {
	ctrl := &UserController{
		userService: userService,
		jwtService:  jwtService,
		redisClient: redisClient,
	}
	if len(db) > 0 {
		ctrl.db = db[0]
	}
	return ctrl
}

// RegisterRoutes 注册路由
func (c *UserController) RegisterRoutes(r *gin.RouterGroup) {
	// 公开接口
	auth := r.Group("/auth")
	{
		auth.GET("/send-verification-code", c.SendVerificationCode)
		auth.POST("/send-verification-code", c.SendVerificationCode)
		auth.POST("/register", c.Register)
		auth.POST("/login", c.Login)
		auth.POST("/login-with-password", c.LoginWithPassword)
		auth.POST("/refresh-token", c.RefreshToken)
		auth.POST("/reset-password", c.ResetPassword)
		auth.POST("/logout", AuthMiddleware(c.jwtService, c.redisClient), c.Logout)
	}

	// 需要认证
	users := r.Group("/users")
	users.Use(AuthMiddleware(c.jwtService, c.redisClient))
	{
		users.GET("/me", c.GetCurrentUser)
		users.PUT("/me", c.UpdateProfile)
		users.POST("/me/avatar", c.UploadAvatar)
		users.PUT("/me/password", c.ChangePassword)
		// 添加修改密码路由别名，兼容前端调用
		users.POST("/change-password", c.ChangePassword)

		// 实名认证
		users.POST("/me/verification", c.SubmitVerification)
		users.GET("/me/verification", c.GetVerificationStatus)

		// 收藏
		users.GET("/me/favorites", c.GetFavorites)
		users.POST("/me/favorites", c.AddFavorite)
		users.DELETE("/me/favorites/:house_id", c.RemoveFavorite)
		users.GET("/me/favorites/:house_id/check", c.CheckFavorite)
		// 添加收藏路由别名，兼容前端调用
		users.GET("/favorites", c.GetFavorites)
		users.POST("/favorites", c.AddFavorite)

		// 用户状态
		users.GET("/status", c.GetUserStatus)

		// 上传
		users.POST("/upload/token", c.GetUploadToken)
		users.DELETE("/me/browsing-history", c.ClearBrowsingHistory)
	}

	// 公开用户接口（不需要认证）
	r.GET("/users/:id", c.GetUserByID)

	// 经纪人申请接口（需要认证）
	agent := r.Group("/agent")
	agent.Use(AuthMiddleware(c.jwtService, c.redisClient))
	{
		agent.POST("/register", c.AgentRegister)
		agent.GET("/status", c.GetAgentStatus)
	}
}

// SendVerificationCodeRequest 发送验证码请求
type SendVerificationCodeRequest struct {
	Phone string `json:"phone" binding:"required"`
	Type  string `json:"type" binding:"required,oneof=register login reset_password"`
}

// SendVerificationCode 发送验证码
func (c *UserController) SendVerificationCode(ctx *gin.Context) {
	// 处理 GET 请求（用于测试）
	if ctx.Request.Method == "GET" {
		common.Success(ctx, gin.H{
			"message": "请使用 POST 方法发送验证码",
			"method":  "POST",
			"params": gin.H{
				"phone": "手机号",
				"type":  "login/register/reset_password",
			},
		})
		return
	}

	var req SendVerificationCodeRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	// IP-based rate limiting: allow at most one SMS per 60 seconds per IP.
	if c.redisClient != nil {
		rateLimitKey := "rate_limit:sms:" + ctx.ClientIP()
		ok, err := c.redisClient.SetNX(context.Background(), rateLimitKey, 1, 60*time.Second).Result()
		if err == nil && !ok {
			common.TooManyRequests(ctx, "操作过于频繁，请稍后再试")
			return
		}
	}

	code, err := c.userService.SendVerificationCode(ctx, req.Phone, req.Type)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	resp := gin.H{
		"expired_at": 300,
		"interval":   60,
	}

	// 开发环境返回验证码
	if gin.Mode() != gin.ReleaseMode {
		resp["code"] = code
	}

	common.Success(ctx, resp)
}

// Register 用户注册
func (c *UserController) Register(ctx *gin.Context) {
	var req service.RegisterRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	resp, err := c.userService.Register(ctx, &req)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, resp)
}

// Login 验证码登录
func (c *UserController) Login(ctx *gin.Context) {
	var req service.LoginRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	resp, err := c.userService.Login(ctx, &req)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, resp)
}

// LoginWithPassword 密码登录
func (c *UserController) LoginWithPassword(ctx *gin.Context) {
	var req service.PasswordLoginRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	resp, err := c.userService.LoginWithPassword(ctx, &req)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, resp)
}

// RefreshTokenRequest 刷新Token请求
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// RefreshToken 刷新Token
func (c *UserController) RefreshToken(ctx *gin.Context) {
	var req RefreshTokenRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	resp, err := c.userService.RefreshToken(ctx, req.RefreshToken)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, resp)
}

// ResetPassword 重置密码
func (c *UserController) ResetPassword(ctx *gin.Context) {
	var req service.ResetPasswordRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	if err := c.userService.ResetPassword(ctx, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, nil)
}

// GetCurrentUser 获取当前用户信息
func (c *UserController) GetCurrentUser(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	
	user, err := c.userService.GetCurrentUser(ctx, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, user)
}

// GetUserByID 获取指定用户信息（公开接口）
func (c *UserController) GetUserByID(ctx *gin.Context) {
	userID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的用户ID")
		return
	}

	user, err := c.userService.GetUserByID(ctx, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, user)
}

// UpdateProfile 更新用户资料
func (c *UserController) UpdateProfile(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	
	var req service.UpdateProfileRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	if err := c.userService.UpdateProfile(ctx, userID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, nil)
}

// UploadAvatar 上传头像
func (c *UserController) UploadAvatar(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	
	file, err := ctx.FormFile("file")
	if err != nil {
		common.BadRequest(ctx, "请上传文件")
		return
	}
	
	// 打开文件
	openedFile, err := file.Open()
	if err != nil {
		common.ServerError(ctx)
		return
	}
	defer openedFile.Close()
	
	// 读取文件内容
	fileData := make([]byte, file.Size)
	_, err = openedFile.Read(fileData)
	if err != nil {
		common.ServerError(ctx)
		return
	}
	
	url, err := c.userService.UploadAvatar(ctx, userID, fileData, file.Filename)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, gin.H{"url": url})
}

// ChangePassword 修改密码
func (c *UserController) ChangePassword(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	
	var req service.ChangePasswordRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	if err := c.userService.ChangePassword(ctx, userID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, nil)
}

// SubmitVerification 提交实名认证
func (c *UserController) SubmitVerification(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	
	var req service.SubmitVerificationRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}
	
	if err := c.userService.SubmitVerification(ctx, userID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, nil)
}

// GetVerificationStatus 获取实名认证状态
func (c *UserController) GetVerificationStatus(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	
	status, err := c.userService.GetVerificationStatus(ctx, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}
	
	common.Success(ctx, status)
}

// GetFavorites 获取收藏列表
func (c *UserController) GetFavorites(ctx *gin.Context) {
	// 简化实现，实际需要调用房源服务
	common.Success(ctx, gin.H{"list": []interface{}{}})
}

// AddFavorite 添加收藏
func (c *UserController) AddFavorite(ctx *gin.Context) {
	// 简化实现
	common.Success(ctx, nil)
}

// RemoveFavorite 取消收藏
func (c *UserController) RemoveFavorite(ctx *gin.Context) {
	// 简化实现
	common.Success(ctx, nil)
}

// CheckFavorite 检查房源是否已收藏
func (c *UserController) CheckFavorite(ctx *gin.Context) {
	common.Success(ctx, gin.H{"is_favorited": false})
}

// GetBrowsingHistory 获取浏览历史
func (c *UserController) GetBrowsingHistory(ctx *gin.Context) {
	// 简化实现
	common.Success(ctx, gin.H{"list": []interface{}{}})
}

// ClearBrowsingHistory 清除浏览历史
func (c *UserController) ClearBrowsingHistory(ctx *gin.Context) {
	// 简化实现
	common.Success(ctx, nil)
}

// AuthMiddleware 认证中间件 - 验证JWT token并设置user_id
func AuthMiddleware(jwtSvc service.JWTService, rdb *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			common.Unauthorized(c)
			c.Abort()
			return
		}

		// 移除Bearer前缀
		token := authHeader
		if strings.HasPrefix(authHeader, "Bearer ") {
			token = authHeader[7:]
		}

		// 检查Redis黑名单（token是否已退出）
		if rdb != nil {
			blacklistKey := "blacklist:" + token
			if val, err := rdb.Get(context.Background(), blacklistKey).Result(); err == nil && val != "" {
				common.Unauthorized(c)
				c.Abort()
				return
			}
		}

		// 解析JWT token
		claims, err := jwtSvc.ParseToken(token)
		if err != nil {
			common.Unauthorized(c)
			c.Abort()
			return
		}

		// 只允许access token访问API
		if claims.Type != "access" {
			common.Unauthorized(c)
			c.Abort()
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("token", token)
		c.Next()
	}
}

// Logout 退出登录
func (c *UserController) Logout(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")
	token := ctx.GetString("token")

	if err := c.userService.Logout(ctx, userID, token); err != nil {
		common.ServerError(ctx)
		return
	}

	common.Success(ctx, nil)
}

// agentRecord maps to the agents table for agent registration
type agentRecord struct {
	ID           int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	UserID       int64      `gorm:"column:user_id" json:"user_id"`
	RealName     string     `gorm:"column:real_name" json:"real_name"`
	IDCardNumber string     `gorm:"column:id_card_number" json:"id_card_number"`
	WorkCity     string     `gorm:"column:work_city" json:"work_city"`
	Status       string     `gorm:"column:status" json:"status"`
	CreatedAt    time.Time  `gorm:"column:created_at" json:"created_at"`
}

func (agentRecord) TableName() string { return "agents" }

// AgentRegisterRequest 经纪人申请请求
type AgentRegisterRequest struct {
	Name         string `json:"name" binding:"required"`
	IDCardNumber string `json:"id_card_number"`
	WorkCity     string `json:"work_city"`
}

// AgentRegister 申请成为经纪人
func (c *UserController) AgentRegister(ctx *gin.Context) {
	if c.db == nil {
		common.ServerError(ctx)
		return
	}
	userID := ctx.GetInt64("user_id")

	var req AgentRegisterRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	// Check if already applied
	var existing agentRecord
	if err := c.db.WithContext(ctx).Where("user_id = ?", userID).First(&existing).Error; err == nil {
		common.ErrorResponse(ctx, common.NewError(common.ErrCodeAgentExists))
		return
	}

	city := req.WorkCity
	if city == "" {
		city = "Yangon"
	}

	agent := &agentRecord{
		UserID:       userID,
		RealName:     req.Name,
		IDCardNumber: req.IDCardNumber,
		WorkCity:     city,
		Status:       "pending",
	}
	if err := c.db.WithContext(ctx).Create(agent).Error; err != nil {
		common.ServerError(ctx)
		return
	}

	common.Success(ctx, gin.H{
		"id":     agent.ID,
		"status": agent.Status,
	})
}

// GetUserStatus 获取用户状态
func (c *UserController) GetUserStatus(ctx *gin.Context) {
	userID := ctx.GetInt64("user_id")

	user, err := c.userService.GetCurrentUser(ctx, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, gin.H{
		"user_id":      userID,
		"status":       user.Status,
		"is_verified":  user.IsVerified,
		"is_agent":     false, // 简化实现，实际应查询经纪人表
	})
}

// GetUploadToken 获取上传Token（简化实现）
func (c *UserController) GetUploadToken(ctx *gin.Context) {
	// 生成临时上传凭证，实际应接入OSS服务（如阿里云OSS、AWS S3等）
	userID := ctx.GetInt64("user_id")

	common.Success(ctx, gin.H{
		"token":       fmt.Sprintf("upload_token_%d_%d", userID, time.Now().Unix()),
		"expire":      3600,
		"upload_url":  "/v1/users/me/avatar",
		"key_prefix":  fmt.Sprintf("uploads/%d/", userID),
	})
}

// GetAgentStatus 获取经纪人申请状态
func (c *UserController) GetAgentStatus(ctx *gin.Context) {
	if c.db == nil {
		common.ServerError(ctx)
		return
	}
	userID := ctx.GetInt64("user_id")

	var agent agentRecord
	if err := c.db.WithContext(ctx).Where("user_id = ?", userID).First(&agent).Error; err != nil {
		common.ErrorResponse(ctx, common.NewError(common.ErrCodeAgentNotFound))
		return
	}

	common.Success(ctx, gin.H{
		"id":     agent.ID,
		"status": agent.Status,
	})
}
