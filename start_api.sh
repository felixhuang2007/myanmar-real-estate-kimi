cd ~/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend

# 直接使用新镜像启动API容器
sudo docker run -d \
  --name myanmar-property-api \
  -p 8080:8080 \
  -e DB_HOST=myanmar-property-db \
  -e DB_PORT=5432 \
  -e DB_USER=myanmar_property \
  -e DB_PASSWORD=myanmar_property_2024 \
  -e DB_NAME=myanmar_property \
  -e REDIS_HOST=myanmar-property-redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=myanmar_redis_2024 \
  -e JWT_SECRET=your-secret-key-here-for-jwt-signing \
  -e SERVER_PORT=8080 \
  -e SERVER_MODE=release \
  -v ~/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend/logs:/app/logs \
  --network backend_myanmar-network \
  --restart unless-stopped \
  backend-api:latest

echo "API容器启动完成"
sleep 3
sudo docker ps | grep api
