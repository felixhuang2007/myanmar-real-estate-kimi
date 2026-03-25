#!/bin/bash
set -e

echo "=== Myanmar RE Platform - Server Init (Tencent Cloud SG) ==="

# 更新系统
apt-get update && apt-get upgrade -y

# 安装 Docker
curl -fsSL https://get.docker.com | sh
systemctl enable docker && systemctl start docker

# 安装 Docker Compose v2
COMPOSE_VERSION="v2.24.5"
curl -SL "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# 防火墙（UFW）
ufw allow 22/tcp
ufw allow 80/tcp
ufw --force enable

# 内核调优（ElasticSearch 需要）
sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -w fs.file-max=100000
echo "fs.file-max=100000" >> /etc/sysctl.conf

# 项目目录
mkdir -p /opt/myanmarestate

echo "=== Init complete. 下一步: git clone 项目到 /opt/myanmarestate ==="
