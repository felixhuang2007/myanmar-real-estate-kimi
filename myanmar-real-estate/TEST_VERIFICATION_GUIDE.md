# 缅甸房产平台 - 测试环境验证指南

## 📱 本地验证方式

### 方式一：Flutter APP 本地运行验证

#### 1. 环境准备
```bash
# 安装 Flutter (如未安装)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# 验证安装
flutter doctor

# 启用 Web 支持
flutter config --enable-web
```

#### 2. 启动 C端APP (Buyer)
```bash
cd /path/to/myanmar-real-estate/flutter

# 获取依赖
flutter pub get

# 运行 Web 版本 (浏览器预览)
flutter run -d chrome -t lib/main_buyer.dart

# 或构建 Web 版本
flutter build web -t lib/main_buyer.dart

# 然后使用 Python 启动本地服务器预览
cd build/web
python3 -m http.server 8080
# 浏览器访问: http://localhost:8080
```

#### 3. 启动 B端APP (Agent)
```bash
cd /path/to/myanmar-real-estate/flutter

# 运行 Web 版本
flutter run -d chrome -t lib/main_agent.dart

# 或构建后预览
flutter build web -t lib/main_agent.dart
```

#### 4. 真机调试 (Android)
```bash
# 连接手机，开启USB调试
flutter devices

# 运行到手机
flutter run -d <device_id> -t lib/main_buyer.dart
```

#### 5. 真机调试 (iOS - 需要Mac)
```bash
# 连接iPhone
flutter run -d ios -t lib/main_buyer.dart
```

---

### 方式二：Web 管理后台验证

#### 1. 环境准备
```bash
# 安装 Node.js (v18+)
node --version

# 安装依赖
cd /path/to/myanmar-real-estate/frontend/web-admin
npm install

# 启动开发服务器
npm run dev
# 默认访问: http://localhost:8000
```

#### 2. 登录验证
- 打开浏览器访问 `http://localhost:8000`
- 使用测试账号登录:
  - 用户名: `admin`
  - 密码: `test123`

---

### 方式三：后端 API 验证

#### 1. 启动后端服务 (Docker方式)
```bash
cd /path/to/myanmar-real-estate/backend

# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

#### 2. 启动后端服务 (本地方式)
```bash
cd /path/to/myanmar-real-estate/backend

# 安装 Go (v1.21+)
go version

# 安装依赖
go mod tidy

# 运行服务
go run cmd/server/main.go

# 服务默认运行在 http://localhost:8080
```

#### 3. API 验证 (使用 curl)
```bash
# 1. 健康检查
curl http://localhost:8080/health

# 2. 用户注册
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"+959123456789","password":"test123","code":"123456"}'

# 3. 用户登录
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+959123456789","password":"test123"}'

# 4. 获取房源列表 (无需认证)
curl http://localhost:8080/api/v1/houses?page=1&page_size=10

# 5. 获取城市列表
curl http://localhost:8080/api/v1/cities
```

#### 4. API 验证 (使用 Postman)
1. 导入 API 文档: `backend/02-api-spec.md`
2. 设置环境变量:
   - `base_url`: `http://localhost:8080`
   - `token`: (登录后获取)
3. 按顺序执行接口测试

---

## 🧪 验证清单

### C端APP (Buyer) 功能验证

#### 首页
- [ ] 页面加载正常，无报错
- [ ] 定位显示正确 (仰光/曼德勒等)
- [ ] Banner轮播正常
- [ ] 快捷入口点击跳转正常
- [ ] 房源列表加载
- [ ] 下拉刷新功能
- [ ] 上拉加载更多

#### 搜索
- [ ] 搜索框输入正常
- [ ] 历史搜索显示
- [ ] 热门搜索标签点击
- [ ] 价格筛选正常
- [ ] 户型筛选正常
- [ ] 搜索结果列表

#### 房源详情
- [ ] 图片轮播正常
- [ ] 验真标识显示
- [ ] 价格/面积/户型信息正确
- [ ] 经纪人信息展示
- [ ] 收藏功能
- [ ] 在线咨询入口
- [ ] 预约带看入口

#### 地图找房
- [ ] 地图加载正常
- [ ] 定位当前位置
- [ ] 房源标记显示
- [ ] 聚合效果正常
- [ ] 点击标记查看详情

#### 个人中心
- [ ] 用户信息展示
- [ ] 我的收藏列表
- [ ] 预约记录
- [ ] 浏览历史
- [ ] 设置页面

#### IM聊天
- [ ] 会话列表
- [ ] 发送文本消息
- [ ] 接收消息
- [ ] 图片消息

### B端APP (Agent) 功能验证

#### 工作台
- [ ] 今日带看数量
- [ ] 待处理任务数
- [ ] 本月业绩统计
- [ ] 快捷入口点击

#### 极速录房
- [ ] 表单字段完整
- [ ] 图片上传功能
- [ ] 地图选点
- [ ] 提交审核

#### 房源管理
- [ ] 房源列表
- [ ] 状态筛选
- [ ] 编辑房源
- [ ] 下架房源

#### 验真任务
- [ ] 任务列表
- [ ] 领取任务
- [ ] 验真表单
- [ ] 照片上传

#### 客户管理
- [ ] 客户列表
- [ ] 新增客户
- [ ] 跟进记录
- [ ] 客户需求标签

#### 带看管理
- [ ] 日程展示
- [ ] 确认带看
- [ ] 完成带看
- [ ] 带看反馈

#### ACN协作
- [ ] 成交申报
- [ ] 分佣比例显示
- [ ] 合作方确认
- [ ] 业绩统计

### Web 管理后台验证

#### 登录
- [ ] 管理员登录
- [ ] 记住密码
- [ ] 权限控制

#### 数据大屏
- [ ] 核心指标展示
- [ ] 趋势图表
- [ ] 实时数据更新

#### 房源管理
- [ ] 房源列表
- [ ] 房源审核
- [ ] 验真管理

#### 用户管理
- [ ] C端用户列表
- [ ] 经纪人管理
- [ ] 实名认证审核

#### 财务结算
- [ ] 佣金结算
- [ ] 提现审核
- [ ] 财务报表

---

## 🔧 常见问题排查

### Flutter 问题

#### 1. 依赖下载失败
```bash
# 切换 Flutter 镜像
flutter config --enable-web
flutter pub get

# 如失败，手动编辑 pubspec.yaml 使用国内镜像
```

#### 2. 编译错误
```bash
# 清理缓存
flutter clean
flutter pub get
flutter run
```

#### 3. 热重载失效
```bash
# 按 R 强制热重启
# 或停止后重新运行
```

### 后端问题

#### 1. 数据库连接失败
```bash
# 检查 PostgreSQL 是否启动
docker-compose ps

# 检查连接配置
cat config.yaml

# 重新初始化数据库
docker-compose down -v
docker-compose up -d
```

#### 2. 端口被占用
```bash
# 查找占用进程
lsof -ti:8080

# 杀死进程
kill -9 <PID>

# 或使用其他端口
go run cmd/server/main.go -port 8081
```

#### 3. JWT 认证失败
```bash
# 检查 Token 是否过期
# 重新登录获取新 Token
```

---

## 📊 测试数据

### 测试账号

| 角色 | 手机号 | 密码 | 说明 |
|------|--------|------|------|
| 购房者 | +959123456789 | test123 | 普通C端用户 |
| 购房者 | +959123456790 | test123 | 备用账号 |
| 经纪人 | +959123456791 | test123 | 张经纪，金牌经纪人 |
| 经纪人 | +959123456792 | test123 | 李经纪 |
| 管理员 | admin | test123 | Web后台管理员 |

### 测试房源数据

| 房源 | 价格 | 位置 | 户型 | 状态 |
|------|------|------|------|------|
| 仰光豪华公寓 | 4.5亿 MMK | 仰光市中心 | 3室2厅 | 在售 |
| 曼德勒新城别墅 | 2.8亿 MMK | 曼德勒新城 | 4室3厅 | 在售 |
| 班莱镇区别墅 | 3.2亿 MMK | 班莱镇区 | 4室2厅 | 已验真 |

---

## 🌐 浏览器验证方式

如无法运行 Flutter，可使用浏览器验证 Web 版本：

### 1. 打开浏览器开发者工具
- Chrome: F12 或右键 → 检查
- 切换到手机模拟器模式 (Device Toolbar)
- 选择 iPhone 12 Pro (390x844) 或 iPhone SE (375x667)

### 2. 访问 Web 版本
```
http://localhost:8080  (Flutter Web)
http://localhost:8000  (Web Admin)
http://localhost:8080  (Backend API)
```

### 3. 验证响应式布局
- 切换不同设备尺寸
- 检查布局适配
- 验证触摸事件

---

## 📞 问题反馈

如遇到无法解决的问题，请提供以下信息：
1. 错误截图
2. 终端报错日志
3. 操作步骤
4. 环境信息 (OS, Flutter/Go版本)

---

**验证完成标准**: 
- ✅ C端APP 13个页面功能正常
- ✅ B端APP 10个页面功能正常
- ✅ Web后台 17个页面功能正常
- ✅ 后端API 42个接口测试通过
- ✅ 无致命Bug，一般Bug少于5个
