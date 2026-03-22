# 缅甸房产平台 - 联调验证方案

**验证时间**: 2026-03-19
**验证环境**: Windows 11 + Docker Desktop

---

## 一、服务状态检查

### 1.1 运行服务清单

| 服务 | 端口 | 状态 | 访问地址 |
|------|------|------|----------|
| 后端 API | 8080 | ✅ 运行中 | http://localhost:8080 |
| Web Admin | 8000 | ✅ 运行中 | http://localhost:8000 |
| PostgreSQL | 5432 | ✅ 运行中 | localhost:5432 |
| Redis | 6379 | ✅ 运行中 | localhost:6379 |
| Elasticsearch | 9200 | ✅ 运行中 | http://localhost:9200 |

### 1.2 快速状态检查命令

```bash
# 检查后端API
curl http://localhost:8080/health

# 检查Elasticsearch
curl http://localhost:9200/_cluster/health

# 检查所有Docker容器
cd myanmar-real-estate/backend && docker-compose ps
```

---

## 二、API 接口联调验证

### 2.1 用户模块验证

#### 2.1.1 发送验证码
```bash
curl -X POST http://localhost:8080/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d '{"phone": "+95111111111"}'
```
**预期响应**: `{"code":200,"message":"success","data":null}`

#### 2.1.2 用户登录
```bash
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+95111111111",
    "code": "123456",
    "device_id": "test_device_001"
  }'
```
**预期响应**: 返回 `access_token` 和 `refresh_token`

#### 2.1.3 获取用户信息
```bash
# 使用上一步获取的token
curl -X GET http://localhost:8080/v1/users/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 2.2 房源模块验证

#### 2.2.1 获取房源列表
```bash
curl -X GET "http://localhost:8080/v1/houses?page=1&size=10"
```

#### 2.2.2 搜索房源
```bash
curl -X GET "http://localhost:8080/v1/houses/search?city_id=1&min_price=100000&max_price=500000&page=1&size=10"
```

#### 2.2.3 获取房源详情
```bash
curl -X GET http://localhost:8080/v1/houses/1
```

### 2.3 地图找房验证

#### 2.3.1 获取地图聚合数据
```bash
curl -X GET "http://localhost:8080/v1/houses/map/aggregate?ne_lat=16.9&ne_lng=96.2&sw_lat=16.7&sw_lng=96.0&zoom=12"
```

---

## 三、前端联调验证

### 3.1 Web Admin 管理后台

**访问地址**: http://localhost:8000

#### 验证步骤:
1. 打开浏览器访问 http://localhost:8000
2. 使用测试账号登录:
   - 账号: admin
   - 密码: admin123
3. 验证以下功能:
   - [ ] 登录成功跳转仪表盘
   - [ ] 左侧菜单正常显示
   - [ ] 房源管理页面能加载数据
   - [ ] 用户管理页面能加载数据

### 3.2 Flutter 移动端

#### 启动Buyer App (C端)
```bash
cd myanmar-real-estate/flutter
flutter pub get
flutter run -t lib/main_buyer.dart
```

#### 验证功能:
- [ ] 启动页正常显示
- [ ] 登录页能发送验证码
- [ ] 登录成功后跳转首页
- [ ] 房源列表能加载数据
- [ ] 房源详情页能正常显示
- [ ] 地图找房功能正常

#### 启动Agent App (B端)
```bash
cd myanmar-real-estate/flutter
flutter run -t lib/main_agent.dart
```

#### 验证功能:
- [ ] 经纪人登录
- [ ] 我的房源管理
- [ ] 带看日程
- [ ] 客户管理

---

## 四、端到端联调场景

### 场景1: 用户完整流程

```
1. 用户打开Buyer App
2. 发送验证码 → 后端 /v1/auth/send-verification-code
3. 输入验证码登录 → 后端 /v1/auth/login
4. 查看房源列表 → 后端 /v1/houses
5. 查看房源详情 → 后端 /v1/houses/:id
6. 收藏房源 → 后端 /v1/users/favorites
7. 预约带看 → 后端 /v1/appointments
```

### 场景2: 经纪人带看流程

```
1. 经纪人打开Agent App
2. 登录账号
3. 查看待办任务
4. 确认预约请求
5. 更新带看状态
6. 填写带看反馈
```

### 场景3: 管理后台审核流程

```
1. 运营人员登录Web Admin
2. 查看待审核房源
3. 审核房源信息
4. 发布房源到线上
```

---

## 五、数据库验证

### 5.1 连接数据库
```bash
# 使用psql连接
psql -h localhost -U myanmar_property -d myanmar_property

# 密码: myanmar_property_2024
```

### 5.2 验证数据
```sql
-- 查看用户数量
SELECT COUNT(*) FROM users;

-- 查看房源数量
SELECT COUNT(*) FROM houses;

-- 查看经纪人数量
SELECT COUNT(*) FROM agents;

-- 查看最近登录的用户
SELECT phone, last_login_at FROM users ORDER BY last_login_at DESC LIMIT 5;
```

---

## 六、常见问题排查

### 6.1 服务启动失败

**问题**: Docker容器无法启动
**解决**:
```bash
# 清理并重启
docker-compose down
docker-compose up -d
```

### 6.2 数据库连接失败

**问题**: 后端无法连接数据库
**解决**:
1. 检查数据库容器状态: `docker-compose ps`
2. 检查端口占用: `netstat -ano | findstr 5432`
3. 重启数据库: `docker-compose restart postgres`

### 6.3 API 返回 500 错误

**排查步骤**:
1. 查看后端日志: `docker-compose logs -f api`
2. 检查数据库连接
3. 检查Redis连接

### 6.4 前端无法连接后端

**问题**: Web Admin 或 Flutter 无法调用 API
**解决**:
1. 确认后端运行在 8080 端口
2. 检查 CORS 配置
3. 检查防火墙设置

---

## 七、测试账号

### 7.1 测试用户 (C端)

| 手机号 | 类型 | 验证码 |
|--------|------|--------|
| +95111111111 | 个人用户 | 123456 |
| +95222222222 | 个人用户 | 123456 |

### 7.2 测试经纪人 (B端)

| 手机号 | 类型 | 验证码 |
|--------|------|--------|
| +95333333333 | 经纪人 | 123456 |
| +95444444444 | 经纪人 | 123456 |

### 7.3 管理后台

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | admin123 | 超级管理员 |

---

## 八、验证清单

### 8.1 后端API验证

- [ ] 健康检查接口正常
- [ ] 发送验证码接口正常
- [ ] 用户登录接口正常
- [ ] 获取用户信息接口正常
- [ ] 房源列表接口正常
- [ ] 房源详情接口正常
- [ ] 地图聚合接口正常
- [ ] 收藏房源接口正常
- [ ] 预约带看接口正常

### 8.2 前端功能验证

- [ ] Buyer App 能正常启动
- [ ] Buyer App 登录流程正常
- [ ] Buyer App 房源列表加载正常
- [ ] Buyer App 房源详情显示正常
- [ ] Agent App 能正常启动
- [ ] Agent App 经纪人登录正常
- [ ] Web Admin 能正常访问
- [ ] Web Admin 登录正常

### 8.3 数据验证

- [ ] 数据库连接正常
- [ ] 测试数据存在
- [ ] Redis 缓存正常
- [ ] Elasticsearch 索引正常

---

## 九、下一步建议

1. **完成房源模块开发** - 根据环境测试报告，房源API尚未完全实现
2. **Flutter联调** - 重点验证房源相关页面
3. **集成测试** - 模拟完整用户流程
4. **性能测试** - 检查高并发下的服务稳定性

---

**验证完成时间**: _______________
**验证人员**: _______________
**验证结果**: ⬜ 通过 / ⬜ 部分通过 / ⬜ 未通过
