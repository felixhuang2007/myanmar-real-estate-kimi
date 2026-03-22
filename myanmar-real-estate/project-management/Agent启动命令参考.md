# 缅甸房产平台 - Agent启动命令

> **说明**: 本项目管理的Agent启动参考命令
> **日期**: 2026-03-17

---

## 启动顺序建议

### Phase 1: 基础设施 (Day 1-2)
```bash
# 1. 启动架构师 (AGENT-001)
# 负责: 架构设计、技术选型、规范制定
# 输入: PRD文档
# 输出: 架构设计文档、API规范

# 2. 启动数据库工程师 (AGENT-006)
# 负责: 数据库设计
# 依赖: AGENT-001的架构设计
# 输出: 数据库Schema

# 3. 启动DevOps工程师 (AGENT-008)
# 负责: CI/CD、环境搭建
# 输出: 开发环境、代码仓库
```

### Phase 2: 核心开发 (Day 3-21)
```bash
# 4. 启动后端工程师 (AGENT-002)
# 负责: Go后端服务开发
# 依赖: AGENT-001的API规范、AGENT-006的数据库设计

# 5. 启动C端APP开发工程师 (AGENT-003)
# 负责: Flutter C端APP
# 依赖: AGENT-001的UI规范、AGENT-002的API

# 6. 启动B端APP开发工程师 (AGENT-004)
# 负责: Flutter B端APP
# 依赖: AGENT-001的UI规范、AGENT-002的API

# 7. 启动前端工程师 (AGENT-005)
# 负责: Vue3 Web后台
# 依赖: AGENT-001的UI规范、AGENT-002的API
```

### Phase 3: 测试与交付 (Day 22-60)
```bash
# 8. 启动测试工程师 (AGENT-007)
# 负责: 测试用例、测试执行
# 依赖: 各开发Agent的产出

# 配合: DevOps工程师进行部署
```

---

## Agent配置参考

### AGENT-001 架构师
```yaml
role: 系统架构师
expertise:
  - 系统架构设计
  - 技术选型
  - API规范设计
  - 技术风险评估
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-001-架构师任务书.md
output:
  - 架构设计文档
  - API接口规范
  - 技术选型报告
```

### AGENT-002 后端工程师
```yaml
role: Go后端工程师
expertise:
  - Go语言开发
  - RESTful API开发
  - 数据库操作
  - 微服务架构
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-002-后端工程师任务书.md
tech_stack:
  - Go 1.22+
  - Gin框架
  - PostgreSQL
  - Redis
```

### AGENT-003 C端APP开发工程师
```yaml
role: Flutter开发工程师
expertise:
  - Flutter跨平台开发
  - 移动端UI开发
  - 状态管理
  - 地图集成
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-003-C端APP开发工程师任务书.md
tech_stack:
  - Flutter 3.x
  - Dart
  - GetX/Bloc
```

### AGENT-004 B端APP开发工程师
```yaml
role: Flutter开发工程师
expertise:
  - Flutter跨平台开发
  - 复杂表单处理
  - 相机/图片处理
  - 日程管理
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-004-B端APP开发工程师任务书.md
tech_stack:
  - Flutter 3.x
  - Dart
  - GetX/Bloc
```

### AGENT-005 前端工程师
```yaml
role: Web前端工程师
expertise:
  - Vue3开发
  - 后台管理系统
  - 数据可视化
  - Element Plus
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-005-前端工程师任务书.md
tech_stack:
  - Vue3
  - TypeScript
  - Element Plus
  - Vite
```

### AGENT-006 数据库工程师
```yaml
role: 数据库工程师
expertise:
  - 数据库设计
  - SQL优化
  - 索引优化
  - 数据迁移
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-006-数据库工程师任务书.md
tech_stack:
  - PostgreSQL
  - Redis
  - SQL
```

### AGENT-007 测试工程师
```yaml
role: 测试工程师
expertise:
  - 测试用例设计
  - 接口测试
  - 自动化测试
  - 性能测试
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-007-测试工程师任务书.md
tools:
  - Postman
  - JMeter
  - Playwright/Appium
```

### AGENT-008 DevOps工程师
```yaml
role: DevOps工程师
expertise:
  - CI/CD流水线
  - Docker/K8s
  - 云平台运维
  - 监控告警
task_file: /root/.openclaw/workspace/project-management/agents/AGENT-008-DevOps工程师任务书.md
tech_stack:
  - Docker
  - Jenkins/GitLab CI
  - Nginx
  - Prometheus/Grafana
```

---

## 关键依赖图

```
Week 1:
  AGENT-001 (架构) ──┬──→ AGENT-006 (数据库)
                    └──→ AGENT-008 (DevOps)

Week 2:
  AGENT-001 ──┬──→ AGENT-002 (后端)
              │       ↑
  AGENT-006 ──┘       │
                      ├──→ AGENT-003 (C端APP)
                      ├──→ AGENT-004 (B端APP)
                      └──→ AGENT-005 (Web)

Week 3-6:
  AGENT-002 ←────── 各前端开发

Week 7-8:
  各开发 → AGENT-007 (测试)
        → AGENT-008 (部署)
```

---

## 检查点

| 检查点 | 时间 | 检查内容 |
|--------|------|----------|
| CP1 | Day 5 | 架构设计完成 |
| CP2 | Day 12 | 数据库设计完成 |
| CP3 | Day 19 | 账号服务联调通过 |
| CP4 | Day 26 | 房源模块联调通过 |
| CP5 | Day 33 | IM功能联调通过 |
| CP6 | Day 40 | 预约验真联调通过 |
| CP7 | Day 47 | ACN功能联调通过 |
| CP8 | Day 55 | 集成测试完成 |
| CP9 | Day 60 | 项目交付 |

---

*文档创建: 2026-03-17*
