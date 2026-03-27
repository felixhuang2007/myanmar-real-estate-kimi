package service

import (
	"context"
	"crypto/rand"
	"fmt"
	"math/big"
	"regexp"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"golang.org/x/crypto/bcrypt"

	"myanmar-property/backend/03-user-service/model"
	"myanmar-property/backend/03-user-service/repository"
	"myanmar-property/backend/07-common"
)

// UserService 用户服务接口
type UserService interface {
	// 认证相关
	SendVerificationCode(ctx context.Context, phone, codeType string) (string, error)
	Register(ctx context.Context, req *RegisterRequest) (*AuthResponse, error)
	Login(ctx context.Context, req *LoginRequest) (*AuthResponse, error)
	LoginWithPassword(ctx context.Context, req *PasswordLoginRequest) (*AuthResponse, error)
	RefreshToken(ctx context.Context, refreshToken string) (*AuthResponse, error)
	Logout(ctx context.Context, userID int64, token string) error
	ResetPassword(ctx context.Context, req *ResetPasswordRequest) error
	
	// 用户资料
	GetCurrentUser(ctx context.Context, userID int64) (*UserInfo, error)
	UpdateProfile(ctx context.Context, userID int64, req *UpdateProfileRequest) error
	UploadAvatar(ctx context.Context, userID int64, fileData []byte, fileName string) (string, error)
	ChangePassword(ctx context.Context, userID int64, req *ChangePasswordRequest) error
	
	// 实名认证
	SubmitVerification(ctx context.Context, userID int64, req *SubmitVerificationRequest) error
	GetVerificationStatus(ctx context.Context, userID int64) (*VerificationInfo, error)
}

// 请求/响应结构
type RegisterRequest struct {
	Phone       string `json:"phone" binding:"required"`
	Code        string `json:"code" binding:"required"`
	Password    string `json:"password,omitempty"`
	InviteCode  string `json:"invite_code,omitempty"`
}

type LoginRequest struct {
	Phone     string `json:"phone" binding:"required"`
	Code      string `json:"code" binding:"required"`
	DeviceID  string `json:"device_id" binding:"required"`
}

type PasswordLoginRequest struct {
	Phone     string `json:"phone" binding:"required"`
	Password  string `json:"password" binding:"required"`
	DeviceID  string `json:"device_id" binding:"required"`
}

type ResetPasswordRequest struct {
	Phone       string `json:"phone" binding:"required"`
	Code        string `json:"code" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

type UpdateProfileRequest struct {
	Nickname *string `json:"nickname,omitempty"`
	Avatar   *string `json:"avatar,omitempty"`
	Gender   *string `json:"gender,omitempty"`
	Birthday *string `json:"birthday,omitempty"`
	Bio      *string `json:"bio,omitempty"`
}

type SubmitVerificationRequest struct {
	RealName     string `json:"real_name" binding:"required"`
	IDCardNumber string `json:"id_card_number" binding:"required"`
	IDCardFront  string `json:"id_card_front" binding:"required"`
	IDCardBack   *string `json:"id_card_back,omitempty"`
}

type ChangePasswordRequest struct {
	OldPassword string `json:"old_password" binding:"required"`
	NewPassword string `json:"new_password" binding:"required,min=6"`
}

type AuthResponse struct {
	UserID       int64     `json:"user_id"`
	UUID         string    `json:"uuid"`
	Token        string    `json:"token"`
	RefreshToken string    `json:"refresh_token"`
	ExpiresAt    time.Time `json:"expires_at"`
	IsNewUser    bool      `json:"is_new_user"`
}

type UserInfo struct {
	UserID        int64              `json:"user_id"`
	UUID          string             `json:"uuid"`
	Phone         string             `json:"phone"`
	Email         *string            `json:"email,omitempty"`
	Status        string             `json:"status"`
	IsVerified    bool               `json:"is_verified"`
	Profile       *model.UserProfile `json:"profile,omitempty"`
	Verification  *VerificationInfo  `json:"verification,omitempty"`
}

type VerificationInfo struct {
	RealName     string     `json:"real_name,omitempty"`
	IDCardNumber string     `json:"id_card_number,omitempty"`
	Status       string     `json:"status"`
	VerifiedAt   *time.Time `json:"verified_at,omitempty"`
}

// userService 实现
type userService struct {
	userRepo    repository.UserRepository
	config      *common.Config
	smsService  SMSService
	jwtService  JWTService
	redisClient *redis.Client
}

// NewUserService 创建用户服务实例
func NewUserService(
	userRepo repository.UserRepository,
	config *common.Config,
	smsService SMSService,
	jwtService JWTService,
	redisClient *redis.Client,
) UserService {
	return &userService{
		userRepo:    userRepo,
		config:      config,
		smsService:  smsService,
		jwtService:  jwtService,
		redisClient: redisClient,
	}
}

// 手机号验证正则（缅甸）
var myanmarPhoneRegex = regexp.MustCompile(`^\+95[0-9]{8,10}$`)

// validatePhone 验证手机号格式
func (s *userService) validatePhone(phone string) error {
	if !myanmarPhoneRegex.MatchString(phone) {
		return common.NewError(common.ErrCodeInvalidPhone)
	}
	return nil
}

// generateCode 生成6位验证码
func generateCode() string {
	n, _ := rand.Int(rand.Reader, big.NewInt(900000))
	return fmt.Sprintf("%06d", n.Int64()+100000)
}

// SendVerificationCode 发送验证码
func (s *userService) SendVerificationCode(ctx context.Context, phone, codeType string) (string, error) {
	// 验证手机号
	if err := s.validatePhone(phone); err != nil {
		return "", err
	}

	// 检查发送频率限制
	latestCode, err := s.userRepo.GetLatestSMSCode(ctx, phone, codeType)
	if err != nil {
		return "", common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	if latestCode != nil && time.Since(latestCode.CreatedAt) < 60*time.Second {
		return "", common.NewError(common.ErrCodeTooManyRequests, "发送过于频繁，请稍后再试")
	}

	// 生成验证码
	code := generateCode()

	// 保存验证码
	smsCode := &model.SMSVerificationCode{
		Phone:     phone,
		Code:      code,
		Type:      codeType,
		ExpiredAt: time.Now().Add(5 * time.Minute),
	}

	if err := s.userRepo.CreateSMSCode(ctx, smsCode); err != nil {
		return "", common.NewError(common.ErrCodeInternalServer, err.Error())
	}

	// 发送短信（开发环境可跳过）
	if s.config.IsProduction() {
		if err := s.smsService.Send(ctx, phone, code); err != nil {
			return "", common.NewError(common.ErrCodeInternalServer, "短信发送失败")
		}
	}

	return code, nil
}

// verifyCode 验证验证码
func (s *userService) verifyCode(ctx context.Context, phone, code, codeType string) error {
	latestCode, err := s.userRepo.GetLatestSMSCode(ctx, phone, codeType)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if latestCode == nil {
		return common.NewError(common.ErrCodeInvalidCode, "验证码不存在")
	}
	
	if latestCode.IsUsed() {
		return common.NewError(common.ErrCodeInvalidCode, "验证码已使用")
	}
	
	if latestCode.IsExpired() {
		return common.NewError(common.ErrCodeCodeExpired)
	}
	
	if latestCode.AttemptCount >= 5 {
		return common.NewError(common.ErrCodeInvalidCode, "错误次数过多，请重新获取")
	}
	
	if latestCode.Code != code {
		s.userRepo.IncrementAttemptCount(ctx, latestCode.ID)
		return common.NewError(common.ErrCodeInvalidCode, "验证码错误")
	}
	
	// 标记验证码已使用
	return s.userRepo.MarkSMSCodeUsed(ctx, latestCode.ID)
}

// Register 用户注册
func (s *userService) Register(ctx context.Context, req *RegisterRequest) (*AuthResponse, error) {
	// 验证手机号
	if err := s.validatePhone(req.Phone); err != nil {
		return nil, err
	}
	
	// 验证验证码
	if err := s.verifyCode(ctx, req.Phone, req.Code, "register"); err != nil {
		return nil, err
	}
	
	// 检查用户是否已存在
	existingUser, err := s.userRepo.FindByPhone(ctx, req.Phone)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if existingUser != nil {
		return nil, common.NewError(common.ErrCodeUserExists)
	}
	
	// 创建用户
	user := &model.User{
		UUID:     uuid.New().String(),
		Phone:    req.Phone,
		Status:   "active",
		UserType: "individual",
	}
	
	// 设置密码（如有）
	if req.Password != "" {
		hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
		if err != nil {
			return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
		}
		user.PasswordHash = string(hash)
	}
	
	if err := s.userRepo.Create(ctx, user); err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	// 生成Token
	token, refreshToken, expiresAt, err := s.jwtService.GenerateToken(user.ID, user.UUID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return &AuthResponse{
		UserID:       user.ID,
		UUID:         user.UUID,
		Token:        token,
		RefreshToken: refreshToken,
		ExpiresAt:    expiresAt,
		IsNewUser:    true,
	}, nil
}

// Login 验证码登录
func (s *userService) Login(ctx context.Context, req *LoginRequest) (*AuthResponse, error) {
	// 验证手机号
	if err := s.validatePhone(req.Phone); err != nil {
		return nil, err
	}
	
	// 验证验证码
	if err := s.verifyCode(ctx, req.Phone, req.Code, "login"); err != nil {
		return nil, err
	}
	
	// 查找用户
	user, err := s.userRepo.FindByPhone(ctx, req.Phone)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if user == nil {
		return nil, common.NewError(common.ErrCodeUserNotFound)
	}
	
	if user.Status != "active" {
		return nil, common.NewError(common.ErrCodeForbidden, "账号状态异常")
	}
	
	// 更新登录信息
	if err := s.userRepo.UpdateLoginInfo(ctx, user.ID); err != nil {
		common.Error("更新登录信息失败", common.ErrorField(err))
	}
	
	// 生成Token
	token, refreshToken, expiresAt, err := s.jwtService.GenerateToken(user.ID, user.UUID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return &AuthResponse{
		UserID:       user.ID,
		UUID:         user.UUID,
		Token:        token,
		RefreshToken: refreshToken,
		ExpiresAt:    expiresAt,
		IsNewUser:    false,
	}, nil
}

// LoginWithPassword 密码登录
func (s *userService) LoginWithPassword(ctx context.Context, req *PasswordLoginRequest) (*AuthResponse, error) {
	// 查找用户
	user, err := s.userRepo.FindByPhone(ctx, req.Phone)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if user == nil {
		return nil, common.NewError(common.ErrCodeUserNotFound)
	}
	
	if user.Status != "active" {
		return nil, common.NewError(common.ErrCodeForbidden, "账号状态异常")
	}
	
	// 验证密码
	if user.PasswordHash == "" {
		return nil, common.NewError(common.ErrCodePasswordIncorrect, "未设置密码，请使用验证码登录")
	}
	
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.Password)); err != nil {
		return nil, common.NewError(common.ErrCodePasswordIncorrect)
	}
	
	// 更新登录信息
	if err := s.userRepo.UpdateLoginInfo(ctx, user.ID); err != nil {
		common.Error("更新登录信息失败", common.ErrorField(err))
	}
	
	// 生成Token
	token, refreshToken, expiresAt, err := s.jwtService.GenerateToken(user.ID, user.UUID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return &AuthResponse{
		UserID:       user.ID,
		UUID:         user.UUID,
		Token:        token,
		RefreshToken: refreshToken,
		ExpiresAt:    expiresAt,
		IsNewUser:    false,
	}, nil
}

// RefreshToken 刷新Token
func (s *userService) RefreshToken(ctx context.Context, refreshToken string) (*AuthResponse, error) {
	// 解析刷新token
	claims, err := s.jwtService.ParseToken(refreshToken)
	if err != nil {
		return nil, common.NewError(common.ErrCodeUnauthorized, "无效的token")
	}
	
	// 查找用户
	user, err := s.userRepo.FindByID(ctx, claims.UserID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if user == nil {
		return nil, common.NewError(common.ErrCodeUserNotFound)
	}
	
	if user.Status != "active" {
		return nil, common.NewError(common.ErrCodeForbidden, "账号状态异常")
	}
	
	// 生成新Token
	token, newRefreshToken, expiresAt, err := s.jwtService.GenerateToken(user.ID, user.UUID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	return &AuthResponse{
		UserID:       user.ID,
		UUID:         user.UUID,
		Token:        token,
		RefreshToken: newRefreshToken,
		ExpiresAt:    expiresAt,
		IsNewUser:    false,
	}, nil
}

// Logout 退出登录 - 将token加入Redis黑名单
func (s *userService) Logout(ctx context.Context, userID int64, token string) error {
	if s.redisClient == nil {
		return nil
	}
	claims, err := s.jwtService.ParseToken(token)
	if err != nil {
		// token本身已无效，无需加入黑名单
		return nil
	}
	ttl := time.Until(claims.ExpiresAt.Time)
	if ttl <= 0 {
		return nil
	}
	key := fmt.Sprintf("blacklist:%s", token)
	return s.redisClient.Set(ctx, key, "1", ttl).Err()
}

// ResetPassword 重置密码
func (s *userService) ResetPassword(ctx context.Context, req *ResetPasswordRequest) error {
	// 验证验证码
	if err := s.verifyCode(ctx, req.Phone, req.Code, "reset_password"); err != nil {
		return err
	}
	
	// 查找用户
	user, err := s.userRepo.FindByPhone(ctx, req.Phone)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if user == nil {
		return common.NewError(common.ErrCodeUserNotFound)
	}
	
	// 更新密码
	hash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	user.PasswordHash = string(hash)
	return s.userRepo.Update(ctx, user)
}

// GetCurrentUser 获取当前用户信息
func (s *userService) GetCurrentUser(ctx context.Context, userID int64) (*UserInfo, error) {
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if user == nil {
		return nil, common.NewError(common.ErrCodeUserNotFound)
	}
	
	info := &UserInfo{
		UserID: user.ID,
		UUID:   user.UUID,
		Phone:  user.Phone,
		Status: user.Status,
		Profile: user.Profile,
	}
	
	if user.Email != nil && *user.Email != "" {
		info.Email = user.Email
	}
	
	if user.Verification != nil {
		info.IsVerified = user.Verification.IsApproved()
		info.Verification = &VerificationInfo{
			RealName:     user.Verification.RealName,
			IDCardNumber: user.Verification.MaskIDCard(),
			Status:       user.Verification.Status,
			VerifiedAt:   user.Verification.VerifiedAt,
		}
	}
	
	return info, nil
}

// UpdateProfile 更新用户资料
func (s *userService) UpdateProfile(ctx context.Context, userID int64, req *UpdateProfileRequest) error {
	profile := &model.UserProfile{
		UserID: userID,
	}
	
	if req.Nickname != nil {
		profile.Nickname = req.Nickname
	}
	if req.Avatar != nil {
		profile.Avatar = req.Avatar
	}
	if req.Gender != nil {
		profile.Gender = req.Gender
	}
	if req.Birthday != nil {
		profile.Birthday = req.Birthday
	}
	if req.Bio != nil {
		profile.Bio = req.Bio
	}
	
	return s.userRepo.CreateOrUpdateProfile(ctx, profile)
}

// UploadAvatar 上传头像
func (s *userService) UploadAvatar(ctx context.Context, userID int64, fileData []byte, fileName string) (string, error) {
	// 这里实现文件上传逻辑，返回URL
	// 简化实现，实际应调用存储服务
	return "", nil
}

// ChangePassword 修改密码
func (s *userService) ChangePassword(ctx context.Context, userID int64, req *ChangePasswordRequest) error {
	// 查找用户
	user, err := s.userRepo.FindByID(ctx, userID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if user == nil {
		return common.NewError(common.ErrCodeUserNotFound)
	}
	
	// 验证旧密码
	if user.PasswordHash == "" {
		return common.NewError(common.ErrCodePasswordIncorrect, "未设置密码")
	}
	
	if err := bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(req.OldPassword)); err != nil {
		return common.NewError(common.ErrCodePasswordIncorrect)
	}
	
	// 更新密码
	hash, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	user.PasswordHash = string(hash)
	return s.userRepo.Update(ctx, user)
}

// SubmitVerification 提交实名认证
func (s *userService) SubmitVerification(ctx context.Context, userID int64, req *SubmitVerificationRequest) error {
	// 检查是否已有认证记录
	existing, err := s.userRepo.GetVerification(ctx, userID)
	if err != nil {
		return common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if existing != nil && existing.Status == "approved" {
		return common.NewError(common.ErrCodeValidation, "已完成实名认证")
	}
	
	if existing != nil && existing.Status == "pending" {
		return common.NewError(common.ErrCodeVerificationPending)
	}
	
	verification := &model.UserVerification{
		UserID:       userID,
		RealName:     req.RealName,
		IDCardNumber: req.IDCardNumber,
		IDCardFront:  req.IDCardFront,
		Status:       "pending",
	}
	
	if req.IDCardBack != nil {
		verification.IDCardBack = req.IDCardBack
	}
	
	if existing == nil {
		return s.userRepo.CreateVerification(ctx, verification)
	}
	
	verification.ID = existing.ID
	return s.userRepo.UpdateVerification(ctx, verification)
}

// GetVerificationStatus 获取实名认证状态
func (s *userService) GetVerificationStatus(ctx context.Context, userID int64) (*VerificationInfo, error) {
	verification, err := s.userRepo.GetVerification(ctx, userID)
	if err != nil {
		return nil, common.NewError(common.ErrCodeInternalServer, err.Error())
	}
	
	if verification == nil {
		return &VerificationInfo{Status: "unverified"}, nil
	}
	
	info := &VerificationInfo{
		Status: verification.Status,
	}
	
	if verification.Status == "approved" {
		info.RealName = verification.RealName
		info.IDCardNumber = verification.MaskIDCard()
		info.VerifiedAt = verification.VerifiedAt
	}
	
	return info, nil
}
