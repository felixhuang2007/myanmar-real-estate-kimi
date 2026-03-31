#!/bin/bash
# P0测试执行脚本
# 执行剩余91个P0测试用例

API_BASE="http://localhost:8080/v1"
TEST_RESULTS="/tmp/p0_test_results_$(date +%Y%m%d_%H%M%S).log"
PASSED=0
FAILED=0
TOTAL=0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$TEST_RESULTS"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$TEST_RESULTS"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$TEST_RESULTS"
}

# 测试执行函数
run_test() {
    local test_id=$1
    local test_name=$2
    local method=$3
    local endpoint=$4
    local data=$5
    local auth=$6
    local expected_code=$7

    TOTAL=$((TOTAL + 1))

    local curl_cmd="curl -s -X $method \"$API_BASE$endpoint\""

    if [ -n "$auth" ]; then
        curl_cmd="$curl_cmd -H \"Authorization: Bearer $auth\""
    fi

    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H \"Content-Type: application/json\" -d '$data'"
    fi

    local response=$(eval $curl_cmd)
    local actual_code=$(echo "$response" | grep -o '"code":[0-9]*' | cut -d: -f2)

    if [ "$actual_code" = "$expected_code" ]; then
        log_info "✅ $test_id: $test_name - 通过 (code: $actual_code)"
        PASSED=$((PASSED + 1))
        echo "PASS|$test_id|$test_name|$actual_code" >> "$TEST_RESULTS"
    else
        log_error "❌ $test_id: $test_name - 失败 (期望: $expected_code, 实际: $actual_code)"
        FAILED=$((FAILED + 1))
        echo "FAIL|$test_id|$test_name|$expected_code|$actual_code|$response" >> "$TEST_RESULTS"
    fi
}

# 获取token
get_token() {
    local phone=$1

    # 发送验证码
    local sms_resp=$(curl -s -X POST "$API_BASE/auth/send-verification-code" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$phone\",\"type\":\"login\"}")
    local code=$(echo "$sms_resp" | grep -o '"code":"[0-9]*"' | cut -d'"' -f4)

    # 登录
    local login_resp=$(curl -s -X POST "$API_BASE/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$phone\",\"code\":\"$code\",\"device_id\":\"test_device_$(date +%s)\"}")

    echo "$login_resp" | grep -o '"token":"[^"]*"' | cut -d'"' -f4
}

# 打印测试报告头部
echo "========================================" | tee -a "$TEST_RESULTS"
echo "P0测试执行报告" | tee -a "$TEST_RESULTS"
echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$TEST_RESULTS"
echo "API地址: $API_BASE" | tee -a "$TEST_RESULTS"
echo "========================================" | tee -a "$TEST_RESULTS"
echo "" | tee -a "$TEST_RESULTS"

# ==================== 用户模块测试 ====================
log_info "开始执行用户模块测试..."

# 获取用户token
USER_PHONE="+959123456790"
log_info "获取用户token (手机号: $USER_PHONE)..."
USER_TOKEN=$(get_token "$USER_PHONE")

if [ -z "$USER_TOKEN" ]; then
    log_error "获取用户token失败，跳过用户模块测试"
else
    log_info "获取token成功: ${USER_TOKEN:0:30}..."

    # TC-USER-010: 全局配置
    run_test "TC-USER-010" "获取全局配置" "GET" "/config" "" "" "" "200"

    # TC-USER-011: 获取当前用户
    run_test "TC-USER-011" "获取当前用户信息" "GET" "/users/me" "" "$USER_TOKEN" "200"

    # TC-USER-012: 更新用户资料
    run_test "TC-USER-012" "更新用户资料" "PUT" "/users/me" \
        '{"nickname":"测试用户","gender":"male","bio":"测试账号"}' "$USER_TOKEN" "200"

    # TC-USER-013: 获取实名认证状态
    run_test "TC-USER-013" "获取实名认证状态" "GET" "/users/me/verification" "" "$USER_TOKEN" "200"

    # TC-USER-014: 登出
    run_test "TC-USER-014" "用户登出" "POST" "/auth/logout" "" "$USER_TOKEN" "200"
fi

# ==================== 房源模块测试 ====================
log_info ""
log_info "开始执行房源模块测试..."

# TC-HOUSE-001: 房源列表
run_test "TC-HOUSE-001" "获取房源列表" "GET" "/houses?page=1&page_size=10" "" "" "200"

# TC-HOUSE-002: 房源搜索
run_test "TC-HOUSE-002" "房源搜索" "GET" "/houses/search?keyword=豪华&page=1&page_size=10" "" "" "200"

# TC-HOUSE-003: 房源详情
run_test "TC-HOUSE-003" "获取房源详情" "GET" "/houses/1" "" "" "200"

# TC-HOUSE-004: 获取用户公开信息
run_test "TC-HOUSE-004" "获取用户公开信息" "GET" "/users/1/public" "" "" "200"

# TC-HOUSE-005: 房源筛选
run_test "TC-HOUSE-005" "房源筛选(价格)" "GET" "/houses?min_price=1000000&max_price=5000000" "" "" "200"

# TC-HOUSE-006: 地区列表
run_test "TC-HOUSE-006" "获取地区列表" "GET" "/regions" "" "" "200"

# ==================== 预约模块测试 ====================
log_info ""
log_info "开始执行预约模块测试..."

if [ -n "$USER_TOKEN" ]; then
    # TC-APPOINTMENT-001: 预约列表
    run_test "TC-APPOINTMENT-001" "获取预约列表" "GET" "/appointments?page=1&page_size=10" "" "$USER_TOKEN" "200"
fi

# ==================== ACN模块测试 ====================
log_info ""
log_info "开始执行ACN模块测试..."

# TC-ACN-001: 获取ACN角色定义
run_test "TC-ACN-001" "获取ACN角色定义" "GET" "/acn/roles" "" "" "200"

if [ -n "$USER_TOKEN" ]; then
    # TC-ACN-002: 佣金余额查询
    run_test "TC-ACN-002" "查询佣金余额" "GET" "/acn/commission/balance" "" "$USER_TOKEN" "200"

    # TC-ACN-003: 成交单列表
    run_test "TC-ACN-003" "成交单列表" "GET" "/acn/deals?page=1&page_size=10" "" "$USER_TOKEN" "200"
fi

# ==================== 测试报告 ====================
echo "" | tee -a "$TEST_RESULTS"
echo "========================================" | tee -a "$TEST_RESULTS"
echo "测试执行完成" | tee -a "$TEST_RESULTS"
echo "结束时间: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$TEST_RESULTS"
echo "========================================" | tee -a "$TEST_RESULTS"
echo "总用例数: $TOTAL" | tee -a "$TEST_RESULTS"
echo "通过: $PASSED" | tee -a "$TEST_RESULTS"
echo "失败: $FAILED" | tee -a "$TEST_RESULTS"
echo "通过率: $(( PASSED * 100 / TOTAL ))%" | tee -a "$TEST_RESULTS"
echo "========================================" | tee -a "$TEST_RESULTS"
echo "" | tee -a "$TEST_RESULTS"
echo "详细日志: $TEST_RESULTS"

# 返回结果
if [ $FAILED -eq 0 ]; then
    log_info "🎉 所有测试通过!"
    exit 0
else
    log_warn "⚠️ 有 $FAILED 个测试失败"
    exit 1
fi
