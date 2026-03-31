# 缅甸房产平台 API 依赖关系文档

## 1. 服务模块概览

### 1.1 模块清单

| 模块 | 目录 | API数量 | 状态 |
|------|------|---------|------|
| User Service | 03-user-service | 18 | 已实现 |
| House Service | 04-house-service | 16 | 已实现 |
| ACN Service | 05-acn-service | 12 | 已实现 |
| Appointment Service | 06-appointment-service | 10 | 已实现 |
| Common | 07-common | - | 公共组件 |
| IM Service | 08-im-service | 8 | 接口预留 |
| Verification Service | 09-verification-service | 6 | 已实现 |
| Upload Service | 11-upload-service | 3 | 已实现 |
| Client Service | 12-client-service | 8 | 已实现 |
| Ops Service | 13-ops-service | 10 | 已实现 |
| Promoter Service | 14-promoter-service | 5 | 已实现 |

**总计**: 51个API接口（47个已实现，4个IM相关待集成）

### 1.2 模块依赖图

```
┌─────────────────────────────────────────────────────────────────────┐
│                        缅甸房产平台 API 架构                          │
└─────────────────────────────────────────────────────────────────────┘

                              ┌──────────────┐
                              │   API Gateway │
                              │   (Nginx)    │
                              └──────┬───────┘
                                     │
        ┌────────────────────────────┼────────────────────────────┐
        │                            │                            │
        ▼                            ▼                            ▼
┌───────────────┐           ┌───────────────┐           ┌───────────────┐
│  公开路由      │           │  认证中间件    │           │  管理后台路由  │
│               │           │               │           │               │
│ /auth/*       │           │ JWT验证        │           │ /admin/*      │
│ /config       │──────────▶│ 权限检查       │◀─────────│ /ops/*        │
│ /regions      │           │               │           │               │
└───────────────┘           └───────┬───────┘           └───────────────┘
                                    │
        ┌───────────────────────────┼───────────────────────────┐
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐          ┌───────────────┐          ┌───────────────┐
│ C端用户路由    │          │  B端经纪人路由 │          │ 公共服务路由   │
│               │          │               │          │               │
│ /users/*      │          │ /agents/*     │          │ /upload/*     │
│ /houses/*     │          │ /houses/*     │          │ /common/*     │
│ /favorites/*  │          │ /clients/*    │          │               │
│ /appointments/*│         │ /appointments/*│         │               │
│ /acn/*        │          │ /acn/*        │          │               │
│ /messages/*   │          │ /messages/*   │          │               │
└───────────────┘          └───────────────┘          └───────────────┘
```

---

## 2. 各服务详细API清单

### 2.1 User Service (用户服务)

**路径前缀**: `/v1`

#### 认证相关 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/auth/send-verification-code` | 发送验证码 | 公开 |
| POST | `/auth/register` | 手机号注册 | 公开 |
| POST | `/auth/login` | 验证码登录 | 公开 |
| POST | `/auth/login-with-password` | 密码登录 | 公开 |
| POST | `/auth/oauth-login` | 第三方登录 | 公开 |
| POST | `/auth/refresh-token` | 刷新Token | 公开 |
| POST | `/auth/logout` | 退出登录 | 需认证 |
| POST | `/auth/reset-password` | 重置密码 | 公开 |

#### 用户资料 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/users/me` | 获取当前用户信息 | 需认证 |
| PUT | `/users/me` | 更新用户资料 | 需认证 |
| POST | `/users/me/avatar` | 上传头像 | 需认证 |
| PUT | `/users/me/password` | 修改密码 | 需认证 |
| POST | `/users/me/verification` | 提交实名认证 | 需认证 |
| GET | `/users/me/verification` | 获取实名认证状态 | 需认证 |

#### 用户行为 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/users/me/favorites` | 获取收藏列表 | 需认证 |
| POST | `/users/me/favorites` | 添加收藏 | 需认证 |
| DELETE | `/users/me/favorites/{house_id}` | 取消收藏 | 需认证 |
| GET | `/users/me/history` | 浏览历史 | 需认证 |
| DELETE | `/users/me/history` | 清空浏览历史 | 需认证 |

**外部依赖**:
- SMS 服务（发送验证码）
- 文件存储服务（头像上传）

---

### 2.2 House Service (房源服务)

**路径前缀**: `/v1/houses`

#### C端房源 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/houses` | 房源列表 | 可选 |
| GET | `/houses/{id}` | 房源详情 | 可选 |
| GET | `/houses/{id}/similar` | 相似房源推荐 | 可选 |
| GET | `/houses/map-search` | 地图找房 | 可选 |
| GET | `/houses/search-suggestions` | 搜索建议 | 可选 |

#### B端房源管理 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/houses` | 发布房源 | 需经纪人认证 |
| PUT | `/houses/{id}` | 编辑房源 | 需经纪人认证（录入人/维护人） |
| DELETE | `/houses/{id}` | 删除房源 | 需经纪人认证 |
| POST | `/houses/{id}/images` | 上传房源图片 | 需经纪人认证 |
| DELETE | `/houses/{id}/images/{image_id}` | 删除房源图片 | 需经纪人认证 |
| POST | `/houses/{id}/offline` | 下架房源 | 需经纪人认证 |
| POST | `/houses/{id}/online` | 上架房源 | 需经纪人认证 |
| PUT | `/houses/{id}/price` | 修改价格 | 需经纪人认证 |
| POST | `/houses/{id}/featured` | 设置精选 | 需经纪人认证 |

#### 房源审核 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/houses/{id}/submit` | 提交审核 | 需经纪人认证 |
| GET | `/houses/{id}/audit-logs` | 获取审核记录 | 需经纪人认证 |

**依赖服务**:
- Upload Service（图片上传）
- Elasticsearch（房源搜索）
- User Service（经纪人信息）

---

### 2.3 ACN Service (ACN分佣服务)

**路径前缀**: `/v1/acn`

#### 成交单管理 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/acn/transactions` | 成交单列表 | 需经纪人认证 |
| GET | `/acn/transactions/{id}` | 成交单详情 | 需经纪人认证 |
| POST | `/acn/transactions` | 申报成交 | 需经纪人认证 |
| PUT | `/acn/transactions/{id}` | 修改成交单 | 需经纪人认证（待确认状态） |
| POST | `/acn/transactions/{id}/confirm` | 确认成交单 | 需经纪人认证 |
| POST | `/acn/transactions/{id}/cancel` | 取消成交单 | 需经纪人认证 |

#### 分佣相关 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/acn/roles` | 获取ACN角色定义 | 需认证 |
| GET | `/acn/commission/balance` | 获取佣金余额 | 需经纪人认证 |
| GET | `/acn/commission/logs` | 佣金明细 | 需经纪人认证 |
| GET | `/acn/commission/stats` | 佣金统计 | 需经纪人认证 |

#### 争议申诉 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/acn/disputes` | 申诉列表 | 需经纪人认证 |
| POST | `/acn/disputes` | 提交申诉 | 需经纪人认证 |
| GET | `/acn/disputes/{id}` | 申诉详情 | 需经纪人认证 |

**依赖服务**:
- User Service（经纪人信息）
- House Service（房源信息）
- Finance Service（账户余额）

---

### 2.4 Appointment Service (预约服务)

**路径前缀**: `/v1/appointments`

#### C端预约 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/appointments` | 我的预约列表 | 需认证 |
| GET | `/appointments/{id}` | 预约详情 | 需认证 |
| POST | `/appointments` | 创建预约 | 需认证 |
| PUT | `/appointments/{id}` | 修改预约 | 需认证 |
| POST | `/appointments/{id}/cancel` | 取消预约 | 需认证 |
| POST | `/appointments/{id}/feedback` | 提交反馈 | 需认证 |

#### B端预约管理 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/agents/{id}/appointments` | 经纪人预约列表 | 需经纪人认证 |
| POST | `/appointments/{id}/confirm` | 确认预约 | 需经纪人认证 |
| POST | `/appointments/{id}/reject` | 拒绝预约 | 需经纪人认证 |
| POST | `/appointments/{id}/complete` | 完成预约 | 需经纪人认证 |

#### 日程管理 API

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/agents/{id}/schedules` | 获取可预约时段 | 公开 |
| PUT | `/agents/{id}/schedules` | 设置可预约时段 | 需经纪人认证 |

**依赖服务**:
- User Service（用户信息）
- House Service（房源信息）
- IM Service（预约通知）

---

### 2.5 IM Service (消息服务)

**路径前缀**: `/v1/messages`

**状态**: 接口预留，待集成环信/融云

| 方法 | 路径 | 说明 | 认证 | 状态 |
|------|------|------|------|------|
| GET | `/conversations` | 会话列表 | 需认证 | 已实现 |
| GET | `/conversations/{id}` | 会话详情 | 需认证 | 已实现 |
| POST | `/conversations` | 创建会话 | 需认证 | 已实现 |
| DELETE | `/conversations/{id}` | 删除会话 | 需认证 | 接口预留 |
| GET | `/conversations/{id}/messages` | 获取消息历史 | 需认证 | 已实现 |
| POST | `/messages/send` | 发送消息 | 需认证 | 接口预留 |
| POST | `/messages/recall` | 撤回消息 | 需认证 | 接口预留 |
| GET | `/quick-replies` | 获取快捷话术 | 需经纪人认证 | 已实现 |
| POST | `/quick-replies` | 添加快捷话术 | 需经纪人认证 | 已实现 |

**外部依赖**:
- 环信 IM 或 融云（第三方IM服务）

---

### 2.6 Verification Service (验真服务)

**路径前缀**: `/v1/verification`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/verification/tasks` | 验真任务列表 | 需经纪人认证 |
| GET | `/verification/tasks/{id}` | 任务详情 | 需经纪人认证 |
| POST | `/verification/tasks/{id}/accept` | 接受任务 | 需经纪人认证 |
| POST | `/verification/tasks/{id}/submit` | 提交验真结果 | 需经纪人认证 |
| GET | `/verification/items` | 验真检查项 | 需经纪人认证 |
| POST | `/verification/photos` | 上传验真照片 | 需经纪人认证 |

**依赖服务**:
- House Service（房源信息）
- Upload Service（照片上传）

---

### 2.7 Upload Service (上传服务)

**路径前缀**: `/v1/upload`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/upload/image` | 上传图片 | 需认证 |
| POST | `/upload/file` | 上传文件 | 需认证 |
| GET | `/upload/signature` | 获取直传签名 | 需认证 |

**外部依赖**:
- MinIO / 腾讯云 COS（对象存储）

---

### 2.8 Client Service (客户服务)

**路径前缀**: `/v1/clients`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/clients` | 客户列表 | 需经纪人认证 |
| GET | `/clients/{id}` | 客户详情 | 需经纪人认证 |
| POST | `/clients` | 创建客户 | 需经纪人认证 |
| PUT | `/clients/{id}` | 更新客户 | 需经纪人认证 |
| DELETE | `/clients/{id}` | 删除客户 | 需经纪人认证 |
| GET | `/clients/{id}/follow-ups` | 跟进记录 | 需经纪人认证 |
| POST | `/clients/{id}/follow-ups` | 添加跟进 | 需经纪人认证 |
| POST | `/clients/{id}/transfer` | 转让客户 | 需经纪人认证 |

**依赖服务**:
- User Service（经纪人信息）
- House Service（房源信息，来源房源）

---

### 2.9 Ops Service (运维服务)

**路径前缀**: `/v1/admin`

#### Banner管理

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/admin/banners` | Banner列表 | 需管理员认证 |
| POST | `/admin/banners` | 创建Banner | 需管理员认证 |
| PUT | `/admin/banners/{id}` | 更新Banner | 需管理员认证 |
| DELETE | `/admin/banners/{id}` | 删除Banner | 需管理员认证 |

#### 系统配置

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/admin/configs` | 配置列表 | 需管理员认证 |
| PUT | `/admin/configs/{key}` | 更新配置 | 需管理员认证 |

#### 数据统计

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/admin/statistics/overview` | 数据概览 | 需管理员认证 |
| GET | `/admin/statistics/agents` | 经纪人统计 | 需管理员认证 |
| GET | `/admin/statistics/houses` | 房源统计 | 需管理员认证 |

---

### 2.10 Promoter Service (地推服务)

**路径前缀**: `/v1/promoters`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/promoters/register` | 地推人员注册 | 公开 |
| GET | `/promoters/me` | 获取地推信息 | 需地推认证 |
| GET | `/promoters/me/tasks` | 推广任务列表 | 需地推认证 |
| GET | `/promoters/me/stats` | 推广统计 | 需地推认证 |
| GET | `/promoters/me/commission` | 佣金记录 | 需地推认证 |

---

### 2.11 公共服务 API

**路径前缀**: `/v1`

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/regions` | 地区列表 | 公开 |
| GET | `/config` | 全局配置 | 公开 |
| GET | `/health` | 健康检查 | 公开 |

---

## 3. 服务间调用关系

### 3.1 同步调用关系

```
┌─────────────────────────────────────────────────────────────────┐
│                      服务间同步调用图                            │
└─────────────────────────────────────────────────────────────────┘

User Service ◀──────────────────────────────────────────────┐
     │                                                       │
     │ 获取用户信息                                           │
     ▼                                                       │
House Service ───▶ Upload Service                            │
     │              (图片上传)                                │
     │                                                       │
     │ 获取房源信息                                           │
     ▼                                                       │
ACN Service ──────▶ User Service                             │
     │               (经纪人信息)                             │
     │                                                       │
     │ 查询余额                                              │
     ▼                                                       │
Finance Service ◀───────────────────────────────────────────┘

Appointment Service ───▶ User Service
                    (用户信息)

Appointment Service ───▶ House Service
                    (房源信息)

Client Service ────▶ User Service
                 (经纪人信息)

Client Service ────▶ House Service
                 (房源信息)

Verification Service ───▶ House Service
                     (房源信息)

Verification Service ───▶ Upload Service
                     (照片上传)
```

### 3.2 异步消息（预留）

```
┌─────────────────────────────────────────────────────────────────┐
│                     异步消息流（预留）                           │
└─────────────────────────────────────────────────────────────────┘

User Service ────────┐
                    │ 用户行为事件
                    ▼
              ┌─────────────┐
              │  Message    │
              │   Queue     │
              │  (Redis/    │
              │   RabbitMQ) │
              └──────┬──────┘
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
  Statistics    Notification   Search
    Service        Service     Service
   (统计)         (通知)       (搜索索引)
```

---

## 4. 认证与权限

### 4.1 认证中间件

所有受保护路由经过以下认证流程：

```
Request
   │
   ▼
[Authorization Header]
   │
   ▼
JWT Token验证
   │
   ├── 无效 ──▶ 401 Unauthorized
   │
   ▼
Token解析 (user_id, agent_id, role)
   │
   ▼
权限检查
   │
   ├── 无权限 ──▶ 403 Forbidden
   │
   ▼
路由处理
```

### 4.2 角色与权限

| 角色 | 标识 | 权限范围 |
|------|------|----------|
| 普通用户 | user | C端API访问 |
| 经纪人 | agent | C端 + B端API访问 |
| 管理员 | admin | 管理后台API访问 |
| 地推人员 | promoter | 地推API访问 |

### 4.3 权限注解

```go
// 公开路由
router.POST("/auth/login", controller.Login)

// 需认证路由
router.GET("/users/me", middleware.Auth(), controller.GetCurrentUser)

// 需经纪人身份
router.POST("/houses", middleware.Auth(), middleware.RequireAgent(), controller.CreateHouse)

// 需管理员身份
router.GET("/admin/banners", middleware.Auth(), middleware.RequireAdmin(), controller.ListBanners)
```

---

## 5. 外部依赖服务

### 5.1 第三方服务清单

| 服务 | 用途 | 当前状态 | 配置Key |
|------|------|----------|---------|
| SMS | 发送验证码 | Mock | `SMS_PROVIDER` |
| IM | 即时消息 | Mock/预留 | `IM_PROVIDER` |
| Payment | 支付 | Mock | `PAYMENT_PROVIDER` |
| Storage | 文件存储 | MinIO(真实) | `STORAGE_TYPE` |
| Elasticsearch | 房源搜索 | 真实 | `ELASTICSEARCH_URL` |
| Redis | 缓存/会话 | 真实 | `REDIS_URL` |

### 5.2 Mock vs 真实切换

详见 [service-mock-guide.md](./service-mock-guide.md)

---

## 6. API 版本管理

### 6.1 当前版本
- **版本**: v1
- **状态**: 稳定
- **Base URL**: `https://api.myanmar-property.com/v1`

### 6.2 版本策略
- URL路径版本控制: `/v1/`, `/v2/`
- 向后兼容: 新版本发布后，旧版本保留至少6个月
- 弃用通知: 提前30天通知客户端

### 6.3 版本变更记录

| 版本 | 日期 | 变更说明 |
|------|------|----------|
| v1.0 | 2026-03-17 | 初始版本，核心功能完整 |

---

## 7. 错误码体系

### 7.1 错误码范围

| 范围 | 模块 |
|------|------|
| 0-99 | 通用错误 |
| 100-199 | 用户模块 |
| 200-299 | 经纪人模块 |
| 300-399 | 房源模块 |
| 400-499 | 验真模块 |
| 500-599 | 预约模块 |
| 600-699 | IM模块 |
| 700-799 | ACN模块 |
| 800-899 | 财务模块 |
| 900-999 | 管理后台模块 |

### 7.2 通用错误码

| 错误码 | 说明 |
|--------|------|
| 0 | 成功 |
| 1 | 参数错误 |
| 2 | 未授权 |
| 3 | 禁止访问 |
| 4 | 资源不存在 |
| 5 | 服务器内部错误 |
| 6 | 服务不可用 |
| 7 | 请求超时 |

---

## 8. 接口限流策略

### 8.1 限流级别

| 级别 | 策略 | 范围 |
|------|------|------|
| 全局 | 10000 req/min | 所有请求 |
| 用户 | 100 req/min | 按用户ID |
| IP | 1000 req/min | 按IP地址 |
| 接口 | 特定限制 | 敏感接口 |

### 8.2 敏感接口限流

| 接口 | 限流 |
|------|------|
| POST /auth/send-verification-code | 1 req/min/phone |
| POST /auth/login | 5 req/min/phone |
| POST /upload/* | 10 req/min/user |

---

**文档版本**: v1.0
**最后更新**: 2026-03-31
**维护人**: 技术团队
