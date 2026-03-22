# 缅甸房产平台 - 快速开始指南

**最后更新**: 2026-03-19

---

## 一、5分钟启动所有服务

### Step 1: 启动基础设施 (30秒)

```bash
cd myanmar-real-estate/backend
docker-compose up -d postgres redis elasticsearch
```

**验证**:
```bash
docker-compose ps
# 应看到3个容器: postgres, redis, elasticsearch
```

### Step 2: 启动后端API (10秒)

```bash
# 在宿主机上运行（不要放在Docker中）
./server.exe
```

**验证**:
```bash
curl http://localhost:8080/health
# 应返回: {"code":200,"message":"success",...}
```

### Step 3: 启动Web Admin (30秒)

```bash
cd ../frontend/web-admin
npm run dev
```

**验证**: 打开 http://localhost:8000

### Step 4: 修改Flutter配置

编辑 `myanmar-real-estate/flutter/lib/core/constants/app_constants.dart`:

```dart
// 找到这行，改为你的本机IP
static const String apiBaseUrl = 'http://192.168.1.100:8080';
```

获取本机IP:
```bash
# Windows
ipconfig | findstr "IPv4"

# Mac/Linux
ifconfig | grep "inet "
```

### Step 5: 启动Flutter APP

```bash
cd myanmar-real-estate/flutter
flutter pub get

# C端 - Buyer App
flutter run -t lib/main_buyer.dart

# B端 - Agent App (另开终端)
flutter run -t lib/main_agent.dart
```

---

## 二、验证服务状态

### 一键验证脚本

```bash
cd /d/work/myanmar-real-estate-kimi
bash quick-test.sh
```

### 预期输出

```
==========================================
缅甸房产平台 - 快速联调验证
==========================================

[1/5] 检查服务状态...
==========================================
后端API (8080): ✅ 正常
Web Admin (8000): ✅ 正常
Elasticsearch (9200): ✅ 正常

[2/5] 测试用户认证API...
==========================================
发送验证码: ✅ 通过
用户登录: ✅ 通过
    Token: eyJhbGciOiJIUzI1NiIs...

[3/5] 测试房源API...
==========================================
房源列表: ❌ 失败
房源详情: ❌ 失败 (可能房源不存在)

...
```

---

## 三、测试账号

| 角色 | 手机号 | 登录方式 | 说明 |
|------|--------|----------|------|
| C端买家 | +95111111111 | 验证码 | 普通用户 |
| C端买家 | +95222222222 | 验证码 | 普通用户 |
| B端经纪人 | +95333333333 | 验证码 | 经纪人 |
| B端经纪人 | +95444444444 | 验证码 | 经纪人 |

**验证码**: 调用API动态生成，默认有效5分钟

---

## 四、API测试命令

### 用户认证

```bash
BASE_URL="http://localhost:8080"

# 1. 发送验证码
curl -X POST ${BASE_URL}/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d '{"phone": "+95111111111", "type": "login"}'

# 2. 用户登录（使用返回的验证码）
curl -X POST ${BASE_URL}/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+95111111111",
    "code": "返回的验证码",
    "device_id": "test_device"
  }'

# 3. 获取用户信息（使用登录返回的token）
curl -X GET ${BASE_URL}/v1/users/me \
  -H "Authorization: Bearer TOKEN"
```

### 数据库查询

```bash
# 连接PostgreSQL
docker exec -it myanmar-property-db psql -U myanmar_property -d myanmar_property

# 查看测试数据
SELECT * FROM users LIMIT 5;
SELECT * FROM houses LIMIT 5;
SELECT * FROM agents LIMIT 5;
```

---

## 五、常见问题

### Q1: Flutter无法连接后端

**现象**: APP显示网络错误

**解决**:
1. 确保使用本机IP而非localhost
2. 确保手机和电脑在同一WiFi
3. 关闭防火墙或开放8080端口

### Q2: 发送验证码失败

**现象**: 验证码发送接口报错

**解决**:
1. 确保在宿主机运行server.exe（非Docker）
2. 检查数据库连接: `docker logs myanmar-property-db`

### Q3: 房源列表为空

**现象**: 首页不显示房源

**原因**: 房源模块API尚未完全实现

**状态**: ⏳ 待开发

### Q4: 地图不显示

**现象**: 地图找房页面空白

**原因**: 需要配置Google Maps API Key

**解决**: 在Flutter配置中添加API Key

---

## 六、开发路线图

### 当前可用 ✅
- 用户注册/登录
- 获取用户信息
- 基础页面导航

### 进行中 ⏳
- 房源列表API
- 房源详情API
- 搜索筛选API

### 待开始 📋
- 地图找房API
- 收藏功能API
- 预约带看API
- IM消息API
- ACN分佣API

---

## 七、相关文档

| 文档 | 说明 |
|------|------|
| `INTEGRATION_STATUS.md` | 联调状态报告 |
| `APP_VERIFICATION_GUIDE.md` | APP验证完整方案 |
| `APP_VERIFICATION_CHECKLIST.md` | 验证清单(打印版) |
| `integration-test-guide.md` | 联调测试指南 |
| `myanmar-real-estate/backend/02-api-spec.md` | API接口文档 |

---

## 八、联系支持

遇到问题？
1. 查看相关文档
2. 检查服务日志
3. 运行验证脚本
4. 核对配置信息

**Happy Coding! 🚀**
