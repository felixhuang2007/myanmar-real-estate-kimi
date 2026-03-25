#!/bin/bash
set -e

PROJECT_DIR="/home/ubuntu/myanmarestate/myanmar-real-estate-kimi"
BACKEND_DIR="$PROJECT_DIR/myanmar-real-estate/backend"
ENV_FILE="$BACKEND_DIR/.env.prod"

echo "=== Deploy: Myanmar RE Platform (Low Memory Mode) ==="

# 拉取最新代码
cd "$PROJECT_DIR"
git pull origin master

# 检查 .env.prod 是否存在
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found."
  echo "Copy .env.prod.example to .env.prod and fill in real passwords."
  exit 1
fi

# 检查内存
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
echo "Detected memory: ${TOTAL_MEM}MB"

if [ "$TOTAL_MEM" -lt 2500 ]; then
  echo "Using low-memory configuration (no Elasticsearch)"
  COMPOSE_FILE="docker-compose.lowmem.yml"
else
  echo "Using standard configuration"
  COMPOSE_FILE="docker-compose.prod.yml"
fi

# 进入 backend 目录
cd "$BACKEND_DIR"

# 构建并启动
docker-compose -f "$COMPOSE_FILE" --env-file .env.prod build --no-cache
docker-compose -f "$COMPOSE_FILE" --env-file .env.prod up -d

# 等待健康检查
echo "Waiting for services..."
sleep 15

# 验证
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:80/health || echo "000")
if [ "$STATUS" = "200" ]; then
  echo "=== Deploy SUCCESS: API healthy (HTTP 200) ==="
else
  echo "WARNING: /health returned HTTP $STATUS. Check logs:"
  echo "  docker-compose -f $COMPOSE_FILE logs api"
fi

# 清理旧镜像
docker image prune -f

echo "=== Done ==="
echo "  Web Admin: http://$(curl -s ifconfig.me 2>/dev/null || echo '<服务器IP>')/"
echo "  API:       http://$(curl -s ifconfig.me 2>/dev/null || echo '<服务器IP>')/api/"
if [ "$COMPOSE_FILE" = "docker-compose.lowmem.yml" ]; then
  echo "  NOTE: Running in low-memory mode (Elasticsearch disabled)"
fi
