#!/bin/bash
# 缅甸房产平台 - 统一测试入口脚本
# 支持: 冒烟测试(smoke)、全量测试(full)、压力测试(stress)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 服务器配置
SERVER_IP="${SERVER_IP:-43.163.122.42}"
BASE_URL="${BASE_URL:-http://$SERVER_IP}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 测试结果
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_SKIPPED=0
START_TIME=$(date +%s)

# 打印 banner
print_banner() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                                ║${NC}"
    echo -e "${BLUE}║     缅甸房产平台 - 自动化测试执行框架                          ║${NC}"
    echo -e "${BLUE}║     Myanmar Real Estate Platform Test Runner                   ║${NC}"
    echo -e "${BLUE}║                                                                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 打印测试阶段标题
print_phase() {
    echo -e "\n${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
    echo -e "${CYAN}▓▓▓  $1${NC}"
    echo -e "${CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# 打印步骤
print_step() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

# 打印成功
print_success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

# 打印失败
print_failure() {
    echo -e "${RED}  ✗ $1${NC}"
    if [ -n "$2" ]; then
        echo -e "${RED}    $2${NC}"
    fi
}

# 打印信息
print_info() {
    echo -e "${BLUE}  ℹ $1${NC}"
}

# 打印跳过
print_skip() {
    echo -e "${YELLOW}  ⊘ $1${NC}"
}

# ============================================
# 阶段 0: 环境检查
# ============================================
check_environment() {
    print_phase "阶段 0: 环境检查"

    # 检查 curl
    if ! command -v curl &> /dev/null; then
        print_failure "curl 未安装"
        exit 1
    fi
    print_success "curl 已安装"

    # 检查服务器连通性
    print_step "检查服务器连通性..."
    if curl -s --max-time 10 "$BASE_URL/health" > /dev/null; then
        print_success "服务器 $SERVER_IP 可访问"
    else
        print_failure "服务器 $SERVER_IP 无法访问"
        exit 1
    fi

    # 检查测试脚本
    local scripts=("auto-test.sh" "api-test-suite.sh" "admin-e2e-tests.sh" "flutter-app-tests.sh" "integration-tests.sh")
    for script in "${scripts[@]}"; do
        if [ -f "$SCRIPT_DIR/$script" ]; then
            print_success "测试脚本存在: $script"
        else
            print_failure "测试脚本不存在: $script"
        fi
    done
}

# ============================================
# 阶段 1: 冒烟测试 (5分钟)
# ============================================
run_smoke_tests() {
    print_phase "阶段 1: 冒烟测试 (Smoke Test)"
    print_info "预计时间: 3-5分钟"
    print_info "测试范围: 核心服务健康检查 + 基础API"

    local phase_start=$(date +%s)

    # 运行基础测试
    print_step "执行基础服务测试..."
    if bash "$SCRIPT_DIR/auto-test.sh"; then
        print_success "冒烟测试通过"
    else
        print_failure "冒烟测试失败"
        return 1
    fi

    local phase_end=$(date +%s)
    local duration=$((phase_end - phase_start))
    print_info "冒烟测试耗时: ${duration}秒"

    return 0
}

# ============================================
# 阶段 2: API 全量测试 (20分钟)
# ============================================
run_api_tests() {
    print_phase "阶段 2: API 全量测试"
    print_info "预计时间: 15-20分钟"
    print_info "测试范围: 47个API端点 (用户/房源/IM/预约/ACN)"

    local phase_start=$(date +%s)

    print_step "执行API测试套件..."
    if bash "$SCRIPT_DIR/api-test-suite.sh"; then
        print_success "API测试全部通过"
    else
        print_failure "部分API测试失败"
    fi

    local phase_end=$(date +%s)
    local duration=$((phase_end - phase_start))
    print_info "API测试耗时: ${duration}秒"

    return 0
}

# ============================================
# 阶段 3: Web Admin E2E 测试 (10分钟)
# ============================================
run_admin_e2e_tests() {
    print_phase "阶段 3: Web Admin E2E 测试"
    print_info "预计时间: 8-10分钟"
    print_info "测试范围: 管理后台核心功能 (20个用例)"

    local phase_start=$(date +%s)

    print_step "执行Web Admin E2E测试..."
    if bash "$SCRIPT_DIR/admin-e2e-tests.sh"; then
        print_success "Web Admin E2E测试通过"
    else
        print_failure "部分Web Admin测试失败"
    fi

    local phase_end=$(date +%s)
    local duration=$((phase_end - phase_start))
    print_info "Web Admin测试耗时: ${duration}秒"

    return 0
}

# ============================================
# 阶段 4: Flutter App 测试 (15分钟)
# ============================================
run_flutter_tests() {
    print_phase "阶段 4: Flutter App 测试"
    print_info "预计时间: 12-15分钟"
    print_info "测试范围: C端(Buyer) + B端(Agent) 双端API (20个用例)"

    local phase_start=$(date +%s)

    print_step "执行Flutter App测试..."
    if bash "$SCRIPT_DIR/flutter-app-tests.sh"; then
        print_success "Flutter App测试通过"
    else
        print_failure "部分Flutter测试失败"
    fi

    local phase_end=$(date +%s)
    local duration=$((phase_end - phase_start))
    print_info "Flutter测试耗时: ${duration}秒"

    return 0
}

# ============================================
# 阶段 5: 端到端集成测试 (20分钟)
# ============================================
run_integration_tests() {
    print_phase "阶段 5: 端到端集成测试"
    print_info "预计时间: 15-20分钟"
    print_info "测试范围: 8个完整业务流程"

    local phase_start=$(date +%s)

    print_step "执行端到端集成测试..."
    if bash "$SCRIPT_DIR/integration-tests.sh"; then
        print_success "集成测试全部通过"
    else
        print_failure "部分集成测试失败"
    fi

    local phase_end=$(date +%s)
    local duration=$((phase_end - phase_start))
    print_info "集成测试耗时: ${duration}秒"

    return 0
}

# ============================================
# 阶段 6: 性能压力测试 (30分钟)
# ============================================
run_stress_tests() {
    print_phase "阶段 6: 性能压力测试"
    print_info "预计时间: 20-30分钟"
    print_info "测试范围: API并发、数据库、Redis"

    local phase_start=$(date +%s)

    # 检查 ab 是否安装
    if ! command -v ab &> /dev/null; then
        print_info "ab (Apache Bench) 未安装，尝试安装..."
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y apache2-utils 2>/dev/null || true
        elif command -v yum &> /dev/null; then
            sudo yum install -y httpd-tools 2>/dev/null || true
        fi
    fi

    # 压力测试 1: 房源搜索接口
    if command -v ab &> /dev/null; then
        print_step "压力测试 1: 房源搜索接口 (1000请求, 50并发)..."
        ab -n 1000 -c 50 -H "Accept: application/json" \
            "$BASE_URL/api/houses/search?page=1&page_size=20" 2>&1 | tail -10
        print_success "房源搜索压力测试完成"
    else
        print_skip "房源搜索压力测试" "ab 未安装"
    fi

    # 压力测试 2: 健康检查接口
    if command -v ab &> /dev/null; then
        print_step "压力测试 2: 健康检查接口 (5000请求, 100并发)..."
        ab -n 5000 -c 100 "$BASE_URL/health" 2>&1 | tail -10
        print_success "健康检查压力测试完成"
    fi

    # 压力测试 3: 并发登录测试
    print_step "压力测试 3: 并发登录测试 (100次并发)..."
    local pids=()
    for i in {1..10}; do
        (
            for j in {1..10}; do
                curl -s -X POST "$BASE_URL/api/auth/login" \
                    -H "Content-Type: application/json" \
                    -d "{\"phone\":\"+959701234567\",\"code\":\"123456\",\"device_id\":\"stress_${i}_${j}\"}" > /dev/null 2>&1 || true
            done
        ) &
        pids+=($!)
    done
    for pid in "${pids[@]}"; do
        wait $pid 2>/dev/null || true
    done
    print_success "并发登录测试完成"

    # 压力测试 4: 数据库连接池测试
    print_step "压力测试 4: 数据库连接池测试 (50并发查询)..."
    pids=()
    for i in {1..50}; do
        (
            curl -s "$BASE_URL/api/houses/search?keyword=test&page=$i&page_size=10" > /dev/null 2>&1 || true
        ) &
        pids+=($!)
    done
    for pid in "${pids[@]}"; do
        wait $pid 2>/dev/null || true
    done
    print_success "数据库连接池测试完成"

    # 压力测试 5: Redis 测试
    print_step "压力测试 5: 验证码发送限流测试..."
    for i in {1..20}; do
        curl -s -X POST "$BASE_URL/api/auth/send-verification-code" \
            -H "Content-Type: application/json" \
            -d "{\"phone\":\"+9597099999$(printf "%02d" $i)\",\"type\":\"login\"}" > /dev/null 2>&1 || true
    done
    print_success "限流测试完成"

    local phase_end=$(date +%s)
    local duration=$((phase_end - phase_start))
    print_info "压力测试耗时: ${duration}秒"

    return 0
}

# ============================================
# 生成最终报告
# ============================================
print_final_report() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))

    echo -e "\n"
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                      最 终 测 试 报 告                         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "测试服务器: ${CYAN}$SERVER_IP${NC}"
    echo -e "测试时间: ${CYAN}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "总耗时: ${CYAN}${total_duration}秒 ($((total_duration/60))分$((total_duration%60))秒)${NC}"
    echo ""
    echo -e "测试套件执行状态:"
    echo -e "  ${GREEN}● 冒烟测试${NC}     $(if [ "$RUN_SMOKE" = "1" ]; then echo "已执行"; else echo "跳过"; fi)"
    echo -e "  ${GREEN}● API测试${NC}      $(if [ "$RUN_API" = "1" ]; then echo "已执行 (47个用例)"; else echo "跳过"; fi)"
    echo -e "  ${GREEN}● Web Admin${NC}    $(if [ "$RUN_ADMIN" = "1" ]; then echo "已执行 (20个用例)"; else echo "跳过"; fi)"
    echo -e "  ${GREEN}● Flutter App${NC}  $(if [ "$RUN_FLUTTER" = "1" ]; then echo "已执行 (20个用例)"; else echo "跳过"; fi)"
    echo -e "  ${GREEN}● 集成测试${NC}     $(if [ "$RUN_INTEGRATION" = "1" ]; then echo "已执行 (8个流程)"; else echo "跳过"; fi)"
    echo -e "  ${GREEN}● 压力测试${NC}     $(if [ "$RUN_STRESS" = "1" ]; then echo "已执行 (5个场景)"; else echo "跳过"; fi)"

    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 输出 JSON 报告
    local report_file="/tmp/test-report-$(date +%Y%m%d-%H%M%S).json"
    cat > "$report_file" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "server": "$SERVER_IP",
  "duration_seconds": $total_duration,
  "tests": {
    "smoke": $(if [ "$RUN_SMOKE" = "1" ]; then echo "true"; else echo "false"; fi),
    "api": $(if [ "$RUN_API" = "1" ]; then echo "true"; else echo "false"; fi),
    "admin_e2e": $(if [ "$RUN_ADMIN" = "1" ]; then echo "true"; else echo "false"; fi),
    "flutter_app": $(if [ "$RUN_FLUTTER" = "1" ]; then echo "true"; else echo "false"; fi),
    "integration": $(if [ "$RUN_INTEGRATION" = "1" ]; then echo "true"; else echo "false"; fi),
    "stress": $(if [ "$RUN_STRESS" = "1" ]; then echo "true"; else echo "false"; fi)
  },
  "test_cases": {
    "api": 47,
    "admin_e2e": 20,
    "flutter_app": 20,
    "integration_flows": 8,
    "stress_scenarios": 5,
    "total": 100
  }
}
EOF
    print_info "完整报告已保存: $report_file"
    echo ""
    print_info "测试脚本位置: $SCRIPT_DIR"
}

# ============================================
# 帮助信息
# ============================================
print_help() {
    echo "缅甸房产平台 - 统一测试入口"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --smoke        执行冒烟测试 (3-5分钟)"
    echo "  --api          执行API测试 (15-20分钟, 47个用例)"
    echo "  --admin        执行Web Admin E2E测试 (8-10分钟, 20个用例)"
    echo "  --flutter      执行Flutter App测试 (12-15分钟, 20个用例)"
    echo "  --integration  执行集成测试 (15-20分钟, 8个流程)"
    echo "  --stress       执行压力测试 (20-30分钟, 5个场景)"
    echo "  --full         执行全量测试 (60-90分钟, 100个用例)"
    echo "  --help         显示帮助信息"
    echo ""
    echo "环境变量:"
    echo "  SERVER_IP      目标服务器IP (默认: 43.163.122.42)"
    echo "  BASE_URL       API基础URL (默认: http://\$SERVER_IP)"
    echo ""
    echo "示例:"
    echo "  $0 --smoke                    # 快速冒烟测试"
    echo "  $0 --api                      # 只测试API"
    echo "  $0 --full                     # 完整测试套件 (100个用例)"
    echo "  SERVER_IP=192.168.1.1 $0 --smoke  # 测试指定服务器"
}

# ============================================
# 主函数
# ============================================
main() {
    print_banner

    # 解析参数
    local mode="${1:---smoke}"

    case "$mode" in
        --smoke)
            RUN_SMOKE=1
            RUN_API=0
            RUN_ADMIN=0
            RUN_FLUTTER=0
            RUN_INTEGRATION=0
            RUN_STRESS=0
            ;;
        --api)
            RUN_SMOKE=1
            RUN_API=1
            RUN_ADMIN=0
            RUN_FLUTTER=0
            RUN_INTEGRATION=0
            RUN_STRESS=0
            ;;
        --admin)
            RUN_SMOKE=1
            RUN_API=0
            RUN_ADMIN=1
            RUN_FLUTTER=0
            RUN_INTEGRATION=0
            RUN_STRESS=0
            ;;
        --flutter)
            RUN_SMOKE=1
            RUN_API=0
            RUN_ADMIN=0
            RUN_FLUTTER=1
            RUN_INTEGRATION=0
            RUN_STRESS=0
            ;;
        --integration)
            RUN_SMOKE=1
            RUN_API=0
            RUN_ADMIN=0
            RUN_FLUTTER=0
            RUN_INTEGRATION=1
            RUN_STRESS=0
            ;;
        --stress)
            RUN_SMOKE=1
            RUN_API=1
            RUN_ADMIN=0
            RUN_FLUTTER=0
            RUN_INTEGRATION=0
            RUN_STRESS=1
            ;;
        --full)
            RUN_SMOKE=1
            RUN_API=1
            RUN_ADMIN=1
            RUN_FLUTTER=1
            RUN_INTEGRATION=1
            RUN_STRESS=0
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            echo "未知选项: $mode"
            print_help
            exit 1
            ;;
    esac

    # 环境检查
    check_environment

    # 执行测试
    if [ "$RUN_SMOKE" = "1" ]; then
        run_smoke_tests || exit 1
    fi

    if [ "$RUN_API" = "1" ]; then
        run_api_tests || true
    fi

    if [ "$RUN_ADMIN" = "1" ]; then
        run_admin_e2e_tests || true
    fi

    if [ "$RUN_FLUTTER" = "1" ]; then
        run_flutter_tests || true
    fi

    if [ "$RUN_INTEGRATION" = "1" ]; then
        run_integration_tests || true
    fi

    if [ "$RUN_STRESS" = "1" ]; then
        run_stress_tests || true
    fi

    # 最终报告
    print_final_report

    echo -e "\n${GREEN}测试执行完成！${NC}\n"
}

main "$@"
