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
	Create(ctx context.Context, house *House) error
	FindByID(ctx context.Context, id int64) (*House, error)
	FindByCode(ctx context.Context, code string) (*House, error)
	Update(ctx context.Context, house *House) error
	Delete(ctx context.Context, id int64) error
	Search(ctx context.Context, params *HouseSearchParams) ([]*House, int64, error)
	GetRecommendations(ctx context.Context, cityCode string, limit int) ([]*House, error)
	MapSearch(ctx context.Context, params *MapSearchParams) ([]*House, error)
	MapAggregate(ctx context.Context, params *MapSearchParams) ([]*MapAggregateResult, error)
	FindByAgent(ctx context.Context, agentID int64, status string, page, pageSize int) ([]*House, int64, error)
	CountByAgent(ctx context.Context, agentID int64) (int64, error)
	AddImage(ctx context.Context, image *HouseImage) error
	DeleteImage(ctx context.Context, imageID int64) error
	GetImages(ctx context.Context, houseID int64) ([]*HouseImage, error)
	SetMainImage(ctx context.Context, houseID, imageID int64) error
	GetCities(ctx context.Context) ([]*City, error)
	GetDistricts(ctx context.Context, cityID int) ([]*District, error)
	GetCommunities(ctx context.Context, districtID int, keywords string) ([]*Community, error)
}

type MapAggregateResult struct {
	ID         int64   `json:"id"`
	Name       string  `json:"name"`
	Lat        float64 `json:"lat"`
	Lng        float64 `json:"lng"`
	AvgPrice   int64   `json:"avg_price"`
	TotalCount int64   `json:"total_count"`
}

type houseRepository struct {
	db        *gorm.DB
	esURL     string
	esEnabled bool
}

func NewHouseRepository(db *gorm.DB, esURL ...string) HouseRepository {
	url := ""
	if len(esURL) > 0 {
		url = esURL[0]
	}
	return &houseRepository{db: db, esURL: url, esEnabled: url != ""}
}

func (r *houseRepository) searchByES(ctx context.Context, keywords string) ([]int64, error) {
	if !r.esEnabled {
		return nil, errors.New("ES not enabled")
	}
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
			continue
		}
		ids = append(ids, id)
	}
	return ids, nil
}

func (r *houseRepository) Create(ctx context.Context, house *House) error {
	return r.db.WithContext(ctx).Create(house).Error
}

func (r *houseRepository) FindByID(ctx context.Context, id int64) (*House, error) {
	var house House
	err := r.db.WithContext(ctx).Preload("Images").First(&house, id).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &house, err
}

func (r *houseRepository) FindByCode(ctx context.Context, code string) (*House, error) {
	var house House
	err := r.db.WithContext(ctx).Where("house_code = ?", code).First(&house).Error
	if err == gorm.ErrRecordNotFound {
		return nil, nil
	}
	return &house, err
}

func (r *houseRepository) Update(ctx context.Context, house *House) error {
	return r.db.WithContext(ctx).Save(house).Error
}

func (r *houseRepository) Delete(ctx context.Context, id int64) error {
	return r.db.WithContext(ctx).Delete(&House{}, id).Error
}

// Search 搜索房源 - 修复UTF8中文编码问题
func (r *houseRepository) Search(ctx context.Context, params *HouseSearchParams) ([]*House, int64, error) {
	var houses []*House
	var total int64

	query := r.db.WithContext(ctx).Model(&House{})

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
		keywords := strings.TrimSpace(params.Keywords)
		if keywords != "" {
			esUsed := false
			if r.esEnabled {
				ids, err := r.searchByES(ctx, keywords)
				if err == nil && len(ids) > 0 {
					query = query.Where("id IN ?", ids)
					esUsed = true
				}
			}
			if !esUsed {
				keywordPattern := "%" + keywords + "%"
				query = query.Where("title ILIKE ? OR address ILIKE ? OR description ILIKE ?",
					keywordPattern, keywordPattern, keywordPattern)
			}
		}
	}

	query = query.Where("status = ?", "online")

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

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

	offset := (params.Page - 1) * params.PageSize
	if err := query.Offset(offset).Limit(params.PageSize).Find(&houses).Error; err != nil {
		return nil, 0, err
	}

	return houses, total, nil
}

func (r *houseRepository) GetRecommendations(ctx context.Context, cityCode string, limit int) ([]*House, error) {
	var houses []*House
	db := r.db.WithContext(ctx).Where("status = ?", "online")
	if cityCode != "" {
		db = db.Where("city_id = (SELECT id FROM cities WHERE code = ?)", cityCode)
	}
	err := db.Order("is_featured DESC, view_count DESC, created_at DESC").Limit(limit).Find(&houses).Error
	return houses, err
}

func (r *houseRepository) MapSearch(ctx context.Context, params *MapSearchParams) ([]*House, error) {
	var houses []*House
	db := r.db.WithContext(ctx).Where("status = ?", "online")
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

func (r *houseRepository) MapAggregate(ctx context.Context, params *MapSearchParams) ([]*MapAggregateResult, error) {
	var results []*MapAggregateResult
	querySQL := `
		SELECT d.id, d.name, d.latitude as lat, d.longitude as lng,
			AVG(h.price) as avg_price, COUNT(*) as total_count
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

func (r *houseRepository) CountByAgent(ctx context.Context, agentID int64) (int64, error) {
	var count int64
	err := r.db.WithContext(ctx).Model(&House{}).
		Where("(entrant_id = ? OR maintainer_id = ?) AND status = ?", agentID, agentID, "online").
		Count(&count).Error
	return count, err
}

func (r *houseRepository) AddImage(ctx context.Context, image *HouseImage) error {
	return r.db.WithContext(ctx).Create(image).Error
}

func (r *houseRepository) DeleteImage(ctx context.Context, imageID int64) error {
	return r.db.WithContext(ctx).Delete(&HouseImage{}, imageID).Error
}

func (r *houseRepository) GetImages(ctx context.Context, houseID int64) ([]*HouseImage, error) {
	var images []*HouseImage
	err := r.db.WithContext(ctx).Where("house_id = ?", houseID).
		Order("is_main DESC, sort_order ASC").Find(&images).Error
	return images, err
}

func (r *houseRepository) SetMainImage(ctx context.Context, houseID, imageID int64) error {
	return r.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&HouseImage{}).Where("house_id = ?", houseID).
			Update("is_main", false).Error; err != nil {
			return err
		}
		return tx.Model(&HouseImage{}).Where("id = ?", imageID).
			Update("is_main", true).Error
	})
}

func (r *houseRepository) GetCities(ctx context.Context) ([]*City, error) {
	var cities []*City
	err := r.db.WithContext(ctx).Where("is_active = ?", true).
		Order("sort_order ASC").Find(&cities).Error
	return cities, err
}

func (r *houseRepository) GetDistricts(ctx context.Context, cityID int) ([]*District, error) {
	var districts []*District
	err := r.db.WithContext(ctx).Where("city_id = ? AND is_active = ?", cityID, true).
		Order("sort_order ASC").Find(&districts).Error
	return districts, err
}

func (r *houseRepository) GetCommunities(ctx context.Context, districtID int, keywords string) ([]*Community, error) {
	var communities []*Community
	db := r.db.WithContext(ctx).Where("district_id = ? AND status = ?", districtID, "active")
	if keywords != "" {
		db = db.Where("name ILIKE ?", "%"+keywords+"%")
	}
	err := db.Order("name ASC").Limit(50).Find(&communities).Error
	return communities, err
}

func GenerateHouseCode() string {
	return fmt.Sprintf("HS%s%06d", time.Now().Format("20060102"), rand.Intn(999999))
}
