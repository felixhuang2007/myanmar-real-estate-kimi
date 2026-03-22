package controller

import (
	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	"myanmar-property/backend/07-common"
	uploadService "myanmar-property/backend/11-upload-service"
)

// UploadController 文件上传控制器
type UploadController struct {
	uploadSvc uploadService.UploadService
}

// NewUploadController 创建上传控制器
func NewUploadController(svc uploadService.UploadService) *UploadController {
	return &UploadController{uploadSvc: svc}
}

// RegisterRoutes 注册路由
func (c *UploadController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	auth := userController.AuthMiddleware(jwtSvc, rdb)
	upload := r.Group("/upload")
	upload.Use(auth)
	{
		upload.POST("/image", c.UploadImage)
		upload.POST("/file", c.UploadFile)
	}
}

// UploadImage 上传图片
func (c *UploadController) UploadImage(ctx *gin.Context) {
	file, err := ctx.FormFile("file")
	if err != nil {
		common.BadRequest(ctx, "请上传文件")
		return
	}

	f, err := file.Open()
	if err != nil {
		common.ServerError(ctx)
		return
	}
	defer f.Close()

	url, err := c.uploadSvc.UploadImage(ctx, f, file, "house")
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

// UploadFile 上传文件
func (c *UploadController) UploadFile(ctx *gin.Context) {
	file, err := ctx.FormFile("file")
	if err != nil {
		common.BadRequest(ctx, "请上传文件")
		return
	}

	f, err := file.Open()
	if err != nil {
		common.ServerError(ctx)
		return
	}
	defer f.Close()

	url, err := c.uploadSvc.UploadFile(ctx, f, file, "doc")
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
