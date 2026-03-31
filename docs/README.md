# 缅甸房产平台 - 技术文档中心

**项目**: Myanmar Home - Real Estate Platform
**版本**: 1.0
**更新日期**: 2026-03-31

---

## 📋 文档总览

| 分类 | 文档数 | 说明 |
|------|--------|------|
| 架构设计 | 1 | 系统整体架构 |
| 技术细节 | 3 | 数据库、API、服务配置 |
| API文档 | 1 | 认证接口详解 |
| 部署运维 | 2 | 本地开发、环境测试 |
| 开发规范 | 1 | 编码规范 |
| 测试指南 | 1 | 测试流程和方法 |
| 项目状态 | 1 | 当前进度跟踪 |
| **总计** | **10** | - |

---

## 📁 文档目录

### 架构设计 (architecture/)

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [01-system-overview.md](./architecture/01-system-overview.md) | 系统整体架构设计、模块划分、技术选型 | 2026-03 |

### 技术细节 (technical/)

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [database-guide.md](./technical/database-guide.md) | 数据库表结构、索引说明、性能优化、35张表详细说明 | 2026-03-31 |
| [api-dependencies.md](./technical/api-dependencies.md) | API模块清单、服务依赖、权限控制、51个接口说明 | 2026-03-31 |
| [service-mock-guide.md](./technical/service-mock-guide.md) | Mock/真实服务切换指南（SMS/IM/支付/存储） | 2026-03-31 |

### API文档 (api/)

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [01-authentication.md](./api/01-authentication.md) | 认证接口详解（登录/注册/Token刷新） | 2026-03 |

### 部署运维 (deployment/)

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [01-local-development.md](./deployment/01-local-development.md) | 本地开发环境搭建指南 | 2026-03 |
| [02-environment-test-report.md](./deployment/02-environment-test-report.md) | 环境搭建测试报告 | 2026-03 |

### 开发规范 (development/)

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [01-coding-standards.md](./development/01-coding-standards.md) | Go/Flutter编码规范 | 2026-03 |

### 测试指南 (testing/)

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [01-testing-guide.md](./testing/01-testing-guide.md) | 测试策略、测试用例编写规范 | 2026-03 |

### 项目状态

| 文档 | 说明 | 更新时间 |
|------|------|----------|
| [project-status.md](./project-status.md) | 当前进度、完成情况、待办事项 | 2026-03 |

---

## 🔧 核心资源路径

### 代码库

| 资源 | 路径 |
|------|------|
| 后端代码 | `myanmar-real-estate/backend/` |
| Flutter App | `myanmar-real-estate/flutter/` |
| Web Admin | `myanmar-real-estate/frontend/web-admin/` |
| 数据库Schema | `myanmar-real-estate/backend/01-database-schema.sql` |
| API规范 | `myanmar-real-estate/backend/02-api-spec.md` |

### QA测试

| 资源 | 路径 |
|------|------|
| 测试计划 | `myanmar-real-estate/qa/test-plan.md` |
| 测试进展 | `myanmar-real-estate/qa/test-progress.md` |
| 执行计划 | `myanmar-real-estate/qa/execution-plan.md` |
| API测试用例 | `myanmar-real-estate/qa/test-cases/api/api-tests.yml` |
| C端测试用例 | `myanmar-real-estate/qa/test-cases/functional/c-app.yml` |
| B端测试用例 | `myanmar-real-estate/qa/test-cases/functional/b-app.yml` |
| 测试脚本 | `myanmar-real-estate/qa/scripts/` |

---

## 📦 归档文档 (archive/)

以下文档已归档，不再活跃维护，仅供参考：

| 分类 | 内容 |
|------|------|
| backup-20250331/ | 文档备份（2026-03-31创建） |
| business/ | 商务文档（报价清单等） |
| qa/bug-reports/ | 历史Bug报告 |
| qa/code-review/ | 历史代码审查记录 |
| qa/reports/ | 历史测试报告 |

---

## 🚀 快速开始

### 新成员入门

1. 阅读 [项目状态](./project-status.md) 了解当前进度（85-90%完成）
2. 阅读 [系统架构](./architecture/01-system-overview.md) 了解整体设计
3. 阅读 [本地开发指南](./deployment/01-local-development.md) 搭建环境
4. 阅读 [编码规范](./development/01-coding-standards.md) 了解开发规范

### 开发工作流

1. 查看 [API依赖文档](./technical/api-dependencies.md) 了解服务接口
2. 查看 [数据库文档](./technical/database-guide.md) 了解表结构
3. 查看 [Mock切换指南](./technical/service-mock-guide.md) 了解服务配置
4. 参考 [测试指南](./testing/01-testing-guide.md) 编写测试用例

---

## ⚡ 环境要求

- Go 1.21+
- Node.js 18+
- Flutter 3.19+
- Docker Desktop

### 快速启动

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

### 访问服务

| 服务 | 地址 |
|------|------|
| 后端API | http://localhost:8080 |
| 管理后台 | http://localhost:8000 |
| API健康检查 | http://localhost:8080/health |

---

## 📊 项目结构

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

## 🔐 模拟服务配置

本地开发无需真实第三方账号，使用以下模拟方案：

| 服务 | 模拟方案 | 配置 |
|------|----------|------|
| **短信** | Mock模式 | 验证码固定`123456` |
| **存储** | MinIO | http://localhost:9000 |
| **IM** | Mock模式 | 内存存储 |
| **支付** | Mock模式 | 直接返回成功 |

真实服务切换参考 [service-mock-guide.md](./technical/service-mock-guide.md)

---

## 📝 开发工作流

### 分支管理
```
main (生产)
  ↑
develop (开发)
  ↑
feature/xxx (功能分支)
```

### 提交规范
```
feat(user): 添加用户实名认证

- 实现身份证OCR识别
- 添加实名认证状态机
```

---

## ⚠️ 安全提醒

生产环境必须修改：
1. JWT Secret（最小32位随机字符串）
2. 数据库密码（强密码）
3. 使用真实第三方服务账号
4. 启用HTTPS
5. 配置防火墙规则

---

## 📞 联系方式

- 技术团队: tech@myanmar-property.com
- QA团队: qa@myanmar-property.com

---

**维护说明**: 本文档由技术团队维护，持续更新中。
