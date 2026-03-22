package common

import (
	"context"
	"fmt"
	"time"

	"github.com/redis/go-redis/v9"
)

// RedisClient Redis客户端实例
var RedisClient *redis.Client

// InitRedis 初始化Redis连接
func InitRedis(config *Config) (*redis.Client, error) {
	rdb := redis.NewClient(&redis.Options{
		Addr:         config.Redis.Addr(),
		Password:     config.Redis.Password,
		DB:           config.Redis.Database,
		PoolSize:     config.Redis.PoolSize,
		MinIdleConns: config.Redis.MinIdleConns,
	})

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := rdb.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("Redis连接失败: %w", err)
	}

	RedisClient = rdb
	return rdb, nil
}

// GetRedis 获取Redis客户端实例
func GetRedis() *redis.Client {
	if RedisClient == nil {
		panic("Redis未初始化")
	}
	return RedisClient
}
