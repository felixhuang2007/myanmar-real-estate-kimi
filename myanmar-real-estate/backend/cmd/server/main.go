package main

import (
	"context"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"gorm.io/gorm"

	userController "myanmar-property/backend/03-user-service/controller"
	userRepository "myanmar-property/backend/03-user-service/repository"
	userService "myanmar-property/backend/03-user-service/service"

	houseController "myanmar-property/backend/04-house-service/controller"
	houseService "myanmar-property/backend/04-house-service"

	acnController "myanmar-property/backend/05-acn-service/controller"
	acnRepository "myanmar-property/backend/05-acn-service/repository"
	acnSvc "myanmar-property/backend/05-acn-service/service"

	appointmentController "myanmar-property/backend/06-appointment-service/controller"
	appointmentRepository "myanmar-property/backend/06-appointment-service/repository"
	appointmentSvc "myanmar-property/backend/06-appointment-service/service"

	"myanmar-property/backend/07-common"

	imController "myanmar-property/backend/08-im-service/controller"
	imRepository "myanmar-property/backend/08-im-service/repository"
	imSvc "myanmar-property/backend/08-im-service/service"

	verificationController "myanmar-property/backend/09-verification-service/controller"
	verificationRepository "myanmar-property/backend/09-verification-service/repository"
	verificationSvc "myanmar-property/backend/09-verification-service/service"

	uploadController "myanmar-property/backend/11-upload-service/controller"
	uploadSvcPkg "myanmar-property/backend/11-upload-service"

	clientController "myanmar-property/backend/12-client-service/controller"
	clientRepository "myanmar-property/backend/12-client-service/repository"
	clientSvc "myanmar-property/backend/12-client-service/service"

	opsController "myanmar-property/backend/13-ops-service/controller"
	opsRepository "myanmar-property/backend/13-ops-service/repository"
	opsSvc "myanmar-property/backend/13-ops-service/service"

	promoterController "myanmar-property/backend/14-promoter-service/controller"
	promoterRepository "myanmar-property/backend/14-promoter-service/repository"
	promoterSvc "myanmar-property/backend/14-promoter-service/service"
)

func main() {
	// 加载配置
	config, err := common.LoadConfig("")
	if err != nil {
		panic("加载配置失败: " + err.Error())
	}

	// 初始化日志
	if err := common.InitLogger(config); err != nil {
		panic("初始化日志失败: " + err.Error())
	}

	common.Info("服务器启动中...",
		common.String("environment", config.Environment),
		common.String("port", fmt.Sprintf("%d", config.Server.Port)))

	// 初始化数据库（失败时继续运行）
	db, err := common.InitDB(config)
	if err != nil {
		common.Warn("数据库初始化失败，运行在无数据库模式", common.ErrorField(err))
		db = nil
	}

	// 初始化Redis（失败时继续运行）
	rdb, err := common.InitRedis(config)
	if err != nil {
		common.Warn("Redis初始化失败，Token黑名单功能不可用", common.ErrorField(err))
		rdb = nil
	}

	// 设置Gin模式
	if config.IsProduction() {
		gin.SetMode(gin.ReleaseMode)
	}

	// 创建Gin引擎
	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(corsMiddleware())
	r.Use(requestIDMiddleware())
	r.Use(loggingMiddleware())

	// 健康检查
	r.GET("/health", func(c *gin.Context) {
		common.Success(c, gin.H{
			"status": "ok",
			"time":   time.Now().Unix(),
		})
	})

	// API路由组 - 兼容 /v1 和 /api 前缀
	v1 := r.Group("/v1")
	api := r.Group("/api")

	// 创建JWT服务（共享实例，用于多模块认证中间件）
	jwtSvc := userService.NewJWTService(config)

	// 初始化用户模块 (同时注册到 /v1 和 /api)
	initUserModule(v1, db, config, rdb)
	initUserModule(api, db, config, rdb)

	// 初始化仪表盘模块 (同时注册到 /v1 和 /api)
	initDashboardModule(v1, db)
	initDashboardModule(api, db)

	// 初始化管理员模块 (同时注册到 /v1 和 /api)
	initAdminModule(v1, db)
	initAdminModule(api, db)

	// 初始化房源模块 (同时注册到 /v1 和 /api)
	initHouseModule(v1, db, config, jwtSvc, rdb)
	initHouseModule(api, db, config, jwtSvc, rdb)

	// 初始化ACN模块 (同时注册到 /v1 和 /api)
	initACNModule(v1, db, config, jwtSvc, rdb)
	initACNModule(api, db, config, jwtSvc, rdb)

	// 初始化预约模块 (同时注册到 /v1 和 /api)
	initAppointmentModule(v1, db, config, jwtSvc, rdb)
	initAppointmentModule(api, db, config, jwtSvc, rdb)

	// 初始化IM模块 (同时注册到 /v1 和 /api)
	initIMModule(v1, db, config, jwtSvc, rdb)
	initIMModule(api, db, config, jwtSvc, rdb)

	// 初始化验真模块 (同时注册到 /v1 和 /api)
	initVerificationModule(v1, db, config, jwtSvc, rdb)
	initVerificationModule(api, db, config, jwtSvc, rdb)

	// 初始化客户模块 (同时注册到 /v1 和 /api)
	initClientModule(v1, db, config, jwtSvc, rdb)
	initClientModule(api, db, config, jwtSvc, rdb)

	// 初始化上传模块 (同时注册到 /v1 和 /api)
	initUploadModule(v1, config, jwtSvc, rdb)
	initUploadModule(api, config, jwtSvc, rdb)

	// 初始化运营模块（Banner）(同时注册到 /v1 和 /api)
	initOpsModule(v1, db)
	initOpsModule(api, db)

	// 初始化地推模块 (同时注册到 /v1 和 /api)
	initPromoterModule(v1, db, config, jwtSvc, rdb)
	initPromoterModule(api, db, config, jwtSvc, rdb)

	// 静态文件服务（本地存储模式）
	r.Static("/uploads", "./uploads")

	// 启动服务器
	srv := &http.Server{
		Addr:    fmt.Sprintf("%s:%d", config.Server.Host, config.Server.Port),
		Handler: r,
	}

	// 优雅关闭
	go func() {
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			common.Fatal("服务器启动失败", common.ErrorField(err))
		}
	}()

	common.Info("服务器启动成功", common.String("addr", srv.Addr))

	// 等待中断信号
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	common.Info("服务器关闭中...")

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		common.Error("服务器关闭失败", common.ErrorField(err))
	}

	common.Info("服务器已关闭")
}

// initUserModule 初始化用户模块
func initUserModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, rdb *redis.Client) {
	// 初始化依赖
	userRepo := userRepository.NewUserRepository(db)
	jwtSvc := userService.NewJWTService(config)
	smsService := userService.NewSMSService(config)
	userSvc := userService.NewUserService(userRepo, config, smsService, jwtSvc, rdb)
	userCtrl := userController.NewUserController(userSvc, jwtSvc, rdb, db)

	// 注册路由
	userCtrl.RegisterRoutes(r)
}

// requestIDMiddleware 请求ID中间件
func requestIDMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		requestID := c.GetHeader("X-Request-ID")
		if requestID == "" {
			requestID = generateRequestID()
		}
		c.Set("request_id", requestID)
		c.Header("X-Request-ID", requestID)
		c.Next()
	}
}

// loggingMiddleware 日志中间件
func loggingMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		raw := c.Request.URL.RawQuery

		c.Next()

		latency := time.Since(start)
		clientIP := c.ClientIP()
		method := c.Request.Method
		statusCode := c.Writer.Status()

		if raw != "" {
			path = path + "?" + raw
		}

		logger := common.GetLogger()
		logger.Info("HTTP请求",
			common.String("request_id", c.GetString("request_id")),
			common.String("client_ip", clientIP),
			common.String("method", method),
			common.String("path", path),
			common.Int("status", statusCode),
			common.Duration("latency", latency),
		)
	}
}

// generateRequestID 生成请求ID
func generateRequestID() string {
	return fmt.Sprintf("%d%d", time.Now().UnixNano(), rand.Intn(9999))
}

// corsMiddleware CORS中间件
func corsMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "*")
		c.Header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization, X-Request-ID, X-Device-ID")
		c.Header("Access-Control-Max-Age", "86400")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	}
}

// initDashboardModule 初始化仪表盘模块
func initDashboardModule(r *gin.RouterGroup, db *gorm.DB) {
	dashboardCtrl := userController.NewDashboardController(db)
	dashboardCtrl.RegisterDashboardRoutes(r)
}

// initAdminModule 初始化管理员模块
func initAdminModule(r *gin.RouterGroup, db *gorm.DB) {
	adminCtrl := userController.NewAdminController(db)
	adminCtrl.RegisterAdminRoutes(r)
}

// initOpsModule 初始化运营模块（Banner）
func initOpsModule(r *gin.RouterGroup, db *gorm.DB) {
	if db == nil {
		return
	}
	bannerRepo := opsRepository.NewBannerRepository(db)
	bannerService := opsSvc.NewBannerService(bannerRepo)
	ctrl := opsController.NewOpsController(bannerService)
	ctrl.RegisterRoutes(r)
}

// initHouseModule 初始化房源模块
func initHouseModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return // 无数据库模式跳过
	}
	// 构建ES URL（使用Hosts列表的第一个条目，为空则禁用ES搜索）
	esURL := ""
	if len(config.Elasticsearch.Hosts) > 0 && config.Elasticsearch.Hosts[0] != "" {
		esURL = config.Elasticsearch.Hosts[0]
	}
	// 初始化依赖
	houseRepo := houseService.NewHouseRepository(db, esURL)
	houseSvc := houseService.NewHouseService(houseRepo, config)
	houseCtrl := houseController.NewHouseController(houseSvc)

	// 注册路由
	houseCtrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initACNModule 初始化ACN分佣模块
func initACNModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return
	}
	acnRepo := acnRepository.NewACNRepository(db)
	acnService := acnSvc.NewACNService(acnRepo, config)
	ctrl := acnController.NewACNController(acnService)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initAppointmentModule 初始化预约模块
func initAppointmentModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return
	}
	appointmentRepo := appointmentRepository.NewAppointmentRepository(db)
	appointmentService := appointmentSvc.NewAppointmentService(appointmentRepo, config)
	ctrl := appointmentController.NewAppointmentController(appointmentService)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initIMModule 初始化IM模块
func initIMModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return
	}
	imRepo := imRepository.NewIMRepository(db)
	imService := imSvc.NewIMService(imRepo, config)
	ctrl := imController.NewIMController(imService)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initVerificationModule 初始化验真模块
func initVerificationModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return
	}
	verificationRepo := verificationRepository.NewVerificationRepository(db)
	verificationService := verificationSvc.NewVerificationService(verificationRepo, config)
	ctrl := verificationController.NewVerificationController(verificationService)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initUploadModule 初始化上传模块
func initUploadModule(r *gin.RouterGroup, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	baseURL := fmt.Sprintf("http://%s:%d", config.Server.Host, config.Server.Port)
	var storageProvider uploadSvcPkg.StorageProvider
	if config.Storage.Endpoint != "" {
		provider, err := uploadSvcPkg.NewMinIOStorageProvider(&config.Storage)
		if err != nil {
			common.Warn("MinIO init failed, falling back to local storage", common.ErrorField(err))
			storageProvider = &uploadSvcPkg.LocalStorageProvider{BaseURL: baseURL}
		} else {
			storageProvider = provider
		}
	} else {
		storageProvider = &uploadSvcPkg.LocalStorageProvider{BaseURL: baseURL}
	}
	uploadSvc := uploadSvcPkg.NewUploadService(config, storageProvider)
	ctrl := uploadController.NewUploadController(uploadSvc)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initClientModule 初始化客户模块
func initClientModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return
	}
	clientRepo := clientRepository.NewClientRepository(db)
	clientService := clientSvc.NewClientService(clientRepo, config)
	ctrl := clientController.NewClientController(clientService)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}

// initPromoterModule 初始化地推模块
func initPromoterModule(r *gin.RouterGroup, db *gorm.DB, config *common.Config, jwtSvc userService.JWTService, rdb *redis.Client) {
	if db == nil {
		return
	}
	promoterRepo := promoterRepository.NewPromoterRepository(db)
	promoterService := promoterSvc.NewPromoterService(promoterRepo, config)
	ctrl := promoterController.NewPromoterController(promoterService)
	ctrl.RegisterRoutes(r, jwtSvc, rdb)
}
