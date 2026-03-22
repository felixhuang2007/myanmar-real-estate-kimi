# AGENT-002 任务书 - 后端工程师

> **角色**: Go后端工程师  
> **代号**: AGENT-002  
> **项目**: 缅甸房产平台  
> **周期**: 8周  
> **汇报对象**: AI项目经理

---

## 一、角色职责

1. **服务端开发**: 开发Go后端服务，实现业务逻辑
2. **API实现**: 实现RESTful API接口
3. **服务集成**: 集成第三方服务（IM、短信、地图等）
4. **性能优化**: 优化服务性能，确保高并发处理能力
5. **单元测试**: 编写单元测试，保证代码质量

---

## 二、任务清单

### Week 1: 环境搭建与基础服务

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-001 | 开发环境搭建 | 可运行环境 | Day 1 | P0 |
| B002-002 | 项目结构初始化 | 代码框架 | Day 2 | P0 |
| B002-003 | 数据库连接与ORM配置 | DB模块 | Day 3 | P0 |
| B002-004 | 日志与配置管理 | 基础组件 | Day 4 | P0 |
| B002-005 | 中间件开发(日志/恢复) | 中间件代码 | Day 5 | P0 |

### Week 2: 用户服务

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-006 | 用户模型与数据库表 | Model + Migration | Day 6 | P0 |
| B002-007 | 手机注册/登录API | Auth API | Day 8 | P0 |
| B002-008 | JWT认证中间件 | JWT组件 | Day 9 | P0 |
| B002-009 | 实名认证API | Verify API | Day 10 | P0 |
| B002-010 | 短信验证码服务 | SMS服务 | Day 10 | P0 |

### Week 3: 房源服务

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-011 | 房源模型与数据库表 | House Model | Day 12 | P0 |
| B002-012 | 房源CRUD API | House API | Day 14 | P0 |
| B002-013 | 房源搜索API | Search API | Day 16 | P0 |
| B002-014 | 图片上传服务 | Upload API | Day 17 | P0 |
| B002-015 | 收藏功能API | Favorite API | Day 18 | P0 |

### Week 4: 地图服务与房源增强

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-016 | 地图聚合服务 | Map Aggregate API | Day 20 | P0 |
| B002-017 | GeoHash索引实现 | 空间索引 | Day 22 | P0 |
| B002-018 | 房源审核状态机 | 状态机实现 | Day 24 | P0 |
| B002-019 | 房源推荐API | Recommend API | Day 25 | P0 |
| B002-020 | 经纪人房源管理API | Agent House API | Day 26 | P0 |

### Week 5: IM与预约服务

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-021 | IM服务集成 | IM SDK集成 | Day 29 | P0 |
| B002-022 | IM会话管理API | Chat API | Day 31 | P0 |
| B002-023 | 消息推送服务 | Push Service | Day 33 | P0 |
| B002-024 | 预约模型与API | Appointment API | Day 34 | P0 |
| B002-025 | 日程管理服务 | Schedule API | Day 35 | P0 |

### Week 6: 验真与客户管理

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-026 | 验真工作流引擎 | Workflow API | Day 37 | P0 |
| B002-027 | 验真任务API | Verification API | Day 39 | P0 |
| B002-028 | 客户模型与API | Client API | Day 41 | P0 |
| B002-029 | 线索分配服务 | Lead API | Day 42 | P0 |
| B002-030 | 跟进记录API | Follow-up API | Day 43 | P0 |
| B002-031 | 带看管理API | Showing API | Day 44 | P0 |
| B002-032 | 水印图片生成服务 | Watermark Service | Day 45 | P0 |

### Week 7: ACN与分佣系统

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-033 | ACN角色模型 | ACN Model | Day 46 | P0 |
| B002-034 | 成交申报API | Deal API | Day 48 | P0 |
| B002-035 | 分佣计算引擎 | Commission Engine | Day 50 | P0 |
| B002-036 | 业绩统计API | Performance API | Day 52 | P0 |
| B002-037 | 地推服务API | Ground Promoter API | Day 53 | P0 |
| B002-038 | 提现管理API | Withdrawal API | Day 54 | P0 |

### Week 8: 后台API与优化

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| B002-039 | 后台管理API | Admin API | Day 55 | P0 |
| B002-040 | 数据看板API | Dashboard API | Day 56 | P0 |
| B002-041 | 性能优化 | 优化代码 | Day 57 | P1 |
| B002-042 | 接口文档整理 | API文档 | Day 58 | P0 |
| B002-043 | Bug修复 | 修复版本 | Day 59-60 | P0 |
| B002-044 | 代码Review | 最终版本 | Day 60 | P0 |

---

## 三、核心API清单

### 3.1 用户服务API

```yaml
# 认证相关
POST   /v1/auth/register          # 注册
POST   /v1/auth/login             # 登录
POST   /v1/auth/refresh           # 刷新Token
POST   /v1/auth/logout            # 退出
POST   /v1/auth/sms/send          # 发送验证码

# 用户相关
GET    /v1/user/profile           # 获取用户信息
PUT    /v1/user/profile           # 更新用户信息
POST   /v1/user/verify            # 实名认证
GET    /v1/user/verify/status     # 查询认证状态
```

### 3.2 房源服务API

```yaml
# 房源CRUD
POST   /v1/houses                 # 创建房源
GET    /v1/houses                 # 房源列表
GET    /v1/houses/:id             # 房源详情
PUT    /v1/houses/:id             # 更新房源
DELETE /v1/houses/:id             # 删除房源

# 房源搜索
GET    /v1/houses/search          # 搜索房源
GET    /v1/houses/recommend       # 推荐房源
GET    /v1/houses/map/aggregate   # 地图聚合

# 收藏
POST   /v1/houses/:id/favorite    # 收藏房源
DELETE /v1/houses/:id/favorite    # 取消收藏
GET    /v1/user/favorites         # 我的收藏
```

### 3.3 预约服务API

```yaml
POST   /v1/appointments           # 创建预约
GET    /v1/appointments           # 预约列表
GET    /v1/appointments/:id       # 预约详情
PUT    /v1/appointments/:id       # 更新预约
POST   /v1/appointments/:id/confirm   # 确认预约
POST   /v1/appointments/:id/cancel    # 取消预约
```

### 3.4 ACN服务API

```yaml
POST   /v1/acn/deals              # 成交申报
GET    /v1/acn/deals              # 成交列表
POST   /v1/acn/deals/:id/confirm  # 确认成交
GET    /v1/acn/commission         # 佣金明细
GET    /v1/acn/performance        # 业绩统计
```

---

## 四、代码规范

### 4.1 项目结构

```
/backend
├── cmd/                    # 启动入口
│   └── server/
├── internal/               # 内部代码
│   ├── config/            # 配置
│   ├── middleware/        # 中间件
│   ├── model/             # 数据模型
│   ├── repository/        # 数据访问
│   ├── service/           # 业务逻辑
│   ├── handler/           # HTTP处理器
│   ├── dto/               # 数据传输对象
│   └── pkg/               # 内部工具包
├── pkg/                    # 公共包
├── api/                    # API定义
├── migrations/             # 数据库迁移
├── scripts/                # 脚本
└── tests/                  # 测试
```

### 4.2 命名规范

- 包名: 小写，简短，有意义
- 文件名: snake_case.go
- 结构体: PascalCase
- 接口: PascalCase，以er结尾
- 方法: PascalCase(公开) / camelCase(私有)
- 变量: camelCase
- 常量: SCREAMING_SNAKE_CASE

### 4.3 接口响应格式

```go
// 统一响应结构
type Response struct {
    Code      int         `json:"code"`
    Message   string      `json:"message"`
    Data      interface{} `json:"data"`
    RequestID string      `json:"requestId"`
}

// 分页响应
type PageResponse struct {
    List     interface{} `json:"list"`
    Total    int64       `json:"total"`
    Page     int         `json:"page"`
    PageSize int         `json:"pageSize"`
}
```

---

## 五、验收标准

### 5.1 功能验收

- [ ] 所有API按文档实现
- [ ] 单元测试覆盖率 > 60%
- [ ] 接口响应时间 < 200ms (P95)
- [ ] 并发处理能力满足需求

### 5.2 代码质量

- [ ] 通过golangci-lint检查
- [ ] 代码注释完整
- [ ] 错误处理完善
- [ ] 无内存泄漏

### 5.3 文档交付

- [ ] API接口文档(Swagger)
- [ ] 数据库设计文档
- [ ] 部署配置文档
- [ ] 接口调用示例

---

## 六、依赖与协作

### 6.1 我依赖谁

| 依赖 | 内容 | 时间 |
|------|------|------|
| AGENT-001 | 架构设计/API规范 | Week 1 |
| AGENT-006 | 数据库设计 | Week 1 |
| AGENT-001 | IM服务选型 | Week 2 |

### 6.2 谁依赖我

| 依赖方 | 内容 | 时间 |
|--------|------|------|
| AGENT-003 | C端APP API | Week 2+ |
| AGENT-004 | B端APP API | Week 2+ |
| AGENT-005 | Web后台 API | Week 2+ |

---

## 七、性能目标

| 指标 | 目标值 | 说明 |
|------|--------|------|
| API响应时间(P95) | < 200ms | 正常负载下 |
| 搜索响应时间 | < 500ms | 复杂查询 |
| 地图聚合响应时间 | < 300ms | 缓存命中 |
| 并发用户支持 | 10000+ | 同时在线 |
| 数据库连接池 | 100 | 最大连接数 |

---

*任务书创建: 2026-03-17*  
*版本: v1.0*
