package service

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"strconv"
	"strings"
	"time"

	"gorm.io/gorm"
)

// HouseRepository 房源数据访问接口
type HouseRepository interface {
	// 基础CRUD
	Create(ctx context.Context, house *House) error
	FindByID(ctx context.Context, id int64) (*House, error)
	FindByCode(ctx context.Context, code string) (*House, error)
	Update(ctx context.Context, house *House) error
	Delete(ctx context.Context, id int64) error

	// 搜索查询
	Search(ctx context.Context, params *HouseSearchParams) ([]*House, int64, error)
	GetRecommendations(ctx context.Context, cityCode string, limit int) ([]*House, error)

	// 地图搜索
	MapSearch(ctx context.Context, params *MapSearchParams) ([]*House, error)
	MapAggregate(ctx context.Context, params *MapSearchParams) ([]*MapAggregateResult, error)

	// 经纪人房源
	FindByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*House, int64, error)
	CountByAgent(ctx context.Context, agentID int64) (int64, error)

	// 图片管理
	AddImage(ctx context.Context, image *HouseImage) error
	DeleteImage(ctx context.Context, imageID int64) error
	GetImages(ctx context.Context, houseID int64) ([]*HouseImage, error)
	SetMainImage(ctx context.Context, houseID, imageID int64) error

	// 城市和区域
	GetCities(ctx context.Context) ([]*City, error)
	GetDistricts(ctx context.Context, cityID int) ([]*District, error)
	GetCommunities(ctx context.Context, districtID int, keywords string) ([]*Community, error)
}

// MapAggregateResult 地图聚合结果
type MapAggregateResult struct {
	ID         int64   `json:"id"`
	Name       string  `json:"name"`
	Lat        float64 `json:"lat"`
	Lng        float64 `json:"lng"`
	AvgPrice   int64   `json:"avg_price"`
	TotalCount int64   `json:"total_count"`
}

// houseRepository 实现
type houseRepository struct {
	db        *gorm.DB
	esURL     string
	esEnabled bool
}

// NewHouseRepository 创建房源仓储
// esURL is optional; when provided ES full-text search is enabled.
func NewHouseRepository(db *gorm.DB, esURL ...string) HouseRepository {
	url := ""
	if len(esURL) > 0 {
		url = esURL[0]
	}
	return &houseRepository{
		db:        db,
		esURL:     url,
		esEnabled: url != "",
	}
}

// searchByES 通过Elasticsearch搜索关键词，返回匹配的房源ID列表
func (r *houseRepository) searchByES(ctx context.Context, keywords string) ([]int64, error) {
	if !r.esEnabled {
		return nil, errors.New("ES not enabled")
	}

	// 构建查询体
	reqBody := map[string]interface{}{
		"query": map[string]interface{}{
			"multi_match": map[string]interface{}{
				"query":  keywords,
				"fields": []string{"name", "description", "community_name", "district_name", "city_name"},
			},
		},
		"_source": []string{"id"},
		"size":    100,
	}
	bodyBytes, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("marshal ES request: %w", err)
	}

	// 发起HTTP请求
	searchURL := strings.TrimRight(r.esURL, "/") + "/houses/_search"
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, searchURL, bytes.NewReader(bodyBytes))
	if err != nil {
		return nil, fmt.Errorf("create ES request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 3 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("ES request failed: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("ES returned status %d", resp.StatusCode)
	}

	// 解析响应
	respBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("read ES response: %w", err)
	}

	var esResp struct {
		Hits struct {
			Hits []struct {
				ID string `json:"_id"`
			} `json:"hits"`
		} `json:"hits"`
	}
	if err := json.Unmarshal(respBytes, &esResp); err != nil {
		return nil, fmt.Errorf("parse ES response: %w", err)
	}

	ids := make([]int64, 0, len(esResp.Hits.Hits))
	for _, hit := range esResp.Hits.Hits {
		id, err := strconv.ParseInt(hit.ID, 10, 64)
		if err != nil {
			continue // skip non-numeric IDs
		}
		ids = append(ids, id)
	}
	return ids, nil
}

// Create 创建房源
func (r *houseRepository) Create(ctx context.Context, house *House) error {
	return r.db.WithContext(ctx).Create(house).Error
}

// FindByID 根据ID查找房源
func (r *houseRepository) FindByID(ctx context.Context, id int64) (*House, error) {
	var house House
	err := r.db.WithContext(ctx).
		Preload("Images").
		First(&house, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &house, err
}

// FindByCode 根据编码查找房源
func (r *houseRepository) FindByCode(ctx context.Context, code string) (*House, error) {
	var house House
	err := r.db.WithContext(ctx).
		Where("house_code = ?", code).
		First(&house).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &house, err
}

// Update 更新房源
func (r *houseRepository) Update(ctx context.Context, house *House) error {
	return r.db.WithContext(ctx).Save(house).Error
}

// Delete 删除房源
func (r *houseRepository) Delete(ctx context.Context, id int64) error {
	return r.db.WithContext(ctx).Delete(&House{}, id).Error
}

// Search 搜索房源
func (r *houseRepository) Search(ctx context.Context, params *HouseSearchParams) ([]*House, int64, error) {
	var houses []*House
	var total int64

	query := r.db.WithContext(ctx).Model(&House{})

	// 构建查询条件
	if params.TransactionType != "" {
		query = query.Where("transaction_type = ?", params.TransactionType)
	}
	if params.IsNewHome != nil {
		query = query.Where("is_new_home = ?", *params.IsNewHome)
	}
	if params.CityCode != "" {
		query = query.Where("city_id = (SELECT id FROM cities WHERE code = ?)", params.CityCode)
	}
	if params.DistrictCode != "" {
		query = query.Where("district_id = (SELECT id FROM districts WHERE code = ?)", params.DistrictCode)
	}
	if params.CommunityID > 0 {
		query = query.Where("community_id = ?", params.CommunityID)
	}
	if params.PriceMin > 0 {
		query = query.Where("price >= ?", params.PriceMin)
	}
	if params.PriceMax > 0 {
		query = query.Where("price <= ?", params.PriceMax)
	}
	if params.AreaMin > 0 {
		query = query.Where("area >= ?", params.AreaMin)
	}
	if params.AreaMax > 0 {
		query = query.Where("area <= ?", params.AreaMax)
	}
	if params.HouseType != "" {
		query = query.Where("house_type = ?", params.HouseType)
	}
	if params.Rooms != "" {
		query = query.Where("rooms = ?", params.Rooms)
	}
	if params.Decoration != "" {
		query = query.Where("decoration = ?", params.Decoration)
	}

	// 关键词搜索：优先使用Elasticsearch，降级为LIKE查询
	if params.Keywords != "" {
		esUsed := false
		if r.esEnabled {
			ids, err := r.searchByES(ctx, params.Keywords)
			if err == nil && len(ids) > 0 {
				query = query.Where("id IN ?", ids)
				esUsed = true
			}
		}
		if !esUsed {
			// 降级：PostgreSQL LIKE查询
			query = query.Where("title ILIKE ? OR address ILIKE ?",
				"%"+params.Keywords+"%", "%"+params.Keywords+"%")
		}
	}

	// 只查询在线状态
	query = query.Where("status = ?", "online")

	// 统计总数
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// 排序
	switch params.SortBy {
	case "price_asc":
		query = query.Order("price ASC")
	case "price_desc":
		query = query.Order("price DESC")
	case "date":
		query = query.Order("created_at DESC")
	case "area":
		query = query.Order("area DESC")
	default:
		query = query.Order("is_featured DESC, created_at DESC")
	}

	// 分页
	offset := (params.Page - 1) * params.PageSize
	if err := query.Offset(offset).Limit(params.PageSize).Find(&houses).Error; err != nil {
		return nil, 0, err
	}

	return houses, total, nil
}

// GetRecommendations 获取推荐房源
func (r *houseRepository) GetRecommendations(ctx context.Context, cityCode string, limit int) ([]*House, error) {
	var houses []*House

	db := r.db.WithContext(ctx).Where("status = ?", "online")

	if cityCode != "" {
		db = db.Where("city_id = (SELECT id FROM cities WHERE code = ?)", cityCode)
	}

	err := db.Order("is_featured DESC, view_count DESC, created_at DESC").
		Limit(limit).
		Find(&houses).Error

	return houses, err
}

// MapSearch 地图搜索
func (r *houseRepository) MapSearch(ctx context.Context, params *MapSearchParams) ([]*House, error) {
	var houses []*House

	db := r.db.WithContext(ctx).Where("status = ?", "online")

	// 地理范围查询
	db = db.Where("latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?",
		params.SwLat, params.NeLat, params.SwLng, params.NeLng)

	if params.TransactionType != "" {
		db = db.Where("transaction_type = ?", params.TransactionType)
	}
	if params.PriceMin > 0 {
		db = db.Where("price >= ?", params.PriceMin)
	}
	if params.PriceMax > 0 {
		db = db.Where("price <= ?", params.PriceMax)
	}

	err := db.Limit(100).Find(&houses).Error
	return houses, err
}

// MapAggregate 地图聚合
func (r *houseRepository) MapAggregate(ctx context.Context, params *MapSearchParams) ([]*MapAggregateResult, error) {
	// 简化实现，按区域聚合
	var results []*MapAggregateResult

	querySQL := `
		SELECT
			d.id,
			d.name,
			d.latitude as lat,
			d.longitude as lng,
			AVG(h.price) as avg_price,
			COUNT(*) as total_count
		FROM houses h
		JOIN districts d ON h.district_id = d.id
		WHERE h.status = 'online'
		AND h.latitude BETWEEN ? AND ?
		AND h.longitude BETWEEN ? AND ?
	`

	args := []interface{}{params.SwLat, params.NeLat, params.SwLng, params.NeLng}

	if params.TransactionType != "" {
		querySQL += " AND h.transaction_type = ?"
		args = append(args, params.TransactionType)
	}

	querySQL += " GROUP BY d.id, d.name, d.latitude, d.longitude"

	err := r.db.WithContext(ctx).Raw(querySQL, args...).Scan(&results).Error
	return results, err
}

// FindByAgent 获取经纪人的房源
func (r *houseRepository) FindByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*House, int64, error) {
	var houses []*House
	var total int64

	db := r.db.WithContext(ctx).Where("entrant_id = ? OR maintainer_id = ?", agentID, agentID)

	if status != "" {
		db = db.Where("status = ?", status)
	}

	if err := db.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * pageSize
	err := db.Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&houses).Error

	return houses, total, err
}

// CountByAgent 统计经纪人的房源数
func (r *houseRepository) CountByAgent(ctx context.Context, agentID int64) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).
		Model(&House{}).
		Where("(entrant_id = ? OR maintainer_id = ?) AND status = ?", agentID, agentID, "online").
		Count(&count).Error
	return count, err
}

// AddImage 添加图片
func (r *houseRepository) AddImage(ctx context.Context, image *HouseImage) error {
	return r.db.WithContext(ctx).Create(image).Error
}

// DeleteImage 删除图片
func (r *houseRepository) DeleteImage(ctx context.Context, imageID int64) error {
	return r.db.WithContext(ctx).Delete(&HouseImage{}, imageID).Error
}

// GetImages 获取房源图片
func (r *houseRepository) GetImages(ctx context.Context, houseID int64) ([]*HouseImage, error) {
	var images []*HouseImage
	err := r.db.WithContext(ctx).
		Where("house_id = ?", houseID).
		Order("is_main DESC, sort_order ASC").
		Find(&images).Error
	return images, err
}

// SetMainImage 设置主图
func (r *houseRepository) SetMainImage(ctx context.Context, houseID, imageID int64) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		// 取消原有主图
		if err := tx.Model(&HouseImage{}).
			Where("house_id = ?", houseID).
			Update("is_main", false).Error; err != nil {
			return err
		}

		// 设置新主图
		return tx.Model(&HouseImage{}).
			Where("id = ?", imageID).
			Update("is_main", true).Error
	})
}

// GetCities 获取城市列表
func (r *houseRepository) GetCities(ctx context.Context) ([]*City, error) {
	var cities []*City
	err := r.db.WithContext(ctx).
		Where("is_active = ?", true).
		Order("sort_order ASC").
		Find(&cities).Error
	return cities, err
}

// GetDistricts 获取镇区列表
func (r *houseRepository) GetDistricts(ctx context.Context, cityID int) ([]*District, error) {
	var districts []*District
	err := r.db.WithContext(ctx).
		Where("city_id = ? AND is_active = ?", cityID, true).
		Order("sort_order ASC").
		Find(&districts).Error
	return districts, err
}

// GetCommunities 获取商圈/小区列表
func (r *houseRepository) GetCommunities(ctx context.Context, districtID int, keywords string) ([]*Community, error) {
	var communities []*Community

	db := r.db.WithContext(ctx).Where("district_id = ? AND status = ?", districtID, "active")

	if keywords != "" {
		db = db.Where("name ILIKE ?", "%"+keywords+"%")
	}

	err := db.Order("name ASC").Limit(50).Find(&communities).Error
	return communities, err
}

// GenerateHouseCode 生成房源编码
func GenerateHouseCode() string {
	return fmt.Sprintf("HS%s%06d", time.Now().Format("20060102"), rand.Intn(999999))
}
