#!/bin/bash
# ============================================
# 部署脚本
# 缅甸房产平台自动化部署
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
ENV=${1:-development}
COMPOSE_FILE="docker-compose.yml"
COMPOSE_PROD_FILE="docker-compose.prod.yml"
PROJECT_DIR="/opt/myanmarestate"

# 打印帮助信息
usage() {
    echo "Usage: $0 [environment]"
    echo ""
    echo "Environments:"
    echo "  development    部署到开发环境"
    echo "  production     部署到生产环境"
    echo ""
    echo "Examples:"
    echo "  $0 development"
    echo "  $0 production"
    exit 1
}

# 检查参数
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
fi

echo -e "${BLUE}============================================${NC}"
echo -e "${BLUE}  缅甸房产平台 - 部署脚本${NC}"
echo -e "${BLUE}  环境: $ENV${NC}"
echo -e "${BLUE}============================================${NC}"
echo ""

# 检查环境
check_environment() {
    echo -e "${YELLOW}[CHECK]${NC} 检查环境..."
    
    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} Docker 未安装"
        exit 1
    fi
    
    # 检查 Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${RED}[ERROR]${NC} Docker Compose 未安装"
        exit 1
    fi
    
    # 检查项目目录
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}[ERROR]${NC} 项目目录不存在: $PROJECT_DIR"
        exit 1
    fi
    
    # 检查环境变量文件
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        echo -e "${RED}[ERROR]${NC} 环境变量文件不存在: $PROJECT_DIR/.env"
        exit 1
    fi
    
    echo -e "${GREEN}[OK]${NC} 环境检查通过"
}

# 拉取最新代码
pull_code() {
    echo -e "${YELLOW}[STEP 1]${NC} 拉取最新代码..."
    cd "$PROJECT_DIR"
    git pull origin main
    echo -e "${GREEN}[OK]${NC} 代码更新完成"
}

# 拉取镜像
pull_images() {
    echo -e "${YELLOW}[STEP 2]${NC} 拉取最新镜像..."
    cd "$PROJECT_DIR/devops/docker"
    
    if [ "$ENV" == "production" ]; then
        docker-compose -f "$COMPOSE_FILE" -f "$COMPOSE_PROD_FILE" pull
    else
        docker-compose pull
    fi
    
    echo -e "${GREEN}[OK]${NC} 镜像拉取完成"
}

# 执行部署
deploy() {
    echo -e "${YELLOW}[STEP 3]${NC} 执行部署..."
    cd "$PROJECT_DIR/devops/docker"
    
    if [ "$ENV" == "production" ]; then
        echo -e "${YELLOW}[INFO]${NC} 使用生产环境配置..."
        docker-compose -f "$COMPOSE_FILE" -f "$COMPOSE_PROD_FILE" up -d --remove-orphans
    else
        echo -e "${YELLOW}[INFO]${NC} 使用开发环境配置..."
        docker-compose up -d --remove-orphans
    fi
    
    echo -e "${GREEN}[OK]${NC} 部署完成"
}

# 健康检查
health_check() {
    echo -e "${YELLOW}[STEP 4]${NC} 健康检查..."
    
    # 等待服务启动
    sleep 5
    
    # 检查后端服务
    if curl -sf http://localhost:3000/health > /dev/null; then
        echo -e "${GREEN}[OK]${NC} 后端服务正常"
    else
        echo -e "${RED}[ERROR]${NC} 后端服务异常"
        return 1
    fi
    
    # 检查 Nginx
    if curl -sf http://localhost:80 > /dev/null; then
        echo -e "${GREEN}[OK]${NC} Nginx 服务正常"
    else
        echo -e "${RED}[ERROR]${NC} Nginx 服务异常"
        return 1
    fi
    
    echo -e "${GREEN}[OK]${NC} 健康检查通过"
}

# 清理旧资源
cleanup() {
    echo -e "${YELLOW}[STEP 5]${NC} 清理旧资源..."
    
    # 清理未使用的镜像
    docker image prune -af --filter "until=168h"
    
    # 清理未使用的卷
    docker volume prune -f
    
    # 清理构建缓存
    docker builder prune -f
    
    echo -e "${GREEN}[OK]${NC} 清理完成"
}

# 显示状态
show_status() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}  部署状态${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
    
    cd "$PROJECT_DIR/devops/docker"
    docker-compose ps
    
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${GREEN}  部署成功!${NC}"
    echo -e "${BLUE}============================================${NC}"
}

# 主流程
main() {
    check_environment
    pull_code
    pull_images
    deploy
    health_check
    cleanup
    show_status
}

# 执行主流程
main
