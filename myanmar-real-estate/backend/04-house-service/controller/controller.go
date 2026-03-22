package controller

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"

	service "myanmar-property/backend/04-house-service"
	userController "myanmar-property/backend/03-user-service/controller"
	userService "myanmar-property/backend/03-user-service/service"
	"myanmar-property/backend/07-common"
)

// HouseController 房源控制器
type HouseController struct {
	houseService service.HouseService
}

// NewHouseController 创建房源控制器
func NewHouseController(houseService service.HouseService) *HouseController {
	return &HouseController{
		houseService: houseService,
	}
}

// RegisterRoutes 注册路由
func (c *HouseController) RegisterRoutes(r *gin.RouterGroup, jwtSvc userService.JWTService, rdb *redis.Client) {
	auth := userController.AuthMiddleware(jwtSvc, rdb)

	// 公开接口
	houses := r.Group("/houses")
	{
		houses.GET("/recommendations", c.GetRecommendations)
		houses.GET("/search", c.Search)
		houses.GET("/map-search", c.MapSearch)
		houses.GET("/cities", c.GetCities)
		houses.GET("/districts", c.GetDistricts)
		houses.GET("/communities", c.GetCommunities)
		houses.GET("/:id", c.GetHouseDetail)
		houses.GET("/:id/similar", c.GetSimilarHouses)
	}

	// 需要认证的经纪人接口
	agentHouses := r.Group("/houses")
	agentHouses.Use(auth)
	{
		agentHouses.GET("/my", c.GetMyHouses)
		agentHouses.POST("", c.CreateHouse)
		agentHouses.PUT("/:id", c.UpdateHouse)
		agentHouses.DELETE("/:id", c.DeleteHouse)
		agentHouses.PUT("/:id/status", c.ChangeHouseStatus)
		agentHouses.PUT("/:id/price", c.UpdateHousePrice)
		agentHouses.POST("/:id/refresh", c.RefreshHouse)
		agentHouses.POST("/:id/images", c.AddHouseImage)
		agentHouses.DELETE("/:id/images/:image_id", c.DeleteHouseImage)
		agentHouses.PUT("/:id/images/:image_id/main", c.SetMainImage)
	}
}

// GetRecommendations 获取推荐房源
func (c *HouseController) GetRecommendations(ctx *gin.Context) {
	cityCode := ctx.Query("city_code")
	if cityCode == "" {
		cityCode = "YGN" // 默认仰光
	}

	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("page_size", "10"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 10
	}

	houses, total, err := c.houseService.GetRecommendations(ctx, cityCode, page, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, gin.H{
		"list": houses,
		"pagination": gin.H{
			"page":      page,
			"page_size": pageSize,
			"total":     total,
			"has_more":  total > int64(page*pageSize),
		},
	})
}

// Search 搜索房源
func (c *HouseController) Search(ctx *gin.Context) {
	params := &service.HouseSearchParams{
		CityCode:        ctx.Query("city_code"),
		DistrictCode:    ctx.Query("district_code"),
		TransactionType: ctx.Query("transaction_type"),
		HouseType:       ctx.Query("house_type"),
		Keywords:        ctx.Query("keyword"),
	}

	if isNewHomeStr := ctx.Query("is_new_home"); isNewHomeStr != "" {
		isNewHome := isNewHomeStr == "true"
		params.IsNewHome = &isNewHome
	}
	if priceMin, err := strconv.ParseInt(ctx.Query("price_min"), 10, 64); err == nil {
		params.PriceMin = priceMin
	}
	if priceMax, err := strconv.ParseInt(ctx.Query("price_max"), 10, 64); err == nil {
		params.PriceMax = priceMax
	}
	if areaMin, err := strconv.ParseFloat(ctx.Query("area_min"), 64); err == nil {
		params.AreaMin = areaMin
	}
	if areaMax, err := strconv.ParseFloat(ctx.Query("area_max"), 64); err == nil {
		params.AreaMax = areaMax
	}

	params.Page, _ = strconv.Atoi(ctx.DefaultQuery("page", "1"))
	params.PageSize, _ = strconv.Atoi(ctx.DefaultQuery("page_size", "20"))

	houses, total, err := c.houseService.Search(ctx, params)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, gin.H{
		"list": houses,
		"pagination": gin.H{
			"page":      params.Page,
			"page_size": params.PageSize,
			"total":     total,
			"has_more":  total > int64(params.Page*params.PageSize),
		},
	})
}

// MapSearch 地图搜索
func (c *HouseController) MapSearch(ctx *gin.Context) {
	params := &service.MapSearchParams{}

	if swLat, err := strconv.ParseFloat(ctx.Query("sw_lat"), 64); err == nil {
		params.SwLat = swLat
	}
	if swLng, err := strconv.ParseFloat(ctx.Query("sw_lng"), 64); err == nil {
		params.SwLng = swLng
	}
	if neLat, err := strconv.ParseFloat(ctx.Query("ne_lat"), 64); err == nil {
		params.NeLat = neLat
	}
	if neLng, err := strconv.ParseFloat(ctx.Query("ne_lng"), 64); err == nil {
		params.NeLng = neLng
	}
	if zoom, err := strconv.Atoi(ctx.Query("zoom")); err == nil {
		params.Zoom = zoom
	}
	if priceMin, err := strconv.ParseInt(ctx.Query("price_min"), 10, 64); err == nil {
		params.PriceMin = priceMin
	}
	if priceMax, err := strconv.ParseInt(ctx.Query("price_max"), 10, 64); err == nil {
		params.PriceMax = priceMax
	}

	result, err := c.houseService.MapSearch(ctx, params)
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

// GetHouseDetail 获取房源详情
func (c *HouseController) GetHouseDetail(ctx *gin.Context) {
	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	var userID int64
	if userIDVal, exists := ctx.Get("user_id"); exists {
		userID = userIDVal.(int64)
	}

	house, err := c.houseService.GetHouseDetail(ctx, houseID, userID)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, house)
}

// GetSimilarHouses 获取相似房源
func (c *HouseController) GetSimilarHouses(ctx *gin.Context) {
	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	limit, _ := strconv.Atoi(ctx.DefaultQuery("limit", "5"))
	if limit <= 0 || limit > 20 {
		limit = 5
	}

	houses, err := c.houseService.GetSimilarHouses(ctx, houseID, limit)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, houses)
}

// GetCities 获取城市列表
func (c *HouseController) GetCities(ctx *gin.Context) {
	cities, err := c.houseService.GetCities(ctx)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, cities)
}

// GetDistricts 获取镇区列表
func (c *HouseController) GetDistricts(ctx *gin.Context) {
	cityCode := ctx.Query("city_code")
	if cityCode == "" {
		common.BadRequest(ctx, "城市代码不能为空")
		return
	}

	districts, err := c.houseService.GetDistricts(ctx, cityCode)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, districts)
}

// GetCommunities 获取商圈/小区列表
func (c *HouseController) GetCommunities(ctx *gin.Context) {
	districtID, err := strconv.Atoi(ctx.Query("district_id"))
	if err != nil {
		common.BadRequest(ctx, "无效的镇区ID")
		return
	}

	keywords := ctx.Query("keywords")

	communities, err := c.houseService.GetCommunities(ctx, districtID, keywords)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, communities)
}

// --- 经纪人房源管理接口 ---

// GetMyHouses 获取我的房源列表
func (c *HouseController) GetMyHouses(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")
	status := ctx.Query("status")
	page, _ := strconv.Atoi(ctx.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(ctx.DefaultQuery("page_size", "20"))

	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 20
	}

	houses, total, err := c.houseService.GetMyHouses(ctx, agentID, status, page, pageSize)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, gin.H{
		"list": houses,
		"pagination": gin.H{
			"page":      page,
			"page_size": pageSize,
			"total":     total,
			"has_more":  total > int64(page*pageSize),
		},
	})
}

// CreateHouse 创建房源
func (c *HouseController) CreateHouse(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	var req service.CreateHouseRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	house, err := c.houseService.CreateHouse(ctx, agentID, &req)
	if err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, house)
}

// UpdateHouse 更新房源
func (c *HouseController) UpdateHouse(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	var req service.UpdateHouseRequest
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.houseService.UpdateHouse(ctx, agentID, houseID, &req); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// DeleteHouse 删除房源
func (c *HouseController) DeleteHouse(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	if err := c.houseService.DeleteHouse(ctx, agentID, houseID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// ChangeHouseStatus 修改房源状态
func (c *HouseController) ChangeHouseStatus(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"`
		Reason string `json:"reason"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.houseService.ChangeHouseStatus(ctx, agentID, houseID, req.Status, req.Reason); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// UpdateHousePrice 修改房源价格
func (c *HouseController) UpdateHousePrice(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	var req struct {
		Price  int64  `json:"price" binding:"required,gt=0"`
		Reason string `json:"reason"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if err := c.houseService.UpdateHousePrice(ctx, agentID, houseID, req.Price, req.Reason); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// RefreshHouse 刷新房源（置顶）
func (c *HouseController) RefreshHouse(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	if err := c.houseService.RefreshHouse(ctx, agentID, houseID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// AddHouseImage 添加房源图片
func (c *HouseController) AddHouseImage(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	var req struct {
		ImageURL  string `json:"image_url" binding:"required"`
		ImageType string `json:"image_type"`
	}
	if err := ctx.ShouldBindJSON(&req); err != nil {
		common.BadRequest(ctx, err.Error())
		return
	}

	if req.ImageType == "" {
		req.ImageType = "interior"
	}

	if err := c.houseService.AddHouseImage(ctx, agentID, houseID, req.ImageURL, req.ImageType); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// DeleteHouseImage 删除房源图片
func (c *HouseController) DeleteHouseImage(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	imageID, err := strconv.ParseInt(ctx.Param("image_id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的图片ID")
		return
	}

	if err := c.houseService.DeleteHouseImage(ctx, agentID, imageID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}

// SetMainImage 设置主图
func (c *HouseController) SetMainImage(ctx *gin.Context) {
	agentID := ctx.GetInt64("user_id")

	houseID, err := strconv.ParseInt(ctx.Param("id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的房源ID")
		return
	}

	imageID, err := strconv.ParseInt(ctx.Param("image_id"), 10, 64)
	if err != nil {
		common.BadRequest(ctx, "无效的图片ID")
		return
	}

	if err := c.houseService.SetMainImage(ctx, agentID, houseID, imageID); err != nil {
		if appErr, ok := err.(*common.AppError); ok {
			common.ErrorResponse(ctx, appErr)
		} else {
			common.ServerError(ctx)
		}
		return
	}

	common.Success(ctx, nil)
}
