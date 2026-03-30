package config

// AppConfig 全局应用配置
type AppConfig struct {
	AppName            string            `json:"app_name"`
	AppNameEn          string            `json:"app_name_en"`
	SupportPhone       string            `json:"support_phone"`
	MinAppVersion      string            `json:"min_app_version"`
	ForceUpdateVersion string            `json:"force_update_version"`
	APIBaseURL         string            `json:"api_base_url"`
	Features           FeatureConfig     `json:"features"`
	HouseFilters       HouseFilterConfig `json:"house_filters"`
}

// FeatureConfig 功能开关配置
type FeatureConfig struct {
	PaymentEnabled bool `json:"payment_enabled"`
	IMEnabled      bool `json:"im_enabled"`
	MapEnabled     bool `json:"map_enabled"`
	ACNEnabled     bool `json:"acn_enabled"`
}

// HouseFilterConfig 房源筛选配置
type HouseFilterConfig struct {
	PriceRanges []PriceRange `json:"price_ranges"`
}

// PriceRange 价格区间
type PriceRange struct {
	Min   int64  `json:"min"`
	Max   int64  `json:"max"`
	Label string `json:"label"`
}

// GetDefaultConfig 获取默认配置
func GetDefaultConfig() *AppConfig {
	return &AppConfig{
		AppName:            "缅甸房产",
		AppNameEn:          "Myanmar Property",
		SupportPhone:       "+959123456789",
		MinAppVersion:      "1.0.0",
		ForceUpdateVersion: "1.0.0",
		APIBaseURL:         "https://api.myanmar-property.com",
		Features: FeatureConfig{
			PaymentEnabled: false,
			IMEnabled:      false,
			MapEnabled:     true,
			ACNEnabled:     true,
		},
		HouseFilters: HouseFilterConfig{
			PriceRanges: []PriceRange{
				{Min: 0, Max: 1000000, Label: "100万以下"},
				{Min: 1000000, Max: 5000000, Label: "100-500万"},
				{Min: 5000000, Max: 10000000, Label: "500-1000万"},
				{Min: 10000000, Max: 50000000, Label: "1000-5000万"},
				{Min: 50000000, Max: 0, Label: "5000万以上"},
			},
		},
	}
}
