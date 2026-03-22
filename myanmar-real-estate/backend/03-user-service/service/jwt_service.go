package service

import (
	"context"
	"errors"
	"time"

	"github.com/golang-jwt/jwt/v5"
	
	"myanmar-property/backend/07-common"
)

// JWTClaims JWT声明
type JWTClaims struct {
	UserID int64  `json:"user_id"`
	UUID   string `json:"uuid"`
	Type   string `json:"type"`
	jwt.RegisteredClaims
}

// JWTService JWT服务接口
type JWTService interface {
	GenerateToken(userID int64, uuid string) (accessToken, refreshToken string, expiresAt time.Time, err error)
	ParseToken(tokenString string) (*JWTClaims, error)
}

// jwtService 实现
type jwtService struct {
	secret          []byte
	accessTokenTTL  time.Duration
	refreshTokenTTL time.Duration
}

// NewJWTService 创建JWT服务
func NewJWTService(config *common.Config) JWTService {
	return &jwtService{
		secret:          []byte(config.JWT.Secret),
		accessTokenTTL:  config.JWT.AccessTokenTTL,
		refreshTokenTTL: config.JWT.RefreshTokenTTL,
	}
}

// GenerateToken 生成Token
func (s *jwtService) GenerateToken(userID int64, uuid string) (accessToken, refreshToken string, expiresAt time.Time, err error) {
	now := time.Now()
	
	// 生成Access Token
	accessClaims := JWTClaims{
		UserID: userID,
		UUID:   uuid,
		Type:   "access",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.accessTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
		},
	}
	
	accessTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, accessClaims)
	accessToken, err = accessTokenObj.SignedString(s.secret)
	if err != nil {
		return "", "", time.Time{}, err
	}
	
	// 生成Refresh Token
	refreshClaims := JWTClaims{
		UserID: userID,
		UUID:   uuid,
		Type:   "refresh",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.refreshTokenTTL)),
			IssuedAt:  jwt.NewNumericDate(now),
		},
	}
	
	refreshTokenObj := jwt.NewWithClaims(jwt.SigningMethodHS256, refreshClaims)
	refreshToken, err = refreshTokenObj.SignedString(s.secret)
	if err != nil {
		return "", "", time.Time{}, err
	}
	
	return accessToken, refreshToken, accessClaims.ExpiresAt.Time, nil
}

// ParseToken 解析Token
func (s *jwtService) ParseToken(tokenString string) (*JWTClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &JWTClaims{}, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return s.secret, nil
	})
	
	if err != nil {
		return nil, err
	}
	
	if claims, ok := token.Claims.(*JWTClaims); ok && token.Valid {
		return claims, nil
	}
	
	return nil, errors.New("invalid token claims")
}

// SMSService 短信服务接口
type SMSService interface {
	Send(ctx context.Context, phone, code string) error
}

// smsService 实现
type smsService struct {
	config *common.Config
}

// NewSMSService 创建短信服务
func NewSMSService(config *common.Config) SMSService {
	return &smsService{config: config}
}

// Send 发送短信
func (s *smsService) Send(ctx context.Context, phone, code string) error {
	// 这里实现实际的短信发送逻辑
	// 可集成Twilio、AWS SNS或其他缅甸本地短信服务商
	common.Info("发送短信验证码", common.String("phone", phone), common.String("code", code))
	return nil
}
