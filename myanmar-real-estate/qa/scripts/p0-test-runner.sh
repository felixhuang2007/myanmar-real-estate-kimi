#!/bin/bash
# P0 测试用例执行脚本
# 执行剩余 P0 测试用例并记录结果

set -e

BASE_URL="http://localhost:8080/v1"
OUTPUT_FILE="/tmp/p0-test-results-$(date +%Y%m%d-%H%M%S).json"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
PASSED=0
FAILED=0
TOTAL=0

# 测试结果数组
RESULTS=()

# 测试函数
run_test() {
    local test_id=$1
    local test_name=$2
    local method=$3
    local endpoint=$4
    local expected_code=$5
    local auth_token=$6
    local data=$7

    TOTAL=$((TOTAL + 1))

    local curl_opts="-s -w \"HTTP_CODE:%{http_code}\""
    local headers=""

    if [ -n "$auth_token" ]; then
        headers="-H \"Authorization: Bearer $auth_token\""
    fi

    local url="${BASE_URL}${endpoint}"
    local response
    local http_code

    echo -n "[$test_id] $test_name ... "

    if [ "$method" = "GET" ]; then
        response=$(curl $curl_opts $headers "$url" 2>/dev/null)
    elif [ "$method" = "POST" ]; then
        if [ -n "$data" ]; then
            response=$(curl $curl_opts $headers -H "Content-Type: application/json" -X POST -d "$data" "$url" 2>/dev/null)
        else
            response=$(curl $curl_opts $headers -X POST "$url" 2>/dev/null)
        fi
    elif [ "$method" = "PUT" ]; then
        response=$(curl $curl_opts $headers -H "Content-Type: application/json" -X PUT -d "$data" "$url" 2>/dev/null)
    elif [ "$method" = "DELETE" ]; then
        response=$(curl $curl_opts $headers -X DELETE "$url" 2>/dev/null)
    fi

    http_code=$(echo "$response" | grep -o "HTTP_CODE:[0-9]*" | cut -d: -f2)

    if [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✅ 通过${NC} (HTTP $http_code)"
        PASSED=$((PASSED + 1))
        RESULTS+=("{\"test_id\":\"$test_id\",\"name\":\"$test_name\",\"status\":\"passed\",\"http_code\":$http_code}")
    else
        echo -e "${RED}❌ 失败${NC} (期望 HTTP $expected_code, 实际 HTTP $http_code)"
        FAILED=$((FAILED + 1))
        RESULTS+=("{\"test_id\":\"$test_id\",\"name\":\"$test_name\",\"status\":\"failed\",\"expected\":$expected_code,\"actual\":$http_code}")
    fi
}

# 获取token
get_token() {
    local phone=$1
    local code=$2

    # 先发送验证码
    curl -s -X POST "${BASE_URL}/auth/send-verification-code" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$phone\",\"type\":\"login\"}" > /dev/null

    # 登录获取token
    local response=$(curl -s -X POST "${BASE_URL}/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$phone\",\"verify_code\":\"$code\"}")

    echo "$response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4
}

# 使用测试账号获取token（假设测试账号已存在）
echo "=== 获取测试Token ==="
# 先尝试密码登录
TEST_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login-with-password" \
    -H "Content-Type: application/json" \
    -d '{"phone":"+959123456789","password":"test123456"}')

TOKEN=$(echo "$TEST_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo "密码登录失败，尝试验证码登录..."
    TOKEN=$(get_token "+959123456789" "123456")
fi

if [ -n "$TOKEN" ]; then
    echo -e "${GREEN}✅ Token获取成功${NC}"
else
    echo -e "${YELLOW}⚠️ 无法获取Token，部分测试将跳过${NC}"
fi

echo ""
echo "=== 执行P0测试用例 ==="
echo ""

# ==================== 公开接口测试 ====================
echo "--- 公开接口测试 ---"

run_test "API-PUBLIC-001" "健康检查" "GET" "/health" "200"
run_test "API-PUBLIC-002" "获取地区列表" "GET" "/regions" "200"
run_test "API-PUBLIC-003" "获取全局配置" "GET" "/config" "200"
run_test "API-PUBLIC-004" "房源列表" "GET" "/houses?page=1&page_size=10" "200"
run_test "API-PUBLIC-005" "房源搜索" "GET" "/houses/search?keyword=Yangon&page=1" "200"
run_test "API-PUBLIC-006" "房源详情" "GET" "/houses/3" "200"
run_test "API-PUBLIC-007" "用户公开信息" "GET" "/users/1/public" "200"
run_test "API-PUBLIC-008" "ACN角色列表" "GET" "/acn/roles" "200"
run_test "API-PUBLIC-009" "经纪人日程" "GET" "/agents/1/schedules" "200"

# ==================== 认证接口测试 ====================
echo ""
echo "--- 认证接口测试 ---"

if [ -n "$TOKEN" ]; then
    run_test "API-AUTH-001" "获取当前用户" "GET" "/users/me" "200" "$TOKEN"
    run_test "API-AUTH-002" "用户状态" "GET" "/users/status" "200" "$TOKEN"
    run_test "API-AUTH-003" "预约列表" "GET" "/appointments?page=1" "200" "$TOKEN"
    run_test "API-AUTH-004" "可用时段" "GET" "/appointments/slots?agentId=1&date=2026-04-01" "200" "$TOKEN"
    run_test "API-AUTH-005" "IM Token" "GET" "/im/token" "200" "$TOKEN"
    run_test "API-AUTH-006" "会话列表" "GET" "/conversations?page=1" "200" "$TOKEN"
    run_test "API-AUTH-007" "成交列表" "GET" "/acn/transactions?page=1" "200" "$TOKEN"
    run_test "API-AUTH-008" "佣金统计" "GET" "/acn/commission/statistics" "200" "$TOKEN"
    run_test "API-AUTH-009" "佣金明细" "GET" "/acn/commission/details?page=1" "200" "$TOKEN"
    run_test "API-AUTH-010" "佣金日志" "GET" "/acn/commission/logs?page=1" "200" "$TOKEN"
    run_test "API-AUTH-011" "佣金余额" "GET" "/acn/commission/balance" "200" "$TOKEN"
    run_test "API-AUTH-012" "C端成交列表" "GET" "/deals?page=1" "200" "$TOKEN"
    run_test "API-AUTH-013" "收藏列表" "GET" "/users/favorites?page=1" "200" "$TOKEN"
    run_test "API-AUTH-014" "上传Token" "GET" "/users/upload/token" "200" "$TOKEN"
else
    echo -e "${YELLOW}⚠️ 跳过需要Token的测试${NC}"
fi

# ==================== 测试总结 ====================
echo ""
echo "=== 测试总结 ==="
echo -e "总用例: $TOTAL"
echo -e "${GREEN}通过: $PASSED${NC}"
echo -e "${RED}失败: $FAILED${NC}"
echo -e "通过率: $(( PASSED * 100 / TOTAL ))%"

# 保存结果到JSON文件
echo "{\"timestamp\":$(date +%s),\"total\":$TOTAL,\"passed\":$PASSED,\"failed\":$FAILED,\"results\":[$(IFS=,; echo "${RESULTS[*]}")]"} > "$OUTPUT_FILE"
echo ""
echo "详细结果已保存到: $OUTPUT_FILE"
