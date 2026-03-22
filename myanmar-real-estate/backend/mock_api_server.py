#!/usr/bin/env python3
"""缅甸房产平台 - Mock API服务器
用于Flutter APP本地测试
"""

from flask import Flask, jsonify, request
from flask_cors import CORS
import random
import time
import json

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# 存储验证码（内存中）
verification_codes = {}
users = {}

@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({
        "code": 200,
        "message": "success",
        "data": {"status": "ok", "time": int(time.time())},
        "timestamp": int(time.time()),
        "request_id": str(int(time.time() * 1000))
    })

@app.route('/v1/auth/send-verification-code', methods=['POST', 'OPTIONS'])
def send_verification_code():
    if request.method == 'OPTIONS':
        return '', 204

    data = request.get_json()
    phone = data.get('phone', '')

    # 生成6位验证码
    code = ''.join([str(random.randint(0, 9)) for _ in range(6)])
    verification_codes[phone] = code

    print(f"[验证码] 手机号: {phone}, 验证码: {code}")

    return jsonify({
        "code": 200,
        "message": "验证码发送成功",
        "data": {
            "expired_at": int(time.time()) + 300,
            "interval": 60
        },
        "timestamp": int(time.time()),
        "request_id": str(int(time.time() * 1000))
    })

@app.route('/v1/auth/login', methods=['POST', 'OPTIONS'])
def login():
    if request.method == 'OPTIONS':
        return '', 204

    data = request.get_json()
    phone = data.get('phone', '')
    code = data.get('code', '')

    # 检查验证码（测试模式下任何6位数字都通过，或者使用存储的验证码）
    if code == '123456' or verification_codes.get(phone) == code:
        user_id = random.randint(10000, 99999)
        token = f"mock_token_{user_id}_{int(time.time())}"

        users[phone] = {
            "user_id": user_id,
            "phone": phone,
            "nickname": "测试用户",
            "token": token
        }

        return jsonify({
            "code": 200,
            "message": "登录成功",
            "data": {
                "user_id": user_id,
                "token": token,
                "refresh_token": f"refresh_{token}",
                "expires_at": int(time.time()) + 86400,
                "is_new_user": False
            },
            "timestamp": int(time.time()),
            "request_id": str(int(time.time() * 1000))
        })
    else:
        return jsonify({
            "code": 1101,
            "message": "验证码错误或已过期",
            "timestamp": int(time.time()),
            "request_id": str(int(time.time() * 1000))
        }), 400

@app.route('/v1/auth/register', methods=['POST', 'OPTIONS'])
def register():
    if request.method == 'OPTIONS':
        return '', 204

    data = request.get_json()
    phone = data.get('phone', '')

    user_id = random.randint(10000, 99999)
    token = f"mock_token_{user_id}_{int(time.time())}"

    return jsonify({
        "code": 200,
        "message": "注册成功",
        "data": {
            "user_id": user_id,
            "token": token,
            "refresh_token": f"refresh_{token}",
            "expires_at": int(time.time()) + 86400,
            "is_new_user": True
        },
        "timestamp": int(time.time()),
        "request_id": str(int(time.time() * 1000))
    })

@app.route('/v1/users/me', methods=['GET', 'OPTIONS'])
def get_current_user():
    if request.method == 'OPTIONS':
        return '', 204

    auth_header = request.headers.get('Authorization', '')

    return jsonify({
        "code": 200,
        "message": "success",
        "data": {
            "user_id": 12345,
            "uuid": "mock-uuid-12345",
            "phone": "+959123456789",
            "email": None,
            "status": "active",
            "is_verified": True,
            "profile": {
                "nickname": "测试用户",
                "avatar": "",
                "gender": None,
                "birthday": None,
                "bio": None
            },
            "verification": None,
            "agent_info": None
        },
        "timestamp": int(time.time()),
        "request_id": str(int(time.time() * 1000))
    })

@app.route('/v1/houses/recommendations', methods=['GET', 'OPTIONS'])
def get_houses():
    if request.method == 'OPTIONS':
        return '', 204

    # 生成模拟房源数据
    houses = []
    for i in range(1, 11):
        houses.append({
            "house_id": i,
            "house_code": f"H{i:06d}",
            "title": f"仰光市中心优质公寓 - {i}号",
            "transaction_type": "sale" if i % 2 == 0 else "rent",
            "price": 50000000 + i * 10000000,
            "price_unit": "MMK",
            "house_type": "apartment",
            "area": 80.0 + i * 5,
            "bedrooms": 2 + i % 3,
            "living_rooms": 1,
            "bathrooms": 1 + i % 2,
            "location": {
                "city": {"code": "YGN", "name": "仰光"},
                "district": {"code": "TAMWE", "name": "Tamwe"},
                "address": f"Test Street {i}"
            },
            "images": [{"id": 1, "url": "https://via.placeholder.com/400x300", "is_main": True}],
            "is_favorited": False,
            "status": "online",
            "created_at": "2024-01-01T00:00:00Z"
        })

    return jsonify({
        "code": 200,
        "message": "success",
        "data": {
            "list": houses,
            "pagination": {
                "page": 1,
                "page_size": 20,
                "total": len(houses),
                "has_more": False
            }
        },
        "timestamp": int(time.time()),
        "request_id": str(int(time.time() * 1000))
    })

if __name__ == '__main__':
    print("=" * 50)
    print("缅甸房产平台 - Mock API服务器")
    print("=" * 50)
    print("API地址: http://localhost:8080")
    print("测试手机号: 任意手机号")
    print("测试验证码: 123456")
    print("=" * 50)
    app.run(host='0.0.0.0', port=8080, debug=True, use_reloader=False)
