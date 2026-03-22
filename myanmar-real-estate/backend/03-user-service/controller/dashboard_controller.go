package controller

import (
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"

	houseModel "myanmar-property/backend/04-house-service"
	userModel "myanmar-property/backend/03-user-service/model"
	"myanmar-property/backend/07-common"
)

// DashboardController 仪表盘控制器
type DashboardController struct {
	db *gorm.DB
}

// NewDashboardController 创建仪表盘控制器
func NewDashboardController(db *gorm.DB) *DashboardController {
	return &DashboardController{db: db}
}

// RegisterDashboardRoutes 注册仪表盘路由
func (dc *DashboardController) RegisterDashboardRoutes(r *gin.RouterGroup) {
	admin := r.Group("/admin")
	{
		dashboard := admin.Group("/dashboard")
		{
			dashboard.GET("/stats", dc.GetStats)
			dashboard.GET("/trend/users", dc.GetUserTrend)
			dashboard.GET("/trend/houses", dc.GetHouseTrend)
			dashboard.GET("/trend/deals", dc.GetDealTrend)
		}
	}
}

// GetStats 获取仪表盘统计数据
func (dc *DashboardController) GetStats(c *gin.Context) {
	if dc.db == nil {
		common.Success(c, gin.H{
			"total_users":   0,
			"total_agents":  0,
			"total_houses":  0,
			"monthly_deals": 0,
			"monthly_gmv":   0,
		})
		return
	}

	var userCount int64
	dc.db.Model(&userModel.User{}).Count(&userCount)

	// Agents are in a separate 'agents' table
	var agentCount int64
	dc.db.Table("agents").Where("status = ?", "active").Count(&agentCount)

	var houseCount int64
	dc.db.Model(&houseModel.House{}).Where("status = ?", "active").Count(&houseCount)

	monthStart := time.Now().AddDate(0, -1, 0)

	var dealCount int64
	dc.db.Table("acn_transactions").
		Where("status = ?", "confirmed").
		Where("created_at >= ?", monthStart).
		Count(&dealCount)

	var gmv struct{ Total int64 }
	dc.db.Table("acn_transactions").
		Select("COALESCE(SUM(transaction_amount), 0) as total").
		Where("status = ?", "confirmed").
		Where("created_at >= ?", monthStart).
		Scan(&gmv)

	common.Success(c, gin.H{
		"total_users":   userCount,
		"total_agents":  agentCount,
		"total_houses":  houseCount,
		"monthly_deals": dealCount,
		"monthly_gmv":   gmv.Total,
	})
}

// GetUserTrend 获取用户增长趋势
func (dc *DashboardController) GetUserTrend(c *gin.Context) {
	days, _ := strconv.Atoi(c.DefaultQuery("days", "7"))
	if days <= 0 || days > 90 {
		days = 7
	}

	type DayCount struct {
		Date  string `json:"date"`
		Count int64  `json:"count"`
	}

	result := make([]DayCount, 0, days)

	if dc.db == nil {
		for i := days - 1; i >= 0; i-- {
			day := time.Now().AddDate(0, 0, -i)
			result = append(result, DayCount{Date: day.Format("2006-01-02"), Count: 0})
		}
		common.Success(c, result)
		return
	}

	for i := days - 1; i >= 0; i-- {
		day := time.Now().AddDate(0, 0, -i)
		start := time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, day.Location())
		end := start.AddDate(0, 0, 1)
		var count int64
		dc.db.Model(&userModel.User{}).
			Where("created_at >= ? AND created_at < ?", start, end).
			Count(&count)
		result = append(result, DayCount{Date: start.Format("2006-01-02"), Count: count})
	}

	common.Success(c, result)
}

// GetHouseTrend 获取房源增长趋势
func (dc *DashboardController) GetHouseTrend(c *gin.Context) {
	days, _ := strconv.Atoi(c.DefaultQuery("days", "7"))
	if days <= 0 || days > 90 {
		days = 7
	}

	type DayCount struct {
		Date  string `json:"date"`
		Count int64  `json:"count"`
	}

	result := make([]DayCount, 0, days)

	if dc.db == nil {
		for i := days - 1; i >= 0; i-- {
			day := time.Now().AddDate(0, 0, -i)
			result = append(result, DayCount{Date: day.Format("2006-01-02"), Count: 0})
		}
		common.Success(c, result)
		return
	}

	for i := days - 1; i >= 0; i-- {
		day := time.Now().AddDate(0, 0, -i)
		start := time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, day.Location())
		end := start.AddDate(0, 0, 1)
		var count int64
		dc.db.Model(&houseModel.House{}).
			Where("created_at >= ? AND created_at < ?", start, end).
			Count(&count)
		result = append(result, DayCount{Date: start.Format("2006-01-02"), Count: count})
	}

	common.Success(c, result)
}

// GetDealTrend 获取交易趋势
func (dc *DashboardController) GetDealTrend(c *gin.Context) {
	days, _ := strconv.Atoi(c.DefaultQuery("days", "7"))
	if days <= 0 || days > 90 {
		days = 7
	}

	type DayCount struct {
		Date  string `json:"date"`
		Count int64  `json:"count"`
	}

	result := make([]DayCount, 0, days)

	if dc.db == nil {
		for i := days - 1; i >= 0; i-- {
			day := time.Now().AddDate(0, 0, -i)
			result = append(result, DayCount{Date: day.Format("2006-01-02"), Count: 0})
		}
		common.Success(c, result)
		return
	}

	for i := days - 1; i >= 0; i-- {
		day := time.Now().AddDate(0, 0, -i)
		start := time.Date(day.Year(), day.Month(), day.Day(), 0, 0, 0, 0, day.Location())
		end := start.AddDate(0, 0, 1)
		var count int64
		dc.db.Table("acn_transactions").
			Where("status = ?", "confirmed").
			Where("created_at >= ? AND created_at < ?", start, end).
			Count(&count)
		result = append(result, DayCount{Date: start.Format("2006-01-02"), Count: count})
	}

	common.Success(c, result)
}
