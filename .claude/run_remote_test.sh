#!/bin/bash
# 远程测试脚本

SERVER_IP="43.163.122.42"
USER="ubuntu"

echo "正在连接到 ${SERVER_IP}..."

ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 \
    ${USER}@${SERVER_IP} << 'REMOTECOMMANDS'
cd ~/myanmarestate/myanmar-real-estate-kimi
echo "=== 拉取最新代码 ==="
git pull origin master

echo ""
echo "=== 执行冒烟测试 ==="
bash devops/scripts/run-all-tests.sh --smoke

exit_code=$?
echo ""
echo "=== 测试完成，退出码: ${exit_code} ==="
exit ${exit_code}
REMOTECOMMANDS
