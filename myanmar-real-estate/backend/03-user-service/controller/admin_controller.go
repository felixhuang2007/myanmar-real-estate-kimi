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

// AdminController 管理员控制器
type AdminController struct {
	db *gorm.DB
}

// NewAdminController 创建管理员控制器
func NewAdminController(db *gorm.DB) *AdminController {
	return &AdminController{db: db}
}

// RegisterAdminRoutes 注册管理员路由
func (ac *AdminController) RegisterAdminRoutes(r *gin.RouterGroup) {
	admin := r.Group("/admin")
	{
		// 当前管理员信息
		admin.GET("/current", ac.AdminUserCurrent)

		// 用户管理
		users := admin.Group("/users")
		{
			users.GET("", ac.GetUserList)
			users.GET("/c-end", ac.GetCEndUserList)
			users.POST("", ac.CreateUser)
			users.PUT("/:id", ac.UpdateUser)
			users.DELETE("/:id", ac.DeleteUser)
		}

		// 房源管理
		houses := admin.Group("/houses")
		{
			houses.GET("", ac.GetHouseList)
			houses.GET("/:id", ac.GetHouseDetail)
			houses.POST("/:id/audit", ac.AuditHouse)
			houses.PUT("/:id/status", ac.UpdateHouseStatus)
			houses.DELETE("/:id", ac.DeleteHouse)
			houses.GET("/stats", ac.GetHouseStats)
		}

		// 经纪人管理
		agents := admin.Group("/agents")
		{
			agents.GET("", ac.GetAgentList)
			agents.POST("/:id/audit", ac.AuditAgent)
			agents.GET("/performance", ac.GetAgentPerformance)
		}
	}
}

// agentRow is the join result for agent list queries
type agentRow struct {
	ID           int64      `json:"id"`
	UserID       int64      `json:"user_id"`
	RealName     string     `json:"real_name"`
	Phone        string     `json:"phone"`
	CompanyName  *string    `json:"company"`
	Status       string     `json:"status"`
	Level        string     `json:"level"`
	Rating       float64    `json:"rating"`
	TotalDeals   int        `json:"deal_count"`
	TotalGMV     int64      `json:"total_gmv"`
	WorkCity     string     `json:"work_city"`
	VerifiedAt   *time.Time `json:"verified_at"`
	CreatedAt    time.Time  `json:"created_at"`
}

// GetAgentList 获取经纪人列表（真实 DB）
func (ac *AdminController) GetAgentList(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", c.DefaultQuery("current", "1")))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 10
	}
	status := c.Query("status")
	search := c.Query("search")

	if ac.db == nil {
		common.Success(c, gin.H{"list": []gin.H{}, "total": 0, "page": page, "pageSize": pageSize})
		return
	}

	query := ac.db.Table("agents a").
		Select("a.id, a.user_id, a.real_name, u.phone, c.name as company_name, a.status, a.level, a.rating, a.total_deals, a.total_gmv, a.work_city, a.verified_at, a.created_at").
		Joins("LEFT JOIN users u ON u.id = a.user_id").
		Joins("LEFT JOIN companies c ON c.id = a.company_id")

	if status != "" {
		query = query.Where("a.status = ?", status)
	}
	if search != "" {
		query = query.Where("(a.real_name LIKE ? OR u.phone LIKE ?)", "%"+search+"%", "%"+search+"%")
	}

	var total int64
	query.Count(&total)

	var rows []agentRow
	offset := (page - 1) * pageSize
	err := query.Order("a.created_at DESC").Offset(offset).Limit(pageSize).Scan(&rows).Error
	if err != nil {
		common.ServerError(c, "查询经纪人列表失败")
		return
	}

	common.Success(c, gin.H{
		"list":     rows,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// AuditAgent 审核经纪人申请
func (ac *AdminController) AuditAgent(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的经纪人ID")
		return
	}

	var req struct {
		Status string `json:"status" binding:"required"`
		Reason string `json:"reason"`
	}
	if err := c.ShouldBindJSON(&req); err != nil {
		common.BadRequest(c, err.Error())
		return
	}

	if req.Status != "active" && req.Status != "suspended" && req.Status != "pending" {
		common.BadRequest(c, "无效的状态值，允许: active, suspended, pending")
		return
	}

	if ac.db == nil {
		common.Success(c, gin.H{"message": "审核完成", "status": req.Status})
		return
	}

	updates := map[string]interface{}{
		"status":     req.Status,
		"updated_at": time.Now(),
	}
	if req.Status == "active" {
		now := time.Now()
		updates["verified_at"] = now
	}

	result := ac.db.Table("agents").Where("id = ?", id).Updates(updates)
	if result.Error != nil {
		common.ServerError(c, "审核操作失败")
		return
	}
	if result.RowsAffected == 0 {
		common.NotFound(c, "经纪人不存在")
		return
	}

	common.Success(c, gin.H{"message": "审核完成", "id": id, "status": req.Status})
}

// GetUserList 获取管理员用户列表
func (ac *AdminController) GetUserList(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("current", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))

	if ac.db == nil {
		common.Success(c, gin.H{"list": []gin.H{}, "total": 0, "current": page, "pageSize": pageSize})
		return
	}

	var users []userModel.User
	var total int64
	offset := (page - 1) * pageSize
	ac.db.Model(&userModel.User{}).Count(&total)
	ac.db.Preload("Profile").Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&users)

	list := make([]gin.H, 0, len(users))
	for _, u := range users {
		nickname := ""
		if u.Profile != nil && u.Profile.Nickname != nil {
			nickname = *u.Profile.Nickname
		}
		list = append(list, gin.H{
			"id":        u.ID,
			"phone":     u.Phone,
			"nickname":  nickname,
			"status":    u.Status,
			"user_type": u.UserType,
			"createdAt": u.CreatedAt,
		})
	}

	common.Success(c, gin.H{
		"list":     list,
		"total":    total,
		"current":  page,
		"pageSize": pageSize,
	})
}

// GetCEndUserList 获取C端用户列表
func (ac *AdminController) GetCEndUserList(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("current", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))
	keyword := c.Query("keyword")

	if ac.db == nil {
		common.Success(c, gin.H{"list": []gin.H{}, "total": 0, "current": page, "pageSize": pageSize})
		return
	}

	query := ac.db.Model(&userModel.User{}).Where("user_type = ?", "individual")
	if keyword != "" {
		query = query.Where("phone LIKE ?", "%"+keyword+"%")
	}

	var total int64
	query.Count(&total)

	var users []userModel.User
	offset := (page - 1) * pageSize
	query.Preload("Profile").Preload("Verification").
		Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&users)

	list := make([]gin.H, 0, len(users))
	for _, u := range users {
		nickname := ""
		if u.Profile != nil && u.Profile.Nickname != nil {
			nickname = *u.Profile.Nickname
		}
		verifyStatus := "unverified"
		if u.Verification != nil {
			verifyStatus = u.Verification.Status
		}
		list = append(list, gin.H{
			"id":             u.ID,
			"phone":          u.Phone,
			"nickname":       nickname,
			"identityStatus": verifyStatus,
			"status":         u.Status,
			"createdAt":      u.CreatedAt,
		})
	}

	common.Success(c, gin.H{
		"list":     list,
		"total":    total,
		"current":  page,
		"pageSize": pageSize,
	})
}

// CreateUser 创建用户
func (ac *AdminController) CreateUser(c *gin.Context) {
	common.Success(c, gin.H{
		"id":       "999",
		"username": "newuser",
		"nickname": "新用户",
		"status":   "active",
	})
}

// UpdateUser 更新用户
func (ac *AdminController) UpdateUser(c *gin.Context) {
	id := c.Param("id")
	common.Success(c, gin.H{
		"id":      id,
		"message": "更新成功",
	})
}

// DeleteUser 删除用户
func (ac *AdminController) DeleteUser(c *gin.Context) {
	common.Success(c, gin.H{
		"message": "删除成功",
	})
}

// GetHouseList 获取房源列表（真实 DB）
func (ac *AdminController) GetHouseList(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("current", c.DefaultQuery("page", "1")))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("pageSize", "10"))
	if page <= 0 {
		page = 1
	}
	if pageSize <= 0 || pageSize > 100 {
		pageSize = 10
	}
	status := c.Query("status")
	search := c.Query("search")

	if ac.db == nil {
		common.Success(c, gin.H{"list": []gin.H{}, "total": 0, "page": page, "pageSize": pageSize})
		return
	}

	query := ac.db.Model(&houseModel.House{})
	if status != "" {
		query = query.Where("status = ?", status)
	}
	if search != "" {
		query = query.Where("title LIKE ? OR address LIKE ?", "%"+search+"%", "%"+search+"%")
	}

	var total int64
	query.Count(&total)

	var houses []houseModel.House
	offset := (page - 1) * pageSize
	query.Order("created_at DESC").Offset(offset).Limit(pageSize).Find(&houses)

	list := make([]gin.H, 0, len(houses))
	for _, h := range houses {
		list = append(list, gin.H{
			"id":              h.ID,
			"house_code":      h.HouseCode,
			"title":           h.Title,
			"transaction_type": h.TransactionType,
			"price":           h.Price,
			"price_unit":      h.PriceUnit,
			"area":            h.Area,
			"address":         h.Address,
			"status":          h.Status,
			"created_at":      h.CreatedAt,
		})
	}

	common.Success(c, gin.H{
		"list":     list,
		"total":    total,
		"page":     page,
		"pageSize": pageSize,
	})
}

// GetHouseDetail 获取房源详情
func (ac *AdminController) GetHouseDetail(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的房源ID")
		return
	}

	if ac.db == nil {
		common.NotFound(c, "房源不存在")
		return
	}

	var house houseModel.House
	if err := ac.db.First(&house, id).Error; err != nil {
		common.NotFound(c, "房源不存在")
		return
	}

	common.Success(c, house)
}

// AuditHouse 审核房源
func (ac *AdminController) AuditHouse(c *gin.Context) {
	var req struct {
		Status string `json:"status" binding:"required"`
		Reason string `json:"reason"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		common.BadRequest(c, err.Error())
		return
	}

	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的房源ID")
		return
	}

	if ac.db != nil {
		updates := map[string]interface{}{
			"status":     req.Status,
			"updated_at": time.Now(),
		}
		ac.db.Model(&houseModel.House{}).Where("id = ?", id).Updates(updates)
	}

	common.Success(c, gin.H{
		"message": "审核完成",
		"id":      id,
		"status":  req.Status,
	})
}

// UpdateHouseStatus 更新房源状态
func (ac *AdminController) UpdateHouseStatus(c *gin.Context) {
	var req struct {
		Status string `json:"status" binding:"required"`
	}

	if err := c.ShouldBindJSON(&req); err != nil {
		common.BadRequest(c, err.Error())
		return
	}

	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的房源ID")
		return
	}

	if ac.db != nil {
		ac.db.Model(&houseModel.House{}).Where("id = ?", id).Update("status", req.Status)
	}

	common.Success(c, gin.H{
		"message": "状态更新成功",
		"status":  req.Status,
	})
}

// DeleteHouse 删除房源
func (ac *AdminController) DeleteHouse(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseInt(idStr, 10, 64)
	if err != nil {
		common.BadRequest(c, "无效的房源ID")
		return
	}

	if ac.db != nil {
		ac.db.Delete(&houseModel.House{}, id)
	}

	common.Success(c, gin.H{"message": "删除成功"})
}

// GetHouseStats 获取房源统计
func (ac *AdminController) GetHouseStats(c *gin.Context) {
	if ac.db == nil {
		common.Success(c, gin.H{
			"total":                0,
			"today_new":            0,
			"pending_audit":        0,
			"pending_verification": 0,
		})
		return
	}

	var total int64
	ac.db.Model(&houseModel.House{}).Count(&total)

	today := time.Now()
	dayStart := time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, today.Location())
	var todayNew int64
	ac.db.Model(&houseModel.House{}).Where("created_at >= ?", dayStart).Count(&todayNew)

	var pendingAudit int64
	ac.db.Model(&houseModel.House{}).Where("status = ?", "pending").Count(&pendingAudit)

	common.Success(c, gin.H{
		"total":                total,
		"today_new":            todayNew,
		"pending_audit":        pendingAudit,
		"pending_verification": 0,
	})
}

// GetAgentPerformance 获取经纪人业绩
func (ac *AdminController) GetAgentPerformance(c *gin.Context) {
	if ac.db == nil {
		common.Success(c, []gin.H{})
		return
	}

	type PerfRow struct {
		AgentID    int64   `json:"agent_id"`
		RealName   string  `json:"agent_name"`
		TotalDeals int     `json:"total_deals"`
		TotalGMV   int64   `json:"total_gmv"`
	}

	var rows []PerfRow
	ac.db.Table("agents").
		Select("id as agent_id, real_name, total_deals, total_gmv").
		Where("status = ?", "active").
		Order("total_gmv DESC").
		Limit(20).
		Scan(&rows)

	common.Success(c, rows)
}

// AdminUserCurrent 获取当前管理员信息
func (ac *AdminController) AdminUserCurrent(c *gin.Context) {
	common.Success(c, gin.H{
		"id":       "1",
		"username": "admin",
		"nickname": "管理员",
		"avatar":   "",
		"phone":    "+95111111111",
		"email":    "admin@myanmarhome.com",
		"role":     "admin",
		"permissions": []string{
			"user:manage",
			"house:manage",
			"agent:manage",
			"finance:view",
			"settings:manage",
		},
	})
}
