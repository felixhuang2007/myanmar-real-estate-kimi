# 缅甸房产平台 - DevOps 基础设施

本目录包含缅甸房产平台的完整 DevOps 基础设施配置，包括 CI/CD 流水线、Docker 编排、部署文档和开发环境配置。

## 📁 目录结构

```
devops/
├── ci-cd/                    # CI/CD 配置文件
│   ├── backend-ci.yml        # 后端服务 GitHub Actions CI/CD
│   ├── frontend-web-ci.yml   # 前端 Web GitHub Actions CI/CD
│   ├── mobile-ci.yml         # 移动端 GitHub Actions CI/CD
│   └── .gitlab-ci.yml        # GitLab CI 配置
│
├── docker/                   # Docker 编排配置
│   ├── docker-compose.yml    # 本地开发环境
│   ├── docker-compose.prod.yml  # 生产环境
│   ├── Dockerfile.backend    # 后端服务 Dockerfile
│   ├── Dockerfile.frontend-web  # 前端 Web Dockerfile
│   ├── Dockerfile.admin-web  # 管理后台 Dockerfile
│   ├── nginx/                # Nginx 配置
│   │   ├── nginx.dev.conf    # 开发环境 Nginx 配置
│   │   └── nginx.prod.conf   # 生产环境 Nginx 配置
│   └── monitoring/           # 监控配置
│       ├── prometheus.yml    # Prometheus 开发配置
│       ├── prometheus.prod.yml  # Prometheus 生产配置
│       ├── alert_rules.yml   # 告警规则
│       └── grafana/          # Grafana 配置
│           ├── datasources/
│           └── dashboards/
│
├── deployment/               # 部署文档
│   ├── DEPLOYMENT_GUIDE.md   # 完整部署指南
│   └── .env.example          # 环境变量模板
│
├── scripts/                  # 部署脚本
│   ├── init.sh               # 服务器初始化脚本
│   ├── deploy.sh             # 部署脚本
│   └── backup.sh             # 数据库备份脚本
│
└── Makefile                  # 常用命令快捷方式
```

## 🚀 快速开始

### 1. 开发环境搭建

```bash
# 克隆代码仓库
git clone https://github.com/your-org/myanmarestate.git
cd myanmarestate

# 启动开发环境
make dev
```

开发环境启动后，可以访问以下服务：

| 服务 | 地址 | 说明 |
|------|------|------|
| API 服务 | http://localhost:3000 | 后端 API |
| Web 前端 | http://localhost:5173 | C 端 Web 应用 |
| 管理后台 | http://localhost:5174 | 管理后台 |
| PostgreSQL | localhost:5432 | 数据库 |
| Redis | localhost:6379 | 缓存 |
| MinIO | http://localhost:9000 | 对象存储 |
| Grafana | http://localhost:3001 | 监控面板 |
| Prometheus | http://localhost:9090 | 指标采集 |

### 2. 常用命令

```bash
# 查看所有可用命令
make help

# 安装依赖
make install

# 启动/停止开发环境
make dev
make dev-stop

# 查看日志
make dev-logs

# 运行测试
make test

# 代码检查
make lint

# 构建项目
make build

# 数据库备份
make db-backup

# 数据库恢复
make db-restore
```

## 📋 CI/CD 流水线

### 后端服务 CI/CD

```
代码提交 → 代码检查 → 单元测试 → 构建 → Docker 镜像 → 部署
```

- **触发条件**: `backend/**` 目录变更
- **代码检查**: ESLint + Prettier + TypeScript 类型检查
- **单元测试**: Jest + 覆盖率报告
- **构建**: TypeScript 编译
- **部署**: Docker 容器自动部署

### 前端 Web CI/CD

```
代码提交 → 代码检查 → 单元测试 → 构建 → CDN 部署
```

- **触发条件**: `frontend-web/**` 目录变更
- **构建**: Vite 构建
- **部署**: AWS S3 + CloudFront / 阿里云 OSS + CDN

### 移动端 CI/CD

```
代码提交 → 代码检查 → 单元测试 → Android 构建 → 分发
                                    ↓
                              iOS 构建 (手动触发)
```

- **触发条件**: `mobile/**` 目录变更
- **Android**: 自动构建 APK/AAB，分发到 Firebase App Distribution / Google Play
- **iOS**: 需要手动触发，使用 macOS Runner 构建并上传到 TestFlight

## 🐳 Docker 服务

### 开发环境

```bash
cd devops/docker
docker-compose up -d
```

包含服务：
- **backend**: Node.js 后端服务
- **postgres**: PostgreSQL 15 数据库
- **redis**: Redis 7 缓存
- **minio**: 对象存储 (替代 S3)
- **nginx**: 反向代理
- **frontend-web**: 前端开发服务器
- **admin-web**: 管理后台开发服务器
- **elasticsearch**: 搜索引擎 (可选)
- **kibana**: 日志分析 (可选)
- **prometheus**: 指标采集
- **grafana**: 监控面板

### 生产环境

```bash
cd devops/docker
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

生产环境特点：
- 使用预构建的 Docker 镜像
- 资源限制配置
- 健康检查
- 日志轮转
- 监控采集

## 🔧 环境变量

复制环境变量模板并修改：

```bash
cp devops/deployment/.env.example .env
vim .env
```

关键环境变量：

| 变量名 | 说明 | 必需 |
|--------|------|------|
| `DATABASE_URL` | PostgreSQL 连接字符串 | ✅ |
| `REDIS_URL` | Redis 连接字符串 | ✅ |
| `JWT_SECRET` | JWT 签名密钥 | ✅ |
| `S3_BUCKET` | 文件存储桶 | ✅ |
| `SMS_PROVIDER` | 短信服务商 | ✅ |
| `IM_APP_KEY` | IM 应用 Key | ✅ |

## 📊 监控告警

### 监控指标

- **应用指标**: 请求量、错误率、延迟
- **系统指标**: CPU、内存、磁盘、网络
- **数据库指标**: 连接数、查询性能
- **业务指标**: 注册数、房源数、交易量

### 告警规则

| 告警名称 | 条件 | 级别 |
|----------|------|------|
| BackendDown | 服务不可用 > 1分钟 | Critical |
| HighErrorRate | 错误率 > 10% | Critical |
| HighLatency | P95 延迟 > 1s | Warning |
| HighCPUUsage | CPU > 80% | Warning |
| DiskSpaceLow | 磁盘空间 < 10% | Critical |

## 🚀 部署指南

详细部署步骤请参考：[deployment/DEPLOYMENT_GUIDE.md](deployment/DEPLOYMENT_GUIDE.md)

### 快速部署

```bash
# 1. 服务器初始化
sudo ./devops/scripts/init.sh

# 2. 配置环境变量
cp devops/deployment/.env.example /opt/myanmarestate/.env
vim /opt/myanmarestate/.env

# 3. 配置 SSL 证书
# 使用 Let's Encrypt 或自签名证书

# 4. 执行部署
./devops/scripts/deploy.sh production
```

## 🔒 安全建议

1. **环境变量**: 不要将 `.env` 文件提交到代码仓库
2. **SSL 证书**: 生产环境必须使用 HTTPS
3. **防火墙**: 仅开放必要的端口 (80, 443)
4. **数据库**: 使用强密码，限制访问 IP
5. **Docker**: 使用非 root 用户运行容器
6. **依赖**: 定期更新依赖包，修复安全漏洞

## 📝 维护任务

### 日常维护

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 重启服务
docker-compose restart backend
```

### 定期维护

- **每日**: 检查监控告警
- **每周**: 检查磁盘空间、日志文件
- **每月**: 更新系统补丁、依赖包
- **每季度**: 安全审计、性能优化

## 📚 更多文档

- [API 文档](../docs/API.md)
- [开发规范](../docs/DEVELOPMENT.md)
- [数据库设计](../docs/DATABASE.md)
- [部署指南](deployment/DEPLOYMENT_GUIDE.md)

## 🤝 贡献

请参考项目根目录的 [CONTRIBUTING.md](../CONTRIBUTING.md) 了解如何贡献代码。

## 📄 许可证

本项目采用 [MIT 许可证](../LICENSE)。
