#!/bin/bash
# 缅甸房产平台 - Android APK构建脚本（服务器端执行）
# 执行方式: ssh ubuntu@43.163.122.42 'bash -s' < build-apk-on-server.sh

set -e

echo "========================================"
echo "  缅甸房产平台 - Android APK构建"
echo "========================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 工作目录
WORK_DIR="/tmp/flutter-build-$$"
APK_OUTPUT="/var/www/downloads"
PROJECT_DIR="/home/ubuntu/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/flutter"

echo -e "${YELLOW}[1/6] 准备工作目录...${NC}"
mkdir -p "$WORK_DIR"
mkdir -p "$APK_OUTPUT"
cd "$WORK_DIR"

echo -e "${YELLOW}[2/6] 检查Flutter环境...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}Flutter未安装，尝试使用Docker构建...${NC}"
    USE_DOCKER=true
else
    echo "Flutter版本: $(flutter --version | head -1)"
    USE_DOCKER=false
fi

echo -e "${YELLOW}[3/6] 复制项目文件...${NC}"
if [ -d "$PROJECT_DIR" ]; then
    cp -r "$PROJECT_DIR"/* .
    echo "项目文件已复制"
else
    echo -e "${RED}错误: 项目目录不存在 $PROJECT_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}[4/6] 安装依赖...${NC}"
if [ "$USE_DOCKER" = true ]; then
    # 使用Docker构建
    echo "使用Docker镜像: cirrusci/flutter:3.19.0"

    # 创建Docker构建脚本
    cat > docker-build.sh << 'DOCKEREOF'
#!/bin/bash
cd /app
flutter config --no-analytics
flutter pub get

# 构建C端APK
echo "构建C端APK..."
flutter build apk \
    --debug \
    --flavor buyer \
    -t lib/main_buyer.dart \
    --dart-define=API_BASE_URL=http://43.163.122.42:8080

# 构建B端APK
echo "构建B端APK..."
flutter build apk \
    --debug \
    --flavor agent \
    -t lib/main_agent.dart \
    --dart-define=API_BASE_URL=http://43.163.122.42:8080

# 复制输出
cp build/app/outputs/flutter-apk/buyer-debug.apk /output/缅甸房产-C端-测试版.apk
cp build/app/outputs/flutter-apk/agent-debug.apk /output/缅甸房产-B端-测试版.apk
echo "构建完成!"
DOCKEREOF
    chmod +x docker-build.sh

    # 运行Docker构建
    docker run --rm \
        -v "$(pwd):/app" \
        -v "$APK_OUTPUT:/output" \
        cirrusci/flutter:3.19.0 \
        bash /app/docker-build.sh
else
    # 使用本地Flutter构建
    flutter config --no-analytics
    flutter pub get

    echo -e "${YELLOW}[5/6] 构建C端APK (买家版)...${NC}"
    flutter build apk \
        --debug \
        --flavor buyer \
        -t lib/main_buyer.dart \
        --dart-define=API_BASE_URL=http://43.163.122.42:8080

    echo -e "${YELLOW}[6/6] 构建B端APK (经纪人版)...${NC}"
    flutter build apk \
        --debug \
        --flavor agent \
        -t lib/main_agent.dart \
        --dart-define=API_BASE_URL=http://43.163.122.42:8080

    # 复制到输出目录
    cp build/app/outputs/flutter-apk/buyer-debug.apk "$APK_OUTPUT/缅甸房产-C端-测试版.apk"
    cp build/app/outputs/flutter-apk/agent-debug.apk "$APK_OUTPUT/缅甸房产-B端-测试版.apk"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  APK构建完成!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "输出文件:"
ls -lh "$APK_OUTPUT"/*.apk 2>/dev/null || ls -lh "$APK_OUTPUT/"
echo ""
echo "下载地址:"
echo "  C端APP: http://43.163.122.42:8000/downloads/缅甸房产-C端-测试版.apk"
echo "  B端APP: http://43.163.122.42:8000/downloads/缅甸房产-B端-测试版.apk"
echo ""

# 清理
cd /
rm -rf "$WORK_DIR"

echo "完成!"
