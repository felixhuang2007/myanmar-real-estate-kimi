#!/bin/bash
# 部署脚本 - 缅甸房产平台API

echo "=== 缅甸房产平台API部署 ==="

cd /opt/myanmar-real-estate-kimi || {
    echo "错误: 无法进入项目目录"
    exit 1
}

echo "[1/5] 拉取最新代码..."
git pull origin master
if [ $? -ne 0 ]; then
    echo "错误: 拉取代码失败"
    exit 1
fi

echo ""
echo "[2/5] 检查当前服务状态..."
docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "[3/5] 重启API服务..."
cd myanmar-real-estate/backend
docker-compose restart api
if [ $? -ne 0 ]; then
    echo "错误: 重启服务失败"
    exit 1
fi

echo ""
echo "[4/5] 等待服务启动..."
sleep 8

echo ""
echo "[5/5] 验证服务..."
echo "- 健康检查:"
curl -s http://localhost:8080/health | head -c 200
echo ""
echo ""
echo "- 房源列表API:"
curl -s "http://localhost:8080/v1/houses?page=1&page_size=5" | head -c 200
echo ""
echo ""
echo "- 用户详情API:"
curl -s "http://localhost:8080/v1/users/1" | head -c 200
echo ""

echo ""
echo "=== 部署完成 ==="
