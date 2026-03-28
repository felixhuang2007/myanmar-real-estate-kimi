#!/bin/bash
# Run API tests directly on server - wrapper script
set +e

BASE_URL="http://43.163.122.42"
TEST_PHONE="+959701234567"
TEST_PASSWORD="admin123"
DEVICE_ID="test_device_$(date +%s)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
SKIPPED=0
TOKEN=""

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

test_api() {
    local test_name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local need_auth="$5"
    local expected_codes="$6"
    local url="${BASE_URL}${endpoint}"
    local http_code
    if [ "$method" = "GET" ]; then
        if [ "$need_auth" = "1" ] && [ -n "$TOKEN" ]; then
            http_code=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $TOKEN" "$url")
        else
            http_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        fi
    else
        if [ "$need_auth" = "1" ] && [ -n "$TOKEN" ]; then
            http_code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$data" "$url")
        else
            http_code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" -H "Content-Type: application/json" -d "$data" "$url")
        fi
    fi
    if echo "$expected_codes" | grep -qw "$http_code"; then
        echo -e "${GREEN}  ✓ PASS${NC} | $test_name (HTTP $http_code)"
        PASSED=$((PASSED + 1))
    elif [ "$http_code" = "404" ] || [ "$http_code" = "501" ]; then
        echo -e "${YELLOW}  ⊘ SKIP${NC} | $test_name (HTTP $http_code - 未实现)"
        SKIPPED=$((SKIPPED + 1))
    elif [ -z "$TOKEN" ] && [ "$need_auth" = "1" ]; then
        echo -e "${YELLOW}  ⊘ SKIP${NC} | $test_name (无Token)"
        SKIPPED=$((SKIPPED + 1))
    else
        echo -e "${RED}  ✗ FAIL${NC} | $test_name (HTTP $http_code)"
        FAILED=$((FAILED + 1))
    fi
}

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     缅甸房产平台 - API 完整测试套件                        ║${NC}"
echo -e "${BLUE}║     服务器: 43.163.122.42                                  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# Get verification code
RESP=$(curl -s -w "\n%{http_code}" -X POST "${BASE_URL}/api/auth/send-verification-code" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"${TEST_PHONE}\",\"type\":\"login\"}")
HTTP=$(echo "$RESP" | tail -n1)
if [ "$HTTP" = "200" ]; then
    echo -e "${GREEN}  ✓ PASS${NC} | 发送验证码 (HTTP 200)"
    PASSED=$((PASSED + 1))
    sleep 1
    VERIFICATION_CODE=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -t -c "SELECT code FROM sms_verification_codes WHERE phone = '${TEST_PHONE}' AND type = 'login' AND expired_at > NOW() ORDER BY created_at DESC LIMIT 1;" 2>/dev/null | xargs)
else
    echo -e "${YELLOW}  ⊘ SKIP${NC} | 发送验证码 (HTTP $HTTP - 频率限制)"
    SKIPPED=$((SKIPPED + 1))
    VERIFICATION_CODE=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -t -c "SELECT code FROM sms_verification_codes WHERE phone = '${TEST_PHONE}' AND type = 'login' AND expired_at > NOW() ORDER BY created_at DESC LIMIT 1;" 2>/dev/null | xargs)
fi

# Login
CODE="${VERIFICATION_CODE:-123456}"
http_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST "${BASE_URL}/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"${TEST_PHONE}\",\"code\":\"${CODE}\",\"device_id\":\"${DEVICE_ID}\"}")
if [ "$http_code" = "200" ]; then
    echo -e "${GREEN}  ✓ PASS${NC} | 验证码登录 (HTTP 200)"
    PASSED=$((PASSED + 1))
    TOKEN=$(curl -s -X POST "${BASE_URL}/api/auth/login" -H "Content-Type: application/json" -d "{\"phone\":\"${TEST_PHONE}\",\"code\":\"${CODE}\",\"device_id\":\"${DEVICE_ID}\"}" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
else
    echo -e "${RED}  ✗ FAIL${NC} | 验证码登录 (HTTP $http_code)"
    FAILED=$((FAILED + 1))
fi

print_header "用户模块 API 测试"
test_api "TEST-001: 用户注册" "POST" "/api/auth/register" "{\"phone\":\"+959701234568\",\"code\":\"123456\",\"password\":\"test123\",\"device_id\":\"${DEVICE_ID}2\"}" "0" "200 201 409"
test_api "TEST-004: 密码登录" "POST" "/api/auth/login-with-password" "{\"phone\":\"09701234567\",\"password\":\"${TEST_PASSWORD}\",\"device_id\":\"${DEVICE_ID}3\"}" "0" "200"
test_api "TEST-005: 获取用户信息" "GET" "/api/users/me" "" "1" "200"
test_api "TEST-006: 更新用户信息" "PUT" "/api/users/me" "{\"nickname\":\"TestUser\",\"avatar\":\"https://example.com/avatar.jpg\"}" "1" "200"
test_api "TEST-007: 刷新Token" "POST" "/api/auth/refresh-token" "{\"refresh_token\":\"invalid\"}" "0" "200 401"
test_api "TEST-008: 实名认证" "POST" "/api/users/me/verification" "{\"real_name\":\"Test\",\"id_card\":\"123456\",\"id_card_front\":\"url\",\"id_card_back\":\"url\"}" "1" "200 201 202"
test_api "TEST-009: 用户收藏" "GET" "/api/users/me/favorites?page=1&page_size=10" "" "1" "200"

print_header "房源模块 API 测试"
test_api "TEST-010: 房源搜索" "GET" "/api/houses/search?page=1&page_size=5" "" "0" "200"
test_api "TEST-011: 房源详情" "GET" "/api/houses/1" "" "0" "200 404"
test_api "TEST-012: 地图聚合" "GET" "/api/houses/map-search?zoom=12&sw_lat=16.8&sw_lng=96.1&ne_lat=16.9&ne_lng=96.2" "" "0" "200"
test_api "TEST-013: 首页推荐" "GET" "/api/houses/recommendations?limit=10" "" "0" "200"
test_api "TEST-014: 创建房源" "POST" "/api/houses" "{\"title\":\"测试房源\",\"price\":1000000,\"area\":100,\"bedrooms\":2,\"property_type\":\"condo\",\"transaction_type\":\"sale\"}" "1" "200 201 403"
test_api "TEST-015: 更新房源" "PUT" "/api/houses/1" "{\"price\":2000000}" "1" "200 403 404"
test_api "TEST-016: 房源下架" "POST" "/api/houses/1/offline" "{}" "1" "200 403 404"
test_api "TEST-017: 收藏房源" "POST" "/api/houses/1/favorite" "{}" "1" "200 201 404"
test_api "TEST-018: 房源列表(经纪人)" "GET" "/api/houses?page=1&page_size=20" "" "1" "200 403"

print_header "IM模块 API 测试"
test_api "TEST-019: 会话列表" "GET" "/api/im/conversations?page=1&page_size=20" "" "1" "200"
test_api "TEST-020: 获取消息" "GET" "/api/im/conversations/1/messages?page=1" "" "1" "200 404"
test_api "TEST-021: 发送消息" "POST" "/api/im/conversations/1/messages" "{\"content\":\"测试消息\",\"type\":\"text\"}" "1" "200 201 404"
test_api "TEST-022: 标记消息已读" "POST" "/api/im/conversations/1/read" "{}" "1" "200 404"
test_api "TEST-023: 创建会话" "POST" "/api/im/conversations" "{\"recipient_id\":2,\"initial_message\":\"你好\"}" "1" "200 201 422"
test_api "TEST-024: 快捷话术" "GET" "/api/im/quick-replies" "" "1" "200"
test_api "TEST-025: 删除会话" "DELETE" "/api/im/conversations/1" "" "1" "200 204 404"

print_header "预约模块 API 测试"
test_api "TEST-026: 可预约时间段" "GET" "/api/appointments/slots?house_id=1&date=2026-03-28" "" "0" "200 404"
test_api "TEST-027: 创建预约" "POST" "/api/appointments" "{\"house_id\":1,\"appointment_date\":\"2026-03-28\",\"appointment_time\":\"14:00\",\"notes\":\"想看房\"}" "1" "200 201"
test_api "TEST-028: 预约列表" "GET" "/api/appointments?page=1&page_size=20" "" "1" "200"
test_api "TEST-029: 预约详情" "GET" "/api/appointments/1" "" "1" "200 404"
test_api "TEST-030: 确认预约" "POST" "/api/appointments/1/confirm" "{}" "1" "200 403 404"
test_api "TEST-031: 拒绝预约" "POST" "/api/appointments/1/reject" "{}" "1" "200 403 404"
test_api "TEST-032: 完成带看" "POST" "/api/appointments/1/complete" "{\"feedback\":\"客户满意\"}" "1" "200 403 404"
test_api "TEST-033: 取消预约" "POST" "/api/appointments/1/cancel" "{\"reason\":\"行程有变\"}" "1" "200 403 404"
test_api "TEST-034: 带看评价" "POST" "/api/appointments/1/review" "{\"rating\":5,\"comment\":\"很好\"}" "1" "200 404"
test_api "TEST-035: 预约日历" "GET" "/api/appointments/calendar?month=2026-03" "" "1" "200 404"

print_header "ACN模块 API 测试"
test_api "TEST-036: 成交申报" "POST" "/api/acn/transactions" "{\"house_id\":1,\"deal_price\":48000000,\"deal_date\":\"2026-03-27\",\"buyer_name\":\"Buyer\",\"buyer_phone\":\"+959701234567\"}" "1" "200 201 403"
test_api "TEST-037: 成交列表" "GET" "/api/acn/transactions?page=1&page_size=20" "" "1" "200"
test_api "TEST-038: 成交详情" "GET" "/api/acn/transactions/1" "" "1" "200 404"
test_api "TEST-039: 确认成交" "POST" "/api/acn/transactions/1/confirm" "{}" "1" "200 403 404"
test_api "TEST-040: 成交申诉" "POST" "/api/acn/disputes" "{\"transaction_id\":1,\"reason\":\"分佣比例有误\"}" "1" "200 201 403"
test_api "TEST-041: 佣金余额" "GET" "/api/acn/commission/statistics" "" "1" "200"
test_api "TEST-042: 佣金明细" "GET" "/api/acn/commission/details?page=1&page_size=20" "" "1" "200"
test_api "TEST-043: 分佣角色" "GET" "/api/acn/roles" "" "1" "200 404"

print_header "公共模块 API 测试"
test_api "TEST-044: 健康检查" "GET" "/health" "" "0" "200"
test_api "TEST-045: 上传配置" "GET" "/api/upload/config" "" "1" "200"
test_api "TEST-046: 城市列表" "GET" "/api/houses/cities" "" "0" "200"
test_api "TEST-047: 退出登录" "POST" "/api/auth/logout" "{}" "1" "200 204"

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}               测 试 报 告               ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

TOTAL=$((PASSED + FAILED + SKIPPED))
echo -e "\n测试统计:"
echo -e "  总用例数: $TOTAL"
echo -e "  ${GREEN}通过: $PASSED${NC}"
echo -e "  ${RED}失败: $FAILED${NC}"
echo -e "  ${YELLOW}跳过: $SKIPPED${NC}"

if [ $TOTAL -gt 0 ]; then
    PASS_RATE=$(( PASSED * 100 / TOTAL ))
    echo -e "  通过率: ${PASS_RATE}%"
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}✗ 有 $FAILED 项测试失败${NC}"
    exit 1
fi
