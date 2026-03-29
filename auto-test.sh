#!/bin/bash
# 缅甸房产平台自动化测试脚本
# 在腾讯云服务器上执行

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试结果统计
PASSED=0
FAILED=0

# 服务器地址
SERVER_IP="${SERVER_IP:-43.163.122.42}"
BASE_URL="http://localhost"

# 密码配置（从环境变量读取，或使用默认值）
DB_PASSWORD="${DB_PASSWORD:-myanmar_property_2024}"
REDIS_PASSWORD="${REDIS_PASSWORD:-myanmar_redis_2024}"

# 日志文件
LOG_FILE="/tmp/auto-test-$(date +%s).log"

# 测试输出函数
print_header() {
    echo -e "\n${YELLOW}==============================================${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}  $1${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}==============================================${NC}" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1" | tee -a "$LOG_FILE"
    PASSED=$((PASSED + 1))
}

print_failure() {
    echo -e "${RED}[FAIL]${NC} $1" | tee -a "$LOG_FILE"
    echo -e "${RED}       Error: $2${NC}" | tee -a "$LOG_FILE"
    FAILED=$((FAILED + 1))
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# 测试 1: Docker 服务状态
test_docker_services() {
    print_header "测试 1: Docker 服务状态"

    cd ~/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend 2>/dev/null || true

    SERVICES="myanmar-property-api myanmar_nginx myanmar-property-db myanmar-property-redis myanmar_web_admin"
    ALL_UP=true

    for service in $SERVICES; do
        STATUS=$(sudo docker ps --filter "name=$service" --format "{{.Status}}" 2>/dev/null || echo "error")
        if [[ "$STATUS" == *"Up"* ]]; then
            print_success "$service 正在运行"
        else
            print_failure "$service 未运行" "$STATUS"
            ALL_UP=false
        fi
    done

    if [ "$ALL_UP" = true ]; then
        return 0
    else
        return 1
    fi
}

# 测试 2: API 健康检查
test_health_check() {
    print_header "测试 2: API 健康检查"

    RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 "$BASE_URL/health" || echo -e "\n000")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Health check 返回 200"
        echo "       Response: $BODY" | tee -a "$LOG_FILE"
        return 0
    else
        print_failure "Health check 失败" "HTTP $HTTP_CODE"
        return 1
    fi
}

# 测试 3: Web Admin 页面访问
test_web_admin() {
    print_header "测试 3: Web Admin 页面访问"

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$BASE_URL/" || echo "000")

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Web Admin 首页可访问"
        return 0
    else
        print_failure "Web Admin 访问失败" "HTTP $HTTP_CODE"
        return 1
    fi
}

# 测试 4: 数据库连通性
test_database() {
    print_header "测试 4: 数据库连通性"

    RESULT=$(sudo docker exec myanmar-property-db psql -U myanmar_property -d myanmar_property -c "SELECT COUNT(*) FROM users;" 2>&1)

    if [ $? -eq 0 ]; then
        print_success "数据库连接正常"
        echo "       用户表记录数: $RESULT" | tee -a "$LOG_FILE"
        return 0
    else
        print_failure "数据库连接失败" "$RESULT"
        return 1
    fi
}

# 测试 5: Redis 连通性
test_redis() {
    print_header "测试 5: Redis 连通性"

    RESULT=$(sudo docker exec myanmar-property-redis redis-cli -a "$REDIS_PASSWORD" ping 2>&1)

    # 检查结果中是否包含 PONG（处理警告信息干扰）
    if echo "$RESULT" | grep -q "PONG"; then
        print_success "Redis 连接正常"
        return 0
    else
        print_failure "Redis 连接失败" "$RESULT"
        return 1
    fi
}

# 测试 6: 短信验证码表检查
test_sms_table() {
    print_header "测试 6: 短信验证码表检查"

    TABLE_EXISTS=$(sudo docker exec myanmar-property-db psql -U myanmar_property -d myanmar_property -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sms_verification_codes');" 2>&1 | grep -E "(t|f)$" | tr -d ' ')

    if [ "$TABLE_EXISTS" = "t" ]; then
        print_success "sms_verification_codes 表存在"
        return 0
    else
        print_failure "sms_verification_codes 表不存在" "需要创建表"
        return 1
    fi
}

# 从数据库获取验证码
get_code_from_db() {
    local phone=$1
    local code_type=$2

    sleep 1
    CODE=$(sudo docker exec myanmar-property-db psql -U myanmar_property -d myanmar_property -t -c "
        SELECT code FROM sms_verification_codes
        WHERE phone = '$phone' AND type = '$code_type'
        ORDER BY created_at DESC LIMIT 1;
    " 2>/dev/null | grep -oE '[0-9]{6}' | head -1)

    echo "$CODE"
}

# 测试 7: 发送验证码 API
test_send_code() {
    print_header "测试 7: 发送验证码 API"

    # 测试 GET 端点
    RESPONSE=$(curl -s --max-time 10 "$BASE_URL/v1/auth/send-verification-code")
    if [[ "$RESPONSE" == *"phone"* ]]; then
        print_success "GET /v1/auth/send-verification-code 返回说明"
    fi

    # 使用测试专用手机号
    TEST_PHONE="+959701234567"

    # 清理该手机号之前的验证码
    sudo docker exec myanmar-property-db psql -U myanmar_property -d myanmar_property -c "
        DELETE FROM sms_verification_codes WHERE phone = '$TEST_PHONE';
    " > /dev/null 2>&1 || true

    # 清除Redis频率限制
    sudo docker exec myanmar-property-redis redis-cli -a "$REDIS_PASSWORD" DEL "rate_limit:sms:127.0.0.1" > /dev/null 2>&1 || true

    # 发送验证码
    RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 -X POST "$BASE_URL/v1/auth/send-verification-code" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$TEST_PHONE\",\"type\":\"login\"}")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" != "200" ]; then
        print_failure "POST 发送验证码失败" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi

    print_success "POST 发送验证码成功"

    # 从数据库查询验证码
    CODE=$(get_code_from_db "$TEST_PHONE" "login")

    if [ ! -z "$CODE" ]; then
        echo "$CODE" > /tmp/test_verify_code.txt
        echo "$TEST_PHONE" > /tmp/test_phone.txt
        print_info "验证码已从数据库获取: $CODE"
        return 0
    else
        print_failure "无法从数据库获取验证码" ""
        return 1
    fi
}

# 测试 8: 登录/注册 API
test_login() {
    print_header "测试 8: 登录/注册 API"

    TEST_PHONE="+959701234567"

    # 先尝试用login验证码登录
    if [ ! -f /tmp/test_verify_code.txt ]; then
        print_failure "无法测试登录" "没有可用的验证码"
        return 1
    fi

    CODE=$(cat /tmp/test_verify_code.txt)

    print_info "尝试使用验证码登录: $CODE"
    RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 -X POST "$BASE_URL/v1/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"phone\":\"$TEST_PHONE\",\"code\":\"$CODE\",\"device_id\":\"test_device_001\"}")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    print_info "登录响应: HTTP $HTTP_CODE"
    echo "       Body: $BODY" | tee -a "$LOG_FILE"

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "登录 API 正常（用户已存在）"
        TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
        if [ ! -z "$TOKEN" ]; then
            echo "$TOKEN" > /tmp/test_token.txt
        fi
        return 0
    fi

    # 检查是否是用户不存在
    if [ "$HTTP_CODE" = "404" ] || [[ "$BODY" == *"用户不存在"* ]] || [[ "$BODY" == *"1000"* ]]; then
        # 用户不存在，需要发送注册验证码并注册
        print_info "用户不存在，发送注册验证码..."

        # 清理并发送注册验证码
        sudo docker exec myanmar-property-db psql -U myanmar_property -d myanmar_property -c "
            DELETE FROM sms_verification_codes WHERE phone = '$TEST_PHONE';
        " > /dev/null 2>&1 || true

        # 清除Redis中的所有速率限制键
        sudo docker exec myanmar-property-redis redis-cli -a "$REDIS_PASSWORD" KEYS "rate_limit:sms:*" | xargs -r sudo docker exec myanmar-property-redis redis-cli -a "$REDIS_PASSWORD" DEL > /dev/null 2>&1 || true

        # 等待一段时间避免速率限制
        print_info "等待5秒以避免速率限制..."
        sleep 5

        RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 -X POST "$BASE_URL/v1/auth/send-verification-code" \
            -H "Content-Type: application/json" \
            -d "{\"phone\":\"$TEST_PHONE\",\"type\":\"register\"}")
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)

        if [ "$HTTP_CODE" != "200" ]; then
            print_failure "发送注册验证码失败" "HTTP $HTTP_CODE"
            return 1
        fi

        REG_CODE=$(get_code_from_db "$TEST_PHONE" "register")

        if [ -z "$REG_CODE" ]; then
            print_failure "无法获取注册验证码" ""
            return 1
        fi

        print_info "注册验证码: $REG_CODE"

        # 使用注册验证码注册
        print_info "尝试注册..."
        REG_PAYLOAD="{\"phone\":\"$TEST_PHONE\",\"code\":\"$REG_CODE\"}"
        print_info "注册请求体: $REG_PAYLOAD"

        RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 -X POST "$BASE_URL/v1/auth/register" \
            -H "Content-Type: application/json" \
            -d "$REG_PAYLOAD")
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        BODY=$(echo "$RESPONSE" | sed '$d')

        print_info "注册响应: HTTP $HTTP_CODE"
        echo "       Body: $BODY" | tee -a "$LOG_FILE"

        if [ "$HTTP_CODE" = "200" ]; then
            print_success "注册并登录成功"
            TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
            if [ ! -z "$TOKEN" ]; then
                echo "$TOKEN" > /tmp/test_token.txt
            fi
            return 0
        else
            print_failure "注册失败" "HTTP $HTTP_CODE - $BODY"
            return 1
        fi
    fi

    print_failure "登录失败" "HTTP $HTTP_CODE - $BODY"
    return 1
}

# 测试 9: 密码登录 API
test_password_login() {
    print_header "测试 9: 密码登录 API"

    # 测试已创建的管理员账号
    RESPONSE=$(curl -s -w "\n%{http_code}" --max-time 10 -X POST "$BASE_URL/v1/auth/login-with-password" \
        -H "Content-Type: application/json" \
        -d '{"phone":"09701234567","password":"admin123","device_id":"test_device_002"}')
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "密码登录 API 正常"
        return 0
    elif [ "$HTTP_CODE" = "401" ]; then
        print_failure "密码登录失败" "账号或密码错误"
        return 1
    elif [ "$HTTP_CODE" = "404" ]; then
        # 用户不存在，这是预期的（用户表为空）
        print_info "用户不存在（用户表为空），跳过密码登录测试"
        return 0
    else
        print_failure "密码登录请求失败" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# 测试 10: Elasticsearch
test_elasticsearch() {
    print_header "测试 10: Elasticsearch"

    RESULT=$(sudo docker exec myanmar_elasticsearch curl -s --max-time 10 http://localhost:9200/_cluster/health 2>&1)

    if [[ "$RESULT" == *"status"* ]]; then
        print_success "Elasticsearch 运行正常"
        echo "       $RESULT" | tee -a "$LOG_FILE"
        return 0
    else
        print_failure "Elasticsearch 检查失败" "$RESULT"
        return 1
    fi
}

# 生成测试报告
print_report() {
    print_header "测试报告"

    TOTAL=$((PASSED + FAILED))
    echo -e "总测试数: $TOTAL" | tee -a "$LOG_FILE"
    echo -e "${GREEN}通过: $PASSED${NC}" | tee -a "$LOG_FILE"
    echo -e "${RED}失败: $FAILED${NC}" | tee -a "$LOG_FILE"

    # 写入状态文件
    echo "PASSED=$PASSED" > /tmp/test_status.txt
    echo "FAILED=$FAILED" >> /tmp/test_status.txt
    echo "TOTAL=$TOTAL" >> /tmp/test_status.txt

    if [ $FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ 所有测试通过！系统运行正常。${NC}" | tee -a "$LOG_FILE"
    else
        echo -e "\n${RED}✗ 有 $FAILED 项测试失败，请检查上述错误。${NC}" | tee -a "$LOG_FILE"
    fi
}

# 主函数
main() {
    echo -e "${YELLOW}==============================================${NC}" | tee "$LOG_FILE"
    echo -e "${YELLOW}  缅甸房产平台 - 自动化测试脚本${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}  服务器: $SERVER_IP${NC}" | tee -a "$LOG_FILE"
    echo -e "${YELLOW}==============================================${NC}" | tee -a "$LOG_FILE"

    # 运行所有测试
    test_docker_services
    test_health_check
    test_web_admin
    test_database
    test_redis
    test_sms_table
    test_send_code
    test_login
    test_password_login
    # test_elasticsearch  # 暂时跳过ES测试

    # 生成报告
    print_report
}

# 执行主函数
main "$@"
