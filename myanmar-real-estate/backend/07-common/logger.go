package common

import (
	"fmt"
	"os"
	"path/filepath"
	"time"

	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gopkg.in/natefinch/lumberjack.v2"
)

// Logger 日志接口
type Logger interface {
	Debug(msg string, fields ...zap.Field)
	Info(msg string, fields ...zap.Field)
	Warn(msg string, fields ...zap.Field)
	Error(msg string, fields ...zap.Field)
	Fatal(msg string, fields ...zap.Field)
	With(fields ...zap.Field) Logger
	Printf(format string, args ...interface{}) // 实现 logger.Writer 接口，供 GORM 使用
}

// zapLogger 实现
type zapLogger struct {
	logger *zap.Logger
}

var defaultLogger Logger

// InitLogger 初始化日志
func InitLogger(config *Config) error {
	var level zapcore.Level
	switch config.Environment {
	case "development":
		level = zapcore.DebugLevel
	case "test":
		level = zapcore.InfoLevel
	default:
		level = zapcore.InfoLevel
	}

	// 编码器配置
	encoderConfig := zapcore.EncoderConfig{
		TimeKey:        "timestamp",
		LevelKey:       "level",
		NameKey:        "logger",
		CallerKey:      "caller",
		FunctionKey:    zapcore.OmitKey,
		MessageKey:     "msg",
		StacktraceKey:  "stacktrace",
		LineEnding:     zapcore.DefaultLineEnding,
		EncodeLevel:    zapcore.LowercaseLevelEncoder,
		EncodeTime:     zapcore.ISO8601TimeEncoder,
		EncodeDuration: zapcore.SecondsDurationEncoder,
		EncodeCaller:   zapcore.ShortCallerEncoder,
	}

	var cores []zapcore.Core

	// 控制台输出（开发环境）
	if config.IsDevelopment() {
		consoleEncoder := zapcore.NewConsoleEncoder(encoderConfig)
		consoleCore := zapcore.NewCore(
			consoleEncoder,
			zapcore.AddSync(os.Stdout),
			level,
		)
		cores = append(cores, consoleCore)
	}

	// 文件输出
	logDir := "./logs"
	if err := os.MkdirAll(logDir, 0755); err != nil {
		return err
	}

	// 应用日志
	appLogPath := filepath.Join(logDir, "app.log")
	appWriter := &lumberjack.Logger{
		Filename:   appLogPath,
		MaxSize:    100, // MB
		MaxBackups: 10,
		MaxAge:     30, // days
		Compress:   true,
	}
	jsonEncoder := zapcore.NewJSONEncoder(encoderConfig)
	fileCore := zapcore.NewCore(
		jsonEncoder,
		zapcore.AddSync(appWriter),
		level,
	)
	cores = append(cores, fileCore)

	// 错误日志（单独文件）
	errorLogPath := filepath.Join(logDir, "error.log")
	errorWriter := &lumberjack.Logger{
		Filename:   errorLogPath,
		MaxSize:    100,
		MaxBackups: 10,
		MaxAge:     30,
		Compress:   true,
	}
	highPriority := zap.LevelEnablerFunc(func(lvl zapcore.Level) bool {
		return lvl >= zapcore.ErrorLevel
	})
	errorCore := zapcore.NewCore(
		jsonEncoder,
		zapcore.AddSync(errorWriter),
		highPriority,
	)
	cores = append(cores, errorCore)

	// 创建logger
	core := zapcore.NewTee(cores...)
	logger := zap.New(core, 
		zap.AddCaller(),
		zap.AddCallerSkip(1),
		zap.AddStacktrace(zapcore.ErrorLevel),
	)

	defaultLogger = &zapLogger{logger: logger}
	return nil
}

// GetLogger 获取默认日志实例
func GetLogger() Logger {
	if defaultLogger == nil {
		// 初始化一个默认的logger
		logger, _ := zap.NewDevelopment()
		defaultLogger = &zapLogger{logger: logger}
	}
	return defaultLogger
}

// Debug 调试日志
func (l *zapLogger) Debug(msg string, fields ...zap.Field) {
	l.logger.Debug(msg, fields...)
}

// Info 信息日志
func (l *zapLogger) Info(msg string, fields ...zap.Field) {
	l.logger.Info(msg, fields...)
}

// Warn 警告日志
func (l *zapLogger) Warn(msg string, fields ...zap.Field) {
	l.logger.Warn(msg, fields...)
}

// Error 错误日志
func (l *zapLogger) Error(msg string, fields ...zap.Field) {
	l.logger.Error(msg, fields...)
}

// Fatal 致命错误日志
func (l *zapLogger) Fatal(msg string, fields ...zap.Field) {
	l.logger.Fatal(msg, fields...)
}

// Printf 实现 logger.Writer 接口，供 GORM 使用
func (l *zapLogger) Printf(format string, args ...interface{}) {
	l.logger.Info(fmt.Sprintf(format, args...))
}

// With 添加字段
func (l *zapLogger) With(fields ...zap.Field) Logger {
	return &zapLogger{logger: l.logger.With(fields...)}
}

// 便捷函数
func Debug(msg string, fields ...zap.Field) {
	GetLogger().Debug(msg, fields...)
}

func Info(msg string, fields ...zap.Field) {
	GetLogger().Info(msg, fields...)
}

func Warn(msg string, fields ...zap.Field) {
	GetLogger().Warn(msg, fields...)
}

func Error(msg string, fields ...zap.Field) {
	GetLogger().Error(msg, fields...)
}

func Fatal(msg string, fields ...zap.Field) {
	GetLogger().Fatal(msg, fields...)
}

// WithContext 添加上下文信息
func WithContext(requestID string, userID int64) Logger {
	fields := []zap.Field{
		zap.String("request_id", requestID),
	}
	if userID > 0 {
		fields = append(fields, zap.Int64("user_id", userID))
	}
	return GetLogger().With(fields...)
}

// Field 便捷创建字段的函数
func String(key, val string) zap.Field {
	return zap.String(key, val)
}

func Int(key string, val int) zap.Field {
	return zap.Int(key, val)
}

func Int64(key string, val int64) zap.Field {
	return zap.Int64(key, val)
}

func Float64(key string, val float64) zap.Field {
	return zap.Float64(key, val)
}

func Bool(key string, val bool) zap.Field {
	return zap.Bool(key, val)
}

func ErrorField(err error) zap.Field {
	return zap.Error(err)
}

func Time(key string, val time.Time) zap.Field {
	return zap.Time(key, val)
}

func Duration(key string, val time.Duration) zap.Field {
	return zap.Duration(key, val)
}

func Any(key string, val interface{}) zap.Field {
	return zap.Any(key, val)
}
