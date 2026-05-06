#!/bin/bash
# Flutter Android APK Build Script for Testing
# Usage: ./build-android.sh

set -e

echo "=== Flutter Android Build Script ==="
echo "Building APKs for testing..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running in Docker
if [ -f /.dockerenv ]; then
    echo "Running inside Docker container"
    IN_DOCKER=true
else
    echo "Running on host"
    IN_DOCKER=false
fi

# Install dependencies
echo -e "${YELLOW}Step 1: Installing dependencies...${NC}"
flutter config --no-analytics
flutter pub get

# Build C端 (Buyer) APK
echo ""
echo -e "${YELLOW}Step 2: Building C端 APP (Buyer)...${NC}"
flutter build apk \
    --debug \
    --flavor buyer \
    -t lib/main_buyer.dart \
    --dart-define=API_BASE_URL=http://43.163.122.42:8080

# Build B端 (Agent) APK
echo ""
echo -e "${YELLOW}Step 3: Building B端 APP (Agent)...${NC}"
flutter build apk \
    --debug \
    --flavor agent \
    -t lib/main_agent.dart \
    --dart-define=API_BASE_URL=http://43.163.122.42:8080

# Copy to output directory with Chinese names
echo ""
echo -e "${YELLOW}Step 4: Copying APK files...${NC}"
mkdir -p build_output

cp build/app/outputs/flutter-apk/buyer-debug.apk "build_output/缅甸房产-C端-测试版.apk"
cp build/app/outputs/flutter-apk/agent-debug.apk "build_output/缅甸房产-B端-测试版.apk"

echo ""
echo -e "${GREEN}Build completed successfully!${NC}"
echo ""
echo "APK files:"
ls -lh build_output/*.apk
echo ""
echo "File sizes:"
du -h build_output/*.apk
