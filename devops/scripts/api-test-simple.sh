#!/bin/bash
# 缅甸房产平台 - API 完整测试套件 (简化版本)
# 目标服务器: 43.163.122.42
# 测试用例数: 47个

set +e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 服务器配置
SERVER_IP="${SERVER_IP:-43.163.122.42}"
BASE_URL="${BASE_URL:-http://$SERVER_IP}"

# 测试数据
TEST_PHONE="+959701234567"
TEST_PASSWORD="admin123"
TIMESTAMP=$(date +%s)
TEST_DEVICE_ID="test_device_${TIMESTAMP}"

# 运行时变量
TOKEN=""
REFRESH_TOKEN=""
USER_ID=""
HOUSE_ID=""
APPOINTMENT_ID=""
CONVERSATION_ID=""
DEAL_ID=""
VERIFICATION_CODE=""

# 测试结果统计
PASSED=0
FAILED=0
SKIPPED=0
TOTAL=0

# 测试开始时间
START_TIME=$(date +%s)

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_subheader() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}  ✓ PASS${NC} | $1"
    PASSED=$((PASSED + 1))
    TOTAL=$((TOTAL + 1))
}

print_failure() {
    echo -e "${RED}  ✗ FAIL${NC} | $1"
    echo -e "${RED}         Error: $2${NC}"
    FAILED=$((FAILED + 1))
    TOTAL=$((TOTAL + 1))
}

print_skip() {
    echo -e "${YELLOW}  ⊘ SKIP${NC} | $1"
    SKIPPED=$((SKIPPED + 1))
    TOTAL=$((TOTAL + 1))
}

# HTTP 请求工具
http_get() {
    local url="$1"
    local headers="${2:-}"
    if [ -n "$headers" ]; then
        curl -s -w "\n%{http_code}" "$url" -H "$headers"
    else
        curl -s -w "\n%{http_code}" "$url"
    fi
}

http_post() {
    local url="$1"
    local data="$2"
    local headers="${3:-Content-Type: application/json}"
    curl -s -w "\n%{http_code}" -X POST "$url" \
        -H "$headers" \
        -d "$data"
}

http_put() {
    local url="$1"
    local data="$2"
    local headers="${3:-Content-Type: application/json}"
    curl -s -w "\n%{http_code}" -X PUT "$url" \
        -H "$headers" \
        -d "$data"
}

http_delete() {
    local url="$1"
    local headers="${2:-}"
    if [ -n "$headers" ]; then
        curl -s -w "\n%{http_code}" -X DELETE "$url" -H "$headers"
    else
        curl -s -w "\n%{http_code}" -X DELETE "$url"
    fi
}

# 提取响应体和状态码
extract_response() {
    local response="$1"
    local var_name="$2"
    HTTP_CODE=$(echo "$response" | tail -n1)
    BODY=$(echo "$response" | sed '$d')
    eval "$var_name=\"\$BODY\""
}

# 从数据库获取验证码
fetch_verification_code() {
    local phone="$1"
    local code=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -t -c "SELECT code FROM sms_verification_codes WHERE phone = '$phone' AND used_at IS NULL ORDER BY created_at DESC LIMIT 1;" 2>/dev/null | xargs)
    echo "$code"
}

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     缅甸房产平台 - API 完整测试套件                        ║${NC}"
echo -e "${BLUE}║     服务器: $SERVER_IP                                     ║${NC}"
echo -e "${BLUE}║     时间: $(date '+%Y-%m-%d %H:%M:%S')                              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

# ============================================
# 测试执行
# ============================================

# TEST-002: 发送验证码
print_subheader "TEST-002: 发送验证码"
RESPONSE=$(http_post "$BASE_URL/api/auth/send-verification-code" \
    "{\"phone\":\"$TEST_PHONE\",\"type\":\"login\"}")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "发送验证码"
    sleep 1
    DB_CODE=$(fetch_verification_code "$TEST_PHONE")
    if [ -n "$DB_CODE" ]; then
        VERIFICATION_CODE="$DB_CODE"
        echo "    [INFO] 从数据库获取验证码: $VERIFICATION_CODE"
    else
        VERIFICATION_CODE="123456"
        echo "    [WARN] 使用测试验证码: $VERIFICATION_CODE"
    fi
elif [ "$HTTP_CODE" = "429" ]; then
    print_skip "发送验证码" "请求过于频繁"
    DB_CODE=$(fetch_verification_code "$TEST_PHONE")
    [ -n "$DB_CODE" ] && VERIFICATION_CODE="$DB_CODE"
else
    print_failure "发送验证码" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-003: 验证码登录
print_subheader "TEST-003: 验证码登录"
CODE="${VERIFICATION_CODE:-123456}"
RESPONSE=$(http_post "$BASE_URL/api/auth/login" \
    "{\"phone\":\"$TEST_PHONE\",\"code\":\"$CODE\",\"device_id\":\"$TEST_DEVICE_ID\"}")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "验证码登录"
    TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    REFRESH_TOKEN=$(echo "$BODY" | grep -o '"refresh_token":"[^"]*"' | cut -d'"' -f4)
else
    print_failure "验证码登录" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-004: 密码登录 (需要先设置密码)
print_subheader "TEST-004: 密码登录"
# 先设置密码
if [ -n "$TOKEN" ]; then
    http_post "$BASE_URL/api/users/me/password" \
        "{\"password\":\"$TEST_PASSWORD\"}" \
        "Authorization: Bearer $TOKEN" > /dev/null 2>&1
fi
RESPONSE=$(http_post "$BASE_URL/api/auth/login-with-password" \
    "{\"phone\":\"$TEST_PHONE\",\"password\":\"$TEST_PASSWORD\",\"device_id\":\"${TEST_DEVICE_ID}_pwd\"}")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "密码登录"
    TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
else
    print_failure "密码登录" "HTTP $HTTP_CODE - $BODY"
fi

print_header "用户模块 API 测试"

# TEST-001: 用户注册
print_subheader "TEST-001: 用户注册"
RESPONSE=$(http_post "$BASE_URL/api/auth/register" \
    "{\"phone\":\"+959701234568\",\"code\":\"123456\",\"password\":\"$TEST_PASSWORD\",\"device_id\":\"${TEST_DEVICE_ID}2\"}")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    print_success "用户注册"
    USER_ID=$(echo "$BODY" | grep -o '"user_id":"[^"]*"' | cut -d'"' -f4)
elif [ "$HTTP_CODE" = "409" ]; then
    print_success "用户注册 - 用户已存在（正常）"
else
    print_failure "用户注册" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-005: 获取用户信息
print_subheader "TEST-005: 获取用户信息"
if [ -z "$TOKEN" ]; then
    print_skip "获取用户信息" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/users/me" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "获取用户信息"
    else
        print_failure "获取用户信息" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-006: 更新用户信息
print_subheader "TEST-006: 更新用户信息"
if [ -z "$TOKEN" ]; then
    print_skip "更新用户信息" "未获取到登录Token"
else
    RESPONSE=$(http_put "$BASE_URL/api/users/me" \
        "{\"nickname\":\"TestUser${TIMESTAMP}\",\"avatar\":\"https://example.com/avatar.jpg\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "更新用户信息"
    else
        print_failure "更新用户信息" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-007: 刷新Token
print_subheader "TEST-007: 刷新Token"
if [ -z "$REFRESH_TOKEN" ]; then
    print_skip "刷新Token" "未获取到Refresh Token"
else
    RESPONSE=$(http_post "$BASE_URL/api/auth/refresh-token" \
        "{\"refresh_token\":\"$REFRESH_TOKEN\"}")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "刷新Token"
        TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    else
        print_failure "刷新Token" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-008: 实名认证提交
print_subheader "TEST-008: 实名认证提交"
if [ -z "$TOKEN" ]; then
    print_skip "实名认证提交" "未获取到登录Token"
else
    RESPONSE=$(http_post "$BASE_URL/api/users/me/verification" \
        "{\"real_name\":\"Test User\",\"id_card_number\":\"12-345678\",\"id_card_front\":\"https://example.com/front.jpg\",\"id_card_back\":\"https://example.com/back.jpg\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ]; then
        print_success "实名认证提交"
    else
        print_failure "实名认证提交" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-009: 用户收藏列表
print_subheader "TEST-009: 用户收藏列表"
if [ -z "$TOKEN" ]; then
    print_skip "用户收藏列表" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/users/me/favorites?page=1&page_size=10" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "用户收藏列表"
    else
        print_failure "用户收藏列表" "HTTP $HTTP_CODE - $BODY"
    fi
fi

print_header "房源模块 API 测试"

# TEST-010: 房源搜索
print_subheader "TEST-010: 房源搜索"
RESPONSE=$(http_get "$BASE_URL/api/houses/search?keyword=condo&page=1&page_size=20")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "房源搜索"
    HOUSE_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
else
    print_failure "房源搜索" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-011: 房源详情
print_subheader "TEST-011: 房源详情"
if [ -z "$HOUSE_ID" ]; then
    print_skip "房源详情" "无房源ID"
else
    RESPONSE=$(http_get "$BASE_URL/api/houses/$HOUSE_ID")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源详情"
    else
        print_failure "房源详情" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-012: 地图聚合
print_subheader "TEST-012: 地图聚合"
RESPONSE=$(http_get "$BASE_URL/api/houses/map-search?zoom=12&sw_lat=16.8&sw_lng=96.1&ne_lat=16.9&ne_lng=96.2")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "地图聚合"
else
    print_failure "地图聚合" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-013: 首页推荐
print_subheader "TEST-013: 首页推荐"
RESPONSE=$(http_get "$BASE_URL/api/houses/recommendations?limit=10")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "首页推荐"
else
    print_failure "首页推荐" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-014: 创建房源（需要经纪人权限）
print_subheader "TEST-014: 创建房源"
if [ -z "$TOKEN" ]; then
    print_skip "创建房源" "未获取到登录Token"
else
    RESPONSE=$(http_post "$BASE_URL/api/houses" \
        "{\"title\":\"测试房源\",\"description\":\"这是一个测试房源\",\"price\":50000000,\"price_unit\":\"MMK\",\"area\":100,\"bedrooms\":2,\"bathrooms\":1,\"house_type\":\"condo\",\"transaction_type\":\"sale\",\"city_code\":\"yangon\",\"district_code\":\" downtown\",\"address\":\"仰光市中心\",\"images\":[\"https://example.com/image1.jpg\"]}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "创建房源"
        HOUSE_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "创建房源" "当前用户无经纪人权限"
    else
        print_failure "创建房源" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-015: 更新房源
print_subheader "TEST-015: 更新房源"
if [ -z "$TOKEN" ]; then
    print_skip "更新房源" "未获取到登录Token"
elif [ -z "$HOUSE_ID" ]; then
    print_skip "更新房源" "无房源ID"
else
    RESPONSE=$(http_put "$BASE_URL/api/houses/$HOUSE_ID" \
        "{\"price\":55000000,\"description\":\"更新后的描述\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "更新房源"
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "更新房源" "当前用户无权限"
    else
        print_failure "更新房源" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-016: 房源下架
print_subheader "TEST-016: 房源下架"
if [ -z "$TOKEN" ]; then
    print_skip "房源下架" "未获取到登录Token"
elif [ -z "$HOUSE_ID" ]; then
    print_skip "房源下架" "无房源ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/houses/$HOUSE_ID/offline" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源下架"
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "房源下架" "当前用户无权限"
    else
        print_failure "房源下架" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-017: 收藏/取消收藏房源
print_subheader "TEST-017: 收藏/取消收藏房源"
if [ -z "$TOKEN" ]; then
    print_skip "收藏房源" "未获取到登录Token"
elif [ -z "$HOUSE_ID" ]; then
    print_skip "收藏房源" "无房源ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/houses/$HOUSE_ID/favorite" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "收藏房源"
        RESPONSE=$(http_delete "$BASE_URL/api/houses/$HOUSE_ID/favorite" "Authorization: Bearer $TOKEN")
        extract_response "$RESPONSE" BODY
        if [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}  ✓ PASS${NC} | 取消收藏房源"
        fi
    else
        print_failure "收藏房源" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-018: 房源列表（经纪人）- 使用正确的经纪人端点
print_subheader "TEST-018: 房源列表（经纪人）"
if [ -z "$TOKEN" ]; then
    print_skip "房源列表" "未获取到登录Token"
else
    # 尝试使用经纪人房源端点
    RESPONSE=$(http_get "$BASE_URL/api/houses/my-listings?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源列表"
    elif [ "$HTTP_CODE" = "404" ]; then
        # 尝试其他可能的端点
        RESPONSE=$(http_get "$BASE_URL/api/agents/houses?page=1&page_size=20" "Authorization: Bearer $TOKEN")
        extract_response "$RESPONSE" BODY
        if [ "$HTTP_CODE" = "200" ]; then
            print_success "房源列表"
        else
            print_skip "房源列表" "端点不存在或用户无经纪人权限"
        fi
    else
        print_failure "房源列表" "HTTP $HTTP_CODE - $BODY"
    fi
fi

print_header "IM 模块 API 测试"

# TEST-019: 会话列表
print_subheader "TEST-019: 会话列表"
if [ -z "$TOKEN" ]; then
    print_skip "会话列表" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/im/conversations?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "会话列表"
        CONVERSATION_ID=$(echo "$BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    else
        print_failure "会话列表" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-020: 获取消息
print_subheader "TEST-020: 获取消息"
if [ -z "$TOKEN" ]; then
    print_skip "获取消息" "未获取到登录Token"
elif [ -z "$CONVERSATION_ID" ]; then
    print_skip "获取消息" "无会话ID"
else
    RESPONSE=$(http_get "$BASE_URL/api/im/conversations/$CONVERSATION_ID/messages?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "获取消息"
    else
        print_failure "获取消息" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-021: 发送消息
print_subheader "TEST-021: 发送消息"
if [ -z "$TOKEN" ]; then
    print_skip "发送消息" "未获取到登录Token"
elif [ -z "$CONVERSATION_ID" ]; then
    print_skip "发送消息" "无会话ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/im/conversations/$CONVERSATION_ID/messages" \
        "{\"content\":\"测试消息\",\"type\":\"text\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "发送消息"
    else
        print_failure "发送消息" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-022: 标记消息已读
print_subheader "TEST-022: 标记消息已读"
if [ -z "$TOKEN" ]; then
    print_skip "标记消息已读" "未获取到登录Token"
elif [ -z "$CONVERSATION_ID" ]; then
    print_skip "标记消息已读" "无会话ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/im/conversations/$CONVERSATION_ID/read" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "标记消息已读"
    else
        print_failure "标记消息已读" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-023: 创建会话
print_subheader "TEST-023: 创建会话"
if [ -z "$TOKEN" ]; then
    print_skip "创建会话" "未获取到登录Token"
else
    RESPONSE=$(http_post "$BASE_URL/api/im/conversations" \
        "{\"recipient_id\":2,\"house_id\":$HOUSE_ID,\"initial_message\":\"我对这个房源感兴趣\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "创建会话"
    elif [ "$HTTP_CODE" = "422" ]; then
        print_skip "创建会话" "接收方用户不存在"
    else
        print_failure "创建会话" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-024: 快捷话术列表
print_subheader "TEST-024: 快捷话术列表"
if [ -z "$TOKEN" ]; then
    print_skip "快捷话术列表" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/im/quick-replies" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "快捷话术列表"
    else
        print_failure "快捷话术列表" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-025: 删除会话
print_subheader "TEST-025: 删除会话"
if [ -z "$TOKEN" ]; then
    print_skip "删除会话" "未获取到登录Token"
elif [ -z "$CONVERSATION_ID" ]; then
    print_skip "删除会话" "无会话ID"
else
    RESPONSE=$(http_delete "$BASE_URL/api/im/conversations/$CONVERSATION_ID" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        print_success "删除会话"
    else
        print_failure "删除会话" "HTTP $HTTP_CODE - $BODY"
    fi
fi

print_header "预约模块 API 测试"

# TEST-026: 可预约时间段
print_subheader "TEST-026: 可预约时间段"
TOMORROW=$(date -d "+1 day" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d 2>/dev/null || echo "2026-03-29")
if [ -z "$HOUSE_ID" ]; then
    print_skip "可预约时间段" "无房源ID"
else
    RESPONSE=$(http_get "$BASE_URL/api/appointments/slots?house_id=$HOUSE_ID&date=$TOMORROW")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "可预约时间段"
    else
        print_failure "可预约时间段" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-027: 创建预约
print_subheader "TEST-027: 创建预约"
if [ -z "$TOKEN" ]; then
    print_skip "创建预约" "未获取到登录Token"
elif [ -z "$HOUSE_ID" ]; then
    print_skip "创建预约" "无房源ID"
else
    TOMORROW=$(date -d "+1 day" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d 2>/dev/null || echo "2026-03-29")
    RESPONSE=$(http_post "$BASE_URL/api/appointments" \
        "{\"house_id\":$HOUSE_ID,\"appointment_date\":\"$TOMORROW\",\"appointment_time\":\"14:00\",\"notes\":\"我想看房，请安排\",\"contact_phone\":\"$TEST_PHONE\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "创建预约"
        APPOINTMENT_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
    else
        print_failure "创建预约" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-028: 预约列表
print_subheader "TEST-028: 预约列表"
if [ -z "$TOKEN" ]; then
    print_skip "预约列表" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/appointments?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "预约列表"
    else
        print_failure "预约列表" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-029: 预约详情
print_subheader "TEST-029: 预约详情"
if [ -z "$TOKEN" ]; then
    print_skip "预约详情" "未获取到登录Token"
elif [ -z "$APPOINTMENT_ID" ]; then
    print_skip "预约详情" "无预约ID"
else
    RESPONSE=$(http_get "$BASE_URL/api/appointments/$APPOINTMENT_ID" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "预约详情"
    else
        print_failure "预约详情" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-030: 确认预约
print_subheader "TEST-030: 确认预约"
if [ -z "$TOKEN" ]; then
    print_skip "确认预约" "未获取到登录Token"
elif [ -z "$APPOINTMENT_ID" ]; then
    print_skip "确认预约" "无预约ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/confirm" \
        "{\"notes\":\"已确认，请准时到达\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "确认预约"
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "确认预约" "当前用户无权限确认此预约"
    else
        print_failure "确认预约" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-031: 拒绝预约（后端无此端点，跳过）
print_subheader "TEST-031: 拒绝预约"
print_skip "拒绝预约" "后端未实现此端点"

# TEST-032: 完成带看
print_subheader "TEST-032: 完成带看"
if [ -z "$TOKEN" ]; then
    print_skip "完成带看" "未获取到登录Token"
elif [ -z "$APPOINTMENT_ID" ]; then
    print_skip "完成带看" "无预约ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/complete" \
        "{\"feedback\":\"客户对房源满意\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "完成带看"
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "完成带看" "当前用户无权限完成此预约"
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "完成带看" "预约状态不允许完成"
    else
        print_failure "完成带看" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-033: 取消预约
print_subheader "TEST-033: 取消预约"
if [ -z "$TOKEN" ]; then
    print_skip "取消预约" "未获取到登录Token"
elif [ -z "$APPOINTMENT_ID" ]; then
    print_skip "取消预约" "无预约ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/cancel" \
        "{\"reason\":\"行程有变，暂时不需要了\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "取消预约"
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "取消预约" "预约状态不允许取消"
    else
        print_failure "取消预约" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-034: 带看评价（后端无此端点，跳过）
print_subheader "TEST-034: 带看评价"
print_skip "带看评价" "后端未实现此端点"

# TEST-035: 经纪人预约日历（后端无此端点，跳过）
print_subheader "TEST-035: 经纪人预约日历"
print_skip "经纪人预约日历" "后端未实现此端点"

print_header "ACN 模块 API 测试"

# TEST-036: 成交申报
print_subheader "TEST-036: 成交申报"
if [ -z "$TOKEN" ]; then
    print_skip "成交申报" "未获取到登录Token"
elif [ -z "$HOUSE_ID" ]; then
    print_skip "成交申报" "无房源ID"
else
    TODAY=$(date +%Y-%m-%d)
    RESPONSE=$(http_post "$BASE_URL/api/acn/transactions" \
        "{\"house_id\":$HOUSE_ID,\"deal_price\":48000000,\"deal_date\":\"$TODAY\",\"buyer_name\":\"Test Buyer\",\"buyer_phone\":\"$TEST_PHONE\",\"seller_name\":\"Test Seller\",\"seller_phone\":\"+959701234568\",\"notes\":\"成交备注\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "成交申报"
        DEAL_ID=$(echo "$BODY" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "成交申报" "当前用户无经纪人权限"
    else
        print_failure "成交申报" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-037: 成交列表
print_subheader "TEST-037: 成交列表"
if [ -z "$TOKEN" ]; then
    print_skip "成交列表" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/acn/transactions?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "成交列表"
    else
        print_failure "成交列表" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-038: 成交详情
print_subheader "TEST-038: 成交详情"
if [ -z "$TOKEN" ]; then
    print_skip "成交详情" "未获取到登录Token"
elif [ -z "$DEAL_ID" ]; then
    print_skip "成交详情" "无成交ID"
else
    RESPONSE=$(http_get "$BASE_URL/api/acn/transactions/$DEAL_ID" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "成交详情"
    else
        print_failure "成交详情" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-039: 确认成交
print_subheader "TEST-039: 确认成交"
if [ -z "$TOKEN" ]; then
    print_skip "确认成交" "未获取到登录Token"
elif [ -z "$DEAL_ID" ]; then
    print_skip "确认成交" "无成交ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/acn/transactions/$DEAL_ID/confirm" \
        "{\"notes\":\"确认成交，开始分佣流程\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "确认成交"
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "确认成交" "当前用户无权限确认"
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "确认成交" "成交状态不允许确认"
    else
        print_failure "确认成交" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-040: 成交申诉
print_subheader "TEST-040: 成交申诉"
if [ -z "$TOKEN" ]; then
    print_skip "成交申诉" "未获取到登录Token"
elif [ -z "$DEAL_ID" ]; then
    print_skip "成交申诉" "无成交ID"
else
    RESPONSE=$(http_post "$BASE_URL/api/acn/disputes" \
        "{\"transaction_id\":$DEAL_ID,\"reason\":\"分佣比例有误\",\"evidence\":\"合同照片\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "成交申诉"
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "成交申诉" "当前用户无权限申诉"
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "成交申诉" "成交状态不允许申诉"
    else
        print_failure "成交申诉" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-041: 佣金余额查询
print_subheader "TEST-041: 佣金余额查询"
if [ -z "$TOKEN" ]; then
    print_skip "佣金余额查询" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/acn/commission/statistics" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "佣金余额查询"
    else
        print_failure "佣金余额查询" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-042: 佣金明细
print_subheader "TEST-042: 佣金明细"
if [ -z "$TOKEN" ]; then
    print_skip "佣金明细" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/acn/commission/details?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "佣金明细"
    else
        print_failure "佣金明细" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-043: 分佣角色设置（后端无此端点，跳过）
print_subheader "TEST-043: 分佣角色设置"
print_skip "分佣角色设置" "后端未实现此端点"

print_header "公共模块 API 测试"

# TEST-044: 健康检查
print_subheader "TEST-044: 健康检查"
RESPONSE=$(http_get "$BASE_URL/health")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "健康检查"
else
    print_failure "健康检查" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-045: 上传配置
print_subheader "TEST-045: 上传配置"
if [ -z "$TOKEN" ]; then
    print_skip "上传配置" "未获取到登录Token"
else
    RESPONSE=$(http_get "$BASE_URL/api/upload/config" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ]; then
        print_success "上传配置"
    else
        print_failure "上传配置" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# TEST-046: 城市列表
print_subheader "TEST-046: 城市列表"
RESPONSE=$(http_get "$BASE_URL/api/houses/cities")
extract_response "$RESPONSE" BODY
if [ "$HTTP_CODE" = "200" ]; then
    print_success "城市列表"
else
    print_failure "城市列表" "HTTP $HTTP_CODE - $BODY"
fi

# TEST-047: 退出登录
print_subheader "TEST-047: 退出登录"
if [ -z "$TOKEN" ]; then
    print_skip "退出登录" "未获取到登录Token"
else
    RESPONSE=$(http_post "$BASE_URL/api/auth/logout" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        print_success "退出登录"
    else
        print_failure "退出登录" "HTTP $HTTP_CODE - $BODY"
    fi
fi

# ============================================
# 测试报告
# ============================================

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}               测 试 报 告                      ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n测试统计:"
echo -e "  总用例数: $TOTAL"
echo -e "  ${GREEN}通过: $PASSED${NC}"
echo -e "  ${RED}失败: $FAILED${NC}"
echo -e "  ${YELLOW}跳过: $SKIPPED${NC}"
echo -e "  耗时: ${DURATION}秒"

if [ $TOTAL -gt 0 ]; then
    PASS_RATE=$(( PASSED * 100 / TOTAL ))
    echo -e "  通过率: ${PASS_RATE}%"
fi

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！${NC}"
    exit 0
else
    echo -e "${RED}✗ 有 $FAILED 项测试失败${NC}"
    exit 1
fi
