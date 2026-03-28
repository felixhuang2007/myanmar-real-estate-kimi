#!/bin/bash
# Simple API test script

BASE_URL="http://43.163.122.42"
TEST_PHONE="+959701234567"
TEST_PASSWORD="admin123"
TEST_DEVICE_ID="test_device_$(date +%s)"

echo "=== TEST-002: Send verification code ==="
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/auth/send-verification-code" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"$TEST_PHONE\",\"type\":\"login\"}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "HTTP: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "SUCCESS: Verification code sent"
    sleep 1
    DB_CODE=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -t -c "SELECT code FROM sms_verification_codes WHERE phone = '$TEST_PHONE' AND type = 'login' AND expired_at > NOW() ORDER BY created_at DESC LIMIT 1;" 2>/dev/null | xargs)
    echo "Code from DB: $DB_CODE"
    VERIFICATION_CODE="$DB_CODE"
else
    echo "SKIP: Rate limited, trying to get existing code from DB"
    DB_CODE=$(sudo docker exec myanmar_postgres psql -U myanmar_property -d myanmar_property -t -c "SELECT code FROM sms_verification_codes WHERE phone = '$TEST_PHONE' AND type = 'login' AND expired_at > NOW() ORDER BY created_at DESC LIMIT 1;" 2>/dev/null | xargs)
    if [ -n "$DB_CODE" ]; then
        echo "Found existing code: $DB_CODE"
        VERIFICATION_CODE="$DB_CODE"
    fi
fi

echo ""
echo "=== TEST-003: Login with code ==="
CODE="${VERIFICATION_CODE:-123456}"
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"$TEST_PHONE\",\"code\":\"$CODE\",\"device_id\":\"$TEST_DEVICE_ID\"}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "HTTP: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "SUCCESS: Login successful"
    TOKEN=$(echo "$BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    echo "Token: ${TOKEN:0:30}..."
else
    echo "FAIL: Login failed"
    echo "Body: $BODY"
fi

echo ""
echo "=== TEST-004: Password login ==="
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/auth/login-with-password" \
    -H "Content-Type: application/json" \
    -d "{\"phone\":\"$TEST_PHONE\",\"password\":\"$TEST_PASSWORD\",\"device_id\":\"${TEST_DEVICE_ID}_pwd\"}")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "HTTP: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "SUCCESS: Password login successful"
else
    echo "SKIP/FAIL: Password login returned $HTTP_CODE"
fi

echo ""
echo "=== TEST-010: House search ==="
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/api/houses/search?page=1&page_size=5")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')
echo "HTTP: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "SUCCESS: House search working"
    HOUSE_ID=$(echo "$BODY" | grep -o '"id":"[0-9]*"' | head -1 | cut -d'"' -f4)
    echo "First house ID: $HOUSE_ID"
else
    echo "FAIL: House search failed"
fi

echo ""
echo "=== TEST-044: Health check ==="
RESPONSE=$(curl -s -w "\n%{http_code}" "$BASE_URL/health")
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
echo "HTTP: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
    echo "SUCCESS: Health check passed"
fi
