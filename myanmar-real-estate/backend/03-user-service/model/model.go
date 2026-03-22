package model

import (
	"time"
)

// User 用户基础模型
type User struct {
	ID           int64     `gorm:"primaryKey;column:id" json:"user_id"`
	UUID         string    `gorm:"column:uuid;uniqueIndex" json:"uuid"`
	Phone        string    `gorm:"column:phone;uniqueIndex;size:20" json:"phone"`
	Email        *string   `gorm:"column:email;size:255" json:"email,omitempty"`
	PasswordHash string    `gorm:"column:password_hash;size:255" json:"-"`
	Status       string    `gorm:"column:status;size:20;default:active" json:"status"`
	UserType     string    `gorm:"column:user_type;size:20;default:individual" json:"user_type"`
	CreatedAt    time.Time `gorm:"column:created_at" json:"created_at"`
	UpdatedAt    time.Time `gorm:"column:updated_at" json:"updated_at"`
	LastLoginAt  *time.Time `gorm:"column:last_login_at" json:"last_login_at,omitempty"`
	LoginCount   int       `gorm:"column:login_count;default:0" json:"login_count"`
	
	// 关联
	Profile       *UserProfile       `gorm:"foreignKey:UserID" json:"profile,omitempty"`
	Verification  *UserVerification  `gorm:"foreignKey:UserID" json:"verification,omitempty"`
}

func (User) TableName() string {
	return "users"
}

// UserProfile 用户资料
type UserProfile struct {
	ID               int64     `gorm:"primaryKey" json:"-"`
	UserID           int64     `gorm:"column:user_id;uniqueIndex" json:"-"`
	Nickname         *string   `gorm:"column:nickname;size:100" json:"nickname,omitempty"`
	Avatar           *string   `gorm:"column:avatar;size:500" json:"avatar,omitempty"`
	Gender           *string   `gorm:"column:gender;size:10" json:"gender,omitempty"`
	Birthday         *string   `gorm:"column:birthday" json:"birthday,omitempty"`
	Bio              *string   `gorm:"column:bio" json:"bio,omitempty"`
	PreferredCity    *string   `gorm:"column:preferred_city;size:50" json:"preferred_city,omitempty"`
	PreferredDistricts *string `gorm:"column:preferred_districts;size:255" json:"preferred_districts,omitempty"`
	BudgetMin        *int64    `gorm:"column:budget_min" json:"budget_min,omitempty"`
	BudgetMax        *int64    `gorm:"column:budget_max" json:"budget_max,omitempty"`
	CreatedAt        time.Time `gorm:"column:created_at" json:"-"`
	UpdatedAt        time.Time `gorm:"column:updated_at" json:"-"`
}

func (UserProfile) TableName() string {
	return "user_profiles"
}

// UserVerification 用户实名认证
type UserVerification struct {
	ID             int64      `gorm:"primaryKey" json:"-"`
	UserID         int64      `gorm:"column:user_id;uniqueIndex" json:"-"`
	RealName       string     `gorm:"column:real_name;size:100" json:"real_name"`
	IDCardNumber   string     `gorm:"column:id_card_number;size:50" json:"id_card_number"`
	IDCardFront    string     `gorm:"column:id_card_front;size:500" json:"id_card_front"`
	IDCardBack     *string    `gorm:"column:id_card_back;size:500" json:"id_card_back,omitempty"`
	FaceRecognitionPhoto *string `gorm:"column:face_recognition_photo;size:500" json:"face_recognition_photo,omitempty"`
	Status         string     `gorm:"column:status;size:20;default:pending" json:"status"`
	RejectReason   *string    `gorm:"column:reject_reason" json:"reject_reason,omitempty"`
	VerifiedAt     *time.Time `gorm:"column:verified_at" json:"verified_at,omitempty"`
	VerifiedBy     *int64     `gorm:"column:verified_by" json:"verified_by,omitempty"`
	CreatedAt      time.Time  `gorm:"column:created_at" json:"-"`
	UpdatedAt      time.Time  `gorm:"column:updated_at" json:"-"`
}

func (UserVerification) TableName() string {
	return "user_verifications"
}

// IsApproved 是否已通过实名认证
func (v *UserVerification) IsApproved() bool {
	return v != nil && v.Status == "approved"
}

// MaskIDCard 脱敏身份证号
func (v *UserVerification) MaskIDCard() string {
	if v == nil || len(v.IDCardNumber) < 8 {
		return ""
	}
	return v.IDCardNumber[:4] + "******" + v.IDCardNumber[len(v.IDCardNumber)-4:]
}

// SMSVerificationCode 短信验证码
type SMSVerificationCode struct {
	ID            int64      `gorm:"primaryKey" json:"-"`
	Phone         string     `gorm:"column:phone;size:20;index" json:"-"`
	Code          string     `gorm:"column:code;size:10" json:"-"`
	Type          string     `gorm:"column:type;size:20" json:"-"`
	ExpiredAt     time.Time  `gorm:"column:expired_at" json:"-"`
	UsedAt        *time.Time `gorm:"column:used_at" json:"-"`
	AttemptCount  int        `gorm:"column:attempt_count;default:0" json:"-"`
	CreatedAt     time.Time  `gorm:"column:created_at" json:"-"`
}

func (SMSVerificationCode) TableName() string {
	return "sms_verification_codes"
}

// IsExpired 是否已过期
func (c *SMSVerificationCode) IsExpired() bool {
	return time.Now().After(c.ExpiredAt)
}

// IsUsed 是否已使用
func (c *SMSVerificationCode) IsUsed() bool {
	return c.UsedAt != nil
}
