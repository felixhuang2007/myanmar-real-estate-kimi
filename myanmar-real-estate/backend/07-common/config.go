package common

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	"github.com/spf13/viper"
)

// Config 应用配置结构
type Config struct {
	Environment string `mapstructure:"environment"`
	Debug       bool   `mapstructure:"debug"`
	
	Server ServerConfig `mapstructure:"server"`
	
	Database   DatabaseConfig   `mapstructure:"database"`
	Redis      RedisConfig      `mapstructure:"redis"`
	Elasticsearch ESConfig      `mapstructure:"elasticsearch"`
	
	JWT     JWTConfig     `mapstructure:"jwt"`
	SMS     SMSConfig     `mapstructure:"sms"`
	Storage StorageConfig `mapstructure:"storage"`
	IM      IMConfig      `mapstructure:"im"`
	
	ACN ACNConfig `mapstructure:"acn"`
}

// ServerConfig 服务器配置
type ServerConfig struct {
	Host         string        `mapstructure:"host"`
	Port         int           `mapstructure:"port"`
	ReadTimeout  time.Duration `mapstructure:"read_timeout"`
	WriteTimeout time.Duration `mapstructure:"write_timeout"`
}

// DatabaseConfig 数据库配置
type DatabaseConfig struct {
	Host            string        `mapstructure:"host"`
	Port            int           `mapstructure:"port"`
	User            string        `mapstructure:"user"`
	Password        string        `mapstructure:"password"`
	Database        string        `mapstructure:"database"`
	SSLMode         string        `mapstructure:"ssl_mode"`
	MaxOpenConns    int           `mapstructure:"max_open_conns"`
	MaxIdleConns    int           `mapstructure:"max_idle_conns"`
	ConnMaxLifetime time.Duration `mapstructure:"conn_max_lifetime"`
}

// RedisConfig Redis配置
type RedisConfig struct {
	Host         string        `mapstructure:"host"`
	Port         int           `mapstructure:"port"`
	Password     string        `mapstructure:"password"`
	Database     int           `mapstructure:"database"`
	PoolSize     int           `mapstructure:"pool_size"`
	MinIdleConns int           `mapstructure:"min_idle_conns"`
}

// ESConfig Elasticsearch配置
type ESConfig struct {
	Hosts    []string `mapstructure:"hosts"`
	Username string   `mapstructure:"username"`
	Password string   `mapstructure:"password"`
}

// JWTConfig JWT配置
type JWTConfig struct {
	Secret           string        `mapstructure:"secret"`
	AccessTokenTTL   time.Duration `mapstructure:"access_token_ttl"`
	RefreshTokenTTL  time.Duration `mapstructure:"refresh_token_ttl"`
}

// SMSConfig 短信配置
type SMSConfig struct {
	Provider  string `mapstructure:"provider"`
	AccessKey string `mapstructure:"access_key"`
	SecretKey string `mapstructure:"secret_key"`
	SignName  string `mapstructure:"sign_name"`
}

// StorageConfig 存储配置
type StorageConfig struct {
	Type      string `mapstructure:"type"`
	Endpoint  string `mapstructure:"endpoint"`
	AccessKey string `mapstructure:"access_key"`
	SecretKey string `mapstructure:"secret_key"`
	Bucket    string `mapstructure:"bucket"`
	Region    string `mapstructure:"region"`
	CDNHost   string `mapstructure:"cdn_host"`
}

// IMConfig IM配置
type IMConfig struct {
	Provider   string `mapstructure:"provider"`
	OrgName    string `mapstructure:"org_name"`
	AppName    string `mapstructure:"app_name"`
	ClientID   string `mapstructure:"client_id"`
	ClientSecret string `mapstructure:"client_secret"`
}

// ACNConfig ACN分佣配置
type ACNConfig struct {
	PlatformRatio        float64       `mapstructure:"platform_ratio"`
	MinWithdrawalAmount  int64         `mapstructure:"min_withdrawal_amount"`
	SourceProtectDays    int           `mapstructure:"source_protect_days"`
	ClientProtectDays    int           `mapstructure:"client_protect_days"`
	SettlementDelayDays  int           `mapstructure:"settlement_delay_days"`
}

var globalConfig *Config

// LoadConfig 加载配置
func LoadConfig(configPath string) (*Config, error) {
	viper.SetConfigType("yaml")
	
	if configPath != "" {
		viper.SetConfigFile(configPath)
	} else {
		// 获取项目根目录
		_, currentFile, _, _ := runtime.Caller(0)
		rootDir := filepath.Dir(filepath.Dir(currentFile))
		
		viper.AddConfigPath(rootDir)
		viper.AddConfigPath(".")
		viper.SetConfigName("config")
	}
	
	// 环境变量前缀
	viper.SetEnvPrefix("MYANMAR_PROPERTY")
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))
	viper.AutomaticEnv()
	
	// 默认值
	setDefaults()
	
	// 读取配置
	if err := viper.ReadInConfig(); err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			return nil, fmt.Errorf("读取配置文件失败: %w", err)
		}
	}
	
	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		return nil, fmt.Errorf("解析配置失败: %w", err)
	}

	// JWT_SECRET env var takes priority over config.yaml value.
	// Falls back to a dev-only default if both are empty.
	if jwtSecret := os.Getenv("JWT_SECRET"); jwtSecret != "" {
		config.JWT.Secret = jwtSecret
	} else if config.JWT.Secret == "" {
		config.JWT.Secret = "dev_fallback_secret_key_change_me!"
	}

	globalConfig = &config
	return &config, nil
}

// setDefaults 设置默认值
func setDefaults() {
	viper.SetDefault("environment", "development")
	viper.SetDefault("debug", false)
	
	viper.SetDefault("server.host", "0.0.0.0")
	viper.SetDefault("server.port", 8080)
	viper.SetDefault("server.read_timeout", "30s")
	viper.SetDefault("server.write_timeout", "30s")
	
	viper.SetDefault("database.host", "localhost")
	viper.SetDefault("database.port", 5432)
	viper.SetDefault("database.ssl_mode", "disable")
	viper.SetDefault("database.max_open_conns", 25)
	viper.SetDefault("database.max_idle_conns", 5)
	viper.SetDefault("database.conn_max_lifetime", "30m")
	
	viper.SetDefault("redis.host", "localhost")
	viper.SetDefault("redis.port", 6379)
	viper.SetDefault("redis.database", 0)
	viper.SetDefault("redis.pool_size", 10)
	viper.SetDefault("redis.min_idle_conns", 5)
	
	viper.SetDefault("jwt.access_token_ttl", "24h")
	viper.SetDefault("jwt.refresh_token_ttl", "720h")
	
	viper.SetDefault("acn.platform_ratio", 10.0)
	viper.SetDefault("acn.min_withdrawal_amount", 10000)
	viper.SetDefault("acn.source_protect_days", 30)
	viper.SetDefault("acn.client_protect_days", 30)
	viper.SetDefault("acn.settlement_delay_days", 7)
}

// GetConfig 获取全局配置
func GetConfig() *Config {
	if globalConfig == nil {
		panic("配置未加载，请先调用LoadConfig")
	}
	return globalConfig
}

// DSN 获取数据库连接字符串
func (c *DatabaseConfig) DSN() string {
	return fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=%s",
		c.Host, c.Port, c.User, c.Password, c.Database, c.SSLMode)
}

// Addr 获取Redis地址
func (c *RedisConfig) Addr() string {
	return fmt.Sprintf("%s:%d", c.Host, c.Port)
}

// IsDevelopment 是否开发环境
func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

// IsProduction 是否生产环境
func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}
