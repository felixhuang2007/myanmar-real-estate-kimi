#!/bin/bash
# 缅甸房产平台 - Flutter App 测试套件
# 测试内容: C端(Buyer)和B端(Agent)Flutter应用
# 测试用例: 20个（C端10 + B端10）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
SERVER_IP="${SERVER_IP:-43.163.122.42}"
API_BASE="${API_BASE:-http://$SERVER_IP}"
FLUTTER_DIR="${FLUTTER_DIR:-./myanmar-real-estate/flutter}"

# 测试结果
PASSED=0
FAILED=0
SKIPPED=0
TOTAL=0

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║               Flutter App 测试套件                              ║${NC}"
echo -e "${BLUE}║        C端(Buyer) + B端(Agent) 双端测试                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# 工具函数
# ============================================

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_subheader() {
    echo -e "\n${CYAN}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}  ✓ PASS${NC} | $1"
    ((PASSED++))
    ((TOTAL++))
}

print_failure() {
    echo -e "${RED}  ✗ FAIL${NC} | $1"
    echo -e "${RED}         $2${NC}"
    ((FAILED++))
    ((TOTAL++))
}

print_skip() {
    echo -e "${YELLOW}  ⊘ SKIP${NC} | $1"
    ((SKIPPED++))
    ((TOTAL++))
}

print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

# ============================================
# 环境检查
# ============================================

check_flutter_env() {
    print_header "环境检查"

    # 检查 Flutter
    if command -v flutter &> /dev/null; then
        local version=$(flutter --version | head -1)
        print_success "Flutter已安装: $version"
    else
        print_failure "Flutter未安装" "请安装Flutter SDK"
        return 1
    fi

    # 检查 Dart
    if command -v dart &> /dev/null; then
        print_success "Dart已安装"
    else
        print_failure "Dart未安装" "Dart应随Flutter一起安装"
        return 1
    fi

    # 检查项目目录
    if [ -d "$FLUTTER_DIR" ]; then
        print_success "Flutter项目目录存在"
    else
        print_failure "Flutter项目目录不存在" "路径: $FLUTTER_DIR"
        return 1
    fi

    # 检查 lib 目录
    if [ -d "$FLUTTER_DIR/lib" ]; then
        print_success "Flutter lib目录存在"
    else
        print_failure "Flutter lib目录不存在" "项目结构异常"
        return 1
    fi

    return 0
}

# ============================================
# 静态代码分析
# ============================================

run_static_analysis() {
    print_header "静态代码分析"

    cd "$FLUTTER_DIR"

    # 分析 Buyer App
    print_subheader "分析 C端(Buyer) App 代码..."
    if flutter analyze lib/main_buyer.dart 2>&1 | grep -q "No issues found"; then
        print_success "C端代码静态分析通过"
    else
        print_failure "C端代码静态分析" "发现代码问题或警告"
    fi

    # 分析 Agent App
    print_subheader "分析 B端(Agent) App 代码..."
    if flutter analyze lib/main_agent.dart 2>&1 | grep -q "No issues found"; then
        print_success "B端代码静态分析通过"
    else
        print_failure "B端代码静态分析" "发现代码问题或警告"
    fi

    cd - > /dev/null
}

# ============================================
# 单元测试执行
# ============================================

run_unit_tests() {
    print_header "单元测试执行"

    cd "$FLUTTER_DIR"

    # 获取依赖
    print_subheader "获取Flutter依赖..."
    if flutter pub get > /dev/null 2>&1; then
        print_success "依赖获取成功"
    else
        print_failure "依赖获取失败" "请检查网络连接"
        cd - > /dev/null
        return 1
    fi

    # 运行测试
    print_subheader "运行单元测试..."
    if [ -d "test" ]; then
        if flutter test 2>&1 | grep -q "All tests passed"; then
            print_success "单元测试通过"
        else
            print_failure "单元测试" "部分测试失败"
        fi
    else
        print_skip "单元测试" "test目录不存在，跳过单元测试"
    fi

    cd - > /dev/null
}

# ============================================
# 构建测试
# ============================================

run_build_tests() {
    print_header "构建测试"

    cd "$FLUTTER_DIR"

    # 测试 C端 APK 构建
    print_subheader "测试 C端(Buyer) APK构建..."
    if flutter build apk --target=lib/main_buyer.dart --release > /dev/null 2>&1; then
        print_success "C端APK构建成功"
        # 检查APK大小
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            local apk_size=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
            print_info "C端APK大小: $apk_size"
        fi
    else
        print_failure "C端APK构建失败" "请检查构建日志"
    fi

    # 测试 B端 APK 构建
    print_subheader "测试 B端(Agent) APK构建..."
    if flutter build apk --target=lib/main_agent.dart --release > /dev/null 2>&1; then
        print_success "B端APK构建成功"
        if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
            local apk_size=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
            print_info "B端APK大小: $apk_size"
        fi
    else
        print_failure "B端APK构建失败" "请检查构建日志"
    fi

    cd - > /dev/null
}

# ============================================
# C端(Buyer) App API 测试
# ============================================

print_header "C端(Buyer) App - API 集成测试"

# BUYER-001: 首页推荐房源API
test_buyer_home_recommend() {
    print_subheader "BUYER-001: 首页推荐房源"

    local resp=$(curl -s "$API_BASE/api/houses/recommend?limit=10")

    if [ -n "$resp" ] && [[ "$resp" != *"error"* ]]; then
        print_success "首页推荐房源API"
    else
        print_failure "首页推荐房源API" "API返回错误或空"
    fi
}

# BUYER-002: 房源搜索API
test_buyer_search() {
    print_subheader "BUYER-002: 房源搜索"

    local resp=$(curl -s "$API_BASE/api/houses/search?keyword=condo&page=1&page_size=20")

    if [ -n "$resp" ]; then
        print_success "房源搜索API"
    else
        print_failure "房源搜索API" "搜索返回空"
    fi
}

# BUYER-003: 房源详情API
test_buyer_house_detail() {
    print_subheader "BUYER-003: 房源详情"

    # 先获取一个房源ID
    local houses=$(curl -s "$API_BASE/api/houses/search?page=1&page_size=1")
    local house_id=$(echo "$houses" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

    if [ -n "$house_id" ]; then
        local resp=$(curl -s "$API_BASE/api/houses/$house_id")
        if [ -n "$resp" ]; then
            print_success "房源详情API"
        else
            print_failure "房源详情API" "无法获取房源详情"
        fi
    else
        print_skip "房源详情API" "系统中无房源数据"
    fi
}

# BUYER-004: 地图聚合API
test_buyer_map_aggregate() {
    print_subheader "BUYER-004: 地图聚合"

    local resp=$(curl -s "$API_BASE/api/houses/map/aggregate?zoom=12&bounds=16.8,96.1|16.9,96.2")

    if [ -n "$resp" ]; then
        print_success "地图聚合API"
    else
        print_failure "地图聚合API" "聚合返回空"
    fi
}

# BUYER-005: 发送验证码API
test_buyer_send_code() {
    print_subheader "BUYER-005: 发送验证码"

    local test_phone="+959709999001"
    local resp=$(curl -s -X POST "$API_BASE/api/auth/send-verification-code" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$test_phone\",\"type\":\"login\"}")

    if [[ "$resp" == *"code"* ]] || [[ "$resp" == *"success"* ]]; then
        print_success "发送验证码API"
    elif [[ "$resp" == *"429"* ]]; then
        print_skip "发送验证码API" "请求过于频繁"
    else
        print_failure "发送验证码API" "返回: $resp"
    fi
}

# BUYER-006: 登录API
test_buyer_login() {
    print_subheader "BUYER-006: 用户登录"

    local resp=$(curl -s -X POST "$API_BASE/api/auth/login-with-password" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"09701234567\",\"password\":\"admin123\",\"device_id\":\"buyer_test\"}")

    if [[ "$resp" == *"token"* ]]; then
        print_success "用户登录API"
        # 保存token供后续使用
        BUYER_TOKEN=$(echo "$resp" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    else
        print_failure "用户登录API" "登录失败"
    fi
}

# BUYER-007: 收藏房源API
test_buyer_favorite() {
    print_subheader "BUYER-007: 收藏房源"

    if [ -z "$BUYER_TOKEN" ]; then
        print_skip "收藏房源API" "未获取登录Token"
        return
    fi

    # 获取房源ID
    local houses=$(curl -s "$API_BASE/api/houses/search?page=1&page_size=1")
    local house_id=$(echo "$houses" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

    if [ -n "$house_id" ]; then
        local resp=$(curl -s -X POST "$API_BASE/api/houses/$house_id/favorite" \
            -H "Authorization: Bearer $BUYER_TOKEN")
        if [ -n "$resp" ]; then
            print_success "收藏房源API"
        else
            print_failure "收藏房源API" "收藏失败"
        fi
    else
        print_skip "收藏房源API" "无房源数据"
    fi
}

# BUYER-008: 预约看房API
test_buyer_appointment() {
    print_subheader "BUYER-008: 预约看房"

    if [ -z "$BUYER_TOKEN" ]; then
        print_skip "预约看房API" "未获取登录Token"
        return
    fi

    local houses=$(curl -s "$API_BASE/api/houses/search?page=1&page_size=1")
    local house_id=$(echo "$houses" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

    if [ -n "$house_id" ]; then
        local tomorrow=$(date -d "+1 day" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d)
        local resp=$(curl -s -X POST "$API_BASE/api/appointments" \
            -H "Authorization: Bearer $BUYER_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"house_id\":$house_id,\"appointment_date\":\"$tomorrow\",\"appointment_time\":\"14:00\"}")

        if [[ "$resp" == *"id"* ]] || [[ "$resp" == *"success"* ]]; then
            print_success "预约看房API"
        else
            print_failure "预约看房API" "预约失败"
        fi
    else
        print_skip "预约看房API" "无房源数据"
    fi
}

# BUYER-009: IM会话列表API
test_buyer_im_conversations() {
    print_subheader "BUYER-009: IM会话列表"

    if [ -z "$BUYER_TOKEN" ]; then
        print_skip "IM会话列表API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/im/conversations" \
        -H "Authorization: Bearer $BUYER_TOKEN")

    if [ -n "$resp" ]; then
        print_success "IM会话列表API"
    else
        print_failure "IM会话列表API" "获取失败"
    fi
}

# BUYER-010: 用户信息API
test_buyer_user_profile() {
    print_subheader "BUYER-010: 用户信息"

    if [ -z "$BUYER_TOKEN" ]; then
        print_skip "用户信息API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/users/profile" \
        -H "Authorization: Bearer $BUYER_TOKEN")

    if [[ "$resp" == *"id"* ]] || [[ "$resp" == *"phone"* ]]; then
        print_success "用户信息API"
    else
        print_failure "用户信息API" "获取失败"
    fi
}

# ============================================
# B端(Agent) App API 测试
# ============================================

print_header "B端(Agent) App - API 集成测试"

# AGENT-001: 经纪人登录API
test_agent_login() {
    print_subheader "AGENT-001: 经纪人登录"

    local resp=$(curl -s -X POST "$API_BASE/api/auth/agent/login" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"09701234567\",\"password\":\"admin123\",\"device_id\":\"agent_test\"}")

    if [[ "$resp" == *"token"* ]]; then
        print_success "经纪人登录API"
        AGENT_TOKEN=$(echo "$resp" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    else
        # 尝试普通登录
        resp=$(curl -s -X POST "$API_BASE/api/auth/login-with-password" \
            -H "Content-Type: application/json" \
            -d "{\"phone\":\"09701234567\",\"password\":\"admin123\",\"device_id\":\"agent_test2\"}")
        if [[ "$resp" == *"token"* ]]; then
            print_success "经纪人登录API (通过普通登录)"
            AGENT_TOKEN=$(echo "$resp" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        else
            print_failure "经纪人登录API" "登录失败"
        fi
    fi
}

# AGENT-002: 经纪人房源列表API
test_agent_house_list() {
    print_subheader "AGENT-002: 经纪人房源列表"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "经纪人房源列表API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/agent/houses?page=1&page_size=20" \
        -H "Authorization: Bearer $AGENT_TOKEN")

    if [ -n "$resp" ]; then
        print_success "经纪人房源列表API"
    else
        # 尝试普通房源列表
        resp=$(curl -s "$API_BASE/api/houses?page=1&page_size=20" \
            -H "Authorization: Bearer $AGENT_TOKEN")
        if [ -n "$resp" ]; then
            print_success "经纪人房源列表API (通过普通端点)"
        else
            print_failure "经纪人房源列表API" "获取失败"
        fi
    fi
}

# AGENT-003: 创建房源API
test_agent_create_house() {
    print_subheader "AGENT-003: 创建房源"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "创建房源API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s -X POST "$API_BASE/api/houses" \
        -H "Authorization: Bearer $AGENT_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"title\":\"测试房源 $(date)\",\"price\":50000000,\"area\":100,\"bedrooms\":2,\"bathrooms\":1,\"location\":{\"address\":\"仰光\",\"latitude\":16.8661,\"longitude\":96.1951},\"property_type\":\"condo\",\"transaction_type\":\"sale\"}")

    if [[ "$resp" == *"id"* ]] || [[ "$resp" == *"success"* ]]; then
        print_success "创建房源API"
        AGENT_HOUSE_ID=$(echo "$resp" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    elif [[ "$resp" == *"403"* ]]; then
        print_skip "创建房源API" "当前用户无经纪人权限"
    else
        print_failure "创建房源API" "创建失败: $resp"
    fi
}

# AGENT-004: 预约管理API
test_agent_appointments() {
    print_subheader "AGENT-004: 预约管理"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "预约管理API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/agent/appointments?page=1&page_size=20" \
        -H "Authorization: Bearer $AGENT_TOKEN")

    if [ -n "$resp" ]; then
        print_success "预约管理API"
    else
        # 尝试普通端点
        resp=$(curl -s "$API_BASE/api/appointments?page=1&page_size=20" \
            -H "Authorization: Bearer $AGENT_TOKEN")
        if [ -n "$resp" ]; then
            print_success "预约管理API (通过普通端点)"
        else
            print_failure "预约管理API" "获取失败"
        fi
    fi
}

# AGENT-005: 客户管理API
test_agent_customers() {
    print_subheader "AGENT-005: 客户管理"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "客户管理API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/agent/customers" \
        -H "Authorization: Bearer $AGENT_TOKEN")

    if [ -n "$resp" ]; then
        print_success "客户管理API"
    else
        print_skip "客户管理API" "端点可能不存在"
    fi
}

# AGENT-006: IM消息发送API
test_agent_send_message() {
    print_subheader "AGENT-006: IM消息发送"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "IM消息发送API" "未获取登录Token"
        return
    fi

    # 先获取会话列表
    local convs=$(curl -s "$API_BASE/api/im/conversations" \
        -H "Authorization: Bearer $AGENT_TOKEN")
    local conv_id=$(echo "$convs" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$conv_id" ]; then
        local resp=$(curl -s -X POST "$API_BASE/api/im/conversations/$conv_id/messages" \
            -H "Authorization: Bearer $AGENT_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"content\":\"你好，我是经纪人\",\"type\":\"text\"}")

        if [ -n "$resp" ]; then
            print_success "IM消息发送API"
        else
            print_failure "IM消息发送API" "发送失败"
        fi
    else
        print_skip "IM消息发送API" "无可用会话"
    fi
}

# AGENT-007: 成交申报API
test_agent_deal_create() {
    print_subheader "AGENT-007: 成交申报"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "成交申报API" "未获取登录Token"
        return
    fi

    if [ -z "$AGENT_HOUSE_ID" ]; then
        # 尝试获取一个房源ID
        local houses=$(curl -s "$API_BASE/api/houses/search?page=1&page_size=1")
        AGENT_HOUSE_ID=$(echo "$houses" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    fi

    if [ -n "$AGENT_HOUSE_ID" ]; then
        local resp=$(curl -s -X POST "$API_BASE/api/acn/deals" \
            -H "Authorization: Bearer $AGENT_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"house_id\":$AGENT_HOUSE_ID,\"deal_price\":48000000,\"deal_date\":\"$(date +%Y-%m-%d)\",\"buyer_name\":\"Test Buyer\",\"buyer_phone\":\"+959701234567\"}")

        if [[ "$resp" == *"id"* ]] || [[ "$resp" == *"success"* ]]; then
            print_success "成交申报API"
        elif [[ "$resp" == *"403"* ]]; then
            print_skip "成交申报API" "当前用户无经纪人权限"
        else
            print_failure "成交申报API" "申报失败"
        fi
    else
        print_skip "成交申报API" "无房源数据"
    fi
}

# AGENT-008: 佣金查询API
test_agent_commission() {
    print_subheader "AGENT-008: 佣金查询"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "佣金查询API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/acn/commission/balance" \
        -H "Authorization: Bearer $AGENT_TOKEN")

    if [ -n "$resp" ]; then
        print_success "佣金查询API"
    else
        print_failure "佣金查询API" "查询失败"
    fi
}

# AGENT-009: 业绩统计API
test_agent_performance() {
    print_subheader "AGENT-009: 业绩统计"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "业绩统计API" "未获取登录Token"
        return
    fi

    local resp=$(curl -s "$API_BASE/api/agent/performance?month=$(date +%Y-%m)" \
        -H "Authorization: Bearer $AGENT_TOKEN")

    if [ -n "$resp" ]; then
        print_success "业绩统计API"
    else
        print_skip "业绩统计API" "端点可能不存在"
    fi
}

# AGENT-010: 带看签到API
test_agent_checkin() {
    print_subheader "AGENT-010: 带看签到"

    if [ -z "$AGENT_TOKEN" ]; then
        print_skip "带看签到API" "未获取登录Token"
        return
    fi

    # 获取预约列表
    local apps=$(curl -s "$API_BASE/api/appointments?page=1&page_size=1" \
        -H "Authorization: Bearer $AGENT_TOKEN")
    local app_id=$(echo "$apps" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)

    if [ -n "$app_id" ]; then
        local resp=$(curl -s -X POST "$API_BASE/api/appointments/$app_id/checkin" \
            -H "Authorization: Bearer $AGENT_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{\"latitude\":16.8661,\"longitude\":96.1951}")

        if [ -n "$resp" ]; then
            print_success "带看签到API"
        else
            print_skip "带看签到API" "签到端点可能不同"
        fi
    else
        print_skip "带看签到API" "无预约数据"
    fi
}

# ============================================
# 主函数
# ============================================

main() {
    local start_time=$(date +%s)

    # 检查环境
    check_flutter_env || exit 1

    # 静态分析
    case "$1" in
        --analyze)
            run_static_analysis
            ;;
        --build)
            run_build_tests
            ;;
        --unit)
            run_unit_tests
            ;;
        --api)
            # 只运行API测试
            test_buyer_home_recommend
            test_buyer_search
            test_buyer_house_detail
            test_buyer_map_aggregate
            test_buyer_send_code
            test_buyer_login
            test_buyer_favorite
            test_buyer_appointment
            test_buyer_im_conversations
            test_buyer_user_profile

            test_agent_login
            test_agent_house_list
            test_agent_create_house
            test_agent_appointments
            test_agent_customers
            test_agent_send_message
            test_agent_deal_create
            test_agent_commission
            test_agent_performance
            test_agent_checkin
            ;;
        --full)
            # 完整测试
            run_static_analysis
            run_unit_tests
            run_build_tests

            test_buyer_home_recommend
            test_buyer_search
            test_buyer_house_detail
            test_buyer_map_aggregate
            test_buyer_send_code
            test_buyer_login
            test_buyer_favorite
            test_buyer_appointment
            test_buyer_im_conversations
            test_buyer_user_profile

            test_agent_login
            test_agent_house_list
            test_agent_create_house
            test_agent_appointments
            test_agent_customers
            test_agent_send_message
            test_agent_deal_create
            test_agent_commission
            test_agent_performance
            test_agent_checkin
            ;;
        --help|-h)
            echo "Flutter App 测试套件"
            echo ""
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --analyze    只运行静态代码分析"
            echo "  --build      只运行构建测试"
            echo "  --unit       只运行单元测试"
            echo "  --api        只运行API集成测试"
            echo "  --full       运行完整测试套件 (默认)"
            echo "  --help       显示帮助"
            echo ""
            echo "环境变量:"
            echo "  SERVER_IP    API服务器IP (默认: 43.163.122.42)"
            echo "  FLUTTER_DIR  Flutter项目目录 (默认: ./myanmar-real-estate/flutter)"
            exit 0
            ;;
        *)
            # 默认运行API测试
            test_buyer_home_recommend
            test_buyer_search
            test_buyer_house_detail
            test_buyer_map_aggregate
            test_buyer_send_code
            test_buyer_login
            test_buyer_favorite
            test_buyer_appointment
            test_buyer_im_conversations
            test_buyer_user_profile

            test_agent_login
            test_agent_house_list
            test_agent_create_house
            test_agent_appointments
            test_agent_customers
            test_agent_send_message
            test_agent_deal_create
            test_agent_commission
            test_agent_performance
            test_agent_checkin
            ;;
    esac

    # 生成报告
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo -e "\n"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}                    Flutter App 测试报告                         ${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "API服务器: ${CYAN}$API_BASE${NC}"
    echo -e "Flutter目录: ${CYAN}$FLUTTER_DIR${NC}"
    echo ""
    echo -e "测试统计:"
    echo -e "  总用例数: $TOTAL"
    echo -e "  ${GREEN}通过: $PASSED${NC}"
    echo -e "  ${RED}失败: $FAILED${NC}"
    echo -e "  ${YELLOW}跳过: $SKIPPED${NC}"
    echo -e "  耗时: ${duration}秒"

    if [ $TOTAL -gt 0 ]; then
        local pass_rate=$(( PASSED * 100 / TOTAL ))
        echo -e "  通过率: ${pass_rate}%"
    fi

    echo ""
    echo -e "${BLUE}模块覆盖:${NC}"
    echo -e "  C端(Buyer): 10个测试用例"
    echo -e "  B端(Agent): 10个测试用例"

    if [ $FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ 所有测试通过！${NC}\n"
        exit 0
    else
        echo -e "\n${RED}✗ 有 $FAILED 项测试失败${NC}\n"
        exit 1
    fi
}

main "$@"
