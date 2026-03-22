#!/bin/bash
# ============================================
# 数据库备份脚本
# 缅甸房产平台自动化备份
# ============================================

set -e

# 配置
BACKUP_DIR="/opt/myanmarestate/backups"
DB_NAME="myanmarestate"
DB_USER="postgres"
RETENTION_DAYS=30
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="db_${DATE}.sql.gz"
S3_BUCKET="myanmarestate-backups"
S3_PREFIX="database/"

# 确保备份目录存在
mkdir -p "$BACKUP_DIR"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}[INFO]${NC} 开始备份数据库..."
echo -e "${YELLOW}[INFO]${NC} 备份文件: $BACKUP_FILE"

# 执行备份
echo -e "${YELLOW}[INFO]${NC} 导出数据库..."
docker exec myanmarestate-postgres pg_dump -U "$DB_USER" "$DB_NAME" | gzip > "$BACKUP_DIR/$BACKUP_FILE"

# 检查备份是否成功
if [ $? -eq 0 ] && [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    echo -e "${GREEN}[SUCCESS]${NC} 备份完成: $BACKUP_FILE ($BACKUP_SIZE)"
else
    echo -e "${RED}[ERROR]${NC} 备份失败!"
    exit 1
fi

# 上传到 S3 (可选)
if command -v aws &> /dev/null; then
    echo -e "${YELLOW}[INFO]${NC} 上传到 S3..."
    aws s3 cp "$BACKUP_DIR/$BACKUP_FILE" "s3://$S3_BUCKET/$S3_PREFIX"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS]${NC} 上传完成: s3://$S3_BUCKET/$S3_PREFIX$BACKUP_FILE"
    else
        echo -e "${RED}[ERROR]${NC} 上传失败!"
    fi
fi

# 清理旧备份
echo -e "${YELLOW}[INFO]${NC} 清理 ${RETENTION_DAYS} 天前的备份..."
DELETED_COUNT=$(find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +$RETENTION_DAYS -type f -print | wc -l)
find "$BACKUP_DIR" -name "db_*.sql.gz" -mtime +$RETENTION_DAYS -type f -delete
echo -e "${GREEN}[SUCCESS]${NC} 清理完成, 删除 $DELETED_COUNT 个旧备份"

# 显示当前备份列表
echo -e "${YELLOW}[INFO]${NC} 当前备份列表:"
ls -lh "$BACKUP_DIR" | grep "db_" | tail -5

echo -e "${GREEN}[SUCCESS]${NC} 备份任务完成!"
