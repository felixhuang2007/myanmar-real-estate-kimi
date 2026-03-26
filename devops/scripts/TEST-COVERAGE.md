# 缅甸房产平台自动化测试 - 覆盖情况汇总

## 测试脚本清单

| 脚本文件 | 测试类型 | 用例数 | 说明 |
|---------|---------|--------|------|
| `auto-test.sh` | 冒烟测试 | 10 | 基础服务健康检查 |
| `api-test-suite.sh` | API测试 | 47 | 后端API端点全覆盖 |
| `admin-e2e-tests.sh` | Web Admin E2E | 20 | 管理后台功能测试 |
| `flutter-app-tests.sh` | Flutter App | 20 | C端/B端App API测试 |
| `integration-tests.sh` | 集成测试 | 8流程 | 端到端业务流程 |
| `run-all-tests.sh` | 统一入口 | - | 测试执行框架 |

**总计: 100+ 测试用例** (原设计195个中的核心用例)

---

## 详细测试覆盖

### 1. API测试 (47个用例) - api-test-suite.sh

#### 用户模块 (9个)
- [x] 用户注册
- [x] 发送验证码
- [x] 验证码登录
- [x] 密码登录
- [x] 获取用户信息
- [x] 更新用户信息
- [x] 刷新Token
- [x] 实名认证提交
- [x] 用户收藏列表

#### 房源模块 (9个)
- [x] 房源搜索
- [x] 房源详情
- [x] 地图聚合
- [x] 首页推荐
- [x] 创建房源
- [x] 更新房源
- [x] 房源下架
- [x] 收藏/取消收藏
- [x] 房源列表

#### IM模块 (7个)
- [x] 会话列表
- [x] 获取消息
- [x] 发送消息
- [x] 标记已读
- [x] 创建会话
- [x] 快捷话术
- [x] 删除会话

#### 预约模块 (10个)
- [x] 可预约时间段
- [x] 创建预约
- [x] 预约列表
- [x] 预约详情
- [x] 确认预约
- [x] 拒绝预约
- [x] 完成带看
- [x] 取消预约
- [x] 带看评价
- [x] 经纪人预约日历

#### ACN模块 (8个)
- [x] 成交申报
- [x] 成交列表
- [x] 成交详情
- [x] 确认成交
- [x] 成交申诉
- [x] 佣金余额
- [x] 佣金明细
- [x] 分佣角色设置

#### 公共模块 (4个)
- [x] 健康检查
- [x] 上传配置
- [x] 城市列表
- [x] 退出登录

---

### 2. Web Admin E2E测试 (20个用例) - admin-e2e-tests.sh

#### 用户管理 (8个)
- [x] C端用户列表查询
- [x] C端用户详情查看
- [x] 用户实名认证审核
- [x] 用户状态管理
- [x] B端经纪人列表查询
- [x] 经纪人入驻审核
- [x] 公司/门店管理
- [x] RBAC权限管理

#### 房源管理 (9个)
- [x] 房源待审核列表
- [x] 房源详情审核
- [x] 房源批量审核
- [x] 房源列表管理
- [x] 房源上下架操作
- [x] 房源价格监控
- [x] 验真任务派发
- [x] 验真报告审核
- [x] 房源数据导出

#### 数据看板 (3个)
- [x] 核心数据看板加载
- [x] 用户数据分析
- [x] 房源数据分析

---

### 3. Flutter App测试 (20个用例) - flutter-app-tests.sh

#### C端(Buyer) (10个)
- [x] 首页推荐房源
- [x] 房源搜索
- [x] 房源详情
- [x] 地图聚合
- [x] 发送验证码
- [x] 用户登录
- [x] 收藏房源
- [x] 预约看房
- [x] IM会话列表
- [x] 用户信息

#### B端(Agent) (10个)
- [x] 经纪人登录
- [x] 经纪人房源列表
- [x] 创建房源
- [x] 预约管理
- [x] 客户管理
- [x] IM消息发送
- [x] 成交申报
- [x] 佣金查询
- [x] 业绩统计
- [x] 带看签到

---

### 4. 端到端集成测试 (8个业务流程) - integration-tests.sh

1. **用户预约带看流程**
   - 用户注册 → 实名认证 → 浏览房源 → 预约带看 → 查看预约

2. **经纪人发布房源流程**
   - 经纪人登录 → 录入房源 → 更新房源 → 提交审核

3. **带看完成流程**
   - 查看预约 → 确认预约 → 带看签到 → 完成带看 → 用户评价

4. **成交分佣流程 (ACN)**
   - 成交申报 → 分佣设置 → 确认成交 → 佣金查询 → 佣金明细

5. **IM转预约流程**
   - 发起会话 → 发送消息 → 发送房源卡片 → 创建预约 → 标记已读

6. **举报处理流程**
   - 提交举报 → 查看状态 → 管理员处理

7. **房源验真流程**
   - 派发任务 → 查看任务 → 提交报告 → 审核报告 → 查看状态

8. **佣金提现流程**
   - 查询余额 → 提交申请 → 查看记录 → 审核申请 → 查看状态

---

### 5. 性能压力测试 (5个场景) - run-all-tests.sh --stress

- [x] 房源搜索接口 (1000请求, 50并发)
- [x] 健康检查接口 (5000请求, 100并发)
- [x] 并发登录测试 (100次并发)
- [x] 数据库连接池测试 (50并发查询)
- [x] 验证码限流测试 (20次快速请求)

---

## 与原始设计195个用例的对比

| 模块 | 原始设计 | 当前实现 | 状态 |
|------|---------|---------|------|
| 用户模块 API | 9 | 9 | ✅ 完整 |
| 房源模块 API | 9 | 9 | ✅ 完整 |
| IM模块 API | 7 | 7 | ✅ 完整 |
| 预约模块 API | 10 | 10 | ✅ 完整 |
| ACN模块 API | 8 | 8 | ✅ 完整 |
| 管理后台功能 | 33 | 20 | ⚠️ 核心功能覆盖 |
| 用户端App | ~40 | 10 | ⚠️ API层覆盖 |
| 经纪人端App | ~40 | 10 | ⚠️ API层覆盖 |
| 集成业务流程 | 8 | 8 | ✅ 完整 |
| 性能测试 | ~17 | 5 | ⚠️ 基础覆盖 |
| 安全测试 | ~14 | 0 | ❌ 未实现 |
| **总计** | **195** | **100+** | **⚠️ 核心覆盖** |

---

## 使用方式

### 快速开始

```bash
# 进入测试脚本目录
cd devops/scripts

# 1. 快速冒烟测试 (3-5分钟)
bash run-all-tests.sh --smoke

# 2. API全量测试 (15-20分钟)
bash run-all-tests.sh --api

# 3. Web Admin测试 (8-10分钟)
bash run-all-tests.sh --admin

# 4. Flutter App测试 (12-15分钟)
bash run-all-tests.sh --flutter

# 5. 集成测试 (15-20分钟)
bash run-all-tests.sh --integration

# 6. 压力测试 (20-30分钟)
bash run-all-tests.sh --stress

# 7. 完整测试套件 (60-90分钟)
bash run-all-tests.sh --full
```

### 单独执行测试

```bash
# 基础冒烟测试
bash auto-test.sh

# API详细测试
bash api-test-suite.sh

# 单个模块测试
bash api-test-suite.sh --user      # 只测用户模块
bash api-test-suite.sh --house     # 只测房源模块
bash api-test-suite.sh --im        # 只测IM模块
bash api-test-suite.sh --appointment  # 只测预约模块
bash api-test-suite.sh --acn       # 只测ACN模块

# Web Admin E2E
bash admin-e2e-tests.sh

# Flutter App测试
bash flutter-app-tests.sh
bash flutter-app-tests.sh --api      # 只测API
bash flutter-app-tests.sh --analyze  # 代码分析

# 集成测试
bash integration-tests.sh
bash integration-tests.sh --flow1    # 单个流程
```

### 指定服务器

```bash
# 测试生产环境
SERVER_IP=43.163.122.42 bash run-all-tests.sh --smoke

# 测试其他环境
SERVER_IP=192.168.1.100 bash run-all-tests.sh --api
```

---

## 测试报告输出

所有测试脚本会生成JSON格式的测试报告：

```json
{
  "timestamp": "2026-03-26T10:30:00+08:00",
  "server": "43.163.122.42",
  "duration_seconds": 450,
  "summary": {
    "total": 47,
    "passed": 42,
    "failed": 3,
    "skipped": 2,
    "pass_rate": 89
  }
}
```

报告保存位置: `/tmp/test-report-YYYYMMDD-HHMMSS.json`

---

## 后续建议

### 短期优化
1. 在服务器上执行一遍测试，根据实际情况调整API端点
2. 根据测试结果修复失败的用例
3. 补充缺失的Web Admin路由

### 中期完善
1. 使用 Playwright 替换 bash 版本的 Web Admin E2E 测试
2. 添加微信小程序测试脚本
3. 增加更多性能测试场景

### 长期规划
1. 集成到 CI/CD 流水线
2. 添加安全测试 (XSS, SQL注入等)
3. 实现测试数据自动清理
4. 添加测试覆盖率报告

---

*文档生成时间: 2026-03-26*
*测试脚本版本: v1.0*
