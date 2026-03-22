# 缅甸房产平台 - PC端测试验证方案

**文档版本**: v1.0
**适用平台**: Windows 10/11, macOS, Linux
**测试方式**: Windows桌面端 / Web端 / 模拟器

---

## 方案一: Flutter Windows桌面端 (推荐)

### 1.1 启用Windows桌面支持

```bash
cd myanmar-real-estate/flutter

# 启用Windows桌面支持
flutter config --enable-windows-desktop

# 检查环境
flutter doctor
```

### 1.2 创建Windows项目

```bash
# 如果还没有windows目录，创建它
flutter create --platforms=windows .
```

### 1.3 运行C端APP

```bash
# 运行Buyer App (C端)
flutter run -d windows -t lib/main_buyer.dart

# 或者先构建再运行
flutter build windows -t lib/main_buyer.dart
build/windows/x64/runner/Release/buyer_app.exe
```

### 1.4 运行B端APP

```bash
# 运行Agent App (B端)
flutter run -d windows -t lib/main_agent.dart

# 或者先构建再运行
flutter build windows -t lib/main_agent.dart
build/windows/x64/runner/Release/agent_app.exe
```

### 1.5 Windows端效果

- 窗口大小: 默认900x600，可调整
- 支持键盘快捷键
- 支持鼠标滚轮滚动
- 支持窗口最大化/最小化

---

## 方案二: Flutter Web端 (最方便)

### 2.1 启用Web支持

```bash
cd myanmar-real-estate/flutter

# 启用Web支持
flutter config --enable-web

# 检查是否启用
flutter devices
```

### 2.2 运行C端Web版

```bash
# 运行Buyer App (C端) - 可指定端口避免冲突
flutter run -d chrome -t lib/main_buyer.dart --web-port=8081

# 或Edge浏览器
flutter run -d edge -t lib/main_buyer.dart --web-port=8081
```

### 2.3 运行B端Web版

```bash
# 运行Agent App (B端) - 使用不同端口
flutter run -d chrome -t lib/main_agent.dart --web-port=8082
```

### 2.4 Web端特点

| 特性 | 说明 |
|------|------|
| 多开测试 | 可同时开多个浏览器窗口 |
| 分辨率切换 | Chrome DevTools模拟手机/平板 |
| 网络调试 | 直接看Network请求 |
| 控制台输出 | 方便查看日志 |

### 2.5 Chrome DevTools设置

```
1. 按F12打开DevTools
2. 点击设备模拟按钮 (Ctrl+Shift+M)
3. 选择设备:
   - iPhone 14 Pro (393x852)
   - iPad Air (820x1180)
   - 自定义尺寸: 375x812 (iPhone X)
4. 刷新页面应用设置
```

---

## 方案三: Android模拟器

### 3.1 安装Android Studio模拟器

```bash
# 打开Android Studio
# Tools > Device Manager > Create Device

# 推荐配置:
# - Phone: Pixel 7 (1080x2400)
# - System Image: Android 13.0 (API 33)
# - RAM: 4096 MB
# - VM heap: 576 MB
```

### 3.2 启动模拟器并运行APP

```bash
# 查看可用设备
flutter devices

# 示例输出:
# Windows (desktop) • windows    • windows-x64    • Microsoft Windows [Version 10.0.19044]
# Chrome (web)      • chrome     • web-javascript • Google Chrome 120.0
# Edge (web)        • edge       • web-javascript • Microsoft Edge 120.0
# sdk gphone64...   • emulator-5554  • android-arm64  • Android 13 (API 33)

# 运行C端
flutter run -d emulator-5554 -t lib/main_buyer.dart

# 运行B端
flutter run -d emulator-5554 -t lib/main_agent.dart
```

### 3.3 模拟器优势

- 最接近真机体验
- 支持GPS模拟
- 支持相机模拟
- 支持传感器模拟

---

## 方案四: Windows Subsystem for Android (WSA)

### 4.1 安装WSA

```powershell
# Windows 11用户可在Microsoft Store搜索 "Amazon Appstore"
# 或通过PowerShell安装

# 检查WSA是否安装
wsa-client --version
```

### 4.2 安装Flutter APK到WSA

```bash
# 构建APK
cd myanmar-real-estate/flutter
flutter build apk -t lib/main_buyer.dart

# 通过ADB安装到WSA
adb connect 127.0.0.1:58526
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## PC端测试对比

| 特性 | Windows桌面 | Web端 | Android模拟器 | WSA |
|------|------------|-------|--------------|-----|
| 启动速度 | ⭐⭐⭐ 快 | ⭐⭐⭐ 快 | ⭐⭐ 较慢 | ⭐⭐ 较慢 |
| 性能 | ⭐⭐⭐ 好 | ⭐⭐ 一般 | ⭐⭐⭐ 好 | ⭐⭐⭐ 好 |
| 调试便利 | ⭐⭐ 一般 | ⭐⭐⭐ 优秀 | ⭐⭐⭐ 优秀 | ⭐⭐ 一般 |
| 多开测试 | ⭐⭐ 需多实例 | ⭐⭐⭐ 优秀 | ⭐⭐ 需多模拟器 | ⭐⭐ 需多开 |
| 地图/GPS | ⭐ 不支持 | ⭐ 不支持 | ⭐⭐⭐ 支持模拟 | ⭐⭐⭐ 支持 |
| 相机 | ⭐ 不支持 | ⭐ 不支持 | ⭐⭐⭐ 支持模拟 | ⭐⭐ 部分支持 |

**推荐**:
- 快速验证UI: Web端
- 完整功能测试: Windows桌面端
- 最接近真机: Android模拟器

---

## PC端API配置

### 修改API地址

编辑 `myanmar-real-estate/flutter/lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // PC端开发使用本机IP
  static const String apiBaseUrl = 'http://192.168.1.100:8080';

  // Web端可能需要用localhost
  // static const String apiBaseUrl = 'http://localhost:8080';

  // 生产环境
  // static const String apiBaseUrl = 'https://api.myanmar-property.com';
}
```

### 获取本机IP

```bash
# Windows
ipconfig | findstr "IPv4"

# Mac
ifconfig | grep "inet " | grep -v "127.0.0.1"

# Linux
hostname -I
```

### 防火墙设置

```powershell
# Windows PowerShell 管理员模式
# 开放8080端口
netsh advfirewall firewall add rule name="Flutter Dev" dir=in action=allow protocol=tcp localport=8080

# 查看规则
netsh advfirewall firewall show rule name="Flutter Dev"
```

---

## PC端快捷测试流程

### 5分钟快速验证

```bash
# 1. 启动后端 (已启动可跳过)
cd myanmar-real-estate/backend
./server.exe

# 2. 测试后端
curl http://localhost:8080/health

# 3. 启动C端Web版 (端口8081)
cd ../flutter
flutter run -d chrome -t lib/main_buyer.dart --web-port=8081

# 4. 启动B端Web版 (端口8082) - 另开终端
flutter run -d chrome -t lib/main_agent.dart --web-port=8082
```

### 同时测试两端

```powershell
# PowerShell脚本: start_both_apps.ps1

# 启动C端
Start-Process powershell -ArgumentList "/c cd myanmar-real-estate/flutter; flutter run -d chrome -t lib/main_buyer.dart --web-port=8081"
Start-Sleep 5

# 启动B端
Start-Process powershell -ArgumentList "/c cd myanmar-real-estate/flutter; flutter run -d chrome -t lib/main_agent.dart --web-port=8082"
```

---

## PC端调试技巧

### Chrome DevTools调试

```
1. 在Chrome中打开Flutter Web App
2. 按F12打开DevTools
3. 常用功能:
   - Elements: 检查UI元素
   - Console: 查看日志输出
   - Network: 查看API请求
   - Application: 查看LocalStorage
```

### Flutter Inspector

```bash
# 运行App时添加observatory
flutter run -d chrome -t lib/main_buyer.dart --web-port=8081

# 打开Observatory URL (通常在控制台输出)
# http://127.0.0.1:8080/xxxxxxxx/
```

### VS Code调试配置

创建 `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "C端 - Chrome",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_buyer.dart",
      "args": ["-d", "chrome", "--web-port", "8081"]
    },
    {
      "name": "B端 - Chrome",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_agent.dart",
      "args": ["-d", "chrome", "--web-port", "8082"]
    },
    {
      "name": "C端 - Windows",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_buyer.dart",
      "args": ["-d", "windows"]
    },
    {
      "name": "B端 - Windows",
      "request": "launch",
      "type": "dart",
      "program": "lib/main_agent.dart",
      "args": ["-d", "windows"]
    }
  ]
}
```

---

## PC端常见问题

### Q1: Web端跨域错误

**现象**: `Access to XMLHttpRequest has been blocked by CORS policy`

**解决**:
```dart
// 后端已配置CORS，如仍有问题，检查:
// 1. 确保使用IP而非localhost
// 2. 检查后端corsMiddleware配置

// 或使用Chrome禁用安全模式(仅开发)
flutter run -d chrome --web-browser-flag="--disable-web-security"
```

### Q2: Windows桌面端窗口太小

**解决**:
```dart
// 修改 windows/runner/main_window.cpp
// 或运行时调整窗口大小

// 或在main.dart中设置最小窗口大小
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(414, 896), // iPhone尺寸
    minimumSize: Size(375, 667),
    center: true,
  );
  await windowManager.waitUntilReadyToShow(windowOptions);
  await windowManager.show();

  runApp(MyApp());
}
```

### Q3: Web端地图不显示

**原因**: Flutter Web的地图插件限制

**解决**: 使用JS Interop或更换地图方案

### Q4: Windows桌面端字体显示异常

**解决**:
```yaml
# pubspec.yaml
flutter:
  fonts:
    - family: NotoSansMyanmar
      fonts:
        - asset: assets/fonts/NotoSansMyanmar-Regular.ttf
```

---

## PC端测试清单

### 基础功能验证

- [ ] C端可以正常启动
- [ ] B端可以正常启动
- [ ] 可以同时运行两端
- [ ] 页面切换流畅
- [ ] 网络请求正常

### 业务功能验证 (C端)

- [ ] 登录页显示正常
- [ ] 可以发送验证码
- [ ] 可以登录成功
- [ ] 首页显示推荐房源
- [ ] 搜索功能可用
- [ ] 房源详情页可打开

### 业务功能验证 (B端)

- [ ] 经纪人可登录
- [ ] 工作台数据加载
- [ ] 房源列表显示
- [ ] 客户管理页面

### 兼容性验证

- [ ] Chrome浏览器正常
- [ ] Edge浏览器正常
- [ ] Firefox浏览器正常 (可选)
- [ ] 不同分辨率适配
- [ ] 窗口缩放适配

---

## 推荐开发工作流

```
1. 启动后端API (server.exe)
   ↓
2. 启动C端Web版 (端口8081)
   ↓
3. 启动B端Web版 (端口8082)
   ↓
4. Chrome DevTools调试两端
   ↓
5. 修改代码，Hot Reload自动刷新
   ↓
6. 功能验证通过后，真机测试
```

---

## 一键启动脚本

### Windows PowerShell脚本

```powershell
# save as: start_dev_env.ps1

Write-Host "========================================" -ForegroundColor Green
Write-Host "缅甸房产平台 - 开发环境启动" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 1. 检查后端
Write-Host "`n[1/4] 检查后端API..." -ForegroundColor Yellow
$health = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET -ErrorAction SilentlyContinue
if ($health.code -eq 200) {
    Write-Host "  ✅ 后端API运行中" -ForegroundColor Green
} else {
    Write-Host "  ❌ 后端API未启动，请先运行 server.exe" -ForegroundColor Red
    exit 1
}

# 2. 启动C端
Write-Host "`n[2/4] 启动C端APP..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd myanmar-real-estate/flutter; flutter run -d chrome -t lib/main_buyer.dart --web-port=8081"

# 3. 启动B端
Write-Host "`n[3/4] 启动B端APP..." -ForegroundColor Yellow
Start-Sleep 3
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd myanmar-real-estate/flutter; flutter run -d chrome -t lib/main_agent.dart --web-port=8082"

# 4. 打开管理后台
Write-Host "`n[4/4] 打开管理后台..." -ForegroundColor Yellow
Start-Process "http://localhost:8000"

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "启动完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "C端: http://localhost:8081" -ForegroundColor Cyan
Write-Host "B端: http://localhost:8082" -ForegroundColor Cyan
Write-Host "WebAdmin: http://localhost:8000" -ForegroundColor Cyan
Write-Host "API: http://localhost:8080" -ForegroundColor Cyan
```

**使用方法**:
```powershell
# 以管理员身份运行PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\start_dev_env.ps1
```

---

**Happy Testing on PC! 🖥️**
