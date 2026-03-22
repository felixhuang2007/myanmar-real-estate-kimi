# 缅甸房产平台 - 技术文档

**项目**: Myanmar Home - Real Estate Platform
**版本**: 1.0
**更新日期**: 2026-03-18

---

## 文档目录

| 文档 | 路径 | 说明 |
|------|------|------|
| **系统架构** | `architecture/01-system-overview.md` | 整体技术架构、模块说明 |
| **本地部署** | `deployment/01-local-development.md` | 开发环境搭建指南 |
| **开发规范** | `development/01-coding-standards.md` | 代码规范、Git流程 |
| **API文档** | `api/01-authentication.md` | 接口详细说明 |
| **测试指南** | `testing/01-testing-guide.md` | 测试策略、用例编写 |

---

## 快速开始

### 1. 环境要求
- Go 1.21+
- Node.js 18+
- Flutter 3.19+
- Docker Desktop

### 2. 启动服务

```bash
# 进入项目目录
cd myanmar-real-estate

# 启动基础设施（PostgreSQL + Redis + ES）
cd backend && docker-compose up -d

# 配置环境变量
cp backend/.env.example backend/.env
# 编辑 .env 填入配置

# 启动后端
source backend/.env
cd backend && go run cmd/server/main.go

# 启动前端（新终端）
cd frontend/web-admin && npm run dev
```

### 3. 访问服务

| 服务 | 地址 |
|------|------|
| 后端API | http://localhost:8080 |
| 管理后台 | http://localhost:8000 |
| API健康检查 | http://localhost:8080/health |

---

## 项目结构

```
myanmar-real-estate/
├── backend/              # Go后端服务
│   ├── cmd/server/       # 入口文件
│   ├── 03-user-service/  # 用户模块
│   ├── 04-house-service/ # 房源模块
│   ├── 05-acn-service/   # ACN分佣模块
│   ├── 07-common/        # 公共组件
│   └── docker-compose.yml
├── flutter/              # Flutter移动端
│   ├── lib/buyer/        # C端买家APP
│   └── lib/agent/        # B端经纪人APP
├── frontend/             # Web前端
│   └── web-admin/        # 管理后台 (React)
├── design/               # 设计文档
├── devops/               # 部署配置
├── qa/                   # 测试用例
└── docs/                 # 技术文档
```

---

## 核心功能

### 1. 用户系统
- 手机号注册/登录
- JWT Token认证
- 实名认证
- 用户画像

### 2. 房源系统
- 房源发布（图片/视频）
- 多维度搜索
- 地图找房
- 房源验真

### 3. ACN协作网络
5角色分佣模型：
- **录入人**: 35%（房源方）
- **维护人**: 分配比例
- **转介绍**: 分配比例
- **带看人**: 65%（客源方）
- **成交人**: 分配比例

### 4. 预约看房
- 在线预约
- 时间冲突检测
- 看房反馈

---

## 技术栈

### 后端
- **语言**: Go 1.21+
- **框架**: Gin
- **ORM**: GORM
- **数据库**: PostgreSQL 15
- **缓存**: Redis 7
- **搜索**: Elasticsearch 8

### 前端
- **移动端**: Flutter 3.19
- **管理后台**: React 18 + UmiJS 4 + Ant Design 5
- **类型**: TypeScript

### 运维
- **容器**: Docker + Docker Compose
- **监控**: Prometheus + Grafana
- **网关**: Nginx

---

## 模拟服务配置

本地开发无需真实第三方账号，使用以下模拟方案：

| 服务 | 模拟方案 | 配置 |
|------|----------|------|
| **短信** | Mock模式 | 验证码固定`123456` |
| **存储** | MinIO | http://localhost:9000 |
| **IM** | Mock模式 | 内存存储 |
| **地图** | Google Maps（可选）| 需申请免费API Key |

启动MinIO:
```bash
docker run -d -p 9000:9000 -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"
```

---

## 开发工作流

### 1. 分支管理
```
main (生产)
  ↑
develop (开发)
  ↑
feature/xxx (功能分支)
```

### 2. 提交规范
```
feat(user): 添加用户实名认证

- 实现身份证OCR识别
- 添加实名认证状态机
```

### 3. 代码审查
- 单元测试通过
- 无敏感信息
- 符合编码规范

---

## 测试

### 运行测试
```bash
# 后端测试
cd backend && go test ./...

# 前端测试
cd flutter && flutter test
```

### 覆盖率
```bash
# Go覆盖率
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

---

## 常见问题

### Q: 数据库连接失败？
A: 确保Docker已启动且容器运行正常
```bash
cd backend
docker-compose ps
docker-compose logs postgres
```

### Q: 如何重置数据库？
A:
```bash
cd backend
docker-compose down -v
docker-compose up -d
# 重新执行schema
psql -h localhost -U myanmar_property -d myanmarhome -f 01-database-schema.sql
```

### Q: 修改代码后需要重启？
A:
- **后端**: 需要重新编译运行
- **前端**: 支持热重载，自动刷新

---

## 安全提醒

⚠️ **生产环境必须修改**:
1. JWT Secret（最小32位随机字符串）
2. 数据库密码（强密码）
3. 使用真实第三方服务账号
4. 启用HTTPS
5. 配置防火墙规则

---

## 联系方式

| 角色 | 职责 |
|------|------|
| 技术负责人 | 架构设计、技术决策 |
| 后端开发 | API开发、数据库设计 |
| 前端开发 | 移动端/Web端开发 |
| 测试工程师 | 测试用例、质量保障 |
| 运维工程师 | 部署、监控 |

---

## 更新日志

### v1.0 (2026-03-18)
- 初始化项目文档
- 添加系统架构说明
- 添加部署指南
- 添加开发规范
- 添加API文档
- 添加测试指南

---

**注意**: 本文档持续更新，如有疑问请查阅具体模块文档。
