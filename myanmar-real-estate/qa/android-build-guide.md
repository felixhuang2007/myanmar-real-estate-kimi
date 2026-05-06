# Android 测试包构建与分发指南

## 📱 测试包下载

### 方式一：直接下载（推荐）

访问以下地址下载最新测试包：

| 应用 | 下载地址 | 二维码 |
|------|----------|--------|
| **C端APP（买家）** | http://43.163.122.42:8000/downloads/缅甸房产-C端-测试版.apk | [生成中] |
| **B端APP（经纪人）** | http://43.163.122.42:8000/downloads/缅甸房产-B端-测试版.apk | [生成中] |

### 方式二：手动构建

如果在服务器上构建了APK，会保存在：
```
/tmp/flutter-build/build_output/
```

## 🔧 构建说明

### 环境要求

- Docker 20.0+
- 或 Android SDK + Flutter 3.19.0

### Docker构建（推荐）

```bash
# 1. 进入Flutter项目目录
cd /path/to/myanmar-real-estate/flutter

# 2. 使用Docker构建
docker run --rm \
  -v "$(pwd)":/app \
  -v "$(pwd)/build_output":/output \
  ghcr.io/cirruslabs/flutter:3.19.0 \
  bash -c "
    cd /app &&
    flutter pub get &&
    flutter build apk --debug --flavor buyer -t lib/main_buyer.dart --dart-define=API_BASE_URL=http://43.163.122.42:8080 &&
    flutter build apk --debug --flavor agent -t lib/main_agent.dart --dart-define=API_BASE_URL=http://43.163.122.42:8080 &&
    cp build/app/outputs/flutter-apk/buyer-debug.apk /output/缅甸房产-C端-测试版.apk &&
    cp build/app/outputs/flutter-apk/agent-debug.apk /output/缅甸房产-B端-测试版.apk
  "

# 3. 查看输出
ls -la build_output/
```

### 本地构建

```bash
# 1. 确保已安装 Flutter 3.19.0 和 Android SDK
cd myanmar-real-estate/flutter

# 2. 获取依赖
flutter pub get

# 3. 构建C端APK
flutter build apk \
  --debug \
  --flavor buyer \
  -t lib/main_buyer.dart \
  --dart-define=API_BASE_URL=http://43.163.122.42:8080

# 4. 构建B端APK
flutter build apk \
  --debug \
  --flavor agent \
  -t lib/main_agent.dart \
  --dart-define=API_BASE_URL=http://43.163.122.42:8080

# 5. 输出文件位置
# build/app/outputs/flutter-apk/buyer-debug.apk
# build/app/outputs/flutter-apk/agent-debug.apk
```

## 📋 安装说明

### Android设备安装步骤

1. **允许未知来源安装**
   - 设置 → 安全 → 允许安装未知来源应用
   - 或点击APK时按提示开启

2. **下载APK文件**
   - 使用手机浏览器访问下载链接
   - 或使用二维码扫描下载

3. **安装应用**
   - 下载完成后点击通知栏的下载完成提示
   - 或在文件管理器中找到APK文件点击安装

### 系统要求

| 项目 | 要求 |
|------|------|
| Android版本 | 7.0 (API 24) 及以上 |
| 存储空间 | 至少100MB可用空间 |
| 网络 | 需要联网访问测试服务器 |

## 🔑 测试账号

### C端APP（买家）
- 手机号：`+959999999999`
- 验证码：`123456`（测试环境固定）

### B端APP（经纪人）
- 手机号：`+959888888888`
- 验证码：`123456`

## 🐛 常见问题

### 1. 安装失败
- **原因**：Android版本过低
- **解决**：确保Android 7.0及以上

### 2. 无法连接服务器
- **原因**：网络问题或服务器未启动
- **解决**：检查 http://43.163.122.42:8080/health 是否可访问

### 3. 验证码收不到
- **原因**：测试环境使用固定验证码
- **解决**：直接输入 `123456`

## 📞 技术支持

如遇问题，请联系开发团队或提交Issue。
