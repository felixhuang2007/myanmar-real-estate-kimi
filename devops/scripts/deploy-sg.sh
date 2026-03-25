#!/bin/bash
set -e

PROJECT_DIR="/home/ubuntu/myanmarestate/myanmar-real-estate-kimi"
BACKEND_DIR="$PROJECT_DIR/myanmar-real-estate/backend"
ENV_FILE="$BACKEND_DIR/.env.prod"

echo "=== Deploy: Myanmar RE Platform ==="

# 拉取最新代码
cd "$PROJECT_DIR"
git pull origin master

# 检查 .env.prod 是否存在
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found."
  echo "Copy .env.prod.example to .env.prod and fill in real passwords."
  exit 1
fi

# 进入 backend 目录（docker-compose 上下文）
cd "$BACKEND_DIR"

# 构建并启动（--env-file 加载密码）
docker-compose -f docker-compose.prod.yml --env-file .env.prod build --no-cache
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

# 等待健康检查
echo "Waiting for services..."
sleep 15

# 验证
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/health)
if [ "$STATUS" = "200" ]; then
  echo "=== Deploy SUCCESS: API healthy (HTTP 200) ==="
else
  echo "WARNING: /health returned HTTP $STATUS. Check logs:"
  echo "  docker-compose -f docker-compose.prod.yml logs api"
fi

# 清理旧镜像
docker image prune -f

echo "=== Done ==="
echo "  Web Admin: http://$(curl -s ifconfig.me)/"
echo "  API:       http://$(curl -s ifconfig.me)/api/"
