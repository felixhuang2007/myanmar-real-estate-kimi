package service

import (
	"time"
)

// House 房源模型
type House struct {
	ID               int64      `gorm:"primaryKey" json:"house_id"`
	HouseCode        string     `gorm:"column:house_code;uniqueIndex" json:"house_code"`
	Title            string     `gorm:"column:title;size:500" json:"title"`
	TitleMy          *string    `gorm:"column:title_my;size:500" json:"title_my,omitempty"`
	
	// 交易类型和价格
	TransactionType  string     `gorm:"column:transaction_type;size:20" json:"transaction_type"`
	Price            int64      `gorm:"column:price" json:"price"`
	PriceUnit        string     `gorm:"column:price_unit;size:20" json:"price_unit"`
	PriceNote        *string    `gorm:"column:price_note;size:255" json:"price_note,omitempty"`
	OriginalPrice    *int64     `gorm:"column:original_price" json:"original_price,omitempty"`
	PriceChangeReason *string   `gorm:"column:price_change_reason;size:255" json:"price_change_reason,omitempty"`
	
	// 房源类型
	HouseType        string     `gorm:"column:house_type;size:50" json:"house_type"`
	PropertyType     *string    `gorm:"column:property_type;size:50" json:"property_type,omitempty"`
	
	// 面积和户型
	Area             float64    `gorm:"column:area" json:"area"`
	UsableArea       *float64   `gorm:"column:usable_area" json:"usable_area,omitempty"`
	Rooms            *string    `gorm:"column:rooms;size:20" json:"rooms,omitempty"`
	Bedrooms         *int       `gorm:"column:bedrooms" json:"bedrooms,omitempty"`
	LivingRooms      *int       `gorm:"column:living_rooms" json:"living_rooms,omitempty"`
	Bathrooms        *int       `gorm:"column:bathrooms" json:"bathrooms,omitempty"`
	Kitchens         *int       `gorm:"column:kitchens" json:"kitchens,omitempty"`
	
	// 楼层
	Floor            *string    `gorm:"column:floor;size:20" json:"floor,omitempty"`
	TotalFloors      *int       `gorm:"column:total_floors" json:"total_floors,omitempty"`
	FloorType        *string    `gorm:"column:floor_type;size:20" json:"floor_type,omitempty"`
	HasElevator      *bool      `gorm:"column:has_elevator" json:"has_elevator,omitempty"`
	
	// 装修和朝向
	Decoration       *string    `gorm:"column:decoration;size:20" json:"decoration,omitempty"`
	Orientation      *string    `gorm:"column:orientation;size:20" json:"orientation,omitempty"`
	BuildYear        *int       `gorm:"column:build_year" json:"build_year,omitempty"`
	
	// 位置
	CityID           *int       `gorm:"column:city_id" json:"city_id,omitempty"`
	DistrictID       *int       `gorm:"column:district_id" json:"district_id,omitempty"`
	CommunityID      *int64     `gorm:"column:community_id" json:"community_id,omitempty"`
	Address          string     `gorm:"column:address" json:"address"`
	AddressMy        *string    `gorm:"column:address_my" json:"address_my,omitempty"`
	Latitude         *float64   `gorm:"column:latitude" json:"latitude,omitempty"`
	Longitude        *float64   `gorm:"column:longitude" json:"longitude,omitempty"`
	
	// 描述
	Description      *string    `gorm:"column:description" json:"description,omitempty"`
	DescriptionMy    *string    `gorm:"column:description_my" json:"description_my,omitempty"`
	Highlights       *string    `gorm:"column:highlights" json:"highlights,omitempty"`
	Facilities       *string    `gorm:"column:facilities" json:"facilities,omitempty"`
	
	// 产权
	OwnershipType    *string    `gorm:"column:ownership_type;size:50" json:"ownership_type,omitempty"`
	OwnerName        *string    `gorm:"column:owner_name;size:100" json:"owner_name,omitempty"`
	OwnerPhone       *string    `gorm:"column:owner_phone;size:20" json:"owner_phone,omitempty"`
	OwnerIDCard      *string    `gorm:"column:owner_id_card;size:50" json:"owner_id_card,omitempty"`
	HasLoan          bool       `gorm:"column:has_loan;default:false" json:"has_loan"`
	LoanAmount       *int64     `gorm:"column:loan_amount" json:"loan_amount,omitempty"`
	PropertyCertificateNo *string `gorm:"column:property_certificate_no;size:100" json:"property_certificate_no,omitempty"`
	
	// 状态和归属
	Status           string     `gorm:"column:status;size:20" json:"status"`
	EntrantID        *int64     `gorm:"column:entrant_id" json:"entrant_id,omitempty"`
	MaintainerID     *int64     `gorm:"column:maintainer_id" json:"maintainer_id,omitempty"`
	CompanyID        *int64     `gorm:"column:company_id" json:"company_id,omitempty"`
	
	// 验真
	VerificationStatus string   `gorm:"column:verification_status;size:20" json:"verification_status"`
	VerifiedAt       *time.Time `gorm:"column:verified_at" json:"verified_at,omitempty"`
	VerifierID       *int64     `gorm:"column:verifier_id" json:"verifier_id,omitempty"`
	
	// 新房/二手房
	IsNewHome        bool       `gorm:"column:is_new_home;default:false" json:"is_new_home"`

	// 推广
	IsFeatured       bool       `gorm:"column:is_featured;default:false" json:"is_featured"`
	IsUrgent         bool       `gorm:"column:is_urgent;default:false" json:"is_urgent"`
	FeaturedUntil    *time.Time `gorm:"column:featured_until" json:"featured_until,omitempty"`
	
	// 统计
	ViewCount        int        `gorm:"column:view_count;default:0" json:"view_count"`
	FavoriteCount    int        `gorm:"column:favorite_count;default:0" json:"favorite_count"`
	InquiryCount     int        `gorm:"column:inquiry_count;default:0" json:"inquiry_count"`
	ShowingCount     int        `gorm:"column:showing_count;default:0" json:"showing_count"`
	
	// 时间
	CreatedAt        time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt        time.Time  `gorm:"column:updated_at" json:"updated_at"`
	PublishedAt      *time.Time `gorm:"column:published_at" json:"published_at,omitempty"`
	OfflineAt        *time.Time `gorm:"column:offline_at" json:"offline_at,omitempty"`
	
	// 关联
	Images           []HouseImage `gorm:"foreignKey:HouseID" json:"images,omitempty"`
	Agent            *AgentInfo   `gorm:"-" json:"agent,omitempty"`
}

func (House) TableName() string {
	return "houses"
}

// HouseImage 房源图片
type HouseImage struct {
	ID            int64     `gorm:"primaryKey" json:"image_id"`
	HouseID       int64     `gorm:"column:house_id;index" json:"house_id"`
	ImageURL      string    `gorm:"column:image_url;size:500" json:"image_url"`
	ThumbnailURL  *string   `gorm:"column:thumbnail_url;size:500" json:"thumbnail_url,omitempty"`
	Type          string    `gorm:"column:type;size:20;default:interior" json:"type"`
	SortOrder     int       `gorm:"column:sort_order;default:0" json:"sort_order"`
	Description   *string   `gorm:"column:description;size:255" json:"description,omitempty"`
	IsMain        bool      `gorm:"column:is_main;default:false" json:"is_main"`
	UploadedBy    *int64    `gorm:"column:uploaded_by" json:"uploaded_by,omitempty"`
	CreatedAt     time.Time `gorm:"column:created_at" json:"created_at"`
}

func (HouseImage) TableName() string {
	return "house_images"
}

// City 城市
type City struct {
	ID       int     `gorm:"primaryKey" json:"id"`
	Code     string  `gorm:"column:code;uniqueIndex;size:20" json:"code"`
	Name     string  `gorm:"column:name;size:100" json:"name"`
	NameEn   *string `gorm:"column:name_en;size:100" json:"name_en,omitempty"`
	NameMy   *string `gorm:"column:name_my;size:100" json:"name_my,omitempty"`
	Latitude  *float64 `gorm:"column:latitude" json:"latitude,omitempty"`
	Longitude *float64 `gorm:"column:longitude" json:"longitude,omitempty"`
	SortOrder int     `gorm:"column:sort_order;default:0" json:"sort_order"`
	IsActive  bool    `gorm:"column:is_active;default:true" json:"is_active"`
}

func (City) TableName() string {
	return "cities"
}

// District 镇区
type District struct {
	ID        int     `gorm:"primaryKey" json:"id"`
	CityID    int     `gorm:"column:city_id;index" json:"city_id"`
	Code      string  `gorm:"column:code;size:20" json:"code"`
	Name      string  `gorm:"column:name;size:100" json:"name"`
	NameEn    *string `gorm:"column:name_en;size:100" json:"name_en,omitempty"`
	NameMy    *string `gorm:"column:name_my;size:100" json:"name_my,omitempty"`
	Latitude  *float64 `gorm:"column:latitude" json:"latitude,omitempty"`
	Longitude *float64 `gorm:"column:longitude" json:"longitude,omitempty"`
	SortOrder int     `gorm:"column:sort_order;default:0" json:"sort_order"`
	IsActive  bool    `gorm:"column:is_active;default:true" json:"is_active"`
}

func (District) TableName() string {
	return "districts"
}

// Community 商圈/小区
type Community struct {
	ID           int64      `gorm:"primaryKey" json:"id"`
	DistrictID   int        `gorm:"column:district_id;index" json:"district_id"`
	Name         string     `gorm:"column:name;size:200" json:"name"`
	NameEn       *string    `gorm:"column:name_en;size:200" json:"name_en,omitempty"`
	NameMy       *string    `gorm:"column:name_my;size:200" json:"name_my,omitempty"`
	Alias        *string    `gorm:"column:alias;size:500" json:"alias,omitempty"`
	Address      *string    `gorm:"column:address" json:"address,omitempty"`
	Latitude     *float64   `gorm:"column:latitude" json:"latitude,omitempty"`
	Longitude    *float64   `gorm:"column:longitude" json:"longitude,omitempty"`
	BuildYear    *int       `gorm:"column:build_year" json:"build_year,omitempty"`
	TotalBuildings *int     `gorm:"column:total_buildings" json:"total_buildings,omitempty"`
	TotalUnits   *int       `gorm:"column:total_units" json:"total_units,omitempty"`
	PropertyType *string    `gorm:"column:property_type;size:50" json:"property_type,omitempty"`
	Developer    *string    `gorm:"column:developer;size:200" json:"developer,omitempty"`
	PropertyCompany *string `gorm:"column:property_company;size:200" json:"property_company,omitempty"`
	PropertyFee  *float64   `gorm:"column:property_fee" json:"property_fee,omitempty"`
	AvgPrice     *int64     `gorm:"column:avg_price" json:"avg_price,omitempty"`
	Facilities   *string    `gorm:"column:facilities" json:"facilities,omitempty"`
	Images       *string    `gorm:"column:images" json:"images,omitempty"`
	Status       string     `gorm:"column:status;size:20;default:active" json:"status"`
	CreatedAt    time.Time  `gorm:"column:created_at" json:"created_at"`
	UpdatedAt    time.Time  `gorm:"column:updated_at" json:"updated_at"`
}

func (Community) TableName() string {
	return "communities"
}

// AgentInfo 经纪人信息（简化）
type AgentInfo struct {
	AgentID   int64   `json:"agent_id"`
	Name      string  `json:"name"`
	Avatar    *string `json:"avatar,omitempty"`
	Company   *string `json:"company,omitempty"`
	Rating    float64 `json:"rating"`
	DealCount int     `json:"deal_count"`
	Phone     string  `json:"phone"`
}

// HouseSearchParams 房源搜索参数
type HouseSearchParams struct {
	TransactionType  string
	IsNewHome        *bool  // nil=不过滤, true=新房, false=二手房
	CityCode         string
	DistrictCode     string
	CommunityID      int64
	PriceMin         int64
	PriceMax         int64
	AreaMin          float64
	AreaMax          float64
	HouseType        string
	Rooms            string
	Decoration       string
	Keywords         string
	SortBy           string
	Page             int
	PageSize         int
}

// MapSearchParams 地图搜索参数
type MapSearchParams struct {
	SwLat            float64
	SwLng            float64
	NeLat            float64
	NeLng            float64
	Zoom             int
	TransactionType  string
	PriceMin         int64
	PriceMax         int64
}
