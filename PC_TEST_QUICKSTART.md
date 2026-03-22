# PC端测试 - 快速开始

## 方式一: 双击启动 (最简单)

```bash
# 1. 确保后端已启动
myanmar-real-estate/backend/server.exe

# 2. 双击运行
start_pc_test.bat

# 3. 等待Chrome自动打开两个窗口
```

## 方式二: 命令行启动

```bash
# 终端1: 启动后端
cd myanmar-real-estate/backend
./server.exe

# 终端2: 启动C端
cd myanmar-real-estate/flutter
flutter run -d chrome -t lib/main_buyer.dart --web-port=8081

# 终端3: 启动B端
cd myanmar-real-estate/flutter
flutter run -d chrome -t lib/main_agent.dart --web-port=8082
```

## 方式三: Windows桌面端

```bash
cd myanmar-real-estate/flutter

# 启用Windows支持 (首次)
flutter config --enable-windows-desktop

# 运行C端
flutter run -d windows -t lib/main_buyer.dart

# 运行B端
flutter run -d windows -t lib/main_agent.dart
```

---

## 验证步骤

### 1. 检查服务状态

打开浏览器访问:
- http://localhost:8080/health - 后端API
- http://localhost:8000 - 管理后台
- http://localhost:8081 - C端APP
- http://localhost:8082 - B端APP

### 2. C端功能验证

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 打开 http://localhost:8081 | 看到启动页/登录页 |
| 2 | 输入 +95111111111 | 手机号显示正确 |
| 3 | 点击"获取验证码" | 按钮开始倒计时 |
| 4 | 输入收到的验证码 | 验证码输入成功 |
| 5 | 点击"登录" | 跳转到首页 |
| 6 | 查看首页 | 看到房源列表 |

### 3. B端功能验证

| 步骤 | 操作 | 预期结果 |
|------|------|----------|
| 1 | 打开 http://localhost:8082 | 看到登录页 |
| 2 | 输入 +95333333333 | 手机号显示正确 |
| 3 | 获取验证码并登录 | 跳转到工作台 |
| 4 | 查看工作台 | 看到数据概览 |

---

## Chrome DevTools调试

### 模拟手机尺寸

```
1. 按 F12 打开开发者工具
2. 按 Ctrl+Shift+M (或点击设备图标)
3. 选择设备:
   - iPhone 12 Pro (390x844)
   - iPhone SE (375x667)
   - iPad (768x1024)
4. 刷新页面
```

### 查看网络请求

```
1. 按 F12 打开开发者工具
2. 切换到 Network 标签
3. 选择 XHR/Fetch
4. 操作APP，查看API调用
```

---

## 常见问题

### 端口被占用

```bash
# 查看占用8081端口的进程
netstat -ano | findstr 8081

# 使用其他端口启动
flutter run -d chrome -t lib/main_buyer.dart --web-port=8083
```

### 跨域错误

**现象**: 登录时提示CORS错误
**解决**:
1. 确保API配置使用本机IP而非localhost
2. 检查后端服务是否正常

### Flutter命令找不到

```bash
# 确保Flutter在PATH中
flutter doctor

# 如果未安装，下载地址:
# https://docs.flutter.dev/get-started/install
```

---

## 测试账号

| 角色 | 手机号 | 验证码 |
|------|--------|--------|
| C端买家 | +95111111111 | 动态生成 |
| C端买家 | +95222222222 | 动态生成 |
| B端经纪人 | +95333333333 | 动态生成 |
| B端经纪人 | +95444444444 | 动态生成 |

---

## 快速测试命令

```bash
# 检查后端
curl http://localhost:8080/health

# 发送验证码
curl -X POST http://localhost:8080/v1/auth/send-verification-code \
  -H "Content-Type: application/json" \
  -d '{"phone": "+95111111111", "type": "login"}'

# 登录
curl -X POST http://localhost:8080/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+95111111111", "code": "验证码", "device_id": "test"}'
```

---

**开始测试吧! 🚀**
