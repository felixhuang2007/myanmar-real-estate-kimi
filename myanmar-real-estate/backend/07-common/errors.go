package common

import (
	"fmt"
	"net/http"
)

// ErrorCode 错误码类型
type ErrorCode int

const (
	// 通用错误码 0-999
	ErrCodeSuccess          ErrorCode = 200
	ErrCodeBadRequest       ErrorCode = 400
	ErrCodeUnauthorized     ErrorCode = 401
	ErrCodeForbidden        ErrorCode = 403
	ErrCodeNotFound         ErrorCode = 404
	ErrCodeConflict         ErrorCode = 409
	ErrCodeValidation       ErrorCode = 422
	ErrCodeTooManyRequests  ErrorCode = 429
	ErrCodeInternalServer   ErrorCode = 500
	ErrCodeServiceUnavailable ErrorCode = 503
	
	// 用户模块错误码 1000-1999
	ErrCodeUserNotFound      ErrorCode = 1000
	ErrCodeUserExists        ErrorCode = 1001
	ErrCodeInvalidPhone      ErrorCode = 1002
	ErrCodeInvalidCode       ErrorCode = 1003
	ErrCodeCodeExpired       ErrorCode = 1004
	ErrCodePasswordIncorrect ErrorCode = 1005
	ErrCodeUserNotVerified   ErrorCode = 1006
	ErrCodeVerificationPending ErrorCode = 1007
	
	// 经纪人模块错误码 2000-2999
	ErrCodeAgentNotFound     ErrorCode = 2000
	ErrCodeAgentExists       ErrorCode = 2001
	ErrCodeAgentNotActive    ErrorCode = 2002
	ErrCodeAgentApplyPending ErrorCode = 2003
	
	// 房源模块错误码 3000-3999
	ErrCodeHouseNotFound      ErrorCode = 3000
	ErrCodeHouseExists        ErrorCode = 3001
	ErrCodeHouseNotAvailable  ErrorCode = 3002
	ErrCodeHouseUnderReview   ErrorCode = 3003
	ErrCodeInvalidHouseData   ErrorCode = 3004
	ErrCodeMaxImagesExceeded  ErrorCode = 3005
	ErrCodeMaxHousesExceeded  ErrorCode = 3006
	
	// 验真模块错误码 4000-4999
	ErrCodeVerificationNotFound   ErrorCode = 4000
	ErrCodeVerificationExists     ErrorCode = 4001
	ErrCodeVerificationCompleted  ErrorCode = 4002
	ErrCodeTaskAlreadyClaimed     ErrorCode = 4003
	
	// 预约模块错误码 5000-5999
	ErrCodeAppointmentNotFound   ErrorCode = 5000
	ErrCodeAppointmentConflict   ErrorCode = 5001
	ErrCodeSlotNotAvailable      ErrorCode = 5002
	ErrCodeAppointmentExpired    ErrorCode = 5003
	ErrCodeAppointmentCancelled  ErrorCode = 5004
	
	// ACN模块错误码 6000-6999
	ErrCodeACNTransactionNotFound  ErrorCode = 6000
	ErrCodeACNTransactionExists    ErrorCode = 6001
	ErrCodeInvalidCommissionRatio  ErrorCode = 6002
	ErrCodeParticipantNotFound     ErrorCode = 6003
	ErrCodeACNTransactionConfirmed ErrorCode = 6004
	ErrCodeACNTransactionDisputed  ErrorCode = 6005
	ErrCodeInsufficientBalance     ErrorCode = 6006
	
	// 财务模块错误码 7000-7999
	ErrCodeWithdrawalNotFound    ErrorCode = 7000
	ErrCodeWithdrawalMinAmount   ErrorCode = 7001
	ErrCodeWithdrawalMaxAmount   ErrorCode = 7002
	ErrCodeInsufficientFunds     ErrorCode = 7003
	ErrCodeInvalidBankInfo       ErrorCode = 7004
)

// errorMessages 错误码对应的错误消息
var errorMessages = map[ErrorCode]string{
	ErrCodeSuccess:              "success",
	ErrCodeBadRequest:           "请求参数错误",
	ErrCodeUnauthorized:         "未授权，请先登录",
	ErrCodeForbidden:            "禁止访问",
	ErrCodeNotFound:             "资源不存在",
	ErrCodeConflict:             "资源冲突",
	ErrCodeValidation:           "业务逻辑错误",
	ErrCodeTooManyRequests:      "请求过于频繁，请稍后再试",
	ErrCodeInternalServer:       "服务器内部错误",
	ErrCodeServiceUnavailable:   "服务暂不可用",
	
	ErrCodeUserNotFound:         "用户不存在",
	ErrCodeUserExists:           "用户已存在",
	ErrCodeInvalidPhone:         "手机号格式不正确",
	ErrCodeInvalidCode:          "验证码错误",
	ErrCodeCodeExpired:          "验证码已过期",
	ErrCodePasswordIncorrect:    "密码错误",
	ErrCodeUserNotVerified:      "用户未实名认证",
	ErrCodeVerificationPending:  "实名认证审核中",
	
	ErrCodeAgentNotFound:        "经纪人不存在",
	ErrCodeAgentExists:          "已提交经纪人申请",
	ErrCodeAgentNotActive:       "经纪人账号未激活",
	ErrCodeAgentApplyPending:    "经纪人申请审核中",
	
	ErrCodeHouseNotFound:        "房源不存在",
	ErrCodeHouseExists:          "房源已存在",
	ErrCodeHouseNotAvailable:    "房源不可查看",
	ErrCodeHouseUnderReview:     "房源审核中",
	ErrCodeInvalidHouseData:     "房源数据无效",
	ErrCodeMaxImagesExceeded:    "超出最大图片数量限制",
	ErrCodeMaxHousesExceeded:    "超出最大在线房源数量限制",
	
	ErrCodeVerificationNotFound:  "验真任务不存在",
	ErrCodeVerificationExists:    "验真任务已存在",
	ErrCodeVerificationCompleted: "验真任务已完成",
	ErrCodeTaskAlreadyClaimed:    "任务已被其他人领取",
	
	ErrCodeAppointmentNotFound:   "预约不存在",
	ErrCodeAppointmentConflict:   "预约时间冲突",
	ErrCodeSlotNotAvailable:      "该时段已约满",
	ErrCodeAppointmentExpired:    "预约已过期",
	ErrCodeAppointmentCancelled:  "预约已取消",
	
	ErrCodeACNTransactionNotFound:  "成交单不存在",
	ErrCodeACNTransactionExists:    "成交单已存在",
	ErrCodeInvalidCommissionRatio:  "分佣比例无效",
	ErrCodeParticipantNotFound:     "参与方不存在",
	ErrCodeACNTransactionConfirmed: "成交单已确认",
	ErrCodeACNTransactionDisputed:  "成交单存在争议",
	ErrCodeInsufficientBalance:     "余额不足",
	
	ErrCodeWithdrawalNotFound:    "提现记录不存在",
	ErrCodeWithdrawalMinAmount:   "提现金额低于最小限制",
	ErrCodeWithdrawalMaxAmount:   "提现金额超过最大限制",
	ErrCodeInsufficientFunds:     "账户余额不足",
	ErrCodeInvalidBankInfo:       "银行信息无效",
}

// AppError 应用错误结构
type AppError struct {
	Code    ErrorCode `json:"code"`
	Message string    `json:"message"`
	Detail  string    `json:"detail,omitempty"`
	Data    interface{} `json:"data,omitempty"`
}

// Error 实现error接口
func (e *AppError) Error() string {
	return fmt.Sprintf("Error %d: %s", e.Code, e.Message)
}

// NewError 创建新的错误
func NewError(code ErrorCode, detail ...string) *AppError {
	msg, ok := errorMessages[code]
	if !ok {
		msg = "未知错误"
	}
	
	err := &AppError{
		Code:    code,
		Message: msg,
	}
	
	if len(detail) > 0 && detail[0] != "" {
		err.Detail = detail[0]
	}
	
	return err
}

// WithData 添加错误数据
func (e *AppError) WithData(data interface{}) *AppError {
	e.Data = data
	return e
}

// WithDetail 添加错误详情
func (e *AppError) WithDetail(detail string) *AppError {
	e.Detail = detail
	return e
}

// HTTPStatusCode 获取HTTP状态码
func (e *AppError) HTTPStatusCode() int {
	switch e.Code {
	case ErrCodeSuccess:
		return http.StatusOK
	case ErrCodeBadRequest, ErrCodeValidation:
		return http.StatusBadRequest
	case ErrCodeUnauthorized:
		return http.StatusUnauthorized
	case ErrCodeForbidden:
		return http.StatusForbidden
	case ErrCodeNotFound:
		return http.StatusNotFound
	case ErrCodeConflict:
		return http.StatusConflict
	case ErrCodeTooManyRequests:
		return http.StatusTooManyRequests
	case ErrCodeServiceUnavailable:
		return http.StatusServiceUnavailable
	case ErrCodeInternalServer:
		return http.StatusInternalServerError
	// 业务错误码映射到标准HTTP状态码
	case ErrCodeInvalidCode, ErrCodeCodeExpired, ErrCodePasswordIncorrect,
		ErrCodeInvalidPhone, ErrCodeInvalidHouseData,
		ErrCodeACNTransactionConfirmed, ErrCodeACNTransactionDisputed,
		ErrCodeSlotNotAvailable, ErrCodeAppointmentConflict,
		ErrCodeAppointmentExpired, ErrCodeAppointmentCancelled,
		ErrCodeInsufficientBalance, ErrCodeInsufficientFunds:
		return http.StatusBadRequest
	case ErrCodeUserNotFound, ErrCodeAgentNotFound, ErrCodeHouseNotFound,
		ErrCodeVerificationNotFound, ErrCodeAppointmentNotFound,
		ErrCodeACNTransactionNotFound, ErrCodeWithdrawalNotFound:
		return http.StatusNotFound
	case ErrCodeUserExists, ErrCodeAgentExists, ErrCodeHouseExists,
		ErrCodeVerificationExists, ErrCodeACNTransactionExists,
		ErrCodeTaskAlreadyClaimed:
		return http.StatusConflict
	case ErrCodeUserNotVerified, ErrCodeVerificationPending,
		ErrCodeAgentNotActive, ErrCodeAgentApplyPending,
		ErrCodeHouseNotAvailable, ErrCodeHouseUnderReview:
		return http.StatusForbidden
	default:
		if e.Code >= 1000 {
			return http.StatusBadRequest
		}
		return http.StatusInternalServerError
	}
}

// IsNotFound 是否未找到错误
func (e *AppError) IsNotFound() bool {
	return e.Code == ErrCodeNotFound || 
		   e.Code == ErrCodeUserNotFound || 
		   e.Code == ErrCodeAgentNotFound || 
		   e.Code == ErrCodeHouseNotFound
}

// IsUnauthorized 是否未授权错误
func (e *AppError) IsUnauthorized() bool {
	return e.Code == ErrCodeUnauthorized
}

// IsValidation 是否校验错误
func (e *AppError) IsValidation() bool {
	return e.Code == ErrCodeValidation || e.Code == ErrCodeBadRequest
}

// 预定义错误变量（常用错误）
var (
	ErrUserNotFound     = NewError(ErrCodeUserNotFound)
	ErrAgentNotFound    = NewError(ErrCodeAgentNotFound)
	ErrHouseNotFound    = NewError(ErrCodeHouseNotFound)
	ErrUnauthorized     = NewError(ErrCodeUnauthorized)
	ErrForbidden        = NewError(ErrCodeForbidden)
	ErrBadRequest       = NewError(ErrCodeBadRequest)
	ErrInternalServer   = NewError(ErrCodeInternalServer)
)
