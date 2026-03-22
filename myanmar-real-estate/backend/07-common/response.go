package common

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
)

// Response 统一响应结构
type Response struct {
	Code      int         `json:"code"`
	Message   string      `json:"message"`
	Data      interface{} `json:"data,omitempty"`
	Timestamp int64       `json:"timestamp"`
	RequestID string      `json:"request_id,omitempty"`
}

// Pagination 分页信息
type Pagination struct {
	Page       int    `json:"page"`
	PageSize   int    `json:"page_size"`
	Total      int64  `json:"total"`
	TotalPages int    `json:"total_pages"`
	HasMore    bool   `json:"has_more"`
	NextCursor string `json:"next_cursor,omitempty"`
}

// PaginatedData 分页数据
type PaginatedData struct {
	List       interface{} `json:"list"`
	Pagination Pagination  `json:"pagination"`
}

// Success 成功响应
func Success(c *gin.Context, data interface{}) {
	response := Response{
		Code:      200,
		Message:   "success",
		Data:      data,
		Timestamp: time.Now().Unix(),
		RequestID: c.GetString("request_id"),
	}
	c.JSON(http.StatusOK, response)
}

// SuccessWithMessage 成功响应（自定义消息）
func SuccessWithMessage(c *gin.Context, message string, data interface{}) {
	response := Response{
		Code:      200,
		Message:   message,
		Data:      data,
		Timestamp: time.Now().Unix(),
		RequestID: c.GetString("request_id"),
	}
	c.JSON(http.StatusOK, response)
}

// Created 创建成功响应
func Created(c *gin.Context, data interface{}) {
	response := Response{
		Code:      201,
		Message:   "created",
		Data:      data,
		Timestamp: time.Now().Unix(),
		RequestID: c.GetString("request_id"),
	}
	c.JSON(http.StatusCreated, response)
}

// NoContent 无内容响应
func NoContent(c *gin.Context) {
	c.Status(http.StatusNoContent)
}

// ErrorResponse 错误响应
func ErrorResponse(c *gin.Context, err *AppError) {
	response := Response{
		Code:      int(err.Code),
		Message:   err.Message,
		Timestamp: time.Now().Unix(),
		RequestID: c.GetString("request_id"),
	}
	
	if err.Detail != "" {
		response.Data = gin.H{"detail": err.Detail}
	}
	if err.Data != nil {
		response.Data = err.Data
	}
	
	c.JSON(err.HTTPStatusCode(), response)
}

// ErrorWithMessage 错误响应（自定义消息）
func ErrorWithMessage(c *gin.Context, code int, message string) {
	response := Response{
		Code:      code,
		Message:   message,
		Timestamp: time.Now().Unix(),
		RequestID: c.GetString("request_id"),
	}
	c.JSON(code, response)
}

// BadRequest 请求参数错误
func BadRequest(c *gin.Context, message string) {
	ErrorWithMessage(c, http.StatusBadRequest, message)
}

// Unauthorized 未授权
func Unauthorized(c *gin.Context, message ...string) {
	msg := "未授权，请先登录"
	if len(message) > 0 {
		msg = message[0]
	}
	ErrorWithMessage(c, http.StatusUnauthorized, msg)
}

// Forbidden 禁止访问
func Forbidden(c *gin.Context, message ...string) {
	msg := "禁止访问"
	if len(message) > 0 {
		msg = message[0]
	}
	ErrorWithMessage(c, http.StatusForbidden, msg)
}

// NotFound 资源不存在
func NotFound(c *gin.Context, message ...string) {
	msg := "资源不存在"
	if len(message) > 0 {
		msg = message[0]
	}
	ErrorWithMessage(c, http.StatusNotFound, msg)
}

// ValidationError 校验错误
func ValidationError(c *gin.Context, message string) {
	ErrorWithMessage(c, http.StatusUnprocessableEntity, message)
}

// TooManyRequests 请求过于频繁
func TooManyRequests(c *gin.Context, message ...string) {
	msg := "操作过于频繁，请稍后再试"
	if len(message) > 0 {
		msg = message[0]
	}
	ErrorWithMessage(c, http.StatusTooManyRequests, msg)
}

// ServerError 服务器内部错误
func ServerError(c *gin.Context, message ...string) {
	msg := "服务器内部错误"
	if len(message) > 0 {
		msg = message[0]
	}
	ErrorWithMessage(c, http.StatusInternalServerError, msg)
}

// Paginated 分页响应
func Paginated(c *gin.Context, list interface{}, page, pageSize int, total int64) {
	totalPages := int(total) / pageSize
	if int(total)%pageSize > 0 {
		totalPages++
	}
	
	data := PaginatedData{
		List: list,
		Pagination: Pagination{
			Page:       page,
			PageSize:   pageSize,
			Total:      total,
			TotalPages: totalPages,
			HasMore:    page < totalPages,
		},
	}
	
	Success(c, data)
}

// PaginatedWithCursor 游标分页响应
func PaginatedWithCursor(c *gin.Context, list interface{}, nextCursor string) {
	data := PaginatedData{
		List: list,
		Pagination: Pagination{
			HasMore:    nextCursor != "",
			NextCursor: nextCursor,
		},
	}
	
	Success(c, data)
}
