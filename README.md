# 缅甸房产平台

**Myanmar Real Estate Platform**

[![Version](https://img.shields.io/badge/version-v1.0--beta-blue.svg)]()
[![Status](https://img.shields.io/badge/status-阶段性目标达成-green.svg)]()
[![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue.svg)]()
[![Go](https://img.shields.io/badge/Go-1.21+-cyan.svg)]()

---

## 项目简介

缅甸房产平台是一个完整的房产交易解决方案，包含C端购房应用、B端经纪人工作平台、Web管理后台和Go微服务后端。

### 核心功能
- 🔐 用户认证（手机验证码登录）
- 🏠 房源浏览、搜索、推荐
- 🗺️ 地图找房
- 📅 预约带看
- 💬 IM消息（预留接口）
- 💰 ACN分佣系统

---

## 快速开始

### 方式一：一键启动（推荐）

```bash
# Windows
double click: start_pc_test.bat
```

### 方式二：手动启动

```bash
# 1. 启动后端
cd myanmar-real-estate/backend
./server.exe

# 2. 启动C端
cd myanmar-real-estate/flutter
flutter run -d chrome -t lib/main_buyer.dart --web-port=8081

# 3. 启动B端
cd myanmar-real-estate/flutter
flutter run -d chrome -t lib/main_agent.dart --web-port=8082
```

---

## 访问地址

| 服务 | URL | 说明 |
|------|-----|------|
| C端APP | http://localhost:8081 | 购房者客户端 |
| B端APP | http://localhost:8082 | 经纪人工作端 |
| 后端API | http://localhost:8080 | API服务 |
| Web Admin | http://localhost:8000 | 管理后台 |

### 测试账号
- **C端**: `+95111111111`
- **B端**: `+95333333333`

---

## 项目文档

| 文档 | 说明 |
|------|------|
| [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) | 项目总结报告 |
| [PROJECT_ARCHIVE.md](PROJECT_ARCHIVE.md) | 项目归档说明 |
| [APP_VERIFICATION_GUIDE.md](APP_VERIFICATION_GUIDE.md) | APP验证指南 |
| [PC_TESTING_GUIDE.md](PC_TESTING_GUIDE.md) | PC端测试指南 |
| [QUICK_START.md](QUICK_START.md) | 快速开始指南 |
| [INTEGRATION_STATUS.md](INTEGRATION_STATUS.md) | 联调状态报告 |
| [CLAUDE.md](CLAUDE.md) | 项目开发指南 |

---

## 技术栈

### 移动端
- **Flutter** 3.19+ / Dart 3.0+
- **Riverpod** 状态管理
- **Dio** HTTP客户端
- **GoRouter** 路由管理

### 后端
- **Go** 1.21+
- **Gin** Web框架
- **GORM** ORM框架
- **JWT** 认证

### 数据库
- **PostgreSQL** 15
- **Redis** 7
- **Elasticsearch** 8

### Web Admin
- **React** 18
- **TypeScript**
- **UmiJS** 4
- **Ant Design** 5

---

## 项目结构

```
myanmar-real-estate-kimi/
├── myanmar-real-estate/
│   ├── backend/          # Go后端服务
│   ├── flutter/          # Flutter移动端
│   └── frontend/         # 前端应用
│       └── web-admin/    # React管理后台
├── docs/                 # 项目文档
├── *.md                  # 根目录文档
└── *.bat/*.ps1           # 启动脚本
```

---

## 已完成工作

### ✅ 后端API
- [x] 用户服务（注册/登录/认证）
- [x] 房源服务（推荐/搜索/地图）
- [x] ACN分佣服务
- [x] 预约服务
- [x] 验真服务

### ✅ 移动端
- [x] C端登录/首页/房源
- [x] B端登录/工作台
- [x] 地图找房
- [x] 搜索筛选

### ✅ 基础设施
- [x] Docker Compose
- [x] 数据库Schema
- [x] API文档

---

## 待办事项

- [ ] 房源数据导入
- [ ] IM消息集成
- [ ] 支付功能
- [ ] 地图API
- [ ] 推送通知
- [ ] 单元测试
- [ ] CI/CD

---

## 贡献指南

1. Fork 项目
2. 创建分支 (`git checkout -b feature/xxx`)
3. 提交更改 (`git commit -m 'feat: add xxx'`)
4. 推送分支 (`git push origin feature/xxx`)
5. 创建Pull Request

### 提交规范
```
feat: 新功能
fix: 修复
docs: 文档
style: 格式
test: 测试
refactor: 重构
```

---

## 许可证

[MIT License](LICENSE)

---

## 联系方式

- 项目主页：https://github.com/your-org/myanmar-real-estate
- 问题反馈：https://github.com/your-org/myanmar-real-estate/issues

---

**项目状态**: 阶段性目标达成 ✅

**最后更新**: 2026-03-19
