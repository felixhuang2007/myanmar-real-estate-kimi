---
name: myanmar-deploy-sg
description: Use when deploying Myanmar Real Estate Platform to Tencent Cloud Singapore (or similar cloud VPS) with Docker Compose, HTTP-only configuration, and automated testing
---

# Myanmar Real Estate Platform - 腾讯云新加坡部署

## 概述

本项目 Skill 记录缅甸房产平台在腾讯云新加坡站点的完整部署流程，包括：
- Docker Compose 多服务编排
- HTTP-only 模式（无 SSL，适合 IP 直接访问）
- Web Admin 前端容器化
- 自动化测试套件

## 部署架构

```
Internet :80 → Nginx → ├── /          → web-admin (React SPA)
                         ├── /api/      → api:8080 (Go)
                         ├── /v1/       → api:8080
                         └── /uploads/  → Docker volume

Internal Network (myanmar_net):
  - postgres:5432
  - redis:6379
  - elasticsearch:9200
  - api:8080
  - web-admin:80
```

## 关键文件清单

| 文件 | 用途 |
|------|------|
| `backend/docker-compose.prod.yml` | 生产环境编排 |
| `backend/nginx/nginx.conf` | HTTP-only Nginx 配置 |
| `frontend/web-admin/Dockerfile` | 前端多阶段构建 |
| `frontend/web-admin/nginx-spa.conf` | SPA 路由配置 |
| `backend/.env.prod.example` | 环境变量模板 |
| `devops/scripts/deploy-sg.sh` | 一键部署脚本 |
| `devops/scripts/auto-test.sh` | 自动化测试 |

## 环境变量命名规范

Go Viper 配置读取的是带 `MYANMAR_PROPERTY_` 前缀的变量名：

```bash
# 正确（docker-compose.prod.yml 中使用）
MYANMAR_PROPERTY_DATABASE_HOST=postgres
MYANMAR_PROPERTY_DATABASE_PASSWORD=${DB_PASSWORD}
MYANMAR_PROPERTY_REDIS_HOST=redis
MYANMAR_PROPERTY_REDIS_PASSWORD=${REDIS_PASSWORD}
MYANMAR_PROPERTY_ELASTICSEARCH_HOSTS=http://elasticsearch:9200
JWT_SECRET=${JWT_SECRET}  # 无前缀，直接读取
```

## 快速部署步骤

### 1. 服务器初始化（仅一次）

```bash
ssh ubuntu@43.163.122.42
curl -O https://raw.githubusercontent.com/.../init-sg.sh
bash init-sg.sh
```

### 2. 克隆代码并配置

```bash
git clone <repo> /opt/myanmarestate/myanmar-real-estate-kimi
cd /opt/myanmarestate/.../backend
cp .env.prod.example .env.prod
# 编辑 .env.prod 填入真实密码
```

### 3. 执行部署

```bash
bash devops/scripts/deploy-sg.sh
```

### 4. 运行测试

```bash
bash devops/scripts/run-all-tests.sh --smoke  # 5分钟
bash devops/scripts/run-all-tests.sh --full   # 完整测试
```

## 常见问题

### 登录 500 错误

通常是 `sms_verification_codes` 表未创建：

```bash
sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -c "
CREATE TABLE IF NOT EXISTS sms_verification_codes (
    id BIGSERIAL PRIMARY KEY,
    phone VARCHAR(20) NOT NULL,
    code VARCHAR(10) NOT NULL,
    type VARCHAR(20) NOT NULL,
    expired_at TIMESTAMP WITH TIME ZONE NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE,
    attempt_count INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_sms_codes_phone ON sms_verification_codes(phone, type);
"
```

### 缅甸手机号格式

必须使用 `+95` 前缀：`+959701234567`（正则：`^\+95[0-9]{8,10}$`）

### Web Admin 404

检查 nginx-spa.conf 中的 `try_files` 配置是否正确。

## 服务器信息

- **IP**: 43.163.122.42
- **配置**: 2C4G 腾讯云 CVM 新加坡
- **访问**: http://43.163.122.42

## 注意事项

1. `.env.prod` 包含真实密码，**绝不提交 Git**
2. 当前为 HTTP-only 模式，微信小程序发布需要 HTTPS 域名
3. Elasticsearch 内存固定 512m，适合 4C8G 以下服务器
4. 上传文件存储在 Docker volume，需定期备份
