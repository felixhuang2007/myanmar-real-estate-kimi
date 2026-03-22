package service

import (
	"context"
	"fmt"
	"math/rand"
	"sync"
	"time"

	"myanmar-property/backend/07-common"
)

// HouseService 房源服务接口
type HouseService interface {
	// 搜索发现
	GetRecommendations(ctx context.Context, cityCode string, page, pageSize int) ([]*House, int64, error)
	Search(ctx context.Context, params *HouseSearchParams) ([]*House, int64, error)
	MapSearch(ctx context.Context, params *MapSearchParams) (*MapSearchResult, error)
	
	// 房源详情
	GetHouseDetail(ctx context.Context, houseID int64, userID int64) (*House, error)
	GetSimilarHouses(ctx context.Context, houseID int64, limit int) ([]*House, error)
	
	// 经纪人房源管理
	GetMyHouses(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*House, int64, error)
	CreateHouse(ctx context.Context, agentID int64, req *CreateHouseRequest) (*House, error)
	UpdateHouse(ctx context.Context, agentID, houseID int64, req *UpdateHouseRequest) error
	DeleteHouse(ctx context.Context, agentID, houseID int64) error
	ChangeHouseStatus(ctx context.Context, agentID, houseID int64, status, reason string) error
	UpdateHousePrice(ctx context.Context, agentID, houseID int64, newPrice int64, reason string) error
	RefreshHouse(ctx context.Context, agentID, houseID int64) error
	
	// 图片管理
	AddHouseImage(ctx context.Context, agentID, houseID int64, imageURL string, imageType string) error
	DeleteHouseImage(ctx context.Context, agentID, imageID int64) error
	SetMainImage(ctx context.Context, agentID, houseID, imageID int64) error
	
	// 位置相关
	GetCities(ctx context.Context) ([]*City, error)
	GetDistricts(ctx context.Context, cityCode string) ([]*District, error)
	GetCommunities(ctx context.Context, districtID int, keywords string) ([]*Community, error)
}

// 请求/响应结构
type CreateHouseRequest struct {
	Title           string   `json:"title" binding:"required"`
	TransactionType string   `json:"transaction_type" binding:"required,oneof=sale rent"`
	HouseType       string   `json:"house_type" binding:"required"`
	Price           int64    `json:"price" binding:"required,gt=0"`
	PriceUnit       string   `json:"price_unit" binding:"required"`
	Area            float64  `json:"area" binding:"required,gt=0"`
	Rooms           string   `json:"rooms,omitempty"`
	Bedrooms        int      `json:"bedrooms,omitempty"`
	LivingRooms     int      `json:"living_rooms,omitempty"`
	Bathrooms       int      `json:"bathrooms,omitempty"`
	Floor           string   `json:"floor,omitempty"`
	TotalFloors     int      `json:"total_floors,omitempty"`
	Decoration      string   `json:"decoration,omitempty"`
	Orientation     string   `json:"orientation,omitempty"`
	BuildYear       int      `json:"build_year,omitempty"`
	CityCode        string   `json:"city_code" binding:"required"`
	DistrictCode    string   `json:"district_code" binding:"required"`
	CommunityID     int64    `json:"community_id,omitempty"`
	Address         string   `json:"address" binding:"required"`
	Latitude        float64  `json:"latitude,omitempty"`
	Longitude       float64  `json:"longitude,omitempty"`
	Description     string   `json:"description,omitempty"`
	Highlights      []string `json:"highlights,omitempty"`
	Facilities      []string `json:"facilities,omitempty"`
	PropertyType    string   `json:"property_type,omitempty"`
	OwnerName       string   `json:"owner_name,omitempty"`
	OwnerPhone      string   `json:"owner_phone,omitempty"`
	HasLoan         bool     `json:"has_loan,omitempty"`
	Images          []string `json:"images" binding:"required,min=5"`
}

type UpdateHouseRequest struct {
	Title       *string   `json:"title,omitempty"`
	Price       *int64    `json:"price,omitempty"`
	PriceNote   *string   `json:"price_note,omitempty"`
	Area        *float64  `json:"area,omitempty"`
	Rooms       *string   `json:"rooms,omitempty"`
	Floor       *string   `json:"floor,omitempty"`
	Decoration  *string   `json:"decoration,omitempty"`
	Address     *string   `json:"address,omitempty"`
	Latitude    *float64  `json:"latitude,omitempty"`
	Longitude   *float64  `json:"longitude,omitempty"`
	Description *string   `json:"description,omitempty"`
	Highlights  []string  `json:"highlights,omitempty"`
	Facilities  []string  `json:"facilities,omitempty"`
	OwnerPhone  *string   `json:"owner_phone,omitempty"`
}

type MapSearchResult struct {
	Level    int                       `json:"level"`
	Clusters []*MapAggregateResult `json:"clusters,omitempty"`
	Houses   []*House            `json:"houses,omitempty"`
}

// mapCacheEntry holds a cached map aggregate result with an expiry timestamp.
type mapCacheEntry struct {
	data      []*MapAggregateResult
	expiresAt time.Time
}

// houseService 实现
type houseService struct {
	houseRepo HouseRepository
	config    *common.Config
	mapCache  sync.Map // key: string, value: *mapCacheEntry
}

// NewHouseService 创建房源服务
func NewHouseService(houseRepo HouseRepository, config *common.Config) HouseService {
	return &houseService{
		houseRepo: houseRepo,
		config:    config,
	}
}

// GetRecommendations 获取推荐房源
func (s *houseService) GetRecommendations(ctx context.Context, cityCode string, page, pageSize int) ([]*House, int64, error) {
	// 简化实现，实际需要返回总数
	houses, err := s.houseRepo.GetRecommendations(ctx, cityCode, pageSize)
	if err != nil {
		return nil, 0, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	return houses, int64(len(houses)), nil
}

// Search 搜索房源
func (s *houseService) Search(ctx context.Context, params *HouseSearchParams) ([]*House, int64, error) {
	if params.Page <= 0 {
		params.Page = 1
	}
	if params.PageSize <= 0 {
		params.PageSize = 20
	}
	if params.PageSize > 100 {
		params.PageSize = 100
	}
	
	houses, total, err := s.houseRepo.Search(ctx, params)
	if err != nil {
		return nil, 0, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return houses, total, nil
}

// MapSearch 地图搜索
func (s *houseService) MapSearch(ctx context.Context, params *MapSearchParams) (*MapSearchResult, error) {
	// 根据缩放级别决定返回聚合数据还是详细数据
	// Level 1: 8-11 镇区聚合
	// Level 2: 12-14 商圈聚合
	// Level 3: 15+  详细房源
	
	var level int
	switch {
	case params.Zoom >= 15:
		level = 3
	case params.Zoom >= 12:
		level = 2
	default:
		level = 1
	}
	
	result := &MapSearchResult{Level: level}
	
	if level < 3 {
		// 返回聚合数据（带5分钟内存缓存）
		cacheKey := fmt.Sprintf("map:%v:%v:%v:%v:%s:%d",
			params.SwLat, params.NeLat, params.SwLng, params.NeLng,
			params.TransactionType, level)

		if raw, ok := s.mapCache.Load(cacheKey); ok {
			entry := raw.(*mapCacheEntry)
			if time.Now().Before(entry.expiresAt) {
				result.Clusters = entry.data
				return result, nil
			}
			// Expired — remove stale entry
			s.mapCache.Delete(cacheKey)
		}

		clusters, err := s.houseRepo.MapAggregate(ctx, params)
		if err != nil {
			return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
		}
		s.mapCache.Store(cacheKey, &mapCacheEntry{
			data:      clusters,
			expiresAt: time.Now().Add(5 * time.Minute),
		})
		result.Clusters = clusters
	} else {
		// 返回详细房源
		houses, err := s.houseRepo.MapSearch(ctx, params)
		if err != nil {
			return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
		}
		result.Houses = houses
	}
	
	return result, nil
}

// GetHouseDetail 获取房源详情
func (s *houseService) GetHouseDetail(ctx context.Context, houseID int64, userID int64) (*House, error) {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return nil, common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查房源状态
	if house.Status != "online" {
		// 非在线状态的房源，只有房源发布者或维护人可以查看
		// 简化实现，实际应检查权限
	}
	
	return house, nil
}

// GetSimilarHouses 获取相似房源
func (s *houseService) GetSimilarHouses(ctx context.Context, houseID int64, limit int) ([]*House, error) {
	// 简化实现，实际应根据房源特征匹配相似房源
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil || house == nil {
		return nil, err
	}
	
	params := &HouseSearchParams{
		TransactionType: house.TransactionType,
		HouseType:       house.HouseType,
		PriceMin:        house.Price * 8 / 10,
		PriceMax:        house.Price * 12 / 10,
		Page:            1,
		PageSize:        limit,
	}
	
	houses, _, err := s.houseRepo.Search(ctx, params)
	return houses, err
}

// GetMyHouses 获取我的房源
func (s *houseService) GetMyHouses(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*House, int64, error) {
	return s.houseRepo.FindByAgent(ctx, agentID, status, page, pageSize)
}

// CreateHouse 创建房源
func (s *houseService) CreateHouse(ctx context.Context, agentID int64, req *CreateHouseRequest) (*House, error) {
	// 检查房源数量限制
	count, err := s.houseRepo.CountByAgent(ctx, agentID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	maxHouses := int64(50) // 从配置读取
	if count >= maxHouses {
		return nil, common.NewError(common.ErrCodeMaxHousesExceeded, fmt.Sprintf("最多可发布%d套房源", maxHouses))
	}
	
	// 生成房源编码
	houseCode := fmt.Sprintf("HS%s%06d", time.Now().Format("20060102"), rand.Intn(999999))
	
	house := &House{
		HouseCode:       houseCode,
		Title:           req.Title,
		TransactionType: req.TransactionType,
		HouseType:       req.HouseType,
		Price:           req.Price,
		PriceUnit:       req.PriceUnit,
		Area:            req.Area,
		Rooms:           &req.Rooms,
		Address:         req.Address,
		Status:          "pending", // 提交后待审核
		EntrantID:       &agentID,
		MaintainerID:    &agentID,
		VerificationStatus: "unverified",
	}
	
	// 可选字段
	if req.Bedrooms > 0 {
		house.Bedrooms = &req.Bedrooms
	}
	if req.LivingRooms > 0 {
		house.LivingRooms = &req.LivingRooms
	}
	if req.Bathrooms > 0 {
		house.Bathrooms = &req.Bathrooms
	}
	if req.Floor != "" {
		house.Floor = &req.Floor
	}
	if req.TotalFloors > 0 {
		house.TotalFloors = &req.TotalFloors
	}
	if req.Decoration != "" {
		house.Decoration = &req.Decoration
	}
	if req.Orientation != "" {
		house.Orientation = &req.Orientation
	}
	if req.BuildYear > 0 {
		house.BuildYear = &req.BuildYear
	}
	if req.Description != "" {
		house.Description = &req.Description
	}
	if req.PropertyType != "" {
		house.PropertyType = &req.PropertyType
	}
	if req.OwnerName != "" {
		house.OwnerName = &req.OwnerName
	}
	if req.OwnerPhone != "" {
		house.OwnerPhone = &req.OwnerPhone
	}
	house.HasLoan = req.HasLoan
	
	// 位置信息
	if req.Latitude != 0 && req.Longitude != 0 {
		house.Latitude = &req.Latitude
		house.Longitude = &req.Longitude
	}
	
	// 保存房源
	if err := s.houseRepo.Create(ctx, house); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 保存图片
	for i, url := range req.Images {
		image := &HouseImage{
			HouseID:  house.ID,
			ImageURL: url,
			Type:     "interior",
			SortOrder: i,
			IsMain:   i == 0,
			UploadedBy: &agentID,
		}
		s.houseRepo.AddImage(ctx, image)
	}
	
	return house, nil
}

// UpdateHouse 更新房源
func (s *houseService) UpdateHouse(ctx context.Context, agentID, houseID int64, req *UpdateHouseRequest) error {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查权限
	if house.EntrantID == nil || *house.EntrantID != agentID {
		if house.MaintainerID == nil || *house.MaintainerID != agentID {
			return common.NewError(common.ErrCodeForbidden, "无权修改该房源")
		}
	}
	
	// 更新字段
	if req.Title != nil {
		house.Title = *req.Title
	}
	if req.Price != nil {
		house.Price = *req.Price
	}
	if req.PriceNote != nil {
		house.PriceNote = req.PriceNote
	}
	if req.Area != nil {
		house.Area = *req.Area
	}
	if req.Rooms != nil {
		house.Rooms = req.Rooms
	}
	if req.Floor != nil {
		house.Floor = req.Floor
	}
	if req.Decoration != nil {
		house.Decoration = req.Decoration
	}
	if req.Address != nil {
		house.Address = *req.Address
	}
	if req.Latitude != nil && req.Longitude != nil {
		house.Latitude = req.Latitude
		house.Longitude = req.Longitude
	}
	if req.Description != nil {
		house.Description = req.Description
	}
	if req.OwnerPhone != nil {
		house.OwnerPhone = req.OwnerPhone
	}
	
	return s.houseRepo.Update(ctx, house)
}

// DeleteHouse 删除房源
func (s *houseService) DeleteHouse(ctx context.Context, agentID, houseID int64) error {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查权限
	if house.EntrantID == nil || *house.EntrantID != agentID {
		return common.NewError(common.ErrCodeForbidden, "无权删除该房源")
	}
	
	return s.houseRepo.Delete(ctx, houseID)
}

// ChangeHouseStatus 修改房源状态
func (s *houseService) ChangeHouseStatus(ctx context.Context, agentID, houseID int64, status, reason string) error {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查权限
	if house.EntrantID == nil || *house.EntrantID != agentID {
		if house.MaintainerID == nil || *house.MaintainerID != agentID {
			return common.NewError(common.ErrCodeForbidden, "无权修改该房源")
		}
	}
	
	house.Status = status
	return s.houseRepo.Update(ctx, house)
}

// UpdateHousePrice 修改房源价格
func (s *houseService) UpdateHousePrice(ctx context.Context, agentID, houseID int64, newPrice int64, reason string) error {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查权限
	if house.EntrantID == nil || *house.EntrantID != agentID {
		if house.MaintainerID == nil || *house.MaintainerID != agentID {
			return common.NewError(common.ErrCodeForbidden, "无权修改该房源")
		}
	}
	
	// 记录价格变更历史
	oldPrice := house.Price
	house.OriginalPrice = &oldPrice
	house.PriceChangeReason = &reason
	house.Price = newPrice
	
	return s.houseRepo.Update(ctx, house)
}

// RefreshHouse 刷新房源
func (s *houseService) RefreshHouse(ctx context.Context, agentID, houseID int64) error {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查权限
	if house.EntrantID == nil || *house.EntrantID != agentID {
		if house.MaintainerID == nil || *house.MaintainerID != agentID {
			return common.NewError(common.ErrCodeForbidden, "无权修改该房源")
		}
	}
	
	// 更新刷新时间
	house.UpdatedAt = time.Now()
	return s.houseRepo.Update(ctx, house)
}

// AddHouseImage 添加房源图片
func (s *houseService) AddHouseImage(ctx context.Context, agentID, houseID int64, imageURL string, imageType string) error {
	house, err := s.houseRepo.FindByID(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if house == nil {
		return common.NewError(common.ErrCodeHouseNotFound)
	}
	
	// 检查图片数量限制
	images, err := s.houseRepo.GetImages(ctx, houseID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if len(images) >= 20 {
		return common.NewError(common.ErrCodeMaxImagesExceeded, "最多上传20张图片")
	}
	
	image := &HouseImage{
		HouseID:    houseID,
		ImageURL:   imageURL,
		Type:       imageType,
		SortOrder:  len(images),
		IsMain:     len(images) == 0,
		UploadedBy: &agentID,
	}
	
	return s.houseRepo.AddImage(ctx, image)
}

// DeleteHouseImage 删除房源图片
func (s *houseService) DeleteHouseImage(ctx context.Context, agentID, imageID int64) error {
	return s.houseRepo.DeleteImage(ctx, imageID)
}

// SetMainImage 设置主图
func (s *houseService) SetMainImage(ctx context.Context, agentID, houseID, imageID int64) error {
	return s.houseRepo.SetMainImage(ctx, houseID, imageID)
}

// GetCities 获取城市列表
func (s *houseService) GetCities(ctx context.Context) ([]*City, error) {
	return s.houseRepo.GetCities(ctx)
}

// GetDistricts 获取镇区列表
func (s *houseService) GetDistricts(ctx context.Context, cityCode string) ([]*District, error) {
	// 简化实现，实际需要根据cityCode查询cityID
	return s.houseRepo.GetDistricts(ctx, 1)
}

// GetCommunities 获取商圈/小区列表
func (s *houseService) GetCommunities(ctx context.Context, districtID int, keywords string) ([]*Community, error) {
	return s.houseRepo.GetCommunities(ctx, districtID, keywords)
}
