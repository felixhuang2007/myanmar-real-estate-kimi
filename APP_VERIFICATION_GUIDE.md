# 缅甸房产平台 - APP验证方案

**文档版本**: v1.0
**验证时间**: 2026-03-19
**适用对象**: C端(Buyer) + B端(Agent)

---

## 一、验证环境准备

### 1.1 服务启动检查

```bash
# 1. 启动基础设施
cd myanmar-real-estate/backend
docker-compose up -d postgres redis elasticsearch

# 2. 启动后端API（宿主机）
./server.exe

# 3. 检查服务状态
curl http://localhost:8080/health
curl http://localhost:9200/_cluster/health
```

### 1.2 获取本机IP

```bash
# Windows
ipconfig | findstr "IPv4"

# 用于Flutter连接后端（不能用localhost）
# 假设IP为: 192.168.1.100
```

### 1.3 Flutter配置

修改 `myanmar-real-estate/flutter/lib/core/constants/app_constants.dart`:

```dart
// 开发环境使用本机IP
static const String apiBaseUrl = 'http://192.168.1.100:8080';
```

---

## 二、C端APP (Buyer App) 验证方案

### 2.1 启动命令

```bash
cd myanmar-real-estate/flutter

# 清理缓存
flutter clean
flutter pub get

# 启动Buyer App
flutter run -t lib/main_buyer.dart
```

### 2.2 验证清单

#### 模块1: 启动与引导 ✅

| 测试项 | 预期结果 | 状态 |
|--------|----------|------|
| 启动页显示 | 显示Logo和slogan，2秒后跳转 | ⬜ |
| 引导页(首次) | 展示3页引导，可滑动跳过 | ⬜ |
| 引导页(非首次) | 直接跳转到首页 | ⬜ |

**验证步骤**:
1. 首次安装启动，观察是否显示引导页
2. 滑动浏览所有引导页
3. 点击"立即体验"进入首页
4. 杀掉APP重新启动，观察是否跳过引导

---

#### 模块2: 登录与注册 🔑

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 手机号输入 | 只能输入数字，+95前缀 | - | ⬜ |
| 发送验证码 | 按钮60秒倒计时，调用API | `POST /v1/auth/send-verification-code` | ⬜ |
| 验证码输入 | 6位数字输入框 | - | ⬜ |
| 验证码登录 | 返回token，跳转首页 | `POST /v1/auth/login` | ⬜ |
| 自动登录 | Token未过期自动进入 | `GET /v1/users/me` | ⬜ |
| 退出登录 | 清除token，返回登录页 | - | ⬜ |

**验证步骤**:

```
步骤1: 手机号验证
- 输入: +95111111111
- 点击"获取验证码"
- 预期: 按钮显示"60s后重试"

步骤2: 验证码登录
- 输入收到的验证码
- 点击"登录"
- 预期: 登录成功，跳转到首页

步骤3: Token持久化
- 杀掉APP重新打开
- 预期: 自动登录，进入首页
```

**测试账号**:
- 手机号: `+95111111111`
- 类型: 个人买家

---

#### 模块3: 首页 🏠

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 城市切换 | 显示城市列表，可切换 | `GET /v1/cities` | ⬜ |
| Banner轮播 | 自动轮播，点击跳转 | - | ⬜ |
| 快捷入口 | 二手房、新房、租房、地图找房 | - | ⬜ |
| 推荐房源 | 显示房源卡片列表 | `GET /v1/houses?recommend=1` | ⬜ |
| 下拉刷新 | 重新加载数据 | - | ⬜ |
| 上拉加载 | 加载更多房源 | `GET /v1/houses?page=2` | ⬜ |

**验证步骤**:
1. 检查城市是否正确显示"仰光"
2. 点击地图找房，跳转地图页面
3. 点击房源卡片，跳转详情页

---

#### 模块4: 房源搜索 🔍

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 搜索框 | 可输入关键词 | - | ⬜ |
| 搜索建议 | 输入时显示建议 | `GET /v1/houses/suggestions` | ⬜ |
| 搜索结果 | 显示房源列表 | `GET /v1/houses/search` | ⬜ |
| 筛选条件 | 价格、户型、区域等 | - | ⬜ |
| 排序方式 | 默认/价格/时间 | - | ⬜ |

**验证步骤**:
1. 点击首页搜索框
2. 输入"公寓"
3. 查看搜索结果
4. 点击筛选，选择价格区间
5. 验证结果是否更新

---

#### 模块5: 地图找房 🗺️

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 地图显示 | 显示Google/高德地图 | - | ⬜ |
| 当前定位 | 显示当前位置标记 | - | ⬜ |
| 区域聚合 | 显示区域气泡和数量 | `GET /v1/houses/map/aggregate` | ⬜ |
| 缩放切换 | 缩放时切换聚合级别 | - | ⬜ |
| 点击气泡 | 显示房源列表 | - | ⬜ |

**验证步骤**:
1. 点击地图找房入口
2. 观察地图是否加载
3. 查看区域气泡显示
4. 缩放地图测试聚合变化
5. 点击气泡查看房源列表

---

#### 模块6: 房源详情 📄

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 图片轮播 | 显示房源图片，可滑动 | - | ⬜ |
| 基本信息 | 价格、面积、户型、楼层 | `GET /v1/houses/:id` | ⬜ |
| 房源特色 | 显示标签（近地铁、精装等） | - | ⬜ |
| 小区信息 | 小区名称、年代、绿化率 | - | ⬜ |
| 经纪人卡片 | 显示负责经纪人 | - | ⬜ |
| 收藏房源 | 点击收藏/取消收藏 | `POST /v1/users/favorites` | ⬜ |
| 预约看房 | 点击打开预约弹窗 | - | ⬜ |
| 在线咨询 | 点击打开IM聊天 | - | ⬜ |

**验证步骤**:
1. 从列表点击房源进入详情
2. 左右滑动查看图片
3. 点击收藏按钮
4. 点击"预约看房"
5. 选择时间，提交预约

---

#### 模块7: 收藏与历史 ⭐

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 收藏列表 | 显示收藏的房源 | `GET /v1/users/favorites` | ⬜ |
| 取消收藏 | 可移除收藏 | `DELETE /v1/users/favorites/:id` | ⬜ |
| 浏览历史 | 显示最近浏览的房源 | `GET /v1/users/history` | ⬜ |
| 清空历史 | 可清空浏览记录 | `DELETE /v1/users/history` | ⬜ |

---

#### 模块8: 个人中心 👤

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 头像显示 | 显示用户头像 | - | ⬜ |
| 昵称显示 | 显示用户昵称 | `GET /v1/users/me` | ⬜ |
| 编辑资料 | 可修改昵称/头像 | `PUT /v1/users/profile` | ⬜ |
| 实名认证 | 显示认证状态 | - | ⬜ |
| 我的预约 | 查看预约记录 | `GET /v1/users/appointments` | ⬜ |
| 设置页面 | 清除缓存、关于我们 | - | ⬜ |

---

### 2.3 C端完整流程测试

#### 流程1: 新用户首次使用
```
启动APP → 引导页 → 登录页 → 发送验证码 → 输入验证码 →
首页 → 搜索房源 → 查看详情 → 收藏房源 → 预约看房 → 个人中心
```

#### 流程2: 老用户找房
```
启动APP → 自动登录 → 首页 → 地图找房 → 查看区域房源 →
查看详情 → 联系经纪人 → 在线咨询
```

---

## 三、B端APP (Agent App) 验证方案

### 3.1 启动命令

```bash
cd myanmar-real-estate/flutter

# 启动Agent App
flutter run -t lib/main_agent.dart
```

### 3.2 验证清单

#### 模块1: 经纪人登录 🔑

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 登录页 | 显示经纪人专属登录页 | - | ⬜ |
| 手机号登录 | 使用经纪人账号登录 | `POST /v1/auth/login` | ⬜ |
| 登录后角色判断 | 跳转到经纪人工作台 | - | ⬜ |

**测试账号**:
- 手机号: `+95333333333`
- 类型: 经纪人

---

#### 模块2: 工作台首页 📊

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 数据概览 | 显示今日带看、本月业绩 | `GET /v1/agents/dashboard` | ⬜ |
| 快捷入口 | 我的房源、客户管理、带看日程 | - | ⬜ |
| 待办事项 | 显示待处理任务 | `GET /v1/agents/todos` | ⬜ |
| 公告通知 | 显示平台公告 | - | ⬜ |

---

#### 模块3: 房源管理 🏠

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 房源列表 | 显示我的房源 | `GET /v1/agents/houses` | ⬜ |
| 房源状态 | 待审核/在售/已售/已下架 | - | ⬜ |
| 新增房源 | 打开房源发布页面 | - | ⬜ |
| 编辑房源 | 可修改房源信息 | `PUT /v1/houses/:id` | ⬜ |
| 房源推广 | 分享房源到社交平台 | - | ⬜ |

**新增房源表单验证**:
```
必填项:
- 房源标题
- 房源类型（二手房/新房/租房）
- 小区名称
- 户型（几室几厅）
- 面积
- 价格
- 楼层
- 朝向
- 装修情况
- 房源图片（至少3张）
```

---

#### 模块4: 客户管理 👥

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 客户列表 | 显示我的客户 | `GET /v1/agents/clients` | ⬜ |
| 客户详情 | 显示客户需求、跟进记录 | `GET /v1/clients/:id` | ⬜ |
| 新增客户 | 录入客户信息 | `POST /v1/clients` | ⬜ |
| 跟进记录 | 添加客户跟进 | `POST /v1/clients/:id/followups` | ⬜ |
| 客户标签 | 设置客户标签（刚需/投资等） | - | ⬜ |

---

#### 模块5: 带看日程 📅

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 日历视图 | 显示本月带看安排 | `GET /v1/agents/schedule` | ⬜ |
| 带看列表 | 按日期显示带看任务 | - | ⬜ |
| 确认带看 | 接受/拒绝预约 | `PUT /v1/appointments/:id` | ⬜ |
| 完成带看 | 标记带看完成 | `PUT /v1/appointments/:id/complete` | ⬜ |
| 带看反馈 | 填写带看反馈 | `POST /v1/appointments/:id/feedback` | ⬜ |

---

#### 模块6: ACN分佣 💰

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 分佣概览 | 显示可提现金额 | `GET /v1/agents/commission/summary` | ⬜ |
| 成交记录 | 显示历史成交 | `GET /v1/agents/transactions` | ⬜ |
| 分佣明细 | 显示每笔分佣详情 | `GET /v1/agents/commissions` | ⬜ |
| 提现申请 | 申请提现到银行卡 | `POST /v1/agents/withdrawals` | ⬜ |
| 角色说明 | 显示当前角色（录入人/带看人等） | - | ⬜ |

---

#### 模块7: IM消息 💬

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 会话列表 | 显示客户咨询列表 | `GET /v1/im/conversations` | ⬜ |
| 聊天界面 | 支持文字/图片/房源卡片 | `GET /v1/im/messages` | ⬜ |
| 快捷话术 | 可发送预设话术 | `GET /v1/im/quick-replies` | ⬜ |
| 已读状态 | 显示消息已读/未读 | - | ⬜ |
| 消息推送 | 收到新消息推送通知 | - | ⬜ |

---

#### 模块8: 个人中心 👤

| 测试项 | 预期结果 | API端点 | 状态 |
|--------|----------|---------|------|
| 经纪人信息 | 显示头像、姓名、门店 | `GET /v1/agents/me` | ⬜ |
| 实名认证 | 显示认证状态 | - | ⬜ |
| 我的评价 | 显示客户评价 | `GET /v1/agents/reviews` | ⬜ |
| 设置 | 修改密码、清理缓存 | - | ⬜ |

---

### 3.3 B端完整流程测试

#### 流程1: 经纪人日常工作
```
登录 → 工作台 → 查看待办 → 确认带看预约 →
带看完成 → 填写反馈 → 录入新客户 → 发布新房源
```

#### 流程2: ACN成交流程
```
录入房源 → 等待验真 → 房源上架 → 客户咨询 →
带看房源 → 确认成交 → 分佣结算 → 申请提现
```

---

## 四、前后端联调问题排查

### 4.1 网络连接问题

**现象**: APP无法连接后端
**排查**:
```bash
# 1. 确认后端运行
curl http://localhost:8080/health

# 2. 确认IP地址正确（使用本机IP，非localhost）
ipconfig

# 3. 检查防火墙
# 确保8080端口允许访问

# 4. 测试手机与电脑同网络
# 手机和电脑必须在同一WiFi
```

### 4.2 CORS跨域问题

**现象**: 浏览器正常，APP报错
**解决**: 后端已配置CORS中间件，检查 `corsMiddleware()` 是否生效

### 4.3 Token失效问题

**现象**: 401 Unauthorized
**排查**:
- 检查token是否正确存储
- 检查token是否过期
- 检查请求头格式: `Authorization: Bearer {token}`

---

## 五、验证报告模板

### 5.1 C端验证报告

```markdown
## C端APP验证报告

**测试日期**: 2026-XX-XX
**测试人员**: XXX
**Flutter版本**: 3.19.0
**后端版本**: v1.0

### 测试结果汇总

| 模块 | 测试项 | 通过 | 失败 | 备注 |
|------|--------|------|------|------|
| 启动引导 | 4 | 4 | 0 | - |
| 登录注册 | 6 | 6 | 0 | - |
| 首页 | 6 | 4 | 2 | 推荐房源加载慢 |
| 搜索 | 5 | 3 | 2 | 筛选未实现 |
| 地图找房 | 5 | 0 | 5 | API未实现 |
| 房源详情 | 8 | 5 | 3 | 收藏功能异常 |
| 个人中心 | 6 | 4 | 2 | - |
| **总计** | **40** | **26** | **14** | **65%** |

### 问题列表

| 优先级 | 问题描述 | 影响范围 | 建议 |
|--------|----------|----------|------|
| P0 | 地图找房API返回404 | 核心功能 | 需实现房源模块 |
| P1 | 收藏房源接口报错 | 用户体验 | 检查数据库连接 |

### 结论
- 基础功能（登录、首页）可用
- 核心业务流程需要房源API支持
- 建议优先实现房源模块
```

### 5.2 B端验证报告

```markdown
## B端APP验证报告

**测试日期**: 2026-XX-XX
**测试人员**: XXX

### 测试结果汇总

| 模块 | 测试项 | 通过 | 失败 | 备注 |
|------|--------|------|------|------|
| 登录 | 3 | 3 | 0 | - |
| 工作台 | 4 | 2 | 2 | 数据概览未实现 |
| 房源管理 | 6 | 2 | 4 | 新增/编辑待实现 |
| 客户管理 | 5 | 1 | 4 | API未实现 |
| 带看日程 | 5 | 1 | 4 | 日历组件异常 |
| ACN分佣 | 5 | 0 | 5 | 模块未开发 |
| IM消息 | 5 | 0 | 5 | 模块未开发 |
| **总计** | **33** | **9** | **24** | **27%** |

### 结论
- 登录功能正常
- 大部分B端功能需要后端API支持
- 建议分阶段实现：房源 → 客户 → 日程 → ACN → IM
```

---

## 六、附录

### 6.1 测试账号清单

| 角色 | 手机号 | 密码/验证码 | 状态 |
|------|--------|-------------|------|
| C端买家 | +95111111111 | 动态验证码 | 已注册 |
| C端买家 | +95222222222 | 动态验证码 | 已注册 |
| B端经纪人 | +95333333333 | 动态验证码 | 已注册 |
| B端经纪人 | +95444444444 | 动态验证码 | 已注册 |

### 6.2 API端点汇总

```yaml
# 认证相关
POST   /v1/auth/send-verification-code  # 发送验证码
POST   /v1/auth/login                   # 登录
GET    /v1/auth/refresh                 # 刷新token

# 用户相关
GET    /v1/users/me                     # 获取当前用户
PUT    /v1/users/profile                # 更新用户资料
GET    /v1/users/favorites              # 收藏列表
POST   /v1/users/favorites              # 添加收藏
DELETE /v1/users/favorites/:id          # 取消收藏

# 房源相关 (待实现)
GET    /v1/houses                       # 房源列表
GET    /v1/houses/:id                   # 房源详情
GET    /v1/houses/search                # 搜索房源
GET    /v1/houses/map/aggregate         # 地图聚合

# 经纪人相关 (待实现)
GET    /v1/agents/me                    # 获取经纪人信息
GET    /v1/agents/dashboard             # 工作台数据
GET    /v1/agents/houses                # 我的房源
GET    /v1/agents/clients               # 我的客户
GET    /v1/agents/schedule              # 带看日程
GET    /v1/agents/commissions           # 分佣记录

# 预约相关 (待实现)
GET    /v1/appointments                 # 预约列表
POST   /v1/appointments                 # 创建预约
PUT    /v1/appointments/:id             # 更新预约状态
POST   /v1/appointments/:id/feedback    # 提交反馈

# IM相关 (待实现)
GET    /v1/im/conversations             # 会话列表
GET    /v1/im/messages                  # 消息列表
POST   /v1/im/messages                  # 发送消息
```

### 6.3 快速测试脚本

```bash
#!/bin/bash
# save as: verify_app.sh

echo "========================================"
echo "APP联调验证脚本"
echo "========================================"

BASE_URL="http://localhost:8080"
PHONE_C="+95111111111"  # C端用户
PHONE_B="+95333333333"  # B端经纪人

# 1. 测试C端登录
echo ""
echo "[C端] 测试用户登录..."
SMS_RESP=$(curl -s -X POST ${BASE_URL}/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"${PHONE_C}\", \"type\": \"login\"}")
SMS_CODE=$(echo $SMS_RESP | grep -o '"code":"[0-9]*"' | head -1 | cut -d'"' -f4)
echo "  验证码: ${SMS_CODE}"

LOGIN_RESP=$(curl -s -X POST ${BASE_URL}/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"${PHONE_C}\", \"code\": \"${SMS_CODE}\", \"device_id\": \"test_c\"}")
TOKEN_C=$(echo $LOGIN_RESP | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "  C端Token: ${TOKEN_C:0:30}..."

# 2. 测试B端登录
echo ""
echo "[B端] 测试经纪人登录..."
SMS_RESP=$(curl -s -X POST ${BASE_URL}/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"${PHONE_B}\", \"type\": \"login\"}")
SMS_CODE=$(echo $SMS_RESP | grep -o '"code":"[0-9]*"' | head -1 | cut -d'"' -f4)
echo "  验证码: ${SMS_CODE}"

LOGIN_RESP=$(curl -s -X POST ${BASE_URL}/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"phone\": \"${PHONE_B}\", \"code\": \"${SMS_CODE}\", \"device_id\": \"test_b\"}")
TOKEN_B=$(echo $LOGIN_RESP | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
echo "  B端Token: ${TOKEN_B:0:30}..."

# 3. 测试用户信息
echo ""
echo "[API] 测试用户信息..."
USER_INFO=$(curl -s -X GET ${BASE_URL}/v1/users/me \
  -H "Authorization: Bearer ${TOKEN_C}")
echo "  用户信息: ${USER_INFO}"

echo ""
echo "========================================"
echo "验证完成"
echo "========================================"
```

---

**文档维护**: 每次API更新后需同步更新此文档
**联系方式**: 开发团队
