package common

import (
	"context"
	"fmt"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"gorm.io/gorm/schema"
)

// DB 数据库连接实例
var DB *gorm.DB

// InitDB 初始化数据库连接
func InitDB(config *Config) (*gorm.DB, error) {
	dbConfig := config.Database
	
	// GORM日志配置
	var logLevel logger.LogLevel
	if config.IsDevelopment() {
		logLevel = logger.Info
	} else {
		logLevel = logger.Error
	}
	
	gormLogger := logger.New(
		GetLogger(),
		logger.Config{
			SlowThreshold:             200 * time.Millisecond,
			LogLevel:                  logLevel,
			IgnoreRecordNotFoundError: true,
			Colorful:                  config.IsDevelopment(),
		},
	)
	
	db, err := gorm.Open(postgres.Open(dbConfig.DSN()), &gorm.Config{
		Logger:                 gormLogger,
		NamingStrategy:         schema.NamingStrategy{SingularTable: true},
		PrepareStmt:            true,
		SkipDefaultTransaction: true,
	})
	if err != nil {
		return nil, fmt.Errorf("连接数据库失败: %w", err)
	}
	
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("获取底层数据库连接失败: %w", err)
	}
	
	// 连接池配置
	sqlDB.SetMaxOpenConns(dbConfig.MaxOpenConns)
	sqlDB.SetMaxIdleConns(dbConfig.MaxIdleConns)
	sqlDB.SetConnMaxLifetime(dbConfig.ConnMaxLifetime)
	
	// 验证连接
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := sqlDB.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("数据库连接验证失败: %w", err)
	}
	
	DB = db
	return db, nil
}

// GetDB 获取数据库实例
func GetDB() *gorm.DB {
	if DB == nil {
		panic("数据库未初始化")
	}
	return DB
}

// Transaction 执行数据库事务
func Transaction(ctx context.Context, fn func(*gorm.DB) error) error {
	return GetDB().WithContext(ctx).Transaction(fn)
}

// ContextDB 获取带上下文的DB实例
func ContextDB(ctx context.Context) *gorm.DB {
	return GetDB().WithContext(ctx)
}

// Paginate 分页查询
func Paginate(page, pageSize int) func(db *gorm.DB) *gorm.DB {
	return func(db *gorm.DB) *gorm.DB {
		if page <= 0 {
			page = 1
		}
		if pageSize <= 0 {
			pageSize = 20
		}
		if pageSize > 100 {
			pageSize = 100
		}
		offset := (page - 1) * pageSize
		return db.Offset(offset).Limit(pageSize)
	}
}

// SoftDelete 软删除
func SoftDelete(db *gorm.DB, model interface{}) error {
	return db.Model(model).Update("deleted_at", time.Now()).Error
}
