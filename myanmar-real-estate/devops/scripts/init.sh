#!/bin/bash
# ============================================
# 初始化脚本
# 缅甸房产平台首次部署初始化
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  缅甸房产平台 - 初始化脚本${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 检查是否以 root 运行
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR]${NC} 请以 root 用户运行此脚本"
    exit 1
fi

# 安装 Docker
echo -e "${YELLOW}[STEP 1]${NC} 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}[OK]${NC} Docker 安装完成"
else
    echo -e "${GREEN}[OK]${NC} Docker 已安装"
fi

# 安装 Docker Compose
echo -e "${YELLOW}[STEP 2]${NC} 安装 Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}[OK]${NC} Docker Compose 安装完成"
else
    echo -e "${GREEN}[OK]${NC} Docker Compose 已安装"
fi

# 创建项目目录
echo -e "${YELLOW}[STEP 3]${NC} 创建项目目录..."
PROJECT_DIR="/opt/myanmarestate"
mkdir -p $PROJECT_DIR/{docker,nginx/ssl,backups,logs}
echo -e "${GREEN}[OK]${NC} 项目目录创建完成: $PROJECT_DIR"

# 配置环境变量
echo -e "${YELLOW}[STEP 4]${NC} 配置环境变量..."
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo -e "${YELLOW}[INFO]${NC} 请复制 .env.example 到 .env 并修改配置"
    echo -e "${YELLOW}[INFO]${NC} 示例: cp devops/deployment/.env.example $PROJECT_DIR/.env"
fi

# 配置防火墙
echo -e "${YELLOW}[STEP 5]${NC} 配置防火墙..."
if command -v ufw &> /dev/null; then
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
    echo -e "${GREEN}[OK]${NC} 防火墙配置完成"
fi

# 配置系统参数
echo -e "${YELLOW}[STEP 6]${NC} 配置系统参数..."
cat >> /etc/sysctl.conf << EOF
# 增加文件描述符限制
fs.file-max = 100000

# 优化网络参数
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.ip_local_port_range = 1024 65535
EOF

sysctl -p

echo -e "${GREEN}[OK]${NC} 系统参数配置完成"

echo ""
echo -e "${BLUE}============================================${NC}"
echo -e "${GREEN}  初始化完成!${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""
echo -e "${YELLOW}后续步骤:${NC}"
echo "  1. 复制环境变量文件: cp devops/deployment/.env.example /opt/myanmarestate/.env"
echo "  2. 编辑环境变量: vim /opt/myanmarestate/.env"
echo "  3. 配置 SSL 证书"
echo "  4. 运行部署脚本: ./devops/scripts/deploy.sh production"
echo ""
