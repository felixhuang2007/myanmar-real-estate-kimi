#!/bin/bash
# 缅甸房产平台 - 快速启动脚本

echo "================================"
echo "缅甸房产平台 - 启动脚本"
echo "================================"
echo ""

# 设置 PATH
export PATH="$PATH:/c/Program Files/Go/bin:$HOME/flutter/bin"

cd "$(dirname "$0")"

# 检查 Docker
if ! docker ps &>/dev/null; then
    echo "⚠️  Docker 未启动，请先启动 Docker Desktop"
    echo "   然后重新运行此脚本"
    exit 1
fi

# 启动 Docker 依赖
echo "📦 启动 Docker 依赖..."
cd backend
docker-compose up -d
cd ..

# 等待服务启动
sleep 5

# 启动后端服务
echo "🚀 启动后端服务..."
cd backend
./server.exe &
BACKEND_PID=$!
echo "   后端 PID: $BACKEND_PID"
cd ..

# 启动 Web Admin
echo "🌐 启动 Web Admin..."
cd frontend/web-admin
npm run dev &
WEB_PID=$!
echo "   Web Admin PID: $WEB_PID"
cd ../..

echo ""
echo "================================"
echo "✅ 服务已启动:"
echo "   后端 API:  http://localhost:8080"
echo "   管理后台:  http://localhost:8000"
echo "================================"
echo ""
echo "按回车键停止所有服务..."
read

# 停止服务
kill $BACKEND_PID 2>/dev/null
kill $WEB_PID 2>/dev/null
docker-compose -f backend/docker-compose.yml down

echo "服务已停止"
