package model

import (
	"time"

	"gorm.io/gorm"
)

// Banner 横幅广告模型
type Banner struct {
	ID         int64          `gorm:"primaryKey;autoIncrement" json:"id"`
	Title      string         `gorm:"size:200;not null" json:"title"`
	ImageURL   string         `gorm:"column:image_url;size:500;not null" json:"image_url"`
	LinkURL    string         `gorm:"column:link_url;size:500" json:"link_url"`
	LinkType   string         `gorm:"column:link_type;size:20;default:'house'" json:"link_type"` // house/url/none
	LinkID     *int64         `gorm:"column:link_id" json:"link_id"`
	Position   string         `gorm:"size:20;default:'home'" json:"position"` // home/search/detail
	SortOrder  int            `gorm:"column:sort_order;default:0" json:"sort_order"`
	Status     string         `gorm:"size:10;default:'active'" json:"status"` // active/inactive
	StartAt    *time.Time     `gorm:"column:start_at" json:"start_at"`
	EndAt      *time.Time     `gorm:"column:end_at" json:"end_at"`
	ClickCount int64          `gorm:"column:click_count;default:0" json:"click_count"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"-"`
}

func (Banner) TableName() string { return "banners" }
