# 缅甸房产平台 RESTful API 接口文档

> 版本: v1.0  
> 最后更新: 2026-03-17  
> 协议: HTTPS  
> 数据格式: JSON  
> 字符编码: UTF-8

---

## 目录

1. [通用规范](#1-通用规范)
2. [用户模块 API](#2-用户模块-api)
3. [经纪人模块 API](#3-经纪人模块-api)
4. [房源模块 API](#4-房源模块-api)
5. [验真模块 API](#5-验真模块-api)
6. [客户模块 API](#6-客户模块-api)
7. [预约带看模块 API](#7-预约带看模块-api)
8. [IM消息模块 API](#8-im消息模块-api)
9. [ACN分佣模块 API](#9-acn分佣模块-api)
10. [财务管理模块 API](#10-财务管理模块-api)
11. [地推模块 API](#11-地推模块-api)
12. [管理后台 API](#12-管理后台-api)

---

## 1. 通用规范

### 1.1 接口地址格式

```
https://api.myanmar-property.com/v1/{模块}/{资源}
```

### 1.2 请求头规范

```http
Content-Type: application/json
Authorization: Bearer {access_token}
X-Request-ID: {uuid}
X-Client-Version: {app_version}
X-Device-ID: {device_id}
```

### 1.3 通用响应格式

```json
{
  "code": 200,
  "message": "success",
  "data": {},
  "timestamp": 1710723600,
  "request_id": "req_xxx"
}
```

### 1.4 错误码定义

| 错误码 | 说明 | HTTP状态码 |
|--------|------|-----------|
| 200 | 成功 | 200 |
| 400 | 请求参数错误 | 400 |
| 401 | 未授权 | 401 |
| 403 | 禁止访问 | 403 |
| 404 | 资源不存在 | 404 |
| 409 | 资源冲突 | 409 |
| 422 | 业务逻辑错误 | 422 |
| 429 | 请求过于频繁 | 429 |
| 500 | 服务器内部错误 | 500 |

### 1.5 分页规范

列表接口统一使用以下分页参数：

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| page | int | 页码，从1开始 | 1 |
| page_size | int | 每页数量 | 20 |
| cursor | string | 游标（用于游标分页） | - |

响应示例：

```json
{
  "code": 200,
  "data": {
    "list": [],
    "pagination": {
      "page": 1,
      "page_size": 20,
      "total": 100,
      "has_more": true,
      "next_cursor": "xxx"
    }
  }
}
```

---

## 2. 用户模块 API

### 2.1 认证相关 (Auth)

#### 2.1.1 发送验证码
```http
POST /v1/auth/send-verification-code
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，+95开头 |
| type | string | 是 | 类型: register/login/reset_password |

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "expired_at": 1710723900,
    "interval": 60
  }
}
```

#### 2.1.2 手机号注册
```http
POST /v1/auth/register
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号 |
| code | string | 是 | 验证码 |
| password | string | 否 | 密码（可选） |
| invite_code | string | 否 | 邀请码 |

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "user_id": 12345,
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "expires_at": 1713315600,
    "is_new_user": true
  }
}
```

#### 2.1.3 手机号登录
```http
POST /v1/auth/login
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号 |
| code | string | 是 | 验证码 |
| device_id | string | 是 | 设备ID |

#### 2.1.4 密码登录
```http
POST /v1/auth/login-with-password
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号 |
| password | string | 是 | 密码 |
| device_id | string | 是 | 设备ID |

#### 2.1.5 第三方登录
```http
POST /v1/auth/oauth-login
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| provider | string | 是 | facebook/google/apple |
| access_token | string | 是 | 第三方access_token |
| device_id | string | 是 | 设备ID |

#### 2.1.6 刷新Token
```http
POST /v1/auth/refresh-token
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| refresh_token | string | 是 | 刷新令牌 |

#### 2.1.7 退出登录
```http
POST /v1/auth/logout
```

#### 2.1.8 重置密码
```http
POST /v1/auth/reset-password
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号 |
| code | string | 是 | 验证码 |
| new_password | string | 是 | 新密码 |

---

### 2.2 用户资料 (User Profile)

#### 2.2.1 获取当前用户信息
```http
GET /v1/users/me
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "user_id": 12345,
    "uuid": "usr_xxx",
    "phone": "+959123456789",
    "email": "user@example.com",
    "status": "active",
    "is_verified": true,
    "profile": {
      "nickname": "小明",
      "avatar": "https://xxx/avatar.jpg",
      "gender": "male",
      "birthday": "1990-01-01"
    },
    "verification": {
      "real_name": "张小明",
      "id_card_number": "12******89",
      "status": "approved",
      "verified_at": "2024-01-01T00:00:00Z"
    },
    "agent_info": {
      "agent_id": 1001,
      "status": "active",
      "level": "senior"
    }
  }
}
```

#### 2.2.2 更新用户资料
```http
PUT /v1/users/me
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| nickname | string | 否 | 昵称 |
| avatar | string | 否 | 头像URL |
| gender | string | 否 | male/female/other |
| birthday | string | 否 | YYYY-MM-DD |
| bio | string | 否 | 个人简介 |

#### 2.2.3 上传头像
```http
POST /v1/users/me/avatar
Content-Type: multipart/form-data
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | file | 是 | 图片文件 |

#### 2.2.4 修改密码
```http
PUT /v1/users/me/password
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| old_password | string | 是 | 旧密码 |
| new_password | string | 是 | 新密码 |

#### 2.2.5 绑定手机号
```http
POST /v1/users/me/phone
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 新手机号 |
| code | string | 是 | 验证码 |

#### 2.2.6 绑定第三方账号
```http
POST /v1/users/me/oauth
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| provider | string | 是 | facebook/google/apple |
| access_token | string | 是 | 第三方token |

---

### 2.3 实名认证 (Verification)

#### 2.3.1 提交实名认证
```http
POST /v1/users/me/verification
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| real_name | string | 是 | 真实姓名 |
| id_card_number | string | 是 | 身份证号 |
| id_card_front | string | 是 | 身份证正面照URL |
| id_card_back | string | 否 | 身份证反面照URL |

#### 2.3.2 获取实名认证状态
```http
GET /v1/users/me/verification
```

#### 2.3.3 重新提交实名认证
```http
PUT /v1/users/me/verification
```

---

### 2.4 收藏和历史 (Favorites & History)

#### 2.4.1 获取收藏列表
```http
GET /v1/users/me/favorites
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码 |
| page_size | int | 每页数量 |

#### 2.4.2 添加收藏
```http
POST /v1/users/me/favorites
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| house_id | int | 是 | 房源ID |

#### 2.4.3 取消收藏
```http
DELETE /v1/users/me/favorites/{house_id}
```

#### 2.4.4 检查是否已收藏
```http
GET /v1/users/me/favorites/{house_id}/check
```

#### 2.4.5 获取浏览历史
```http
GET /v1/users/me/browsing-history
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码 |
| page_size | int | 每页数量 |

#### 2.4.6 清除浏览历史
```http
DELETE /v1/users/me/browsing-history
```

---

## 3. 经纪人模块 API

### 3.1 经纪人注册与管理

#### 3.1.1 提交经纪人申请
```http
POST /v1/agents/apply
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| real_name | string | 是 | 真实姓名 |
| id_card_number | string | 是 | 身份证号 |
| license_number | string | 否 | 从业资格证号 |
| company_id | int | 否 | 所属公司ID |
| work_city | string | 是 | 工作城市 |
| work_districts | array | 否 | 工作区域 |
| bio | string | 否 | 个人简介 |
| id_card_front | string | 是 | 身份证正面 |
| id_card_back | string | 是 | 身份证反面 |

#### 3.1.2 获取经纪人申请状态
```http
GET /v1/agents/apply/status
```

#### 3.1.3 获取经纪人信息
```http
GET /v1/agents/{agent_id}
```

#### 3.1.4 获取当前经纪人信息
```http
GET /v1/agents/me
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "agent_id": 1001,
    "user_id": 12345,
    "real_name": "张小明",
    "avatar": "https://xxx/avatar.jpg",
    "company": {
      "id": 10,
      "name": "某某房产"
    },
    "work_city": "YGN",
    "work_districts": ["TAMWE", "BAHAN"],
    "status": "active",
    "level": "senior",
    "rating": 4.8,
    "total_deals": 50,
    "total_gmv": 500000000,
    "statistics": {
      "this_month_deals": 3,
      "this_month_gmv": 30000000,
      "this_month_commission": 1500000
    }
  }
}
```

#### 3.1.5 更新经纪人资料
```http
PUT /v1/agents/me
```

#### 3.1.6 获取经纪人统计
```http
GET /v1/agents/me/statistics
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| start_date | string | 开始日期 YYYY-MM-DD |
| end_date | string | 结束日期 YYYY-MM-DD |

---

### 3.2 团队管理

#### 3.2.1 获取团队信息
```http
GET /v1/agents/me/team
```

#### 3.2.2 获取团队成员列表
```http
GET /v1/teams/{team_id}/members
```

#### 3.2.3 获取团队业绩统计
```http
GET /v1/teams/{team_id}/statistics
```

---

### 3.3 快捷话术

#### 3.3.1 获取快捷话术列表
```http
GET /v1/agents/me/quick-replies
```

#### 3.3.2 添加快捷话术
```http
POST /v1/agents/me/quick-replies
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| category | string | 是 | 分类 |
| content | string | 是 | 内容 |

#### 3.3.3 更新快捷话术
```http
PUT /v1/agents/me/quick-replies/{id}
```

#### 3.3.4 删除快捷话术
```http
DELETE /v1/agents/me/quick-replies/{id}
```

---

## 4. 房源模块 API

### 4.1 房源搜索与发现

#### 4.1.1 首页推荐
```http
GET /v1/houses/recommendations
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| city_code | string | 城市代码 |
| district_code | string | 镇区代码 |
| page | int | 页码 |
| page_size | int | 每页数量 |

#### 4.1.2 房源搜索
```http
GET /v1/houses/search
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| transaction_type | string | sale/rent |
| city_code | string | 城市代码 |
| district_code | string | 镇区代码 |
| community_id | int | 小区ID |
| price_min | int | 最低价格 |
| price_max | int | 最高价格 |
| area_min | int | 最小面积 |
| area_max | int | 最大面积 |
| house_type | string | apartment/house/townhouse/land/commercial |
| rooms | string | 户型 |
| decoration | string | 装修程度 |
| keywords | string | 关键词 |
| sort_by | string | default/price_asc/price_desc/date/area |
| page | int | 页码 |
| page_size | int | 每页数量 |

#### 4.1.3 地图找房聚合
```http
GET /v1/houses/map-aggregate
```

**查询参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sw_lat | float | 是 | 西南角纬度 |
| sw_lng | float | 是 | 西南角经度 |
| ne_lat | float | 是 | 东北角纬度 |
| ne_lng | float | 是 | 东北角经度 |
| zoom | int | 是 | 缩放级别 |
| transaction_type | string | 否 | 交易类型 |
| price_min | int | 否 | 最低价格 |
| price_max | int | 否 | 最高价格 |

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "level": 2,
    "clusters": [
      {
        "id": "cluster_1",
        "name": "Tamwe",
        "lat": 16.8661,
        "lng": 96.1951,
        "avg_price": 85000000,
        "total_count": 128,
        "bounds": {
          "sw_lat": 16.86,
          "sw_lng": 96.19,
          "ne_lat": 16.87,
          "ne_lng": 96.20
        }
      }
    ],
    "houses": []
  }
}
```

#### 4.1.4 地图找房列表
```http
GET /v1/houses/map-list
```

**查询参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| sw_lat | float | 是 | 西南角纬度 |
| sw_lng | float | 是 | 西南角经度 |
| ne_lat | float | 是 | 东北角纬度 |
| ne_lng | float | 是 | 东北角经度 |
| page | int | 否 | 页码 |

#### 4.1.5 获取房源详情
```http
GET /v1/houses/{house_id}
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "house_id": 10001,
    "house_code": "HS202403170001",
    "title": "仰光Tamwe区精装3室公寓，交通便利",
    "title_my": "",
    "transaction_type": "sale",
    "price": 150000000,
    "price_unit": "MMK",
    "price_note": "可议价",
    "house_type": "apartment",
    "property_type": "grant",
    "area": 120.5,
    "usable_area": 115.0,
    "rooms": "3室2厅2卫",
    "bedrooms": 3,
    "living_rooms": 2,
    "bathrooms": 2,
    "floor": "8/15",
    "decoration": "fine",
    "orientation": "south",
    "build_year": 2018,
    "location": {
      "city": {
        "code": "YGN",
        "name": "仰光"
      },
      "district": {
        "code": "TAMWE",
        "name": "Tamwe"
      },
      "community": {
        "id": 100,
        "name": "某某小区"
      },
      "address": "某某街道123号",
      "lat": 16.8661,
      "lng": 96.1951
    },
    "description": "房源描述...",
    "highlights": ["近地铁", "精装修", "学区房"],
    "facilities": ["parking", "gym", "swimming_pool"],
    "property": {
      "property_type": "grant",
      "ownership": "个人产权",
      "has_loan": false,
      "property_certificate_no": "GR-XXXXX"
    },
    "verification": {
      "status": "verified",
      "verified_at": "2024-03-01T00:00:00Z",
      "verified_by": "平台验真员",
      "report_url": "https://xxx/report.pdf"
    },
    "images": [
      {
        "id": 1,
        "url": "https://xxx/image1.jpg",
        "type": "interior",
        "is_main": true
      }
    ],
    "agent": {
      "agent_id": 1001,
      "name": "张小明",
      "avatar": "https://xxx/avatar.jpg",
      "company": "某某房产",
      "rating": 4.8,
      "deal_count": 50,
      "phone": "+9591234****"
    },
    "stats": {
      "view_count": 500,
      "favorite_count": 30,
      "inquiry_count": 15
    },
    "is_favorited": false,
    "created_at": "2024-03-01T00:00:00Z",
    "published_at": "2024-03-01T00:00:00Z"
  }
}
```

#### 4.1.6 获取相似房源
```http
GET /v1/houses/{house_id}/similar
```

#### 4.1.7 获取推荐房源
```http
GET /v1/houses/suggested
```

---

### 4.2 经纪人房源管理

#### 4.2.1 获取我的房源列表
```http
GET /v1/agents/me/houses
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| status | string | 状态筛选 |
| transaction_type | string | 交易类型 |
| page | int | 页码 |
| page_size | int | 每页数量 |

#### 4.2.2 创建房源
```http
POST /v1/agents/me/houses
```

**请求参数:**

```json
{
  "title": "房源标题",
  "transaction_type": "sale",
  "house_type": "apartment",
  "price": 150000000,
  "price_unit": "MMK",
  "area": 120,
  "rooms": "3室2厅2卫",
  "bedrooms": 3,
  "living_rooms": 2,
  "bathrooms": 2,
  "floor": "8",
  "total_floors": 15,
  "decoration": "fine",
  "orientation": "south",
  "build_year": 2018,
  "city_code": "YGN",
  "district_code": "TAMWE",
  "community_id": 100,
  "address": "详细地址",
  "latitude": 16.8661,
  "longitude": 96.1951,
  "description": "房源描述",
  "highlights": ["近地铁", "精装修"],
  "facilities": ["parking", "gym"],
  "property_type": "grant",
  "owner_name": "业主姓名",
  "owner_phone": "+959123456789",
  "has_loan": false,
  "images": [
    {"url": "https://xxx/1.jpg", "type": "interior"},
    {"url": "https://xxx/2.jpg", "type": "exterior"}
  ]
}
```

#### 4.2.3 获取房源草稿
```http
GET /v1/agents/me/houses/drafts
```

#### 4.2.4 保存房源草稿
```http
POST /v1/agents/me/houses/drafts
```

#### 4.2.5 更新房源
```http
PUT /v1/agents/me/houses/{house_id}
```

#### 4.2.6 删除房源
```http
DELETE /v1/agents/me/houses/{house_id}
```

#### 4.2.7 上架/下架房源
```http
PUT /v1/agents/me/houses/{house_id}/status
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| status | string | 是 | online/offline |
| reason | string | 否 | 原因 |

#### 4.2.8 修改房源价格
```http
PUT /v1/agents/me/houses/{house_id}/price
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| new_price | int | 是 | 新价格 |
| reason | string | 否 | 调价原因 |

#### 4.2.9 刷新房源
```http
POST /v1/agents/me/houses/{house_id}/refresh
```

---

### 4.3 图片管理

#### 4.3.1 上传房源图片
```http
POST /v1/agents/me/houses/{house_id}/images
Content-Type: multipart/form-data
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| files | files | 是 | 图片文件 |
| type | string | 否 | 图片类型 |

#### 4.3.2 删除房源图片
```http
DELETE /v1/agents/me/houses/{house_id}/images/{image_id}
```

#### 4.3.3 设置主图
```http
PUT /v1/agents/me/houses/{house_id}/images/{image_id}/main
```

#### 4.3.4 调整图片顺序
```http
PUT /v1/agents/me/houses/{house_id}/images/sort
```

---

## 5. 验真模块 API

### 5.1 验真任务管理

#### 5.1.1 获取待验真任务列表
```http
GET /v1/verification/tasks
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| status | string | 状态筛选 |
| page | int | 页码 |

#### 5.1.2 领取验真任务
```http
POST /v1/verification/tasks/{task_id}/claim
```

#### 5.1.3 获取验真任务详情
```http
GET /v1/verification/tasks/{task_id}
```

#### 5.1.4 提交验真结果
```http
POST /v1/verification/tasks/{task_id}/submit
```

**请求参数:**

```json
{
  "result": "pass",
  "score": 95,
  "report": "验真报告内容",
  "items": [
    {
      "item_name": "房源存在性",
      "status": "pass",
      "remark": "现场核实房源存在",
      "photos": ["url1", "url2"]
    }
  ],
  "photos": [
    {
      "photo_type": "building_exterior",
      "photo_url": "https://xxx/1.jpg",
      "lat": 16.8661,
      "lng": 96.1951
    }
  ]
}
```

#### 5.1.5 获取验真报告
```http
GET /v1/houses/{house_id}/verification-report
```

---

## 6. 客户模块 API

### 6.1 客户管理

#### 6.1.1 获取客户列表
```http
GET /v1/agents/me/clients
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| status | string | 状态筛选 |
| priority | string | 优先级筛选 |
| keywords | string | 关键词搜索 |
| page | int | 页码 |

#### 6.1.2 获取客户详情
```http
GET /v1/agents/me/clients/{client_id}
```

#### 6.1.3 创建客户
```http
POST /v1/agents/me/clients
```

**请求参数:**

```json
{
  "name": "客户姓名",
  "phone": "+959123456789",
  "gender": "male",
  "demand_type": "buy",
  "demand_city": "YGN",
  "demand_districts": ["TAMWE", "BAHAN"],
  "budget_min": 100000000,
  "budget_max": 200000000,
  "preferred_house_types": ["apartment", "house"],
  "preferred_rooms": ["2室", "3室"],
  "move_in_date": "2024-06-01",
  "priority": "high",
  "source": "platform"
}
```

#### 6.1.4 更新客户信息
```http
PUT /v1/agents/me/clients/{client_id}
```

#### 6.1.5 删除客户
```http
DELETE /v1/agents/me/clients/{client_id}
```

---

### 6.2 跟进记录

#### 6.2.1 获取跟进记录列表
```http
GET /v1/agents/me/clients/{client_id}/follow-ups
```

#### 6.2.2 添加跟进记录
```http
POST /v1/agents/me/clients/{client_id}/follow-ups
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| follow_up_type | string | 是 | phone/wechat/meeting/showing |
| content | string | 是 | 跟进内容 |
| next_follow_up_at | string | 否 | 下次跟进时间 |
| next_follow_up_content | string | 否 | 下次跟进内容 |

---

## 7. 预约带看模块 API

### 7.1 预约管理

#### 7.1.1 创建预约
```http
POST /v1/appointments
```

**请求参数:**

```json
{
  "house_id": 10001,
  "agent_id": 1001,
  "appointment_date": "2024-03-20",
  "appointment_time_start": "14:00",
  "appointment_time_end": "15:00",
  "client_name": "客户姓名",
  "client_phone": "+959123456789",
  "client_note": "备注"
}
```

#### 7.1.2 获取预约列表
```http
GET /v1/appointments
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| role | string | user/agent 视角 |
| status | string | 状态筛选 |
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |
| page | int | 页码 |

#### 7.1.3 获取预约详情
```http
GET /v1/appointments/{appointment_id}
```

#### 7.1.4 确认预约
```http
PUT /v1/appointments/{appointment_id}/confirm
```

#### 7.1.5 拒绝预约
```http
PUT /v1/appointments/{appointment_id}/reject
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| reason | string | 是 | 拒绝原因 |
| suggested_time | string | 否 | 建议的其他时间 |

#### 7.1.6 取消预约
```http
PUT /v1/appointments/{appointment_id}/cancel
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| reason | string | 是 | 取消原因 |

#### 7.1.7 完成带看
```http
PUT /v1/appointments/{appointment_id}/complete
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| showing_result | string | 是 | interested/considering/not_interested/negotiating |
| showing_feedback | string | 否 | 反馈内容 |

---

### 7.2 日程管理

#### 7.2.1 获取可用时段
```http
GET /v1/agents/{agent_id}/schedules
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| date | string | 日期 YYYY-MM-DD |

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "date": "2024-03-20",
    "slots": [
      {
        "time": "09:00-09:30",
        "is_available": true,
        "max_appointments": 3,
        "booked_count": 1
      },
      {
        "time": "09:30-10:00",
        "is_available": false,
        "max_appointments": 3,
        "booked_count": 3
      }
    ]
  }
}
```

#### 7.2.2 设置日程
```http
PUT /v1/agents/me/schedules
```

**请求参数:**

```json
{
  "schedules": [
    {
      "work_date": "2024-03-20",
      "time_slots": [
        {"time": "09:00-09:30", "is_available": true},
        {"time": "09:30-10:00", "is_available": true}
      ]
    }
  ]
}
```

---

## 8. IM消息模块 API

### 8.1 会话管理

#### 8.1.1 获取会话列表
```http
GET /v1/conversations
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| page | int | 页码 |

#### 8.1.2 获取或创建会话
```http
POST /v1/conversations
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| agent_id | int | 是 | 经纪人ID |
| house_id | int | 否 | 关联房源ID |

#### 8.1.3 获取会话详情
```http
GET /v1/conversations/{conversation_id}
```

#### 8.1.4 删除会话
```http
DELETE /v1/conversations/{conversation_id}
```

#### 8.1.5 会话置顶/取消置顶
```http
PUT /v1/conversations/{conversation_id}/pin
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| is_pinned | bool | 是 | 是否置顶 |

---

### 8.2 消息管理

#### 8.2.1 获取消息列表
```http
GET /v1/conversations/{conversation_id}/messages
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| before_id | int | 早于该ID的消息 |
| after_id | int | 晚于该ID的消息 |
| limit | int | 数量限制 |

#### 8.2.2 发送消息
```http
POST /v1/conversations/{conversation_id}/messages
```

**请求参数:**

```json
{
  "message_type": "text",
  "content": "消息内容",
  "extra_data": {}
}
```

#### 8.2.3 发送图片消息
```http
POST /v1/conversations/{conversation_id}/messages/image
Content-Type: multipart/form-data
```

#### 8.2.4 发送房源卡片
```http
POST /v1/conversations/{conversation_id}/messages/house-card
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| house_id | int | 是 | 房源ID |

#### 8.2.5 撤回消息
```http
PUT /v1/conversations/{conversation_id}/messages/{message_id}/recall
```

#### 8.2.6 标记已读
```http
PUT /v1/conversations/{conversation_id}/read
```

---

### 8.3 第三方IM集成

#### 8.3.1 获取IM Token
```http
GET /v1/im/token
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "token": "xxx",
    "expires_at": 1710727200,
    "provider": "easemob"
  }
}
```

#### 8.3.2 同步用户到IM
```http
POST /v1/im/sync-user
```

#### 8.3.3 获取历史消息
```http
GET /v1/im/history-messages
```

---

## 9. ACN分佣模块 API

### 9.1 ACN规则与配置

#### 9.1.1 获取ACN角色列表
```http
GET /v1/acn/roles
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "roles": [
      {
        "code": "ENTRANT",
        "name": "房源录入人",
        "default_ratio": 15.0,
        "role_type": "source"
      },
      {
        "code": "MAINTAINER",
        "name": "房源维护人",
        "default_ratio": 20.0,
        "role_type": "source"
      },
      {
        "code": "INTRODUCER",
        "name": "客源转介绍",
        "default_ratio": 10.0,
        "role_type": "client"
      },
      {
        "code": "ACCOMPANIER",
        "name": "带看人",
        "default_ratio": 15.0,
        "role_type": "client"
      },
      {
        "code": "CLOSER",
        "name": "成交人",
        "default_ratio": 40.0,
        "role_type": "client"
      }
    ],
    "platform_ratio": 10.0
  }
}
```

---

### 9.2 成交单管理

#### 9.2.1 申报成交
```http
POST /v1/acn/transactions
```

**请求参数:**

```json
{
  "house_id": 10001,
  "deal_price": 150000000,
  "commission_amount": 3000000,
  "deal_date": "2024-03-15",
  "contract_image": "https://xxx/contract.jpg",
  "participants": [
    {"role": "ENTRANT", "agent_id": 1001, "ratio": 15},
    {"role": "MAINTAINER", "agent_id": 1002, "ratio": 20},
    {"role": "ACCOMPANIER", "agent_id": 1003, "ratio": 15},
    {"role": "CLOSER", "agent_id": 1004, "ratio": 40}
  ]
}
```

#### 9.2.2 获取成交单列表
```http
GET /v1/acn/transactions
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| status | string | 状态筛选 |
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |
| page | int | 页码 |

#### 9.2.3 获取成交单详情
```http
GET /v1/acn/transactions/{transaction_id}
```

#### 9.2.4 确认成交单
```http
PUT /v1/acn/transactions/{transaction_id}/confirm
```

#### 9.2.5 发起争议
```http
POST /v1/acn/transactions/{transaction_id}/disputes
```

**请求参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| dispute_type | string | 是 | 争议类型 |
| reason | string | 是 | 争议原因 |
| evidence | array | 否 | 证据图片 |

---

### 9.3 分佣结算

#### 9.3.1 获取分佣明细
```http
GET /v1/acn/commissions
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| status | string | 状态筛选 |
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |

#### 9.3.2 获取分佣统计
```http
GET /v1/acn/commissions/statistics
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "total_commission": 5000000,
    "pending_amount": 2000000,
    "confirmed_amount": 2500000,
    "paid_amount": 500000,
    "this_month": 1500000,
    "last_month": 2000000,
    "by_role": {
      "ENTRANT": 800000,
      "MAINTAINER": 1000000,
      "CLOSER": 2000000
    }
  }
}
```

---

## 10. 财务管理模块 API

### 10.1 账户管理

#### 10.1.1 获取账户余额
```http
GET /v1/finance/account
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "balance": 5000000,
    "frozen_amount": 1000000,
    "available_amount": 4000000,
    "total_earned": 20000000,
    "total_withdrawn": 15000000
  }
}
```

#### 10.1.2 获取账户流水
```http
GET /v1/finance/account/logs
```

**查询参数:**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 类型筛选 |
| start_date | string | 开始日期 |
| end_date | string | 结束日期 |
| page | int | 页码 |

---

### 10.2 提现管理

#### 10.2.1 申请提现
```http
POST /v1/finance/withdrawals
```

**请求参数:**

```json
{
  "amount": 1000000,
  "bank_name": "KBZ Bank",
  "bank_account_name": "Zhang Xiaoming",
  "bank_account_number": "1234567890"
}
```

#### 10.2.2 获取提现记录
```http
GET /v1/finance/withdrawals
```

#### 10.2.3 获取提现详情
```http
GET /v1/finance/withdrawals/{withdrawal_id}
```

#### 10.2.4 取消提现申请
```http
PUT /v1/finance/withdrawals/{withdrawal_id}/cancel
```

---

## 11. 地推模块 API

### 11.1 地推人员管理

#### 11.1.1 申请成为地推
```http
POST /v1/promoters/apply
```

#### 11.1.2 获取地推信息
```http
GET /v1/promoters/me
```

#### 11.1.3 获取推广二维码
```http
GET /v1/promoters/me/qrcode
```

---

### 11.2 推广任务与统计

#### 11.2.1 获取推广统计
```http
GET /v1/promoters/me/statistics
```

**响应示例:**

```json
{
  "code": 200,
  "data": {
    "total_invited_agents": 10,
    "total_invited_owners": 20,
    "total_commission": 500000,
    "this_month": {
      "invited_agents": 2,
      "invited_owners": 5,
      "commission": 100000
    }
  }
}
```

#### 11.2.2 获取推广记录
```http
GET /v1/promoters/me/tasks
```

---

## 12. 管理后台 API

### 12.1 用户管理

#### 12.1.1 获取用户列表
```http
GET /v1/admin/users
```

#### 12.1.2 获取用户详情
```http
GET /v1/admin/users/{user_id}

#### 12.1.3 更新用户状态
```http
PUT /v1/admin/users/{user_id}/status
```

#### 12.1.4 审核实名认证
```http
PUT /v1/admin/verifications/{verification_id}/review
```

---

### 12.2 经纪人管理

#### 12.2.1 获取经纪人列表
```http
GET /v1/admin/agents
```

#### 12.2.2 审核经纪人申请
```http
PUT /v1/admin/agents/{agent_id}/review
```

#### 12.2.3 更新经纪人等级
```http
PUT /v1/admin/agents/{agent_id}/level
```

---

### 12.3 房源管理

#### 12.3.1 获取房源列表
```http
GET /v1/admin/houses
```

#### 12.3.2 审核房源
```http
PUT /v1/admin/houses/{house_id}/review
```

#### 12.3.3 下架房源
```http
PUT /v1/admin/houses/{house_id}/offline
```

---

### 12.4 验真管理

#### 12.4.1 分配验真任务
```http
POST /v1/admin/verification-tasks/assign
```

#### 12.4.2 获取验真任务列表
```http
GET /v1/admin/verification-tasks
```

---

### 12.5 财务管理

#### 12.5.1 获取提现申请列表
```http
GET /v1/admin/withdrawals
```

#### 12.5.2 审核提现申请
```http
PUT /v1/admin/withdrawals/{withdrawal_id}/review
```

#### 12.5.3 标记提现完成
```http
PUT /v1/admin/withdrawals/{withdrawal_id}/complete
```

---

### 12.6 ACN争议仲裁

#### 12.6.1 获取争议列表
```http
GET /v1/admin/acn-disputes
```

#### 12.6.2 处理争议
```http
PUT /v1/admin/acn-disputes/{dispute_id}/resolve
```

---

### 12.7 数据统计

#### 12.7.1 获取核心数据看板
```http
GET /v1/admin/dashboard
```

#### 12.7.2 获取用户统计数据
```http
GET /v1/admin/statistics/users
```

#### 12.7.3 获取房源统计数据
```http
GET /v1/admin/statistics/houses
```

#### 12.7.4 获取交易统计数据
```http
GET /v1/admin/statistics/transactions
```

---

### 12.8 系统配置

#### 12.8.1 获取配置列表
```http
GET /v1/admin/configs
```

#### 12.8.2 更新配置
```http
PUT /v1/admin/configs/{config_key}
```

#### 12.8.3 Banner管理
```http
GET /v1/admin/banners
POST /v1/admin/banners
PUT /v1/admin/banners/{id}
DELETE /v1/admin/banners/{id}
```

---

## 附录 A: 接口统计

| 模块 | 接口数量 |
|------|----------|
| 用户模块 | 28 |
| 经纪人模块 | 18 |
| 房源模块 | 24 |
| 验真模块 | 5 |
| 客户模块 | 9 |
| 预约带看模块 | 10 |
| IM消息模块 | 13 |
| ACN分佣模块 | 8 |
| 财务管理模块 | 7 |
| 地推模块 | 5 |
| 管理后台 | 28 |
| **总计** | **155** |

---

*文档结束*
