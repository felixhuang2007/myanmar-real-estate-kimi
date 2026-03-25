#!/bin/bash
# 配置 Docker 镜像加速

set -e

echo "=== 配置 Docker 镜像加速 ==="

# 备份现有配置
if [ -f /etc/docker/daemon.json ]; then
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.bak.$(date +%Y%m%d%H%M%S)
fi

# 创建/更新 daemon.json
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<'EOF'
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com"
  ]
}
EOF

echo "重启 Docker 服务..."
sudo systemctl daemon-reload
sudo systemctl restart docker

echo "=== Docker 镜像加速配置完成 ==="
echo "配置内容:"
cat /etc/docker/daemon.json
