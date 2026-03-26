---
name: myanmar-real-estate-platform
description: 缅甸房产平台项目知识库 - 技术架构、入口点导航、变更日志
trigger:
  - 缅甸房产
  - myanmar real estate
  - 买家APP
  - 经纪人APP
  - C端
  - B端
  - ACN分佣
  - 项目状态
---

## 项目速览

| 属性 | 内容 |
|------|------|
| 项目名称 | 缅甸房产平台 (Myanmar Real Estate) |
| 当前阶段 | MVP 完成 / 准备上线 |
| 最后更新 | 2026-03-22 |
| 代码规模 | ~41,000+ 行 |

**阻塞项清单：**
- [ ] 支付渠道集成（缅甸本地）
- [ ] IM 服务接入（环信/融云）
- [ ] 生产环境部署

---

## 核心架构导航

```
myanmar-real-estate/
├── flutter/                    # Flutter APP（主力）
│   ├── lib/main_buyer.dart     # C端入口
│   ├── lib/main_agent.dart     # B端入口
│   ├── buyer/presentation/     # C端页面（13个）
│   ├── agent/presentation/     # B端页面（10个）
│   └── core/                   # 核心层
│
├── backend/                    # Go 微服务
│   ├── cmd/server/main.go      # 服务入口
│   ├── 03-user-service/        # 用户服务
│   ├── 04-house-service/       # 房源服务
│   ├── 05-acn-service/         # ACN分佣（核心难点）
│   ├── 06-appointment-service/ # 预约服务
│   └── 09-verification-service/# 验真服务
│
├── frontend/
│   ├── web-admin/              # React 管理后台
│   └── mini-program/           # 微信小程序
│
└── qa/test-cases/              # 195个测试用例
```

---

## 关键技术约定

| 层级 | 技术栈 | 核心文件模式 |
|------|--------|--------------|
| 移动端 | Flutter 3.19 + Riverpod | `*/presentation/pages/*.dart` |
| 后端 | Go + Gin + GORM | `model.go` → `repository.go` → `service.go` → `controller.go` |
| Web后台 | React + UmiJS 4 | `src/pages/**/index.tsx` |

**ACN 佣金模型（核心业务）：**
- 录入人 35% | 带看人 65% | 平台 10%
- 关键文件：`05-acn-service/service.go`

---

## 本机测试准备流程

当用户提出**本机测试**需求时，必须主动完成以下三步，无需用户逐项要求：

### 第一步：服务启动与验证

```bash
# 1. 检查 Docker 服务（后端依赖）
docker ps | grep myanmar-property
# 预期：postgres / redis / elasticsearch / api 均为 healthy

# 2. 检查 API 健康
curl http://localhost:8080/health

# 3. 检查 Web Admin dev server
curl -s -o /dev/null -w "%{http_code}" http://localhost:8005
# 如未运行，执行：
cd myanmar-real-estate/frontend/web-admin && npx umi dev
```

如任何服务未启动，**先修复再继续**，不要把未就绪的地址告知用户。

### 第二步：测试数据验证

登录前确认数据库中存在可用账号及验证码：

```sql
-- 验证账号存在
SELECT phone, user_type, CASE WHEN password_hash IS NOT NULL THEN '已设置' ELSE '未设置' END AS pwd
FROM users WHERE phone IN ('+95333333333','+95444444444','+95222222222');

-- 为 Web Admin 补充一次性验证码（每次测试前执行，code 用完即失效）
INSERT INTO sms_verification_codes (phone, code, type, expired_at) VALUES
('+95333333333','888888','login', NOW() + INTERVAL '24 hour'),
('+95444444444','888888','login', NOW() + INTERVAL '24 hour'),
('+95222222222','888888','login', NOW() + INTERVAL '24 hour');
```

如需重置密码（bcrypt hash of `Test@1234`）：
```sql
UPDATE users SET password_hash='$2a$10$VUJFvzsmC9O10GK2N4.LhO.Ii6UW2aMF//wqwkzrlkG/5nnq0owQe'
WHERE phone IN ('+95333333333','+95444444444','+95222222222','+95111111111');
```

### 第三步：向用户提供测试信息

按以下格式输出，覆盖三个模块：

**服务地址**

| 模块 | 地址 | 启动方式 |
|------|------|----------|
| Web Admin（管理后台） | http://localhost:8005 | `npx umi dev`（web-admin 目录） |
| C端 APP（买家） | http://localhost:7001 | `flutter run -t lib/main_buyer.dart -d chrome --web-port=7001` |
| B端 APP（经纪人） | http://localhost:7002 | `flutter run -t lib/main_agent.dart -d chrome --web-port=7002` |
| 后端 API | http://localhost:8080 | `docker-compose up -d`（backend 目录） |

所有地址需实时验证是否在监听；如未启动按上述命令启动，先修复再告知用户。

**测试账号**

| 手机号 | 角色 | 适用模块 | 密码登录 | 验证码 |
|--------|------|----------|----------|--------|
| `+95333333333` | 经纪人（李经纪人，active） | B端APP / Web Admin | `Test@1234` | `888888`（一次性） |
| `+95444444444` | 经纪人（王经纪人，active） | B端APP / Web Admin | `Test@1234` | `888888`（一次性） |
| `+95222222222` | 买家（普通用户） | C端APP | `Test@1234` | `888888`（一次性） |
| `+95111111111` | 经纪人（QA Agent，pending） | B端APP | `Test@1234` | `888888`（一次性） |

**登录说明**
- **Web Admin**：手机号 + 验证码 `888888`（一次性，用完重新执行第二步 SQL）
- **C端 / B端 APP**：手机号 + 密码 `Test@1234`（可重复使用，推荐）
- **API 直接测试**：`POST /v1/auth/login-with-password`，body 需含 `device_id` 字段

---

## 快速命令

```bash
# 启动后端
cd myanmar-real-estate/backend && docker-compose up -d

# 运行Flutter
cd myanmar-real-estate/flutter
flutter run -t lib/main_buyer.dart   # C端
flutter run -t lib/main_agent.dart   # B端

# Web后台
cd myanmar-real-estate/frontend/web-admin
npm install && npm run dev
```

---

## 变更日志

### 2026-03-22
- GitHub 安全推送完成
- 清理 config.yaml 敏感信息历史
- 创建 github-secure-push skill
- 创建 myanmar-real-estate-platform skill（本文件）
- 本地测试环境搭建完成（所有 Docker 服务运行正常）
- 为测试账号设置密码 Test@1234，无需 SMS 即可登录
- 修复 Web Admin .umi 模块丢失错误，dev server 运行于 localhost:8005
- C端 APP 以 Web 模式运行于 localhost:7001（Chrome）
- B端 APP 以 Web 模式运行于 localhost:7002（Chrome）
- 修复 verification/tasks 404、agents/performance 待开发、admin/banners 500 三个问题

### 2026-03-21
- Flutter i18n 国际化完成（中/英/缅三语）
- 修复 8 个跨端 bug
- QA 测试通过率 79.1%

### 2026-03-20
- 8 个 AI Agent 并行开发完成基础代码
- 总代码量 41,000+ 行
