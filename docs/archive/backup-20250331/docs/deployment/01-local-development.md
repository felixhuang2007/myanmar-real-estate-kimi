# 本地开发环境搭建指南

**适用场景**: 无外部服务账号，完全本地独立运行

---

## 1. 环境要求

### 1.1 基础工具
| 工具 | 版本 | 下载地址 |
|------|------|----------|
| Go | 1.21+ | https://golang.org/dl/ |
| Node.js | 18+ | https://nodejs.org/ |
| Flutter | 3.19+ | https://flutter.dev/docs/get-started/install |
| Docker Desktop | 最新 | https://www.docker.com/products/docker-desktop |
| Git | 2.x | https://git-scm.com/ |

### 1.2 验证安装
```bash
# Go
go version
# 输出: go version go1.21.x windows/amd64

# Node.js
node --version
# 输出: v18.x.x

# Flutter
flutter --version
# 输出: Flutter 3.19.x

# Docker
docker --version
# 输出: Docker version 24.x.x
```

---

## 2. 快速启动（推荐）

### 2.1 一键启动脚本
```bash
# 进入项目目录
cd myanmar-real-estate

# 运行启动脚本
./start-all.sh
```

### 2.2 手动分步启动

#### 步骤1: 启动基础设施（Docker）
```bash
cd backend

# 启动 PostgreSQL + Redis + Elasticsearch
docker-compose up -d

# 验证服务状态
docker-compose ps

# 查看日志
docker-compose logs -f postgres
```

#### 步骤2: 配置环境变量
```bash
cd backend

# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入以下配置
```

**.env 文件内容（本地开发版）**:
```bash
# 应用环境
export MYANMAR_PROPERTY_ENVIRONMENT=development
export MYANMAR_PROPERTY_DEBUG=true

# 服务器配置
export MYANMAR_PROPERTY_SERVER_HOST=0.0.0.0
export MYANMAR_PROPERTY_SERVER_PORT=8080

# 数据库配置（Docker默认）
export MYANMAR_PROPERTY_DATABASE_HOST=localhost
export MYANMAR_PROPERTY_DATABASE_PORT=5432
export MYANMAR_PROPERTY_DATABASE_USER=myanmar_property
export MYANMAR_PROPERTY_DATABASE_PASSWORD=myanmar_property_2024
export MYANMAR_PROPERTY_DATABASE_DATABASE=myanmarhome

# Redis配置（Docker默认）
export MYANMAR_PROPERTY_REDIS_HOST=localhost
export MYANMAR_PROPERTY_REDIS_PORT=6379
export MYANMAR_PROPERTY_REDIS_PASSWORD=

# JWT配置（本地开发用固定值）
export MYANMAR_PROPERTY_JWT_SECRET=dev_jwt_secret_key_change_in_production_32chars

# 短信服务（本地Mock模式）
export MYANMAR_PROPERTY_SMS_PROVIDER=mock
export MYANMAR_PROPERTY_SMS_ACCESS_KEY=mock_key
export MYANMAR_PROPERTY_SMS_SECRET_KEY=mock_secret

# 存储服务（本地MinIO）
export MYANMAR_PROPERTY_STORAGE_TYPE=minio
export MYANMAR_PROPERTY_STORAGE_ENDPOINT=http://localhost:9000
export MYANMAR_PROPERTY_STORAGE_ACCESS_KEY=minioadmin
export MYANMAR_PROPERTY_STORAGE_SECRET_KEY=minioadmin
export MYANMAR_PROPERTY_STORAGE_BUCKET=myanmar-property
export MYANMAR_PROPERTY_STORAGE_REGION=ap-southeast-1

# IM服务（本地Mock）
export MYANMAR_PROPERTY_IM_PROVIDER=mock
```

#### 步骤3: 初始化数据库
```bash
# 进入backend目录
cd backend

# 安装migrate工具
go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

# 执行数据库迁移（如果有迁移脚本）
migrate -path ./migrations -database "postgresql://myanmar_property:myanmar_property_2024@localhost:5432/myanmarhome?sslmode=disable" up

# 或者直接执行schema文件
psql -h localhost -U myanmar_property -d myanmarhome -f 01-database-schema.sql
```

#### 步骤4: 启动后端服务
```bash
cd backend

# 加载环境变量
source .env

# 编译并运行
go build -o server.exe cmd/server/main.go
./server.exe

# 服务启动后访问
# Health Check: http://localhost:8080/health
```

#### 步骤5: 启动Web Admin
```bash
cd frontend/web-admin

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问: http://localhost:8000
```

---

## 3. 模拟服务配置

### 3.1 短信服务 Mock
**配置**:
```yaml
# config.yaml
sms:
  provider: mock  # 改为mock模式
```

**实现**:
- 验证码固定为 `123456`
- 日志输出短信内容
- 不实际发送短信

### 3.2 文件存储 MinIO
**启动 MinIO**:
```bash
# 使用Docker启动MinIO
docker run -d \
  --name minio \
  -p 9000:9000 \
  -p 9001:9001 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  minio/minio server /data --console-address ":9001"

# 访问控制台: http://localhost:9001
# 用户名: minioadmin
# 密码: minioadmin
```

**创建Bucket**:
```bash
# 使用mc客户端
mc alias set local http://localhost:9000 minioadmin minioadmin
mc mb local/myanmar-property
mc policy set public local/myanmar-property
```

### 3.3 IM服务 Mock
**配置**:
```yaml
# config.yaml
im:
  provider: mock
```

**实现**:
- 消息存储在内存中
- 支持单用户消息查询
- 24小时数据清理

---

## 4. 服务端口说明

| 服务 | 端口 | 用途 | 访问地址 |
|------|------|------|----------|
| Backend API | 8080 | 后端API | http://localhost:8080 |
| Web Admin | 8000 | 管理后台 | http://localhost:8000 |
| PostgreSQL | 5432 | 数据库 | localhost:5432 |
| Redis | 6379 | 缓存 | localhost:6379 |
| Elasticsearch | 9200 | 搜索引擎 | http://localhost:9200 |
| MinIO API | 9000 | 对象存储 | http://localhost:9000 |
| MinIO Console | 9001 | 存储控制台 | http://localhost:9001 |

---

## 5. 常见问题

### 5.1 数据库连接失败
**症状**: `dial tcp 127.0.0.1:5432: connectex: No connection could be made`

**解决**:
```bash
# 检查Docker容器状态
docker-compose ps

# 如果未运行，启动它
docker-compose up -d postgres

# 检查日志
docker-compose logs postgres
```

### 5.2 端口被占用
**症状**: `bind: address already in use`

**解决**:
```bash
# 查找占用端口的进程
netstat -ano | findstr :8080

# 结束进程（Windows）
taskkill /PID <PID> /F
```

### 5.3 环境变量未生效
**症状**: 配置未按预期加载

**解决**:
```bash
# Windows PowerShell
$env:MYANMAR_PROPERTY_DATABASE_PASSWORD="myanmar_property_2024"

# Windows CMD
set MYANMAR_PROPERTY_DATABASE_PASSWORD=myanmar_property_2024

# Git Bash
export MYANMAR_PROPERTY_DATABASE_PASSWORD=myanmar_property_2024
```

---

## 6. 开发模式 vs 生产模式

### 6.1 开发模式特性
- 数据库演示模式（可选）
- 详细错误信息
- Mock第三方服务
- 热重载支持

### 6.2 生产模式要求
- 必须使用真实数据库
- 第三方服务真实账号
- SSL/TLS加密
- 日志脱敏
- 监控告警

---

## 7. 验证环境

### 7.1 API健康检查
```bash
curl http://localhost:8080/health

# 期望响应
{
  "code": 200,
  "message": "success",
  "data": {
    "status": "ok",
    "time": 1773798324
  }
}
```

### 7.2 数据库连接检查
```bash
# PostgreSQL
psql -h localhost -U myanmar_property -d myanmarhome -c "SELECT version();"

# Redis
redis-cli ping
# 期望响应: PONG
```

### 7.3 前端访问
打开浏览器访问:
- 管理后台: http://localhost:8000
- API文档: http://localhost:8080/swagger/index.html (如果有)

---

## 8. 停止服务

### 8.1 停止后端服务
```bash
# 在运行后端的终端按 Ctrl+C
# 或者在新的终端执行
taskkill /F /IM server.exe
```

### 8.2 停止Docker服务
```bash
cd backend
docker-compose down

# 停止并删除数据卷（清理数据）
docker-compose down -v
```

### 8.3 停止MinIO
```bash
docker stop minio
docker rm minio
```

---

## 9. 下一步

环境搭建完成后，请参考:
- `../development/DEVELOPMENT_GUIDE.md` - 开发规范
- `../testing/TESTING_GUIDE.md` - 测试指南
- `../api/API_REFERENCE.md` - API接口文档
