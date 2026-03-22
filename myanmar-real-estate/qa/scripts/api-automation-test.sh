#!/bin/bash
# ============================================
# 缅甸房产平台 - API自动化测试脚本
# 使用方式: bash api-automation-test.sh
# ============================================

echo "========================================"
echo "  缅甸房产平台 - API自动化测试"
echo "========================================"
echo ""
echo "正在执行Python测试脚本..."
echo ""

# 运行Python测试
python3 /root/.openclaw/workspace/qa/scripts/run_api_tests.py

exit_code=$?

echo ""
echo "测试脚本执行完成！"
echo ""
echo "报告位置: /root/.openclaw/workspace/qa/reports/API自动化测试报告_2026-03-17.md"

exit $exit_code
