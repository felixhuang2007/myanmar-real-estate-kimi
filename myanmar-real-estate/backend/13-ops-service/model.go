package model

import (
	"time"
)

// Banner 横幅广告模型（字段与 01-database-schema.sql banners 表对齐）
type Banner struct {
	ID         int64      `gorm:"primaryKey;autoIncrement" json:"id"`
	Title      string     `gorm:"size:200" json:"title"`
	ImageURL   string     `gorm:"column:image_url;size:500;not null" json:"image_url"`
	LinkType   string     `gorm:"column:link_type;size:50;not null" json:"link_type"`
	LinkValue  string     `gorm:"column:link_value;size:500" json:"link_value"`
	Position   string     `gorm:"size:50;default:'home'" json:"position"`
	CityID     *int64     `gorm:"column:city_id" json:"city_id,omitempty"`
	SortOrder  int        `gorm:"column:sort_order;default:0" json:"sort_order"`
	IsActive   bool       `gorm:"column:is_active;default:true" json:"is_active"`
	StartAt    *time.Time `gorm:"column:start_at" json:"start_at"`
	EndAt      *time.Time `gorm:"column:end_at" json:"end_at"`
	ViewCount  int64      `gorm:"column:view_count;default:0" json:"view_count"`
	ClickCount int64      `gorm:"column:click_count;default:0" json:"click_count"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`
}

func (Banner) TableName() string { return "banners" }
