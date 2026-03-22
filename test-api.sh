#!/bin/bash
# 缅甸房产平台 - API 自动化测试脚本
# 使用: bash test-api.sh

set -e

BASE_URL="http://localhost:8080"
TOKEN=""

echo "========================================"
echo "  缅甸房产平台 - API 自动化测试"
echo "========================================"
echo ""
echo "测试地址: $BASE_URL"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 测试计数
PASSED=0
FAILED=0

# 测试函数
run_test() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local check=$5

    echo "测试: $name"
    echo "  $method $endpoint"

    if [ -n "$data" ]; then
        if [ -n "$TOKEN" ]; then
            RESPONSE=$(curl -s -X $method "$BASE_URL$endpoint" \
                -H "Content-Type: application/json" \
                -H "Authorization: Bearer $TOKEN" \
                -d "$data" 2>/dev/null || echo '{"code":-1}')
        else
            RESPONSE=$(curl -s -X $method "$BASE_URL$endpoint" \
                -H "Content-Type: application/json" \
                -d "$data" 2>/dev/null || echo '{"code":-1}')
        fi
    else
        if [ -n "$TOKEN" ]; then
            RESPONSE=$(curl -s -X $method "$BASE_URL$endpoint" \
                -H "Authorization: Bearer $TOKEN" 2>/dev/null || echo '{"code":-1}')
        else
            RESPONSE=$(curl -s -X $method "$BASE_URL$endpoint" 2>/dev/null || echo '{"code":-1}')
        fi
    fi

    if echo "$RESPONSE" | grep -q "$check"; then
        echo -e "  ${GREEN}✅ 通过${NC}"
        ((PASSED++))

        # 如果是登录接口，提取token
        if [ "$endpoint" = "/v1/auth/login" ]; then
            TOKEN=$(echo "$RESPONSE" | grep -o '"access_token":"[^"]*"' | head -1 | cut -d'"' -f4)
            echo "  Token: ${TOKEN:0:30}..."
        fi
    else
        echo -e "  ${RED}❌ 失败${NC}"
        echo "  响应: ${RESPONSE:0:200}"
        ((FAILED++))
    fi
    echo ""
}

# 1. 健康检查
run_test "健康检查" "GET" "/health" "" '"code":200'

# 2. 发送验证码
run_test "发送验证码" "POST" "/v1/auth/send-verification-code" \
    '{"phone":"+95111111111","type":"register"}' \
    '"code":'

# 3. 用户注册
run_test "用户注册" "POST" "/v1/auth/register" \
    '{"phone":"+95111111111","code":"123456","password":"password123","name":"测试用户","user_type":"buyer"}' \
    '"code":'

# 4. 用户登录
run_test "用户登录" "POST" "/v1/auth/login" \
    '{"phone":"+95111111111","code":"123456","device_id":"test-device-001","device_type":"ios"}' \
    '"code":'

# 5. 获取用户信息（需要Token）
if [ -n "$TOKEN" ]; then
    run_test "获取用户信息" "GET" "/v1/users/me" "" '"code":'
else
    echo "跳过: 获取用户信息 (无Token)"
    echo ""
fi

# 6. 刷新Token
if [ -n "$TOKEN" ]; then
    REFRESH_TOKEN=$(curl -s -X POST "$BASE_URL/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"phone":"+95111111111","code":"123456","device_id":"test-device-001","device_type":"ios"}' 2>/dev/null | \
        grep -o '"refresh_token":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$REFRESH_TOKEN" ]; then
        run_test "刷新Token" "POST" "/v1/auth/refresh-token" \
            "{\"refresh_token\":\"$REFRESH_TOKEN\"}" \
            '"code":'
    fi
fi

# 汇总
echo "========================================"
echo "  测试结果汇总"
echo "========================================"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试通过!${NC}"
    exit 0
else
    echo -e "${RED}⚠️  部分测试失败，请检查服务状态${NC}"
    exit 1
fi
