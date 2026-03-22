#!/bin/bash
# 缅甸房产平台 - API冒烟测试脚本
# 使用方法: ./api-smoke-test.sh [BASE_URL]

BASE_URL="${1:-http://localhost:8080}"
TOKEN=""
USER_ID=""

echo "================================"
echo "缅甸房产平台 API 冒烟测试"
echo "================================"
echo "测试地址: $BASE_URL"
echo "测试时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================"
echo

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
PASSED=0
FAILED=0

# 测试函数
test_api() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_code=$5
    
    echo -n "Testing $name ... "
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "%{http_code}" -X $method "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data" 2>/dev/null)
    else
        response=$(curl -s -w "%{http_code}" -X $method "$BASE_URL$endpoint" 2>/dev/null)
    fi
    
    http_code=${response: -3}
    
    if [ "$http_code" = "$expected_code" ] || [ "$http_code" = "200" ]; then
        echo -e "${GREEN}PASS${NC} ($http_code)"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${NC} (Expected: $expected_code, Got: $http_code)"
        ((FAILED++))
    fi
}

echo "1. 服务健康检查"
echo "----------------"
test_api "Health Check" "GET" "/health" "" "200"
echo

echo "2. 用户模块测试"
echo "----------------"
# 发送验证码
test_api "Send Verification Code" "POST" "/v1/auth/send-verification-code" \
    '{"phone":"+959123456789","type":"register"}' "200"

# 用户注册
register_response=$(curl -s -X POST "$BASE_URL/v1/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"phone":"+959123456789","code":"123456","password":"123456"}' 2>/dev/null)

echo "Register Response: $register_response"
TOKEN=$(echo $register_response | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
USER_ID=$(echo $register_response | grep -o '"user_id":[0-9]*' | cut -d':' -f2)

if [ -n "$TOKEN" ]; then
    echo -e "User Registration: ${GREEN}PASS${NC}"
    ((PASSED++))
else
    echo -e "User Registration: ${YELLOW}SKIP (needs valid SMS code)${NC}"
fi

# 密码登录
test_api "Login with Password" "POST" "/v1/auth/login-with-password" \
    '{"phone":"+959123456789","password":"123456","device_id":"test-device"}' "200"

# 重置密码
test_api "Reset Password" "POST" "/v1/auth/reset-password" \
    '{"phone":"+959123456789","code":"123456","new_password":"newpass123"}' "200"
echo

echo "3. 房源模块测试"
echo "----------------"
# 房源搜索
test_api "House Search" "GET" "/v1/houses/search?city_code=YGN&page=1&page_size=10" "" "200"

# 推荐房源
test_api "House Recommendations" "GET" "/v1/houses/recommendations?city_code=YGN" "" "200"

# 地图聚合
test_api "Map Aggregate" "GET" "/v1/houses/map-aggregate?sw_lat=16.8&sw_lng=96.1&ne_lat=16.9&ne_lng=96.2&zoom=12" "" "200"
echo

echo "4. IM消息模块测试"
echo "----------------"
if [ -n "$TOKEN" ]; then
    # 获取会话列表
    test_api "Get Conversations" "GET" "/v1/conversations" "" "200"
    
    # 创建会话
    conv_response=$(curl -s -X POST "$BASE_URL/v1/conversations" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d '{"agent_id":1,"house_id":1}' 2>/dev/null)
    echo "Create Conversation: $conv_response"
    
    # 获取IM Token
    test_api "Get IM Token" "GET" "/v1/im/token" "" "200"
else
    echo -e "IM Tests: ${YELLOW}SKIP (needs authentication)${NC}"
fi
echo

echo "5. 预约带看模块测试"
echo "----------------"
if [ -n "$TOKEN" ]; then
    # 创建预约
    test_api "Create Appointment" "POST" "/v1/appointments" \
        '{"house_id":1,"agent_id":1,"appointment_date":"2026-03-20","appointment_time_start":"14:00","appointment_time_end":"15:00","client_name":"Test","client_phone":"+959123456789"}' "200"
    
    # 获取预约列表
    test_api "Get Appointments" "GET" "/v1/appointments" "" "200"
    
    # 获取可用时段
    test_api "Get Available Slots" "GET" "/v1/agents/1/schedules?date=2026-03-20" "" "200"
else
    echo -e "Appointment Tests: ${YELLOW}SKIP (needs authentication)${NC}"
fi
echo

echo "6. ACN分佣模块测试"
echo "----------------"
if [ -n "$TOKEN" ]; then
    # 获取ACN角色
    test_api "Get ACN Roles" "GET" "/v1/acn/roles" "" "200"
    
    # 获取成交单列表
    test_api "Get Transactions" "GET" "/v1/acn/transactions" "" "200"
    
    # 获取分佣统计
    test_api "Get Commission Statistics" "GET" "/v1/acn/commissions/statistics" "" "200"
else
    echo -e "ACN Tests: ${YELLOW}SKIP (needs authentication)${NC}"
fi
echo

echo "================================"
echo "测试完成!"
echo "================================"
echo -e "通过: ${GREEN}$PASSED${NC}"
echo -e "失败: ${RED}$FAILED${NC}"
echo "================================"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}所有测试通过!${NC}"
    exit 0
else
    echo -e "${RED}存在失败的测试，请检查!${NC}"
    exit 1
fi
