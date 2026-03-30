package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"

	"myanmar-property/backend/07-common"
	opsConfig "myanmar-property/backend/13-ops-service/config"
	"myanmar-property/backend/13-ops-service/service"
)

// OpsController 运营控制器（Banner管理）
type OpsController struct {
	bannerSvc service.BannerService
}

// NewOpsController 创建运营控制器
func NewOpsController(bannerSvc service.BannerService) *OpsController {
	return &OpsController{bannerSvc: bannerSvc}
}

// RegisterRoutes 注册路由（挂载在 /admin 下）
func (ctrl *OpsController) RegisterRoutes(r *gin.RouterGroup) {
	// 公开路由 - 无需认证（始终可用）
	public := r.Group("")
	{
		public.GET("/regions", ctrl.GetRegions)
		public.GET("/config", ctrl.GetConfig)
	}

	// 管理后台路由 - 需要认证（需要数据库）
	if ctrl.bannerSvc != nil {
		admin := r.Group("/admin")
		{
			banners := admin.Group("/banners")
			{
				banners.GET("", ctrl.ListBanners)
				banners.POST("", ctrl.CreateBanner)
				banners.PUT("/:id", ctrl.UpdateBanner)
				banners.DELETE("/:id", ctrl.DeleteBanner)
				banners.PUT("/:id/status", ctrl.UpdateBannerStatus)
			}
		}
	}
}

// ListBanners 获取横幅列表
func (ctrl *OpsController) ListBanners(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "20"))
	position := c.Query("position")
	status := c.Query("status")

	banners, total, err := ctrl.bannerSvc.ListBanners(c.Request.Context(), position, status, page, pageSize)
	if err != nil {
		common.ServerError(c, "查询横幅列表失败")
		return
	}

	common.Success(c, gin.H{
		"list":     banners,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// CreateBanner 创建横幅
func (ctrl *OpsController) CreateBanner(c *gin.Context) {
	var req service.CreateBannerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.BadRequest(c, err.Error())
		return
	}

	banner, err := ctrl.bannerSvc.CreateBanner(c.Request.Context(), &req)
	if err != nil {
		common.ServerError(c, "创建横幅失败")
		return
	}

	common.Success(c, banner)
}

// UpdateBanner 更新横幅
func (ctrl *OpsController) UpdateBanner(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的横幅ID")
		return
	}

	var req service.UpdateBannerRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		common.BadRequest(c, err.Error())
		return
	}

	banner, err := ctrl.bannerSvc.UpdateBanner(c.Request.Context(), id, &req)
	if err != nil {
		common.ServerError(c, "更新横幅失败")
		return
	}

	common.Success(c, banner)
}

// DeleteBanner 删除横幅
func (ctrl *OpsController) DeleteBanner(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的横幅ID")
		return
	}

	if err := ctrl.bannerSvc.DeleteBanner(c.Request.Context(), id); err != nil {
		common.ServerError(c, "删除横幅失败")
		return
	}

	common.Success(c, gin.H{"message": "删除成功"})
}

// UpdateBannerStatus 更新横幅状态
func (ctrl *OpsController) UpdateBannerStatus(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的横幅ID")
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		common.BadRequest(c, err.Error())
		return
	}

	if req.Status != "active" && req.Status != "inactive" {
		common.BadRequest(c, "无效的状态值，允许: active, inactive")
		return
	}

	if err := ctrl.bannerSvc.UpdateBannerStatus(c.Request.Context(), id, req.Status); err != nil {
		common.ServerError(c, "更新状态失败")
		return
	}

	common.Success(c, gin.H{"message": "状态更新成功", "id": id, "status": req.Status})
}

// Region 地区信息
type Region struct {
	ID     int64  `json:"id"`
	Name   string `json:"name"`
	NameEn string `json:"name_en"`
	Code   string `json:"code"`
}

// GetRegions 获取地区列表
func (ctrl *OpsController) GetRegions(c *gin.Context) {
	// 静态地区数据（缅甸主要城市）
	regions := []Region{
		{ID: 1, Name: "仰光", NameEn: "Yangon", Code: "YGN"},
		{ID: 2, Name: "曼德勒", NameEn: "Mandalay", Code: "MDL"},
		{ID: 3, Name: "内比都", NameEn: "Naypyidaw", Code: "NPY"},
		{ID: 4, Name: "东枝", NameEn: "Taunggyi", Code: "TGI"},
		{ID: 5, Name: "勃生", NameEn: "Pathein", Code: "PTN"},
		{ID: 6, Name: "毛淡棉", NameEn: "Mawlamyine", Code: "MWM"},
		{ID: 7, Name: "密铁拉", NameEn: "Meiktila", Code: "MKT"},
		{ID: 8, Name: "实皆", NameEn: "Sagaing", Code: "SGG"},
		{ID: 9, Name: "密支那", NameEn: "Myitkyina", Code: "MYT"},
		{ID: 10, Name: "皎漂", NameEn: "Kyaukpyu", Code: "KYP"},
	}

	common.Success(c, gin.H{
		"regions": regions,
	})
}

// GetConfig 获取全局配置
func (ctrl *OpsController) GetConfig(c *gin.Context) {
	platform := c.DefaultQuery("platform", "android")

	// 获取默认配置
	config := opsConfig.GetDefaultConfig()

	// 根据平台返回差异化配置（如有需要）
	if platform == "ios" {
		// iOS特定配置
		config.AppName = "缅甸房产 iOS"
	}

	common.Success(c, config)
}
