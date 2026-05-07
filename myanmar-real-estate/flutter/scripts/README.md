# 缅甸房产 Flutter APP - 构建脚本使用指南

## 环境要求

- Windows 10/11
- Flutter 3.19.0+
- Android SDK (platform-tools, build-tools)
- 已配置环境变量: ANDROID_HOME, PATH (含 adb)
- USB 调试已开启的 Android 手机（用于真机测试）

## 脚本说明

### 1. build-apk.bat - 一键构建 APK

```cmd
scripts\build-apk.bat [buyer|agent] [debug|release]
```

示例:
```cmd
# 构建 C 端 debug 版本（默认）
scripts\build-apk.bat

# 构建 C 端 release 版本
scripts\build-apk.bat buyer release

# 构建 B 端 debug 版本
scripts\build-apk.bat agent debug
```

输出: `build\outputs\YYYYMMDD_HHMMSS\缅甸房产-XX端-X版-TIMESTAMP.apk`

### 2. adb-install.bat - 安装到手机

```cmd
scripts\adb-install.bat [APK文件路径]
```

示例:
```cmd
# 安装最新的构建产物
scripts\adb-install.bat

# 安装指定 APK
scripts\adb-install.bat build\outputs\xxx\缅甸房产-C端-debug-xxx.apk
```

### 3. deploy-apk.bat - 上传到远程服务器

```cmd
scripts\deploy-apk.bat [APK文件路径]
```

上传后可在 http://43.163.122.42/downloads/ 下载

### 4. ci-build.bat - 完整 CI 流程

```cmd
scripts\ci-build.bat [buyer|agent] [debug|release]
```

流程: API测试 → 构建 → 安装到手机 → 上传到服务器 → 收集日志

### 5. adb-logcat.bat - 收集崩溃日志

```cmd
scripts\adb-logcat.bat [输出文件名]
```

运行后复现闪退问题，按任意键收集日志。

## 常用工作流

### 开发调试流程
```cmd
# 1. 连接手机，直接运行（支持热重载）
flutter run --flavor buyer -t lib/main_buyer.dart

# 2. 修改代码，保存后自动热重载
# 3. 按 r 热重载，按 R 热重启，按 q 退出
```

### 构建测试流程
```cmd
# 1. 一键构建
scripts\build-apk.bat buyer debug

# 2. 安装到手机
scripts\adb-install.bat

# 3. 如果闪退，收集日志
scripts\adb-logcat.bat
```

### 完整发布流程
```cmd
# 1. 运行完整 CI
scripts\ci-build.bat buyer release

# 2. APK 已自动上传到服务器
# 3. 访问 http://43.163.122.42/downloads/ 下载
```

## 手机连接检查

```cmd
# 查看已连接设备
adb devices

# 预期输出:
# List of devices attached
# xxxxxxxx    device
```

如果未显示设备，请检查:
1. USB 线是否连接正常
2. 手机是否开启 USB 调试
3. 是否允许电脑调试授权（手机弹窗）
