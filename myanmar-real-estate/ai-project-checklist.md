# 缅甸房产平台 - AI员工项目检查清单

## 检查时间表

### 第1次检查（启动后4小时）
- [ ] PM-Agent：项目计划是否生成
- [ ] UI-Agent：设计系统文档是否完成
- [ ] Backend-Agent：数据库Schema是否完成
- [ ] DevOps-Agent：基础配置是否完成

**决策点**：
- 如果设计稿完成 → 通知iOS/Android/Web Agent开始编码
- 如果API文档完成 → 通知QA Agent开始写测试用例

### 第2次检查（启动后24小时）
- [ ] 各端编码进度（目标：基础框架搭建完成）
- [ ] API接口实现进度（目标：用户/房源核心API完成）
- [ ] 设计稿是否全部完成

### 第3次检查（启动后3天）
- [ ] C端核心功能完成度
- [ ] B端核心功能完成度
- [ ] 接口联调状态

### 第4次检查（启动后1周）
- [ ] 功能完整性检查
- [ ] QA测试用例执行
- [ ] Bug修复进度

## 文件产出检查路径

```
/workspace/
├── project-management/     # PM-Agent产出
│   ├── project-plan.md
│   └── daily-reports/
├── design/                 # UI-Agent产出
│   ├── 01-design-system.md
│   ├── 02-c端-app-design.md
│   ├── 03-b端-app-design.md
│   ├── 04-web-admin-design.md
│   └── 05-mini-program-design.md
├── backend/                # Backend-Agent产出
│   ├── 01-database-schema.sql
│   ├── 02-api-spec.md
│   ├── 03-user-service/
│   ├── 04-house-service/
│   ├── 05-acn-service/
│   └── 08-Dockerfile
├── devops/                 # DevOps-Agent产出
│   ├── ci-cd/
│   ├── docker/
│   └── deployment/
├── ios/                    # iOS-Agent产出
│   ├── MyanmarHome/
│   └── README.md
├── android/                # Android-Agent产出
│   ├── myanmarhome/
│   └── README.md
├── frontend/               # Web-Agent产出
│   ├── mini-program/
│   └── web-admin/
└── qa/                     # QA-Agent产出
    ├── test-cases/
    └── code-review/
```

## 风险预案

### 如果AI员工输出质量不达标
- 立即发送修正指令，明确问题点
- 必要时重新spawn新的Agent接管

### 如果产出文件被截断
- 要求Agent分多个小文件输出
- 避免单文件超过500行

### 如果Agent停滞不动
- 发送sessions_send催促消息
- 检查是否需要提供更多输入（如设计稿）
