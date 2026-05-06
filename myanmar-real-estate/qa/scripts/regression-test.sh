#!/bin/bash
# P0 回归测试套件
# 执行所有P0测试用例验证修复

BASE_URL="http://43.163.122.42:8080"
V1_URL="$BASE_URL/v1"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 计数器
PASSED=0
FAILED=0
TOTAL=0

# 测试函数
run_test() {
    local name="$1"
    local method="$2"
    local endpoint="$3"
    local expected_code="$4"
    local headers="${5:-}"
    local body="${6:-}"

    TOTAL=$((TOTAL + 1))

    local curl_cmd="curl -s -X $method"
    if [ -n "$headers" ]; then
        curl_cmd="$curl_cmd -H \"$headers\""
    fi
    if [ -n "$body" ]; then
        curl_cmd="$curl_cmd -d '$body'"
    fi
    curl_cmd="$curl_cmd \"$endpoint\""

    response=$(eval $curl_cmd 2>/dev/null)

    # 检查响应码
    if echo "$response" | grep -q "\"code\":$expected_code"; then
        echo -e "✅ [$TOTAL] $name - 通过"
        PASSED=$((PASSED + 1))
    else
        echo -e "❌ [$TOTAL] $name - 失败"
        echo "   响应: $(echo $response | cut -c1-100)"
        FAILED=$((FAILED + 1))
    fi
}

echo "=== P0 回归测试套件 ==="
echo "测试地址: $BASE_URL"
echo "测试时间: $(date)"
echo ""

# 1. 公开接口测试
echo "--- 公开接口测试 ---"
run_test "健康检查" "GET" "$BASE_URL/health" "200"
run_test "获取地区列表" "GET" "$V1_URL/regions" "200"
run_test "获取全局配置" "GET" "$V1_URL/config" "200"
run_test "房源列表" "GET" "$V1_URL/houses?page=1&page_size=10" "200"
run_test "房源搜索" "GET" "$V1_URL/houses/search?keywords=Yangon&page=1" "200"
run_test "房源详情" "GET" "$V1_URL/houses/3" "200"
run_test "用户公开信息" "GET" "$V1_URL/users/1/public" "200"
run_test "ACN角色列表" "GET" "$V1_URL/acn/roles" "200"
run_test "经纪人日程" "GET" "$V1_URL/agents/1/schedules" "200"
run_test "城市列表" "GET" "$V1_URL/houses/cities" "200"
run_test "区域列表" "GET" "$V1_URL/houses/districts?city_code=YGN" "200"

# 2. 发送验证码 (获取token前)
echo ""
echo "--- 认证接口测试 ---"
CODE_RESPONSE=$(curl -s -X POST "$V1_URL/auth/send-verification-code" \
    -H "Content-Type: application/json" \
    -d '{"phone": "+959999999997", "type": "login"}')

if echo "$CODE_RESPONSE" | grep -q '"code":200'; then
    echo "✅ 发送验证码 - 通过"
    PASSED=$((PASSED + 1))
    # 提取验证码
    VERIFY_CODE=$(echo "$CODE_RESPONSE" | grep -o '"code":"[0-9]*"' | cut -d'"' -f4)
else
    echo "❌ 发送验证码 - 失败"
    FAILED=$((FAILED + 1))
    VERIFY_CODE="123456"
fi
TOTAL=$((TOTAL + 1))

# 3. 登录获取token
LOGIN_RESPONSE=$(curl -s -X POST "$V1_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"phone\": \"+959999999997\", \"code\": \"$VERIFY_CODE\", \"device_id\": \"test-device\"}")

if echo "$LOGIN_RESPONSE" | grep -q '"code":200'; then
    echo "✅ 用户登录 - 通过"
    PASSED=$((PASSED + 1))
    TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | head -1 | cut -d'"' -f4)
else
    echo "❌ 用户登录 - 失败"
    FAILED=$((FAILED + 1))
    TOKEN=""
fi
TOTAL=$((TOTAL + 1))

# 4. 需要认证的接口测试
if [ -n "$TOKEN" ]; then
    AUTH_HEADER="Authorization: Bearer $TOKEN"

    run_test "获取当前用户" "GET" "$V1_URL/users/me" "200" "$AUTH_HEADER"
    run_test "获取用户状态" "GET" "$V1_URL/users/status" "200" "$AUTH_HEADER"
    run_test "更新用户信息" "PUT" "$V1_URL/users/me" "200" "$AUTH_HEADER" '{"nickname": "Test User"}'
    run_test "预约列表" "GET" "$V1_URL/appointments" "200" "$AUTH_HEADER"
    run_test "收藏列表" "GET" "$V1_URL/users/me/favorites" "200" "$AUTH_HEADER"
    run_test "会话列表" "GET" "$V1_URL/conversations" "200" "$AUTH_HEADER"
    run_test "ACN佣金统计" "GET" "$V1_URL/acn/commission/statistics" "200" "$AUTH_HEADER"
    run_test "ACN佣金明细" "GET" "$V1_URL/acn/commission/details" "200" "$AUTH_HEADER"
    run_test "C端成交列表" "GET" "$V1_URL/deals" "200" "$AUTH_HEADER"

    # 创建成交单测试 (BUG-015回归测试)
    echo ""
    echo "--- BUG-015 回归测试 ---"
    TX_RESPONSE=$(curl -s -X POST "$V1_URL/acn/transactions" \
        -H "Content-Type: application/json" \
        -H "$AUTH_HEADER" \
        -d '{
            "house_id": 3,
            "deal_price": 150000,
            "commission_amount": 7500,
            "deal_date": "2026-04-01",
            "contract_image": "https://example.com/contract.jpg",
            "participants": [
                {"role": "ENTRANT", "agent_id": 1, "ratio": 1500},
                {"role": "CLOSER", "agent_id": 1, "ratio": 7500}
            ]
        }')

    if echo "$TX_RESPONSE" | grep -q '"code":200'; then
        echo -e "✅ 创建成交单 - 通过 (BUG-015已修复)"
        PASSED=$((PASSED + 1))
    else
        echo -e "❌ 创建成交单 - 失败"
        echo "   响应: $(echo $TX_RESPONSE | cut -c1-150)"
        FAILED=$((FAILED + 1))
    fi
    TOTAL=$((TOTAL + 1))
fi

# 5. 权限控制测试
echo ""
echo "--- 权限控制测试 ---"
run_test "无Token访问用户接口" "GET" "$V1_URL/users/me" "401"
run_test "无Token访问ACN统计" "GET" "$V1_URL/acn/commission/statistics" "401"
run_test "无Token访问佣金余额" "GET" "$V1_URL/acn/commission/balance" "401"

# 测试总结
echo ""
echo "=== 测试总结 ==="
echo "总用例: $TOTAL"
echo -e "通过: ${GREEN}$PASSED${NC}"
echo -e "失败: ${RED}$FAILED${NC}"
echo "通过率: $(($PASSED * 100 / $TOTAL))%"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 所有测试用例通过！${NC}"
    exit 0
else
    echo -e "${RED}⚠️ 有 $FAILED 个测试用例失败${NC}"
    exit 1
fi
