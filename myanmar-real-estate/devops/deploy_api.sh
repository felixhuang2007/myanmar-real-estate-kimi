#!/bin/bash
# 后台构建脚本
LOG_FILE="/tmp/deploy_api.log"

echo "=== $(date) 开始部署 ===" >> $LOG_FILE

cd /home/ubuntu/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend

echo "停止旧容器..." >> $LOG_FILE
sudo docker-compose stop api >> $LOG_FILE 2>&1

echo "重新构建镜像..." >> $LOG_FILE
sudo docker-compose build --no-cache api >> $LOG_FILE 2>&1

echo "启动新容器..." >> $LOG_FILE
sudo docker-compose up -d api >> $LOG_FILE 2>&1

echo "等待服务启动..." >> $LOG_FILE
sleep 10

echo "检查健康状态..." >> $LOG_FILE
curl -s http://localhost:8080/health >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

echo "测试新接口..." >> $LOG_FILE
curl -s "http://localhost:8080/v1/houses?page=1&page_size=5" >> $LOG_FILE 2>&1
echo "" >> $LOG_FILE

echo "=== $(date) 部署完成 ===" >> $LOG_FILE
