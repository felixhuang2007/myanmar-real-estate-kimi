#!/bin/bash
set -e

echo "=== 同步最新代码并重新部署 ==="

PROJECT_DIR="/home/ubuntu/myanmarestate/myanmar-real-estate-kimi"
BACKEND_DIR="$PROJECT_DIR/myanmar-real-estate/backend"
ENV_FILE="$BACKEND_DIR/.env.prod"

cd "$PROJECT_DIR"

echo "1. 丢弃本地修改（Dockerfile 等）..."
git checkout -- myanmar-real-estate/frontend/web-admin/Dockerfile
git checkout -- myanmar-real-estate/backend/08-Dockerfile

echo "2. 拉取最新代码..."
git pull origin master

echo "3. 验证 Dockerfile 内容..."
echo "--- web-admin Dockerfile ---"
head -10 myanmar-real-estate/frontend/web-admin/Dockerfile

echo ""
echo "4. 检查 .env.prod..."
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE 不存在"
  echo "请先创建 .env.prod 文件"
  exit 1
fi

echo "5. 重新部署..."
cd "$BACKEND_DIR"
docker-compose -f docker-compose.prod.yml --env-file .env.prod build --no-cache web-admin
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

echo ""
echo "=== 部署完成，检查状态 ==="
docker-compose -f docker-compose.prod.yml ps
