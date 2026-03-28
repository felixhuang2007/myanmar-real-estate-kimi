#!/bin/bash
# 缅甸房产平台 - API 完整测试套件
# 目标服务器: 43.163.122.42
# 测试用例数: 47个（用户9 + 房源9 + IM7 + 预约10 + ACN8）

set -e

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
TEST_DEVICE_ID="test_device_$(date +%s)"

# 运行时变量
TOKEN=""
REFRESH_TOKEN=""
USER_ID=""
HOUSE_ID=""
APPOINTMENT_ID=""
CONVERSATION_ID=""
DEAL_ID=""
COMMISSION_BALANCE=""

# 测试结果统计
PASSED=0
FAILED=0
SKIPPED=0
TOTAL=0

# 测试开始时间
START_TIME=$(date +%s)

# 测试报告数组
declare -a TEST_RESULTS

# ============================================
# 工具函数
# ============================================

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
    ((PASSED++))
    TOTAL=$((TOTAL + 1))
    TEST_RESULTS+=("{\"name\":\"$1\",\"status\":\"passed\",\"duration\":\"$2\"}")
}

print_failure() {
    echo -e "${RED}  ✗ FAIL${NC} | $1"
    echo -e "${RED}         Error: $2${NC}"
    ((FAILED++))
    TOTAL=$((TOTAL + 1))
    TEST_RESULTS+=("{\"name\":\"$1\",\"status\":\"failed\",\"error\":\"$2\"}")
}

print_skip() {
    echo -e "${YELLOW}  ⊘ SKIP${NC} | $1"
    ((SKIPPED++))
    TOTAL=$((TOTAL + 1))
    TEST_RESULTS+=("{\"name\":\"$1\",\"status\":\"skipped\",\"reason\":\"$2\"}")
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

# 检查 JSON 字段
json_has_field() {
    local json="$1"
    local field="$2"
    [[ "$json" == *"\"$field\""* ]]
}

# ============================================
# 用户模块测试 (9个用例)
# ============================================

print_header "用户模块 API 测试"

# TEST-001: 用户注册
test_user_register() {
    print_subheader "TEST-001: 用户注册"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_post "$BASE_URL/api/auth/register" \
        "{\"phone\":\"$TEST_PHONE\",\"code\":\"123456\",\"password\":\"$TEST_PASSWORD\",\"device_id\":\"$TEST_DEVICE_ID\"}")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "用户注册" "$duration"
        USER_ID=$(echo "$BODY" | grep -o '"user_id":"[^"]*"' | cut -d'"' -f4)
        return 0
    elif [ "$HTTP_CODE" = "409" ]; then
        print_success "用户注册 - 用户已存在（正常）" "$duration"
        return 0
    else
        print_failure "用户注册" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-002: 发送验证码
test_user_send_code() {
    print_subheader "TEST-002: 发送验证码"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_post "$BASE_URL/api/auth/send-verification-code" \
        "{\"phone\":\"$TEST_PHONE\",\"type\":\"login\"}")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "发送验证码" "$duration"
        # 保存验证码（测试环境可能返回）
        VERIFICATION_CODE=$(echo "$BODY" | grep -o '"code":"[0-9]*"' | cut -d'"' -f4)
        return 0
    elif [ "$HTTP_CODE" = "429" ]; then
        print_skip "发送验证码" "请求过于频繁，请稍后再试"
        return 0
    else
        print_failure "发送验证码" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-003: 验证码登录
test_user_login() {
    print_subheader "TEST-003: 验证码登录"
    local start=$(($(date +%s * 1000)))

    # 如果没有验证码，使用测试验证码
    local code="${VERIFICATION_CODE:-123456}"

    RESPONSE=$(http_post "$BASE_URL/api/auth/login" \
        "{\"phone\":\"$TEST_PHONE\",\"code\":\"$code\",\"device_id\":\"$TEST_DEVICE_ID\"}")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "验证码登录" "$duration"
        TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        REFRESH_TOKEN=$(echo "$BODY" | grep -o '"refresh_token":"[^"]*"' | cut -d'"' -f4)
        return 0
    else
        print_failure "验证码登录" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-004: 密码登录
test_user_password_login() {
    print_subheader "TEST-004: 密码登录"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_post "$BASE_URL/api/auth/login-with-password" \
        "{\"phone\":\"$TEST_PHONE\",\"password\":\"$TEST_PASSWORD\",\"device_id\":\"${TEST_DEVICE_ID}_pwd\"}")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "密码登录" "$duration"
        TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        return 0
    else
        print_failure "密码登录" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-005: 获取用户信息
test_user_profile_get() {
    print_subheader "TEST-005: 获取用户信息"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "获取用户信息" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/users/profile" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "获取用户信息" "$duration"
        return 0
    else
        print_failure "获取用户信息" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-006: 更新用户信息
test_user_profile_update() {
    print_subheader "TEST-006: 更新用户信息"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "更新用户信息" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_put "$BASE_URL/api/users/profile" \
        "{\"nickname\":\"TestUser$(date +%s)\",\"avatar\":\"https://example.com/avatar.jpg\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "更新用户信息" "$duration"
        return 0
    else
        print_failure "更新用户信息" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-007: 刷新Token
test_user_refresh_token() {
    print_subheader "TEST-007: 刷新Token"
    local start=$(($(date +%s * 1000)))

    if [ -z "$REFRESH_TOKEN" ]; then
        print_skip "刷新Token" "未获取到Refresh Token"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/auth/refresh-token" \
        "{\"refresh_token\":\"$REFRESH_TOKEN\"}")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "刷新Token" "$duration"
        TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        return 0
    else
        print_failure "刷新Token" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-008: 实名认证提交
test_user_verification_submit() {
    print_subheader "TEST-008: 实名认证提交"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "实名认证提交" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/users/verification" \
        "{\"real_name\":\"Test User\",\"id_card\":\"12-345678\",\"id_card_front\":\"https://example.com/front.jpg\",\"id_card_back\":\"https://example.com/back.jpg\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    # 实名认证可能需要审核，返回 202 或 200 都算成功
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ] || [ "$HTTP_CODE" = "202" ]; then
        print_success "实名认证提交" "$duration"
        return 0
    else
        print_failure "实名认证提交" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-009: 用户收藏列表
test_user_favorites() {
    print_subheader "TEST-009: 用户收藏列表"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "用户收藏列表" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/users/favorites?page=1&page_size=10" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "用户收藏列表" "$duration"
        return 0
    else
        print_failure "用户收藏列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# ============================================
# 房源模块测试 (9个用例)
# ============================================

print_header "房源模块 API 测试"

# TEST-010: 房源搜索
test_house_search() {
    print_subheader "TEST-010: 房源搜索"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_get "$BASE_URL/api/houses/search?keyword= condo&page=1&page_size=20")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源搜索" "$duration"
        # 保存第一个房源ID供后续测试使用
        HOUSE_ID=$(echo "$BODY" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)
        return 0
    else
        print_failure "房源搜索" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-011: 房源详情
test_house_detail() {
    print_subheader "TEST-011: 房源详情"
    local start=$(($(date +%s * 1000)))

    # 如果没有房源ID，跳过
    if [ -z "$HOUSE_ID" ]; then
        # 尝试搜索获取一个房源ID
        RESPONSE=$(http_get "$BASE_URL/api/houses/search?page=1&page_size=1")
        extract_response "$RESPONSE" BODY
        HOUSE_ID=$(echo "$BODY" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)
    fi

    if [ -z "$HOUSE_ID" ]; then
        print_skip "房源详情" "系统中暂无房源数据"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/houses/$HOUSE_ID")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源详情" "$duration"
        return 0
    else
        print_failure "房源详情" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-012: 地图聚合
test_house_map_aggregate() {
    print_subheader "TEST-012: 地图聚合"
    local start=$(($(date +%s * 1000)))

    # 仰光地区坐标范围
    RESPONSE=$(http_get "$BASE_URL/api/houses/map/aggregate?zoom=12&bounds=16.8,96.1|16.9,96.2")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "地图聚合" "$duration"
        return 0
    else
        print_failure "地图聚合" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-013: 首页推荐
test_house_recommend() {
    print_subheader "TEST-013: 首页推荐"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_get "$BASE_URL/api/houses/recommend?limit=10")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "首页推荐" "$duration"
        return 0
    else
        print_failure "首页推荐" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-014: 创建房源（需要经纪人权限）
test_house_create() {
    print_subheader "TEST-014: 创建房源"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "创建房源" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/houses" \
        "{\"title\":\"测试房源 $(date '+%Y-%m-%d %H:%M:%S')\",\"description\":\"这是一个测试房源\",\"price\":50000000,\"area\":100,\"bedrooms\":2,\"bathrooms\":1,\"location\":{\"address\":\"仰光市中心\",\"latitude\":16.8661,\"longitude\":96.1951},\"property_type\":\"condo\",\"transaction_type\":\"sale\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "创建房源" "$duration"
        HOUSE_ID=$(echo "$BODY" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "创建房源" "当前用户无经纪人权限"
        return 1
    else
        print_failure "创建房源" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-015: 更新房源
test_house_update() {
    print_subheader "TEST-015: 更新房源"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "更新房源" "未获取到登录Token"
        return 1
    fi

    if [ -z "$HOUSE_ID" ]; then
        print_skip "更新房源" "无房源ID"
        return 1
    fi

    RESPONSE=$(http_put "$BASE_URL/api/houses/$HOUSE_ID" \
        "{\"price\":55000000,\"description\":\"更新后的描述 $(date)\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "更新房源" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "更新房源" "当前用户无权限"
        return 1
    else
        print_failure "更新房源" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-016: 房源下架
test_house_offline() {
    print_subheader "TEST-016: 房源下架"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "房源下架" "未获取到登录Token"
        return 1
    fi

    if [ -z "$HOUSE_ID" ]; then
        print_skip "房源下架" "无房源ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/houses/$HOUSE_ID/offline" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源下架" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "房源下架" "当前用户无权限"
        return 1
    else
        print_failure "房源下架" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-017: 收藏/取消收藏房源
test_house_favorite() {
    print_subheader "TEST-017: 收藏/取消收藏房源"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "收藏房源" "未获取到登录Token"
        return 1
    fi

    if [ -z "$HOUSE_ID" ]; then
        print_skip "收藏房源" "无房源ID"
        return 1
    fi

    # 收藏
    RESPONSE=$(http_post "$BASE_URL/api/houses/$HOUSE_ID/favorite" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "收藏房源" "$duration"

        # 取消收藏
        RESPONSE=$(http_delete "$BASE_URL/api/houses/$HOUSE_ID/favorite" "Authorization: Bearer $TOKEN")
        extract_response "$RESPONSE" BODY

        if [ "$HTTP_CODE" = "200" ]; then
            print_success "取消收藏房源" "$duration"
        fi
        return 0
    else
        print_failure "收藏房源" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-018: 房源列表（经纪人）
test_house_list() {
    print_subheader "TEST-018: 房源列表（经纪人）"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "房源列表" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/houses?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "房源列表" "$duration"
        return 0
    else
        print_failure "房源列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# ============================================
# IM 模块测试 (7个用例)
# ============================================

print_header "IM 模块 API 测试"

# TEST-019: 会话列表
test_im_conversations() {
    print_subheader "TEST-019: 会话列表"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "会话列表" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/im/conversations?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "会话列表" "$duration"
        CONVERSATION_ID=$(echo "$BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        return 0
    else
        print_failure "会话列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-020: 获取消息
test_im_messages_get() {
    print_subheader "TEST-020: 获取消息"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "获取消息" "未获取到登录Token"
        return 1
    fi

    if [ -z "$CONVERSATION_ID" ]; then
        # 尝试获取会话列表
        RESPONSE=$(http_get "$BASE_URL/api/im/conversations?page=1&page_size=1" "Authorization: Bearer $TOKEN")
        extract_response "$RESPONSE" BODY
        CONVERSATION_ID=$(echo "$BODY" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    fi

    if [ -z "$CONVERSATION_ID" ]; then
        print_skip "获取消息" "无会话ID"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/im/conversations/$CONVERSATION_ID/messages?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "获取消息" "$duration"
        return 0
    else
        print_failure "获取消息" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-021: 发送消息
test_im_message_send() {
    print_subheader "TEST-021: 发送消息"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "发送消息" "未获取到登录Token"
        return 1
    fi

    if [ -z "$CONVERSATION_ID" ]; then
        print_skip "发送消息" "无会话ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/im/conversations/$CONVERSATION_ID/messages" \
        "{\"content\":\"测试消息 $(date)\",\"type\":\"text\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "发送消息" "$duration"
        return 0
    else
        print_failure "发送消息" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-022: 标记消息已读
test_im_message_read() {
    print_subheader "TEST-022: 标记消息已读"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "标记消息已读" "未获取到登录Token"
        return 1
    fi

    if [ -z "$CONVERSATION_ID" ]; then
        print_skip "标记消息已读" "无会话ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/im/conversations/$CONVERSATION_ID/read" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "标记消息已读" "$duration"
        return 0
    else
        print_failure "标记消息已读" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-023: 创建会话
test_im_conversation_create() {
    print_subheader "TEST-023: 创建会话"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "创建会话" "未获取到登录Token"
        return 1
    fi

    # 需要另一个用户ID作为接收方
    RESPONSE=$(http_post "$BASE_URL/api/im/conversations" \
        "{\"recipient_id\":2,\"house_id\":$HOUSE_ID,\"initial_message\":\"我对这个房源感兴趣\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "创建会话" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "422" ]; then
        print_skip "创建会话" "接收方用户不存在"
        return 1
    else
        print_failure "创建会话" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-024: 快捷话术列表
test_im_quick_replies() {
    print_subheader "TEST-024: 快捷话术列表"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "快捷话术列表" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/im/quick-replies" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "快捷话术列表" "$duration"
        return 0
    else
        print_failure "快捷话术列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-025: 删除会话
test_im_conversation_delete() {
    print_subheader "TEST-025: 删除会话"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "删除会话" "未获取到登录Token"
        return 1
    fi

    if [ -z "$CONVERSATION_ID" ]; then
        print_skip "删除会话" "无会话ID"
        return 1
    fi

    RESPONSE=$(http_delete "$BASE_URL/api/im/conversations/$CONVERSATION_ID" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        print_success "删除会话" "$duration"
        return 0
    else
        print_failure "删除会话" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# ============================================
# 预约模块测试 (10个用例)
# ============================================

print_header "预约模块 API 测试"

# TEST-026: 可预约时间段
test_appointment_slots() {
    print_subheader "TEST-026: 可预约时间段"
    local start=$(($(date +%s * 1000)))

    if [ -z "$HOUSE_ID" ]; then
        print_skip "可预约时间段" "无房源ID"
        return 1
    fi

    # 获取明天的日期
    TOMORROW=$(date -d "+1 day" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d)

    RESPONSE=$(http_get "$BASE_URL/api/appointments/slots?house_id=$HOUSE_ID&date=$TOMORROW")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "可预约时间段" "$duration"
        return 0
    else
        print_failure "可预约时间段" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-027: 创建预约
test_appointment_create() {
    print_subheader "TEST-027: 创建预约"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "创建预约" "未获取到登录Token"
        return 1
    fi

    if [ -z "$HOUSE_ID" ]; then
        print_skip "创建预约" "无房源ID"
        return 1
    fi

    TOMORROW=$(date -d "+1 day" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d)

    RESPONSE=$(http_post "$BASE_URL/api/appointments" \
        "{\"house_id\":$HOUSE_ID,\"appointment_date\":\"$TOMORROW\",\"appointment_time\":\"14:00\",\"notes\":\"我想看房，请安排\",\"contact_phone\":\"$TEST_PHONE\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "创建预约" "$duration"
        APPOINTMENT_ID=$(echo "$BODY" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)
        return 0
    else
        print_failure "创建预约" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-028: 预约列表
test_appointment_list() {
    print_subheader "TEST-028: 预约列表"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "预约列表" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/appointments?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "预约列表" "$duration"
        return 0
    else
        print_failure "预约列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-029: 预约详情
test_appointment_detail() {
    print_subheader "TEST-029: 预约详情"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "预约详情" "未获取到登录Token"
        return 1
    fi

    if [ -z "$APPOINTMENT_ID" ]; then
        print_skip "预约详情" "无预约ID"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/appointments/$APPOINTMENT_ID" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "预约详情" "$duration"
        return 0
    else
        print_failure "预约详情" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-030: 确认预约
test_appointment_confirm() {
    print_subheader "TEST-030: 确认预约"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "确认预约" "未获取到登录Token"
        return 1
    fi

    if [ -z "$APPOINTMENT_ID" ]; then
        print_skip "确认预约" "无预约ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/confirm" \
        "{\"notes\":\"已确认，请准时到达\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "确认预约" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "确认预约" "当前用户无权限确认此预约"
        return 1
    else
        print_failure "确认预约" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-031: 拒绝预约
test_appointment_reject() {
    print_subheader "TEST-031: 拒绝预约"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "拒绝预约" "未获取到登录Token"
        return 1
    fi

    if [ -z "$APPOINTMENT_ID" ]; then
        print_skip "拒绝预约" "无预约ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/reject" \
        "{\"reason\":\"该时间段已被预约\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "拒绝预约" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "拒绝预约" "当前用户无权限拒绝此预约"
        return 1
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "拒绝预约" "预约状态不允许拒绝"
        return 1
    else
        print_failure "拒绝预约" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-032: 完成带看
test_appointment_complete() {
    print_subheader "TEST-032: 完成带看"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "完成带看" "未获取到登录Token"
        return 1
    fi

    if [ -z "$APPOINTMENT_ID" ]; then
        print_skip "完成带看" "无预约ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/complete" \
        "{\"feedback\":\"客户对房源满意\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "完成带看" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "完成带看" "当前用户无权限完成此预约"
        return 1
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "完成带看" "预约状态不允许完成"
        return 1
    else
        print_failure "完成带看" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-033: 取消预约
test_appointment_cancel() {
    print_subheader "TEST-033: 取消预约"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "取消预约" "未获取到登录Token"
        return 1
    fi

    if [ -z "$APPOINTMENT_ID" ]; then
        print_skip "取消预约" "无预约ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/cancel" \
        "{\"reason\":\"行程有变，暂时不需要了\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "取消预约" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "取消预约" "预约状态不允许取消"
        return 1
    else
        print_failure "取消预约" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-034: 带看评价
test_appointment_review() {
    print_subheader "TEST-034: 带看评价"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "带看评价" "未获取到登录Token"
        return 1
    fi

    if [ -z "$APPOINTMENT_ID" ]; then
        print_skip "带看评价" "无预约ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/appointments/$APPOINTMENT_ID/review" \
        "{\"rating\":5,\"content\":\"经纪人很专业，服务很好！\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "带看评价" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "带看评价" "当前用户无权限评价"
        return 1
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "带看评价" "预约状态不允许评价"
        return 1
    else
        print_failure "带看评价" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-035: 经纪人预约日历
test_appointment_calendar() {
    print_subheader "TEST-035: 经纪人预约日历"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "经纪人预约日历" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/appointments/calendar?month=$(date +%Y-%m)" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "经纪人预约日历" "$duration"
        return 0
    else
        print_failure "经纪人预约日历" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# ============================================
# ACN 模块测试 (8个用例)
# ============================================

print_header "ACN 模块 API 测试"

# TEST-036: 成交申报
test_deal_create() {
    print_subheader "TEST-036: 成交申报"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "成交申报" "未获取到登录Token"
        return 1
    fi

    if [ -z "$HOUSE_ID" ]; then
        print_skip "成交申报" "无房源ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/acn/deals" \
        "{\"house_id\":$HOUSE_ID,\"deal_price\":48000000,\"deal_date\":\"$(date +%Y-%m-%d)\",\"buyer_name\":\"Test Buyer\",\"buyer_phone\":\"$TEST_PHONE\",\"seller_name\":\"Test Seller\",\"seller_phone\":\"+959701234568\",\"notes\":\"成交备注\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "成交申报" "$duration"
        DEAL_ID=$(echo "$BODY" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "成交申报" "当前用户无经纪人权限"
        return 1
    else
        print_failure "成交申报" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-037: 成交列表
test_deal_list() {
    print_subheader "TEST-037: 成交列表"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "成交列表" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/acn/deals?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "成交列表" "$duration"
        return 0
    else
        print_failure "成交列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-038: 成交详情
test_deal_detail() {
    print_subheader "TEST-038: 成交详情"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "成交详情" "未获取到登录Token"
        return 1
    fi

    if [ -z "$DEAL_ID" ]; then
        print_skip "成交详情" "无成交ID"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/acn/deals/$DEAL_ID" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "成交详情" "$duration"
        return 0
    else
        print_failure "成交详情" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-039: 确认成交
test_deal_confirm() {
    print_subheader "TEST-039: 确认成交"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "确认成交" "未获取到登录Token"
        return 1
    fi

    if [ -z "$DEAL_ID" ]; then
        print_skip "确认成交" "无成交ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/acn/deals/$DEAL_ID/confirm" \
        "{\"notes\":\"确认成交，开始分佣流程\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "确认成交" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "确认成交" "当前用户无权限确认"
        return 1
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "确认成交" "成交状态不允许确认"
        return 1
    else
        print_failure "确认成交" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-040: 成交申诉
test_deal_dispute() {
    print_subheader "TEST-040: 成交申诉"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "成交申诉" "未获取到登录Token"
        return 1
    fi

    if [ -z "$DEAL_ID" ]; then
        print_skip "成交申诉" "无成交ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/acn/deals/$DEAL_ID/dispute" \
        "{\"reason\":\"分佣比例有误\",\"evidence\":\"合同照片\"}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
        print_success "成交申诉" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "成交申诉" "当前用户无权限申诉"
        return 1
    elif [ "$HTTP_CODE" = "409" ]; then
        print_skip "成交申诉" "成交状态不允许申诉"
        return 1
    else
        print_failure "成交申诉" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-041: 佣金余额查询
test_commission_balance() {
    print_subheader "TEST-041: 佣金余额查询"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "佣金余额查询" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/acn/commission/balance" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "佣金余额查询" "$duration"
        COMMISSION_BALANCE=$(echo "$BODY" | grep -o '"balance":[0-9.]*' | cut -d':' -f2)
        return 0
    else
        print_failure "佣金余额查询" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-042: 佣金明细
test_commission_records() {
    print_subheader "TEST-042: 佣金明细"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "佣金明细" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/acn/commission/records?page=1&page_size=20" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "佣金明细" "$duration"
        return 0
    else
        print_failure "佣金明细" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-043: 分佣角色设置
test_acn_roles() {
    print_subheader "TEST-043: 分佣角色设置"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "分佣角色设置" "未获取到登录Token"
        return 1
    fi

    if [ -z "$DEAL_ID" ]; then
        print_skip "分佣角色设置" "无成交ID"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/acn/deals/$DEAL_ID/roles" \
        "{\"entry_agent_id\":1,\"entry_percentage\":35,\"maintainer_id\":2,\"maintainer_percentage\":15,\"referrer_id\":null,\"referrer_percentage\":0,\"viewer_id\":3,\"viewer_percentage\":40,\"closer_id\":4,\"closer_percentage\":10}" \
        "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "分佣角色设置" "$duration"
        return 0
    elif [ "$HTTP_CODE" = "403" ]; then
        print_skip "分佣角色设置" "当前用户无权限设置"
        return 1
    else
        print_failure "分佣角色设置" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# ============================================
# 公共模块测试 (4个用例)
# ============================================

print_header "公共模块 API 测试"

# TEST-044: 健康检查
test_health_check() {
    print_subheader "TEST-044: 健康检查"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_get "$BASE_URL/health")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "健康检查" "$duration"
        return 0
    else
        print_failure "健康检查" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-045: 上传配置
test_upload_config() {
    print_subheader "TEST-045: 上传配置"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "上传配置" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_get "$BASE_URL/api/upload/config" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "上传配置" "$duration"
        return 0
    else
        print_failure "上传配置" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-046: 城市列表
test_cities_list() {
    print_subheader "TEST-046: 城市列表"
    local start=$(($(date +%s * 1000)))

    RESPONSE=$(http_get "$BASE_URL/api/cities")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "城市列表" "$duration"
        return 0
    else
        print_failure "城市列表" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# TEST-047: 退出登录
test_user_logout() {
    print_subheader "TEST-047: 退出登录"
    local start=$(($(date +%s * 1000)))

    if [ -z "$TOKEN" ]; then
        print_skip "退出登录" "未获取到登录Token"
        return 1
    fi

    RESPONSE=$(http_post "$BASE_URL/api/auth/logout" "{}" "Authorization: Bearer $TOKEN")
    extract_response "$RESPONSE" BODY

    local end=$(($(date +%s * 1000))); local duration=$((end - start))ms

    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        print_success "退出登录" "$duration"
        return 0
    else
        print_failure "退出登录" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# ============================================
# 主函数
# ============================================

run_all_tests() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     缅甸房产平台 - API 完整测试套件                        ║${NC}"
    echo -e "${BLUE}║     服务器: $SERVER_IP                                     ║${NC}"
    echo -e "${BLUE}║     时间: $(date '+%Y-%m-%d %H:%M:%S')                              ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

    # 用户模块 (9个)
    test_user_send_code
    test_user_login
    test_user_password_login
    test_user_register
    test_user_profile_get
    test_user_profile_update
    test_user_refresh_token
    test_user_verification_submit
    test_user_favorites

    # 房源模块 (9个)
    test_house_search
    test_house_detail
    test_house_map_aggregate
    test_house_recommend
    test_house_create
    test_house_update
    test_house_offline
    test_house_favorite
    test_house_list

    # IM模块 (7个)
    test_im_conversations
    test_im_messages_get
    test_im_message_send
    test_im_message_read
    test_im_conversation_create
    test_im_quick_replies
    test_im_conversation_delete

    # 预约模块 (10个)
    test_appointment_slots
    test_appointment_create
    test_appointment_list
    test_appointment_detail
    test_appointment_confirm
    test_appointment_reject
    test_appointment_complete
    test_appointment_cancel
    test_appointment_review
    test_appointment_calendar

    # ACN模块 (8个)
    test_deal_create
    test_deal_list
    test_deal_detail
    test_deal_confirm
    test_deal_dispute
    test_commission_balance
    test_commission_records
    test_acn_roles

    # 公共模块 (4个)
    test_health_check
    test_upload_config
    test_cities_list
    test_user_logout
}

# 生成测试报告
print_report() {
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

    # 计算通过率
    if [ $TOTAL -gt 0 ]; then
        PASS_RATE=$(( PASSED * 100 / TOTAL ))
        echo -e "  通过率: ${PASS_RATE}%"
    fi

    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # JSON报告输出
    REPORT_FILE="/tmp/api-test-report-$(date +%Y%m%d-%H%M%S).json"
    cat > "$REPORT_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "environment": "production",
  "server": "$SERVER_IP",
  "summary": {
    "total": $TOTAL,
    "passed": $PASSED,
    "failed": $FAILED,
    "skipped": $SKIPPED,
    "duration_seconds": $DURATION,
    "pass_rate": ${PASS_RATE:-0}
  },
  "categories": {
    "user": {"total": 9, "status": "completed"},
    "house": {"total": 9, "status": "completed"},
    "im": {"total": 7, "status": "completed"},
    "appointment": {"total": 10, "status": "completed"},
    "acn": {"total": 8, "status": "completed"},
    "common": {"total": 4, "status": "completed"}
  }
}
EOF

    echo -e "\n详细报告已保存: $REPORT_FILE"

    if [ $FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ 所有测试通过！${NC}"
        exit 0
    else
        echo -e "\n${RED}✗ 有 $FAILED 项测试失败${NC}"
        exit 1
    fi
}

# 运行测试
main() {
    # 检查 curl 是否安装
    if ! command -v curl &> /dev/null; then
        echo "错误: curl 未安装"
        exit 1
    fi

    # 支持命令行参数
    case "$1" in
        --user)
            print_header "用户模块 API 测试"
            test_user_send_code; test_user_login; test_user_password_login
            test_user_register; test_user_profile_get; test_user_profile_update
            test_user_refresh_token; test_user_verification_submit; test_user_favorites
            ;;
        --house)
            print_header "房源模块 API 测试"
            test_house_search; test_house_detail; test_house_map_aggregate
            test_house_recommend; test_house_create; test_house_update
            test_house_offline; test_house_favorite; test_house_list
            ;;
        --im)
            print_header "IM模块 API 测试"
            test_im_conversations; test_im_messages_get; test_im_message_send
            test_im_message_read; test_im_conversation_create; test_im_quick_replies
            test_im_conversation_delete
            ;;
        --appointment)
            print_header "预约模块 API 测试"
            test_appointment_slots; test_appointment_create; test_appointment_list
            test_appointment_detail; test_appointment_confirm; test_appointment_reject
            test_appointment_complete; test_appointment_cancel; test_appointment_review
            test_appointment_calendar
            ;;
        --acn)
            print_header "ACN模块 API 测试"
            test_deal_create; test_deal_list; test_deal_detail; test_deal_confirm
            test_deal_dispute; test_commission_balance; test_commission_records
            test_acn_roles
            ;;
        --help|-h)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --user         只运行用户模块测试"
            echo "  --house        只运行房源模块测试"
            echo "  --im           只运行IM模块测试"
            echo "  --appointment  只运行预约模块测试"
            echo "  --acn          只运行ACN模块测试"
            echo "  --help         显示帮助"
            echo ""
            echo "环境变量:"
            echo "  SERVER_IP      目标服务器IP (默认: 43.163.122.42)"
            echo "  BASE_URL       API基础URL (默认: http://\$SERVER_IP)"
            exit 0
            ;;
        *)
            run_all_tests
            ;;
    esac

    print_report
}

main "$@"
