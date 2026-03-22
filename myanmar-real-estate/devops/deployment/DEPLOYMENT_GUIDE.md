# ============================================
# 缅甸房产平台 - 部署指南
# ============================================

## 目录

1. [服务器环境要求](#服务器环境要求)
2. [部署架构](#部署架构)
3. [部署步骤](#部署步骤)
4. [环境变量配置](#环境变量配置)
5. [监控告警配置](#监控告警配置)
6. [备份策略](#备份策略)
7. [故障处理](#故障处理)

---

## 服务器环境要求

### 生产环境推荐配置

| 组件 | 配置 | 数量 | 备注 |
|------|------|------|------|
| **应用服务器** | 4核8G | 2台 | 运行 Docker 容器 |
| **数据库服务器** | 8核16G | 1台 | PostgreSQL 主库 |
| **缓存服务器** | 2核4G | 1台 | Redis |
| **文件存储** | - | - | AWS S3 / 阿里云 OSS |
| **CDN** | - | - | CloudFront / 阿里云 CDN |

### 软件版本要求

| 软件 | 版本 | 用途 |
|------|------|------|
| Docker | 24.x+ | 容器化运行 |
| Docker Compose | 2.x+ | 容器编排 |
| Nginx | 1.24+ | 反向代理 |
| PostgreSQL | 15.x | 主数据库 |
| Redis | 7.x | 缓存/会话 |

### 网络要求

- **公网访问**: 80, 443 端口开放
- **内网访问**: 3000, 5432, 6379, 9090 端口
- **监控访问**: 3001(Grafana), 9090(Prometheus)

---

## 部署架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                           用户请求                                   │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        CloudFront / CDN                             │
│                    (静态资源缓存 + DDoS 防护)                        │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         Nginx 负载均衡                               │
│                   (SSL 终止 + 反向代理 + 限流)                       │
└─────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
          ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
          │  Backend-1   │ │  Backend-2   │ │  Backend-3   │
          │   (Docker)   │ │   (Docker)   │ │   (Docker)   │
          └──────────────┘ └──────────────┘ └──────────────┘
                    │               │               │
                    └───────────────┼───────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
          ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
          │  PostgreSQL  │ │    Redis     │ │     S3       │
          │    (主从)    │ │   (主从)     │ │  (对象存储)  │
          └──────────────┘ └──────────────┘ └──────────────┘
```

---

## 部署步骤

### 1. 服务器初始化

```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 安装 Docker
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

# 添加当前用户到 docker 组
sudo usermod -aG docker $USER
newgrp docker

# 安装其他工具
sudo apt install -y curl wget git vim htop

# 配置防火墙
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

### 2. 创建应用目录

```bash
sudo mkdir -p /opt/myanmarestate
cd /opt/myanmarestate

# 创建子目录
sudo mkdir -p {docker,nginx/ssl,backups,logs}
sudo chown -R $USER:$USER /opt/myanmarestate
```

### 3. 配置 SSL 证书

```bash
# 使用 Let's Encrypt 免费证书
cd /opt/myanmarestate/nginx/ssl

# 安装 certbot
sudo apt install -y certbot

# 申请证书
sudo certbot certonly --standalone -d api.myanmarestate.com -d www.myanmarestate.com -d admin.myanmarestate.com

# 复制证书到应用目录
sudo cp /etc/letsencrypt/live/api.myanmarestate.com/fullchain.pem ./api.myanmarestate.com.crt
sudo cp /etc/letsencrypt/live/api.myanmarestate.com/privkey.pem ./api.myanmarestate.com.key
sudo chown $USER:$USER *.crt *.key
```

### 4. 配置环境变量

```bash
cd /opt/myanmarestate
cp devops/deployment/.env.example .env

# 编辑环境变量
vim .env
```

### 5. 启动服务

```bash
cd /opt/myanmarestate

# 拉取最新镜像
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull

# 启动服务
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# 查看状态
docker-compose ps
```

### 6. 数据库初始化

```bash
# 进入数据库容器
docker exec -it myanmarestate-postgres psql -U postgres

# 创建数据库
CREATE DATABASE myanmarestate;
CREATE DATABASE myanmarestate_test;

# 退出
\q

# 执行数据库迁移 (在应用容器内)
docker exec -it myanmarestate-backend npm run migration:run
```

### 7. 验证部署

```bash
# 检查服务健康状态
curl https://api.myanmarestate.com/health
curl https://www.myanmarestate.com
curl https://admin.myanmarestate.com

# 查看日志
docker-compose logs -f backend
docker-compose logs -f nginx
```

---

## 环境变量配置

### 必需环境变量

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `DATABASE_URL` | PostgreSQL 连接字符串 | `postgresql://user:pass@host:5432/db` |
| `REDIS_URL` | Redis 连接字符串 | `redis://host:6379` |
| `REDIS_PASSWORD` | Redis 密码 | `your-redis-password` |
| `JWT_SECRET` | JWT 签名密钥 | `your-secret-key-min-32-chars` |
| `JWT_EXPIRES_IN` | JWT 过期时间 | `7d` |

### 文件存储配置

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `S3_ENDPOINT` | S3 服务端点 | `https://s3.ap-southeast-1.amazonaws.com` |
| `S3_BUCKET` | S3 存储桶名 | `myanmarestate-prod` |
| `S3_ACCESS_KEY` | S3 Access Key | `AKIAXXXXXXXXXXXXXXXX` |
| `S3_SECRET_KEY` | S3 Secret Key | `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |

### 短信服务配置

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `SMS_PROVIDER` | 短信服务商 | `twilio` / `aws-sns` |
| `SMS_API_KEY` | API Key | `xxxxxxxxxx` |
| `SMS_API_SECRET` | API Secret | `xxxxxxxxxx` |

### IM 服务配置

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `IM_APP_KEY` | IM 应用 Key | `xxxxxxxxxx` |
| `IM_APP_SECRET` | IM 应用 Secret | `xxxxxxxxxx` |

### 监控配置

| 变量名 | 说明 | 示例 |
|--------|------|------|
| `GRAFANA_ADMIN_PASSWORD` | Grafana 管理员密码 | `secure-password` |
| `GRAFANA_ROOT_URL` | Grafana 根 URL | `https://monitor.myanmarestate.com` |

---

## 监控告警配置

### 1. Prometheus 配置

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'backend'
    static_configs:
      - targets: ['backend:3000']
    metrics_path: /metrics

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
```

### 2. 告警规则

```yaml
# alert_rules.yml
groups:
  - name: backend
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ $value }}s"

  - name: system
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High CPU usage"
          description: "CPU usage is {{ $value }}%"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value }}%"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Low disk space"
          description: "Disk space is {{ $value }}%"
```

### 3. Alertmanager 配置

```yaml
# alertmanager.yml
global:
  slack_api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'

route:
  receiver: 'slack-notifications'
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - channel: '#alerts'
        title: ' MyanmarEstate Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}\n{{ .Annotations.description }}\n{{ end }}'

  - name: 'email-notifications'
    email_configs:
      - to: 'devops@myanmarestate.com'
        from: 'alerts@myanmarestate.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'alerts@myanmarestate.com'
        auth_password: 'your-email-password'
```

---

## 备份策略

### 数据库备份

```bash
#!/bin/bash
# backup.sh - 数据库备份脚本

BACKUP_DIR="/opt/myanmarestate/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="myanmarestate"

docker exec myanmarestate-postgres pg_dump -U postgres $DB_NAME | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# 保留最近30天的备份
find $BACKUP_DIR -name "db_*.sql.gz" -mtime +30 -delete

# 上传到 S3
aws s3 cp $BACKUP_DIR/db_$DATE.sql.gz s3://myanmarestate-backups/database/
```

### 定时任务

```bash
# 添加 crontab 任务
crontab -e

# 每天凌晨 2 点执行备份
0 2 * * * /opt/myanmarestate/scripts/backup.sh >> /var/log/backup.log 2>&1
```

---

## 故障处理

### 常见问题

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 服务无法启动 | 端口占用 | `sudo lsof -i :3000` 查看占用进程 |
| 数据库连接失败 | 网络/认证问题 | 检查 `DATABASE_URL` 和环境变量 |
| 内存不足 | 内存泄漏/配置过高 | 调整 Docker 资源限制 |
| SSL 证书过期 | 证书续期失败 | 运行 `certbot renew` |
| 502 Bad Gateway | 后端服务异常 | 检查后端日志和容器状态 |

### 重启服务

```bash
# 重启单个服务
docker-compose restart backend

# 重启所有服务
docker-compose restart

# 强制重新创建容器
docker-compose up -d --force-recreate backend
```

### 查看日志

```bash
# 实时查看日志
docker-compose logs -f backend

# 查看最近 100 行
docker-compose logs --tail 100 backend

# 查看特定时间段的日志
docker-compose logs --since "2024-01-01T00:00:00" backend
```

### 回滚部署

```bash
# 查看可用镜像
docker images | grep myanmarestate

# 回滚到指定版本
docker-compose -f docker-compose.yml -f docker-compose.prod.yml pull
docker tag myanmarestate/backend:previous-tag myanmarestate/backend:latest
docker-compose up -d backend
```
