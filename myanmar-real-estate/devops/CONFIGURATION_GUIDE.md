# 缅甸房产平台 - DevOps 配置文件清单

## 📁 完整文件列表

### CI/CD 配置 (`ci-cd/`)

| 文件路径 | 用途 | 适用平台 |
|----------|------|----------|
| `ci-cd/backend-ci.yml` | 后端服务 CI/CD 流水线 | GitHub Actions |
| `ci-cd/frontend-web-ci.yml` | 前端 Web CI/CD 流水线 | GitHub Actions |
| `ci-cd/mobile-ci.yml` | 移动端 CI/CD 流水线 | GitHub Actions |
| `ci-cd/.gitlab-ci.yml` | 完整的 GitLab CI 配置 | GitLab CI |

**GitHub Actions 流水线说明：**

1. **后端服务 CI/CD** (`backend-ci.yml`)
   - 代码检查 (ESLint + Prettier + TypeScript)
   - 单元测试 (Jest + PostgreSQL + Redis 服务)
   - 构建应用
   - 打包 Docker 镜像 (多架构支持: amd64/arm64)
   - 部署到开发环境 (自动)
   - 部署到生产环境 (自动 + Slack 通知)

2. **前端 Web CI/CD** (`frontend-web-ci.yml`)
   - 代码检查 (ESLint + Prettier)
   - 单元测试
   - 构建应用 (区分开发/生产环境)
   - 部署到 AWS S3 + CloudFront CDN

3. **移动端 CI/CD** (`mobile-ci.yml`)
   - 代码检查 (Flutter analyze + dart format)
   - 单元测试
   - Android 构建 (APK/AAB)
   - iOS 构建 (手动触发)
   - 分发到 Firebase App Distribution
   - 发布到 Google Play Store

### Docker 配置 (`docker/`)

| 文件路径 | 用途 | 环境 |
|----------|------|------|
| `docker/docker-compose.yml` | 本地开发环境完整编排 | 开发 |
| `docker/docker-compose.prod.yml` | 生产环境编排配置 | 生产 |
| `docker/Dockerfile.backend` | 后端服务多阶段构建 | 开发/生产 |
| `docker/Dockerfile.frontend-web` | 前端 Web 多阶段构建 | 开发/生产 |
| `docker/Dockerfile.admin-web` | 管理后台多阶段构建 | 开发/生产 |
| `docker/nginx/nginx.dev.conf` | 开发环境 Nginx 配置 | 开发 |
| `docker/nginx/nginx.prod.conf` | 生产环境 Nginx 配置 (含 SSL) | 生产 |

**Docker Compose 服务说明：**

- **开发环境** (`docker-compose.yml`): 12 个服务
  - backend, postgres, redis, minio, nginx
  - frontend-web, admin-web
  - elasticsearch, kibana
  - prometheus, grafana

- **生产环境** (`docker-compose.prod.yml`): 6 个服务
  - backend (多副本), nginx, redis
  - prometheus, grafana
  - node-exporter, cadvisor (监控)

### 部署文档 (`deployment/`)

| 文件路径 | 用途 |
|----------|------|
| `deployment/DEPLOYMENT_GUIDE.md` | 完整部署指南 (服务器要求、部署步骤、故障处理) |
| `deployment/.env.example` | 环境变量模板 (包含所有必需和可选变量) |

### 脚本 (`scripts/`)

| 文件路径 | 用途 |
|----------|------|
| `scripts/init.sh` | 服务器初始化脚本 (安装 Docker、配置系统参数) |
| `scripts/deploy.sh` | 自动化部署脚本 (支持开发/生产环境) |
| `scripts/backup.sh` | 数据库备份脚本 (自动上传到 S3、清理旧备份) |

### 监控配置 (`docker/monitoring/`)

| 文件路径 | 用途 |
|----------|------|
| `docker/monitoring/prometheus.yml` | Prometheus 开发环境配置 |
| `docker/monitoring/prometheus.prod.yml` | Prometheus 生产环境配置 |
| `docker/monitoring/alert_rules.yml` | 告警规则配置 (后端、系统、数据库) |
| `docker/monitoring/grafana/datasources/datasources.yml` | Grafana 数据源配置 |
| `docker/monitoring/grafana/dashboards/dashboard.json` | Grafana 仪表板配置 |

### 开发工具

| 文件路径 | 用途 |
|----------|------|
| `devops/Makefile` | 常用命令快捷方式 (开发、测试、部署、备份) |
| `devops/README.md` | DevOps 基础设施说明文档 |

## 🔄 配置使用流程

### 开发环境搭建

```bash
# 1. 复制环境变量
cp devops/deployment/.env.example .env

# 2. 编辑环境变量
vim .env

# 3. 使用 Makefile 启动开发环境
make dev

# 4. 查看日志
make dev-logs
```

### CI/CD 配置

```bash
# GitHub Actions
# 将 ci-cd/*.yml 复制到项目根目录的 .github/workflows/
mkdir -p .github/workflows
cp devops/ci-cd/*.yml .github/workflows/

# GitLab CI
# 将 ci-cd/.gitlab-ci.yml 复制到项目根目录
cp devops/ci-cd/.gitlab-ci.yml .gitlab-ci.yml
```

### 生产部署

```bash
# 1. 服务器初始化
ssh root@your-server
curl -fsSL https://raw.githubusercontent.com/your-org/myanmarestate/main/devops/scripts/init.sh | sudo bash

# 2. 配置环境变量
cp /opt/myanmarestate/devops/deployment/.env.example /opt/myanmarestate/.env
vim /opt/myanmarestate/.env

# 3. 配置 SSL 证书
# 将证书放到 /opt/myanmarestate/nginx/ssl/

# 4. 执行部署
/opt/myanmarestate/devops/scripts/deploy.sh production
```

## 📝 重要配置说明

### 环境变量优先级

1. 系统环境变量 (最高优先级)
2. `.env` 文件中的变量
3. Docker Compose 中的默认变量 (最低优先级)

### 安全配置

- **生产环境必须使用 HTTPS**: 配置 SSL 证书到 `nginx/ssl/`
- **数据库密码**: 使用强密码，长度至少 16 位
- **JWT Secret**: 使用随机生成的字符串，长度至少 32 位
- **API Keys**: 不要提交到代码仓库，使用环境变量

### 监控告警

- **Prometheus**: 访问 http://localhost:9090 (开发) / 内网访问 (生产)
- **Grafana**: 访问 http://localhost:3001，默认账号 admin/admin
- **告警通知**: 配置 Slack Webhook 或邮件服务器

### 备份策略

- **自动备份**: 配置 crontab 运行 `scripts/backup.sh`
- **备份保留**: 默认保留 30 天
- **异地备份**: 自动上传到 S3
- **恢复测试**: 定期测试备份恢复流程

## 🐛 故障排查

### 常见问题

1. **端口冲突**: 修改 `docker-compose.yml` 中的端口映射
2. **内存不足**: 调整 Docker 资源限制或增加服务器内存
3. **数据库连接失败**: 检查 `DATABASE_URL` 和环境变量
4. **SSL 证书错误**: 确保证书文件路径和权限正确

### 日志位置

- **Docker 日志**: `docker-compose logs`
- **Nginx 日志**: `/var/log/nginx/`
- **应用日志**: 容器内 stdout/stderr (使用 `docker-compose logs` 查看)

## 📞 技术支持

如有问题，请联系：
- 邮箱: devops@myanmarestate.com
- Slack: #devops-support
