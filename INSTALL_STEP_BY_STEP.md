# 手把手安装教程

> 按照本教程一步一步操作，预计需要 30-45 分钟

---

## 第一步：安装 Java JDK（5分钟）

### 1.1 下载
打开浏览器，访问：
```
https://learn.microsoft.com/java/openjdk/download
```

找到 **Microsoft Build of OpenJDK 17** → 下载 **Windows x64 .msi** 版本

### 1.2 安装
1. 双击下载的 `.msi` 文件
2. 点击 "Next" → "Next" → "Install"
3. 等待安装完成，点击 "Finish"

### 1.3 验证
打开 PowerShell（按 `Win + X`，选择 "终端" 或 "PowerShell"），输入：
```powershell
java -version
```
应该显示类似：
```
openjdk version "17.0.9" 2023-10-17 LTS
```

---

## 第二步：安装 Flutter SDK（5分钟）

### 2.1 下载
打开浏览器，访问：
```
https://docs.flutter.dev/release/archive?tab=windows
```

找到 **Stable channel (Windows)** → 下载 **3.19.0** 或最新版本

### 2.2 解压
1. 打开下载的 `flutter_windows_3.19.0-stable.zip`
2. 解压到 `C:\Development\flutter`
   - 如果没有 `C:\Development` 文件夹，先创建它

### 2.3 配置环境变量
1. 按 `Win + S` 搜索 "环境变量"
2. 点击 "编辑系统环境变量"
3. 点击 "环境变量" 按钮
4. 在"用户变量"中找到 `Path`，双击编辑
5. 点击 "新建"，输入：`C:\Development\flutter\bin`
6. 点击 "确定" 保存（需要点击 3 次确定）

### 2.4 验证
**关闭并重新打开** PowerShell，输入：
```powershell
flutter --version
```
应该显示：
```
Flutter 3.19.0 • channel stable
```

---

## 第三步：安装 Android Studio（15分钟）

### 3.1 下载
打开浏览器，访问：
```
https://developer.android.com/studio
```

点击绿色 "Download Android Studio" 按钮下载

### 3.2 安装
1. 双击下载的安装程序
2. 点击 "Next" → "Next" → "Install"
3. 安装完成后，勾选 "Start Android Studio"
4. 点击 "Finish"

### 3.3 首次配置
1. 选择 "Do not import settings" → "OK"
2. 选择 "Standard" → "Next"
3. 选择主题（Darcula 或 Light）→ "Next"
4. 验证设置 → "Next"
5. 接受所有许可协议：
   - 点击 "Accept"
   - 点击左侧第二个许可 → "Accept"
   - 点击 "Finish"
6. 等待下载组件（约 10-15 分钟，取决于网速）

### 3.4 创建模拟器
1. Android Studio 启动后，点击 "More Actions" → "Virtual Device Manager"
2. 点击 "Create Device"
3. 选择 "Phone" → "Pixel 6" → "Next"
4. 下载系统镜像：
   - 找到 "Android 14.0 (API 34)"
   - 点击 "Download"
   - 等待下载完成 → "Finish"
5. 选择 "Android 14.0" → "Next"
6. 点击 "Finish" 创建模拟器

### 3.5 启动模拟器
在 Virtual Device Manager 中，点击 Pixel 6 旁边的 "启动" 按钮（▶）

等待模拟器启动（首次启动可能需要 5-10 分钟）

---

## 第四步：配置 Flutter（5分钟）

### 4.1 运行 Flutter Doctor
打开 PowerShell，输入：
```powershell
flutter doctor
```

### 4.2 解决常见问题

**问题1：Android SDK 未找到**
```powershell
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk"
```

**问题2：Android Studio 路径未设置**
```powershell
flutter config --android-studio-dir "C:\Program Files\Android\Android Studio"
```

**问题3：缺少 Android SDK Command-line Tools**
1. 打开 Android Studio
2. 点击 "Tools" → "SDK Manager"
3. 切换到 "SDK Tools" 标签
4. 勾选 "Android SDK Command-line Tools (latest)"
5. 点击 "Apply" → "OK"

**问题4：接受 Android 许可**
```powershell
flutter doctor --android-licenses
```
输入 `y` 接受所有许可

### 4.3 再次验证
```powershell
flutter doctor
```
确保所有都是 [✓] 绿色勾

---

## 第五步：运行项目（5分钟）

### 5.1 打开项目
打开 PowerShell，输入：
```powershell
cd D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter
```

### 5.2 获取依赖
```powershell
flutter pub get
```

### 5.3 确保模拟器已启动
检查 Android Studio 中的模拟器是否正在运行

### 5.4 运行买家 APP
```powershell
flutter run -t lib/main_buyer.dart
```

等待编译（首次需要 5-10 分钟），APP 会自动安装到模拟器

### 5.5 运行经纪人 APP（另一个终端）
新开一个 PowerShell 窗口：
```powershell
cd D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter
flutter run -t lib/main_agent.dart
```

---

## 故障排查

### 模拟器无法启动
**解决**：
1. 重启电脑
2. 进入 BIOS 开启虚拟化（Intel VT-x 或 AMD-V）
3. 关闭 Windows Hyper-V：
   - 控制面板 → 程序 → 启用或关闭 Windows 功能
   - 取消勾选 "Hyper-V"
   - 重启电脑

### 编译报错 "Connection refused"
**解决**：
确保后端服务已启动：
```powershell
cd D:\work\myanmar-real-estate-kimi\myanmar-real-estate\backend
.\server.exe
```

### Flutter 命令无法识别
**解决**：
1. 检查环境变量是否正确添加
2. **重新打开** PowerShell（必须关闭再开）
3. 输入 `flutter --version` 验证

---

## 快速检查清单

完成安装后，请确认：

- [ ] `java -version` 显示版本 17
- [ ] `flutter --version` 显示版本 3.19+
- [ ] `flutter doctor` 无错误 [!]
- [ ] Android Studio 能启动模拟器
- [ ] `flutter pub get` 成功
- [ ] 买家 APP 能在模拟器运行

---

## 需要帮助？

如果在任何步骤遇到问题：

1. **截图错误信息**
2. **告诉我是哪一步**
3. **提供完整的错误日志**

我可以帮您进一步排查。
