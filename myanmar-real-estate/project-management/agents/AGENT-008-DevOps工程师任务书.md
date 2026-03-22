# AGENT-008 任务书 - DevOps工程师

> **角色**: DevOps工程师  
> **代号**: AGENT-008  
> **项目**: 缅甸房产平台  
> **周期**: 8周  
> **汇报对象**: AI项目经理

---

## 一、角色职责

1. **CI/CD流水线**: 搭建持续集成/持续部署流水线
2. **环境管理**: 搭建和管理开发、测试、生产环境
3. **容器化**: 实现应用容器化部署
4. **监控告警**: 搭建监控告警系统
5. **自动化部署**: 实现一键部署和回滚
6. **文档编写**: 编写部署文档和运维手册

---

## 二、任务清单

### Week 1: 环境规划与CI/CD搭建

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-001 | 环境规划方案 | 环境规划文档 | Day 2 | P0 |
| O008-002 | 服务器资源申请 | 服务器清单 | Day 3 | P0 |
| O008-003 | Git仓库初始化 | 代码仓库 | Day 3 | P0 |
| O008-004 | CI/CD工具选型 | 选型报告 | Day 4 | P0 |
| O008-005 | CI流水线搭建 | CI配置 | Day 5 | P0 |
| O008-006 | 代码质量检查配置 | Lint配置 | Day 5 | P0 |

### Week 2: 容器化与开发环境

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-007 | Docker基础镜像制作 | Dockerfile | Day 7 | P0 |
| O008-008 | 后端服务Docker化 | Docker配置 | Day 8 | P0 |
| O008-009 | 前端应用Docker化 | Docker配置 | Day 9 | P0 |
| O008-010 | Docker Compose开发环境 | docker-compose.yml | Day 10 | P0 |
| O008-011 | 开发环境部署 | 开发环境 | Day 11 | P0 |
| O008-012 | 开发环境文档 | 开发文档 | Day 12 | P0 |

### Week 3: 测试环境

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-013 | 测试环境规划 | 测试环境方案 | Day 14 | P0 |
| O008-014 | 测试环境部署 | 测试环境 | Day 16 | P0 |
| O008-015 | 数据库部署 | PostgreSQL部署 | Day 17 | P0 |
| O008-016 | Redis部署 | Redis部署 | Day 18 | P0 |
| O008-017 | Nginx反向代理配置 | Nginx配置 | Day 19 | P0 |
| O008-018 | SSL证书配置 | HTTPS配置 | Day 19 | P0 |
| O008-019 | 测试环境文档 | 测试文档 | Day 20 | P0 |

### Week 4: 生产环境规划

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-020 | 生产环境架构设计 | 生产架构图 | Day 22 | P0 |
| O008-021 | 高可用方案设计 | HA方案文档 | Day 24 | P0 |
| O008-022 | 数据库主从方案 | 数据库架构 | Day 25 | P0 |
| O008-023 | 负载均衡方案 | LB架构 | Day 26 | P0 |
| O008-024 | 备份策略制定 | 备份方案 | Day 27 | P0 |

### Week 5: 监控与日志

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-025 | 监控系统选型 | 监控选型报告 | Day 29 | P0 |
| O008-026 | Prometheus部署 | 监控部署 | Day 31 | P0 |
| O008-027 | Grafana看板配置 | 监控看板 | Day 33 | P0 |
| O008-028 | 应用指标接入 | 指标采集 | Day 34 | P0 |
| O008-029 | 告警规则配置 | 告警配置 | Day 35 | P0 |
| O008-030 | 日志收集方案(ELK/Loki) | 日志方案 | Day 36 | P0 |

### Week 6: 自动化部署

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-031 | CD流水线完善 | CD配置 | Day 38 | P0 |
| O008-032 | 自动化部署脚本 | 部署脚本 | Day 40 | P0 |
| O008-033 | 蓝绿部署方案 | 部署方案 | Day 42 | P0 |
| O008-034 | 自动化回滚脚本 | 回滚脚本 | Day 43 | P0 |
| O008-035 | 数据库迁移脚本集成 | 迁移集成 | Day 44 | P0 |
| O008-036 | 配置中心方案 | 配置管理 | Day 45 | P0 |

### Week 7: 生产环境部署

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-037 | 生产环境搭建 | 生产环境 | Day 47 | P0 |
| O008-038 | 数据库集群部署 | 数据库集群 | Day 49 | P0 |
| O008-039 | 应用服务部署 | 应用部署 | Day 51 | P0 |
| O008-040 | 负载均衡部署 | LB部署 | Day 52 | P0 |
| O008-041 | CDN配置 | CDN配置 | Day 53 | P0 |
| O008-042 | 域名解析配置 | DNS配置 | Day 54 | P0 |
| O008-043 | 安全组/防火墙配置 | 安全配置 | Day 55 | P0 |

### Week 8: 验收与交付

| 任务ID | 任务描述 | 交付物 | 截止时间 | 优先级 |
|--------|----------|--------|----------|--------|
| O008-044 | 部署验证测试 | 验证报告 | Day 56 | P0 |
| O008-045 | 压力测试配合 | 配合测试 | Day 57 | P0 |
| O008-046 | 部署文档编写 | 部署文档 | Day 58 | P0 |
| O008-047 | 运维手册编写 | 运维手册 | Day 59 | P0 |
| O008-048 | 灾难恢复手册 | DR手册 | Day 59 | P0 |
| O008-049 | 项目交付 | 最终交付 | Day 60 | P0 |

---

## 三、环境规划

### 3.1 环境架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        生产环境架构                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│     ┌──────────┐                                                │
│     │   CDN    │                                                │
│     └────┬─────┘                                                │
│          │                                                      │
│     ┌────▼─────┐                                                │
│     │  Nginx   │  ← 负载均衡 (2台)                              │
│     │   LB     │                                                │
│     └────┬─────┘                                                │
│          │                                                      │
│    ┌─────┴─────┐                                                │
│    │           │                                                │
│ ┌──▼──┐    ┌──▼──┐                                             │
│ │ APP │    │ APP │  ← 应用服务 (3+台)                          │
│ │ SVC │    │ SVC │                                             │
│ └──┬──┘    └──┬──┘                                             │
│    │           │                                                │
│    └─────┬─────┘                                                │
│          │                                                      │
│     ┌────▼────┐      ┌────────┐                                │
│     │   PgSQL │←────→│ Replica│  ← 数据库主从                   │
│     │ Primary │      │        │                                │
│     └────┬────┘      └────────┘                                │
│          │                                                      │
│     ┌────▼────┐      ┌────────┐                                │
│     │  Redis  │      │  Redis │  ← Redis主从                   │
│     │ Primary │      │ Replica│                                │
│     └─────────┘      └────────┘                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 服务器规划

| 环境 | 配置 | 数量 | 用途 |
|------|------|------|------|
| 开发环境 | 4C8G | 1 | 开发联调 |
| 测试环境 | 4C8G | 2 | 功能测试 |
| 生产环境 | 8C16G | 5+ | 应用服务 |
| 数据库 | 8C32G | 2 | 主从集群 |
| 缓存 | 4C8G | 2 | Redis主从 |

---

## 四、CI/CD流水线

### 4.1 CI流程

```yaml
# CI Pipeline
stages:
  - lint
  - test
  - build
  - security

lint:
  stage: lint
  script:
    - golangci-lint run    # Go代码检查
    - flutter analyze      # Flutter代码检查
    - eslint .             # Vue代码检查

test:
  stage: test
  script:
    - go test ./...        # Go单元测试
    - flutter test         # Flutter测试
  coverage: '/coverage: \d+\.\d+%/'

build:
  stage: build
  script:
    - docker build -t $IMAGE_NAME:$CI_COMMIT_SHA .
    - docker push $IMAGE_NAME:$CI_COMMIT_SHA
  only:
    - main
    - develop

security:
  stage: security
  script:
    - trivy image $IMAGE_NAME:$CI_COMMIT_SHA
```

### 4.2 CD流程

```yaml
# CD Pipeline
stages:
  - deploy-staging
  - test-staging
  - deploy-production
  - verify-production

deploy-staging:
  stage: deploy-staging
  script:
    - kubectl set image deployment/app app=$IMAGE_NAME:$CI_COMMIT_SHA -n staging
  environment:
    name: staging

test-staging:
  stage: test-staging
  script:
    - run smoke tests
  
deploy-production:
  stage: deploy-production
  script:
    - kubectl set image deployment/app app=$IMAGE_NAME:$CI_COMMIT_SHA -n production
  environment:
    name: production
  when: manual
```

---

## 五、Docker配置示例

### 5.1 后端服务Dockerfile

```dockerfile
# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server

# Runtime stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates
WORKDIR /root/

COPY --from=builder /app/server .
COPY --from=builder /app/configs ./configs

EXPOSE 8080

CMD ["./server"]
```

### 5.2 Docker Compose开发环境

```yaml
version: '3.8'

services:
  app:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      - DB_HOST=postgres
      - REDIS_HOST=redis
    depends_on:
      - postgres
      - redis
    volumes:
      - ./backend:/app
    
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: myanmar
      POSTGRES_PASSWORD: password
      POSTGRES_DB: property
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./migrations:/docker-entrypoint-initdb.d
      
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
      
  web:
    build: ./web
    ports:
      - "3000:80"
    depends_on:
      - app

volumes:
  postgres_data:
```

---

## 六、监控告警

### 6.1 监控指标

| 类别 | 指标 | 告警阈值 |
|------|------|----------|
| 系统 | CPU使用率 | > 80% |
| 系统 | 内存使用率 | > 85% |
| 系统 | 磁盘使用率 | > 85% |
| 应用 | API错误率 | > 1% |
| 应用 | API响应时间(P95) | > 500ms |
| 应用 | QPS | 根据容量 |
| 数据库 | 连接数 | > 80% |
| 数据库 | 慢查询数 | > 10/min |

### 6.2 告警配置

```yaml
groups:
  - name: app-alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.01
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.5
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
```

---

## 七、验收标准

### 7.1 交付物

- [ ] CI/CD流水线配置
- [ ] Docker配置文件
- [ ] K8s部署文件(如有)
- [ ] 监控告警配置
- [ ] 部署文档
- [ ] 运维手册
- [ ] 灾难恢复手册

### 7.2 环境验收

- [ ] 开发环境可正常使用
- [ ] 测试环境可正常使用
- [ ] 生产环境部署完成
- [ ] CI/CD流水线正常运行
- [ ] 监控告警正常工作
- [ ] 日志收集正常工作

### 7.3 部署验收

- [ ] 一键部署成功
- [ ] 一键回滚成功
- [ ] 蓝绿部署可用
- [ ] 零停机部署

---

## 八、依赖与协作

### 8.1 我依赖谁

| 依赖 | 内容 | 时间 |
|------|------|------|
| AGENT-001 | 架构设计 | Week 1 |
| AGENT-002 | 后端代码 | Week 2+ |
| AGENT-005 | 前端代码 | Week 2+ |

### 8.2 谁依赖我

| 依赖方 | 内容 | 时间 |
|--------|------|------|
| 全体开发 | 开发环境 | Week 2 |
| AGENT-007 | 测试环境 | Week 3 |
| PM | 生产部署 | Week 8 |

---

*任务书创建: 2026-03-17*  
*版本: v1.0*
