#!/bin/bash
# 缅甸房产平台自动化测试脚本
# 在腾讯云服务器上执行

set -e

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

# 测试输出函数
print_header() {
    echo -e "\n${YELLOW}==============================================${NC}"
    echo -e "${YELLOW}  $1${NC}"
    echo -e "${YELLOW}==============================================${NC}"
}

print_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED++))
}

print_failure() {
    echo -e "${RED}[FAIL]${NC} $1"
    echo -e "${RED}       Error: $2${NC}"
    ((FAILED++))
}

# 测试 1: Docker 服务状态
test_docker_services() {
    print_header "测试 1: Docker 服务状态"

    cd ~/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend

    SERVICES="myanmar_api myanmar_nginx myanmar_postgres myanmar_redis myanmar_web_admin"
    ALL_UP=true

    for service in $SERVICES; do
        STATUS=$(sudo docker ps --filter "name=$service" --format "{{.Status}}")
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

    RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "Health check 返回 200"
        echo "       Response: $BODY"
        return 0
    else
        print_failure "Health check 失败" "HTTP $HTTP_CODE"
        return 1
    fi
}

# 测试 3: Web Admin 页面访问
test_web_admin() {
    print_header "测试 3: Web Admin 页面访问"

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/")

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

    RESULT=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -c "SELECT COUNT(*) FROM users;" 2>&1)

    if [ $? -eq 0 ]; then
        print_success "数据库连接正常"
        echo "       用户表记录数: $RESULT"
        return 0
    else
        print_failure "数据库连接失败" "$RESULT"
        return 1
    fi
}

# 测试 5: Redis 连通性
test_redis() {
    print_header "测试 5: Redis 连通性"

    RESULT=$(sudo docker exec myanmar_redis redis-cli -a "$REDIS_PASSWORD" ping 2>&1)

    if [ "$RESULT" = "PONG" ]; then
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

    TABLE_EXISTS=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sms_verification_codes');" 2>&1 | grep -E "(t|f)$" | tr -d ' ')

    if [ "$TABLE_EXISTS" = "t" ]; then
        print_success "sms_verification_codes 表存在"
        return 0
    else
        print_failure "sms_verification_codes 表不存在" "需要创建表"

        # 自动创建表
        echo -e "${YELLOW}[INFO] 正在创建 sms_verification_codes 表...${NC}"
        sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -c "
            CREATE TABLE IF NOT EXISTS sms_verification_codes (
                id BIGSERIAL PRIMARY KEY,
                phone VARCHAR(20) NOT NULL,
                code VARCHAR(10) NOT NULL,
                type VARCHAR(20) NOT NULL DEFAULT 'login',
                expired_at TIMESTAMP WITH TIME ZONE NOT NULL,
                used_at TIMESTAMP WITH TIME ZONE,
                attempt_count INT DEFAULT 0,
                created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
            );
            CREATE INDEX IF NOT EXISTS idx_sms_codes_phone ON sms_verification_codes(phone, type);
        " 2>&1

        if [ $? -eq 0 ]; then
            print_success "sms_verification_codes 表创建成功"
            return 0
        else
            return 1
        fi
    fi
}

# 测试 7: 发送验证码 API
test_send_code() {
    print_header "测试 7: 发送验证码 API"

    # 测试 GET 端点
    RESPONSE=$(curl -s "$BASE_URL/api/auth/send-verification-code")
    if [[ "$RESPONSE" == *"缅甸手机号"* ]] || [[ "$RESPONSE" == *"phone"* ]]; then
        print_success "GET /api/auth/send-verification-code 返回说明"
    fi

    # 测试 POST 端点（缅甸手机号格式）
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/auth/send-verification-code" \
        -H "Content-Type: application/json" \
        -d '{"phone":"+959701234567","type":"login"}')
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')

    if [ "$HTTP_CODE" = "200" ]; then
        print_success "POST 发送验证码成功"
        echo "       Response: $BODY"

        # 保存验证码用于登录测试
        CODE=$(echo "$BODY" | grep -o '"code":"[0-9]*"' | cut -d'"' -f4)
        if [ ! -z "$CODE" ]; then
            echo "$CODE" > /tmp/test_verify_code.txt
            echo "$CODE" > /tmp/test_phone.txt
            echo -e "${YELLOW}[INFO] 验证码已保存: $CODE${NC}"
        fi
        return 0
    elif [ "$HTTP_CODE" = "400" ]; then
        print_failure "POST 发送验证码失败" "请求格式错误 - $BODY"
        return 1
    elif [ "$HTTP_CODE" = "429" ]; then
        print_failure "POST 发送验证码失败" "请求过于频繁"
        return 1
    elif [ "$HTTP_CODE" = "500" ]; then
        print_failure "POST 发送验证码失败" "服务器内部错误 (500)"
        echo -e "${YELLOW}[INFO] 正在诊断问题...${NC}"

        # 检查 sms_verification_codes 表是否存在
        TABLE_EXISTS=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'sms_verification_codes');" 2>&1 | grep -E "(t|f)$" | tr -d ' ')
        if [ "$TABLE_EXISTS" = "t" ]; then
            echo -e "${YELLOW}       - sms_verification_codes 表: 存在${NC}"
        else
            echo -e "${RED}       - sms_verification_codes 表: 不存在!${NC}"
        fi

        # 检查 API 日志
        echo -e "${YELLOW}[INFO] 最近 API 日志:${NC}"
        cd ~/myanmarestate/myanmar-real-estate-kimi/myanmar-real-estate/backend 2>/dev/null || true
        sudo docker-compose -f docker-compose.prod.yml logs --tail=20 api 2>&1 | tail -10 || true

        return 1
    else
        print_failure "POST 发送验证码失败" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# 测试 8: 登录 API
test_login() {
    print_header "测试 8: 登录 API"

    # 读取之前保存的验证码
    if [ -f /tmp/test_verify_code.txt ]; then
        CODE=$(cat /tmp/test_verify_code.txt)
        PHONE="+959701234567"

        RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/auth/login" \
            -H "Content-Type: application/json" \
            -d "{\"phone\":\"$PHONE\",\"code\":\"$CODE\",\"device_id\":\"test_device_001\"}")
        HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
        BODY=$(echo "$RESPONSE" | sed '$d')

        if [ "$HTTP_CODE" = "200" ]; then
            print_success "登录 API 正常"
            echo "       获取到 Token"

            # 保存 token 用于后续测试
            TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
            if [ ! -z "$TOKEN" ]; then
                echo "$TOKEN" > /tmp/test_token.txt
            fi
            return 0
        else
            print_failure "登录失败" "HTTP $HTTP_CODE - $BODY"
            return 1
        fi
    else
        print_failure "无法测试登录" "没有可用的验证码"
        return 1
    fi
}

# 测试 9: 密码登录 API
test_password_login() {
    print_header "测试 9: 密码登录 API"

    # 测试已创建的管理员账号
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/auth/login-with-password" \
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
    else
        print_failure "密码登录请求失败" "HTTP $HTTP_CODE - $BODY"
        return 1
    fi
}

# 测试 10: Elasticsearch
test_elasticsearch() {
    print_header "测试 10: Elasticsearch"

    RESULT=$(sudo docker exec myanmar_elasticsearch curl -s http://localhost:9200/_cluster/health 2>&1)

    if [[ "$RESULT" == *"status"* ]]; then
        print_success "Elasticsearch 运行正常"
        echo "       $RESULT"
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
    echo -e "总测试数: $TOTAL"
    echo -e "${GREEN}通过: $PASSED${NC}"
    echo -e "${RED}失败: $FAILED${NC}"

    if [ $FAILED -eq 0 ]; then
        echo -e "\n${GREEN}✓ 所有测试通过！系统运行正常。${NC}"
        exit 0
    else
        echo -e "\n${RED}✗ 有 $FAILED 项测试失败，请检查上述错误。${NC}"
        exit 1
    fi
}

# 主函数
main() {
    echo -e "${YELLOW}==============================================${NC}"
    echo -e "${YELLOW}  缅甸房产平台 - 自动化测试脚本${NC}"
    echo -e "${YELLOW}  服务器: $SERVER_IP${NC}"
    echo -e "${YELLOW}==============================================${NC}"

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
    test_elasticsearch

    # 生成报告
    print_report
}

# 执行主函数
main "$@"
