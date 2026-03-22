package service

import (
	"bytes"
	"context"
	"fmt"
	"io"
	"mime/multipart"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"myanmar-property/backend/07-common"
)

// UploadService 文件上传服务接口
type UploadService interface {
	UploadImage(ctx context.Context, file multipart.File, header *multipart.FileHeader, fileType string) (string, error)
	UploadFile(ctx context.Context, file multipart.File, header *multipart.FileHeader, fileType string) (string, error)
	DeleteFile(ctx context.Context, fileURL string) error
	GenerateThumbnail(ctx context.Context, imageURL string, width, height int) (string, error)
}

// uploadService 实现
type uploadService struct {
	config     *common.Config
	storage    StorageProvider
}

// StorageProvider 存储提供者接口
type StorageProvider interface {
	Upload(ctx context.Context, key string, data []byte, contentType string) (string, error)
	Delete(ctx context.Context, key string) error
	GetURL(ctx context.Context, key string) string
}

// NewUploadService 创建上传服务
func NewUploadService(config *common.Config, storage StorageProvider) UploadService {
	return &uploadService{
		config:  config,
		storage: storage,
	}
}

// UploadImage 上传图片
func (s *uploadService) UploadImage(ctx context.Context, file multipart.File, header *multipart.FileHeader, fileType string) (string, error) {
	// 验证文件类型
	contentType := header.Header.Get("Content-Type")
	if !isValidImageType(contentType) {
		return "", common.NewError(common.ErrCodeValidation, "无效的图片格式")
	}
	
	// 验证文件大小（最大10MB）
	if header.Size > 10*1024*1024 {
		return "", common.NewError(common.ErrCodeValidation, "图片大小不能超过10MB")
	}
	
	// 读取文件内容
	data, err := io.ReadAll(file)
	if err != nil {
		return "", common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 生成文件名
	ext := filepath.Ext(header.Filename)
	if ext == "" {
		ext = ".jpg"
	}
	
	key := generateFileKey(fileType, ext)
	
	// 上传文件
	url, err := s.storage.Upload(ctx, key, data, contentType)
	if err != nil {
		return "", common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return url, nil
}

// UploadFile 上传文件
func (s *uploadService) UploadFile(ctx context.Context, file multipart.File, header *multipart.FileHeader, fileType string) (string, error) {
	// 验证文件大小（最大50MB）
	if header.Size > 50*1024*1024 {
		return "", common.NewError(common.ErrCodeValidation, "文件大小不能超过50MB")
	}
	
	// 读取文件内容
	data, err := io.ReadAll(file)
	if err != nil {
		return "", common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 生成文件名
	ext := filepath.Ext(header.Filename)
	key := generateFileKey(fileType, ext)
	
	contentType := header.Header.Get("Content-Type")
	if contentType == "" {
		contentType = "application/octet-stream"
	}
	
	// 上传文件
	url, err := s.storage.Upload(ctx, key, data, contentType)
	if err != nil {
		return "", common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return url, nil
}

// DeleteFile 删除文件
func (s *uploadService) DeleteFile(ctx context.Context, fileURL string) error {
	// 从URL中提取key
	key := extractKeyFromURL(fileURL)
	if key == "" {
		return common.NewError(common.ErrCodeValidation, "无效的文件URL")
	}
	
	return s.storage.Delete(ctx, key)
}

// GenerateThumbnail 生成缩略图
func (s *uploadService) GenerateThumbnail(ctx context.Context, imageURL string, width, height int) (string, error) {
	// 简化实现，实际需要下载图片、生成缩略图、重新上传
	return imageURL, nil
}

// isValidImageType 验证图片类型
func isValidImageType(contentType string) bool {
	validTypes := []string{
		"image/jpeg",
		"image/jpg",
		"image/png",
		"image/gif",
		"image/webp",
	}
	
	for _, t := range validTypes {
		if strings.EqualFold(contentType, t) {
			return true
		}
	}
	return false
}

// generateFileKey 生成文件key
func generateFileKey(fileType, ext string) string {
	timestamp := time.Now().UnixNano()
	random := timestamp % 10000
	
	date := time.Now().Format("2006/01/02")
	
	return fmt.Sprintf("%s/%s/%d%d%s", fileType, date, timestamp, random, ext)
}

// extractKeyFromURL 从URL中提取key
func extractKeyFromURL(url string) string {
	// 简化实现，实际应根据存储配置解析
	parts := strings.Split(url, "/")
	if len(parts) < 4 {
		return ""
	}
	return strings.Join(parts[3:], "/")
}

// LocalStorageProvider 本地存储实现
type LocalStorageProvider struct {
	BasePath string
	BaseURL  string
}

// NewLocalStorageProvider 创建本地存储
func NewLocalStorageProvider(basePath, baseURL string) StorageProvider {
	return &LocalStorageProvider{
		BasePath: basePath,
		BaseURL:  baseURL,
	}
}

// Upload 上传文件到本地 ./uploads/ 目录
func (s *LocalStorageProvider) Upload(ctx context.Context, key string, data []byte, contentType string) (string, error) {
	// Create directory if not exists
	fullPath := filepath.Join("./uploads", filepath.FromSlash(key))
	dir := filepath.Dir(fullPath)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return "", err
	}
	// Write file
	if err := os.WriteFile(fullPath, data, 0644); err != nil {
		return "", err
	}
	return s.BaseURL + "/uploads/" + key, nil
}

// Delete 删除文件
func (s *LocalStorageProvider) Delete(ctx context.Context, key string) error {
	fullPath := filepath.Join("./uploads", filepath.FromSlash(key))
	return os.Remove(fullPath)
}

// GetURL 获取文件URL
func (s *LocalStorageProvider) GetURL(ctx context.Context, key string) string {
	return s.BaseURL + "/uploads/" + key
}

// MinIOStorageProvider MinIO存储实现
type MinIOStorageProvider struct {
	client   *minio.Client
	bucket   string
	cdnHost  string
	endpoint string
	useSSL   bool
}

// NewMinIOStorageProvider 创建MinIO存储
func NewMinIOStorageProvider(cfg *common.StorageConfig) (StorageProvider, error) {
	useSSL := strings.HasPrefix(cfg.Endpoint, "https://")
	endpoint := strings.TrimPrefix(strings.TrimPrefix(cfg.Endpoint, "https://"), "http://")

	client, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.AccessKey, cfg.SecretKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		return nil, err
	}
	return &MinIOStorageProvider{
		client:   client,
		bucket:   cfg.Bucket,
		cdnHost:  cfg.CDNHost,
		endpoint: endpoint,
		useSSL:   useSSL,
	}, nil
}

// Upload 上传文件到MinIO
func (s *MinIOStorageProvider) Upload(ctx context.Context, key string, data []byte, contentType string) (string, error) {
	reader := bytes.NewReader(data)
	_, err := s.client.PutObject(ctx, s.bucket, key, reader, int64(len(data)), minio.PutObjectOptions{ContentType: contentType})
	if err != nil {
		return "", err
	}
	return s.GetURL(ctx, key), nil
}

// Delete 删除MinIO中的文件
func (s *MinIOStorageProvider) Delete(ctx context.Context, key string) error {
	return s.client.RemoveObject(ctx, s.bucket, key, minio.RemoveObjectOptions{})
}

// GetURL 获取文件URL
func (s *MinIOStorageProvider) GetURL(ctx context.Context, key string) string {
	if s.cdnHost != "" {
		return s.cdnHost + "/" + key
	}
	scheme := "http"
	if s.useSSL {
		scheme = "https"
	}
	return scheme + "://" + s.endpoint + "/" + s.bucket + "/" + key
}
