package utils

import (
	"crypto/md5"
	"crypto/rand"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"math/big"
	"regexp"
	"strings"
	"time"
	"unicode"
)

// GenerateCode 生成指定长度的随机数字验证码
func GenerateCode(length int) string {
	if length <= 0 {
		length = 6
	}
	
	max := big.NewInt(0)
	max.Exp(big.NewInt(10), big.NewInt(int64(length)), nil)
	
	n, _ := rand.Int(rand.Reader, max)
	format := fmt.Sprintf("%%0%dd", length)
	return fmt.Sprintf(format, n.Int64())
}

// GenerateUUID 生成UUID
func GenerateUUID() string {
	b := make([]byte, 16)
	rand.Read(b)
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
}

// HashMD5 MD5哈希
func HashMD5(data string) string {
	h := md5.New()
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}

// HashPassword 密码哈希（简化版，实际应使用bcrypt）
func HashPassword(password string) string {
	return HashMD5(password + "myanmar_property_salt")
}

// VerifyPassword 验证密码
func VerifyPassword(password, hash string) bool {
	return HashPassword(password) == hash
}

// MaskPhone 脱敏手机号
func MaskPhone(phone string) string {
	if len(phone) < 8 {
		return phone
	}
	return phone[:4] + "****" + phone[len(phone)-4:]
}

// MaskIDCard 脱敏身份证号
func MaskIDCard(idCard string) string {
	if len(idCard) < 8 {
		return idCard
	}
	return idCard[:4] + "******" + idCard[len(idCard)-4:]
}

// ValidatePhone 验证手机号格式（缅甸）
func ValidatePhone(phone string) bool {
	// 缅甸手机号格式：+95开头，后面8-10位数字
	pattern := `^\+95[0-9]{8,10}$`
	match, _ := regexp.MatchString(pattern, phone)
	return match
}

// ValidateEmail 验证邮箱格式
func ValidateEmail(email string) bool {
	pattern := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	match, _ := regexp.MatchString(pattern, email)
	return match
}

// GenerateHouseCode 生成房源编码
func GenerateHouseCode() string {
	return fmt.Sprintf("HS%s%06d", time.Now().Format("20060102"), generateRandom(999999))
}

// GenerateTransactionCode 生成交存单编码
func GenerateTransactionCode() string {
	return fmt.Sprintf("TX%s%06d", time.Now().Format("20060102"), generateRandom(999999))
}

// GenerateAppointmentCode 生成预约编码
func GenerateAppointmentCode() string {
	return fmt.Sprintf("AP%s%06d", time.Now().Format("20060102"), generateRandom(999999))
}

// GenerateTaskCode 生成任务编码
func GenerateTaskCode() string {
	return fmt.Sprintf("TK%s%06d", time.Now().Format("20060102"), generateRandom(999999))
}

func generateRandom(max int) int {
	return int(time.Now().UnixNano() % int64(max))
}

// TruncateString 截断字符串
func TruncateString(s string, maxLen int) string {
	if len(s) <= maxLen {
		return s
	}
	return s[:maxLen] + "..."
}

// RemoveSpecialChars 移除特殊字符
func RemoveSpecialChars(s string) string {
	var result strings.Builder
	for _, r := range s {
		if unicode.IsLetter(r) || unicode.IsNumber(r) || unicode.IsSpace(r) {
			result.WriteRune(r)
		}
	}
	return result.String()
}

// IsEmptyString 检查字符串是否为空
func IsEmptyString(s string) bool {
	return strings.TrimSpace(s) == ""
}

// ContainsString 检查字符串数组是否包含指定字符串
func ContainsString(arr []string, str string) bool {
	for _, a := range arr {
		if a == str {
			return true
		}
	}
	return false
}

// UniqueStrings 去重字符串数组
func UniqueStrings(arr []string) []string {
	seen := make(map[string]bool)
	result := []string{}
	for _, s := range arr {
		if !seen[s] {
			seen[s] = true
			result = append(result, s)
		}
	}
	return result
}

// FormatPrice 格式化价格
func FormatPrice(price int64, currency string) string {
	if currency == "" {
		currency = "MMK"
	}
	
	// 格式化为千分位
	p := float64(price)
	if p >= 100000000 {
		return fmt.Sprintf("%.2f亿%s", p/100000000, currency)
	}
	if p >= 10000 {
		return fmt.Sprintf("%.0f万%s", p/10000, currency)
	}
	return fmt.Sprintf("%d%s", price, currency)
}

// FormatArea 格式化面积
func FormatArea(area float64) string {
	return fmt.Sprintf("%.2f㎡", area)
}

// GetAgeFromBirthday 从生日计算年龄
func GetAgeFromBirthday(birthday time.Time) int {
	now := time.Now()
	age := now.Year() - birthday.Year()
	if now.YearDay() < birthday.YearDay() {
		age--
	}
	return age
}

// Base64Encode Base64编码
func Base64Encode(data []byte) string {
	return base64.StdEncoding.EncodeToString(data)
}

// Base64Decode Base64解码
func Base64Decode(s string) ([]byte, error) {
	return base64.StdEncoding.DecodeString(s)
}

// GetCurrentTime 获取当前时间戳（毫秒）
func GetCurrentTime() int64 {
	return time.Now().UnixMilli()
}

// ParseTime 解析时间字符串
func ParseTime(timeStr string, format string) (time.Time, error) {
	if format == "" {
		format = "2006-01-02 15:04:05"
	}
	return time.Parse(format, timeStr)
}

// FormatTime 格式化时间
func FormatTime(t time.Time, format string) string {
	if format == "" {
		format = "2006-01-02 15:04:05"
	}
	return t.Format(format)
}

// IsSameDay 判断是否为同一天
func IsSameDay(t1, t2 time.Time) bool {
	return t1.Year() == t2.Year() && t1.YearDay() == t2.YearDay()
}

// AddDays 添加天数
func AddDays(t time.Time, days int) time.Time {
	return t.AddDate(0, 0, days)
}

// StartOfDay 获取一天的开始
func StartOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

// EndOfDay 获取一天的结束
func EndOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 999999999, t.Location())
}
