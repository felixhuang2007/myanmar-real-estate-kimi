#!/usr/bin/env python3
# ============================================
# 缅甸房产平台 - 完整Mock后端服务
# 用于API自动化测试
# ============================================

from flask import Flask, jsonify, request
import psycopg2
import redis
import json
import uuid
import time
from datetime import datetime
from functools import wraps

app = Flask(__name__)

# 数据库配置
DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'user': 'postgres',
    'password': 'test123',
    'database': 'myanmarhome'
}

# Redis配置
REDIS_CONFIG = {
    'host': 'localhost',
    'port': 6379,
    'db': 0
}

# 模拟数据存储
users = {}
houses = {}
appointments = {}
deals = {}
conversations = {}
messages = {}
favorites = set()
agents = {}
tokens = {}

# 初始化模拟数据
def init_mock_data():
    # 初始化测试用户
    users['1'] = {
        'id': '1',
        'phone': '+8613800138000',
        'nickname': '测试用户',
        'avatar': '',
        'status': 'active',
        'verified': True,
        'created_at': datetime.now().isoformat()
    }
    
    # 初始化测试房源
    for i in range(1, 6):
        houses[str(i)] = {
            'id': str(i),
            'houseCode': f'H{i:06d}',
            'title': f'测试房源{i}',
            'titleMy': f'အစမ်း အိမ်ခြံမြေ {i}',
            'transactionType': 'sale' if i % 2 == 0 else 'rent',
            'price': 100000 + i * 10000,
            'priceUnit': 'USD',
            'houseType': 'apartment',
            'area': 80 + i * 10,
            'rooms': 2 + i,
            'bedrooms': 1 + i,
            'bathrooms': 1,
            'floor': i,
            'address': f'仰光测试地址{i}',
            'description': f'这是一个测试房源{i}',
            'status': 'online',
            'cityName': '仰光',
            'districtName': '市中心',
            'agentName': '张经纪',
            'created_at': datetime.now().isoformat()
        }
    
    # 初始化经纪人
    for i in range(1, 4):
        agents[str(i)] = {
            'id': str(i),
            'realName': f'经纪人{i}',
            'workCity': '仰光',
            'bio': f'专业房产经纪人，从业{i}年',
            'specialties': ['住宅', '公寓'],
            'level': 'gold',
            'rating': 4.5 + i * 0.1,
            'totalDeals': 10 * i,
            'companyName': '缅甸房产公司',
            'status': 'active'
        }

# 数据库连接
def get_db_connection():
    try:
        return psycopg2.connect(**DB_CONFIG)
    except:
        return None

def get_redis_connection():
    try:
        return redis.Redis(**REDIS_CONFIG)
    except:
        return None

# JWT验证装饰器
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Bearer '):
            return jsonify({'code': 401, 'message': '未授权'}), 401
        token = auth_header[7:]
        if token not in tokens and token != 'test_token':
            return jsonify({'code': 401, 'message': 'Token无效'}), 401
        return f(*args, **kwargs)
    return decorated

# ============================================
# 健康检查
# ============================================
@app.route('/health', methods=['GET'])
def health_check():
    db_status = 'connected' if get_db_connection() else 'disconnected'
    redis_status = 'connected' if get_redis_connection() else 'disconnected'
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'services': {
            'database': db_status,
            'redis': redis_status
        }
    }), 200

# ============================================
# 用户模块
# ============================================
@app.route('/api/v1/auth/register', methods=['POST'])
def register():
    data = request.get_json() or {}
    user_id = str(len(users) + 1)
    users[user_id] = {
        'id': user_id,
        'phone': data.get('phone', ''),
        'nickname': '新用户',
        'status': 'active',
        'verified': False,
        'created_at': datetime.now().isoformat()
    }
    return jsonify({'code': 200, 'message': '注册成功', 'data': {'userId': user_id}}), 200

@app.route('/api/v1/auth/login', methods=['POST'])
def login():
    data = request.get_json() or {}
    access_token = str(uuid.uuid4())
    refresh_token = str(uuid.uuid4())
    tokens[access_token] = {'user_id': '1', 'created_at': time.time()}
    return jsonify({
        'code': 200,
        'message': '登录成功',
        'data': {
            'accessToken': access_token,
            'refreshToken': refresh_token,
            'expiresIn': 86400,
            'user': users.get('1', {})
        }
    }), 200

@app.route('/api/v1/auth/logout', methods=['POST'])
@require_auth
def logout():
    return jsonify({'code': 200, 'message': '登出成功'}), 200

@app.route('/api/v1/auth/me', methods=['GET'])
@require_auth
def get_me():
    return jsonify({'code': 200, 'data': users.get('1', {})}), 200

@app.route('/api/v1/users/verification', methods=['POST'])
@require_auth
def user_verification():
    data = request.get_json() or {}
    if '1' in users:
        users['1']['verified'] = True
        users['1']['realName'] = data.get('realName', '')
    return jsonify({'code': 200, 'message': '认证成功'}), 200

@app.route('/api/v1/users/<user_id>', methods=['GET'])
@require_auth
def get_user(user_id):
    user = users.get(user_id)
    if not user:
        return jsonify({'code': 404, 'message': '用户不存在'}), 404
    return jsonify({'code': 200, 'data': user}), 200

@app.route('/api/v1/users/<user_id>', methods=['PUT'])
@require_auth
def update_user(user_id):
    data = request.get_json() or {}
    if user_id in users:
        users[user_id].update(data)
    return jsonify({'code': 200, 'message': '更新成功'}), 200

@app.route('/api/v1/auth/refresh', methods=['POST'])
def refresh_token():
    new_token = str(uuid.uuid4())
    return jsonify({
        'code': 200,
        'data': {
            'accessToken': new_token,
            'refreshToken': str(uuid.uuid4()),
            'expiresIn': 86400
        }
    }), 200

# ============================================
# 房源模块
# ============================================
@app.route('/api/v1/houses', methods=['GET'])
def get_houses():
    house_list = list(houses.values())
    return jsonify({
        'code': 200,
        'data': house_list,
        'total': len(house_list)
    }), 200

@app.route('/api/v1/houses', methods=['POST'])
@require_auth
def create_house():
    data = request.get_json() or {}
    house_id = str(len(houses) + 1)
    houses[house_id] = {
        'id': house_id,
        'houseCode': f'H{int(house_id):06d}',
        **data,
        'status': 'online',
        'created_at': datetime.now().isoformat()
    }
    return jsonify({'code': 200, 'message': '创建成功', 'data': {'id': house_id}}), 200

@app.route('/api/v1/houses/<house_id>', methods=['GET'])
def get_house_detail(house_id):
    house = houses.get(house_id)
    if not house:
        return jsonify({'code': 404, 'message': '房源不存在'}), 404
    return jsonify({'code': 200, 'data': house}), 200

@app.route('/api/v1/houses/<house_id>', methods=['PUT'])
@require_auth
def update_house(house_id):
    data = request.get_json() or {}
    if house_id in houses:
        houses[house_id].update(data)
        return jsonify({'code': 200, 'message': '更新成功'}), 200
    return jsonify({'code': 404, 'message': '房源不存在'}), 404

@app.route('/api/v1/houses/<house_id>', methods=['DELETE'])
@require_auth
def delete_house(house_id):
    if house_id in houses:
        houses[house_id]['status'] = 'deleted'
    return jsonify({'code': 200, 'message': '删除成功'}), 200

@app.route('/api/v1/houses/search', methods=['POST'])
def search_houses():
    data = request.get_json() or {}
    results = list(houses.values())
    return jsonify({
        'code': 200,
        'data': results,
        'total': len(results)
    }), 200

@app.route('/api/v1/houses/map', methods=['GET'])
def map_houses():
    house_list = list(houses.values())
    return jsonify({
        'code': 200,
        'data': house_list,
        'total': len(house_list)
    }), 200

@app.route('/api/v1/houses/<house_id>/favorite', methods=['POST'])
@require_auth
def favorite_house(house_id):
    favorites.add(house_id)
    return jsonify({'code': 200, 'message': '收藏成功'}), 200

@app.route('/api/v1/houses/favorites', methods=['GET'])
@require_auth
def get_favorites():
    fav_list = [houses.get(hid, {}) for hid in favorites if hid in houses]
    return jsonify({
        'code': 200,
        'data': fav_list,
        'total': len(fav_list)
    }), 200

@app.route('/api/v1/houses/<house_id>/report', methods=['POST'])
@require_auth
def report_house(house_id):
    return jsonify({'code': 200, 'message': '举报已提交'}), 200

# ============================================
# 预约模块
# ============================================
@app.route('/api/v1/appointments', methods=['POST'])
@require_auth
def create_appointment():
    data = request.get_json() or {}
    apt_id = str(len(appointments) + 1)
    appointments[apt_id] = {
        'id': apt_id,
        **data,
        'status': 'pending',
        'created_at': datetime.now().isoformat()
    }
    return jsonify({'code': 200, 'message': '预约创建成功', 'data': {'id': apt_id}}), 200

@app.route('/api/v1/appointments', methods=['GET'])
@require_auth
def get_appointments():
    apt_list = list(appointments.values())
    return jsonify({
        'code': 200,
        'data': apt_list,
        'total': len(apt_list)
    }), 200

@app.route('/api/v1/appointments/<apt_id>', methods=['GET'])
@require_auth
def get_appointment(apt_id):
    apt = appointments.get(apt_id)
    if not apt:
        return jsonify({'code': 404, 'message': '预约不存在'}), 404
    return jsonify({'code': 200, 'data': apt}), 200

@app.route('/api/v1/appointments/<apt_id>/confirm', methods=['PUT'])
@require_auth
def confirm_appointment(apt_id):
    if apt_id in appointments:
        appointments[apt_id]['status'] = 'confirmed'
        return jsonify({'code': 200, 'message': '预约已确认'}), 200
    return jsonify({'code': 404, 'message': '预约不存在'}), 404

@app.route('/api/v1/appointments/<apt_id>/cancel', methods=['PUT'])
@require_auth
def cancel_appointment(apt_id):
    if apt_id in appointments:
        appointments[apt_id]['status'] = 'cancelled'
        return jsonify({'code': 200, 'message': '预约已取消'}), 200
    return jsonify({'code': 404, 'message': '预约不存在'}), 404

@app.route('/api/v1/appointments/<apt_id>/complete', methods=['PUT'])
@require_auth
def complete_appointment(apt_id):
    if apt_id in appointments:
        appointments[apt_id]['status'] = 'completed'
        return jsonify({'code': 200, 'message': '预约已完成'}), 200
    return jsonify({'code': 404, 'message': '预约不存在'}), 404

# ============================================
# ACN模块
# ============================================
@app.route('/api/v1/acn/deals', methods=['POST'])
@require_auth
def create_deal():
    data = request.get_json() or {}
    deal_id = str(len(deals) + 1)
    deals[deal_id] = {
        'id': deal_id,
        **data,
        'status': 'pending',
        'created_at': datetime.now().isoformat()
    }
    return jsonify({'code': 200, 'message': '成交创建成功', 'data': {'id': deal_id}}), 200

@app.route('/api/v1/acn/deals', methods=['GET'])
@require_auth
def get_deals():
    deal_list = list(deals.values())
    return jsonify({
        'code': 200,
        'data': deal_list,
        'total': len(deal_list)
    }), 200

@app.route('/api/v1/acn/deals/<deal_id>', methods=['GET'])
@require_auth
def get_deal(deal_id):
    deal = deals.get(deal_id)
    if not deal:
        return jsonify({'code': 404, 'message': '成交不存在'}), 404
    return jsonify({'code': 200, 'data': deal}), 200

@app.route('/api/v1/acn/deals/<deal_id>/confirm', methods=['POST'])
@require_auth
def confirm_deal(deal_id):
    if deal_id in deals:
        deals[deal_id]['status'] = 'confirmed'
        return jsonify({'code': 200, 'message': '成交已确认'}), 200
    return jsonify({'code': 404, 'message': '成交不存在'}), 404

@app.route('/api/v1/acn/commission', methods=['GET'])
@require_auth
def calculate_commission():
    deal_price = float(request.args.get('dealPrice', 100000))
    commission = deal_price * 0.03
    return jsonify({
        'code': 200,
        'data': {
            'dealPrice': deal_price,
            'commission': commission,
            'rate': 0.03
        }
    }), 200

@app.route('/api/v1/acn/stats', methods=['GET'])
@require_auth
def acn_stats():
    return jsonify({
        'code': 200,
        'data': {
            'totalDeals': len(deals),
            'totalCommission': sum(d.get('commission', 0) for d in deals.values()),
            'monthlyDeals': len(deals)
        }
    }), 200

# ============================================
# IM模块
# ============================================
@app.route('/api/v1/im/conversations', methods=['POST'])
@require_auth
def create_conversation():
    data = request.get_json() or {}
    conv_id = f"conv_{len(conversations) + 1}"
    conversations[conv_id] = {
        'id': conv_id,
        **data,
        'created_at': datetime.now().isoformat()
    }
    return jsonify({'code': 200, 'message': '会话创建成功', 'data': {'id': conv_id}}), 200

@app.route('/api/v1/im/conversations', methods=['GET'])
@require_auth
def get_conversations():
    conv_list = list(conversations.values())
    return jsonify({
        'code': 200,
        'data': conv_list,
        'total': len(conv_list)
    }), 200

@app.route('/api/v1/im/messages', methods=['POST'])
@require_auth
def send_message():
    data = request.get_json() or {}
    msg_id = str(len(messages) + 1)
    messages[msg_id] = {
        'id': msg_id,
        **data,
        'created_at': datetime.now().isoformat()
    }
    return jsonify({'code': 200, 'message': '发送成功', 'data': {'id': msg_id}}), 200

@app.route('/api/v1/im/messages/<conversation_id>', methods=['GET'])
@require_auth
def get_messages(conversation_id):
    msgs = [m for m in messages.values() if m.get('conversationId') == conversation_id]
    return jsonify({
        'code': 200,
        'data': msgs,
        'total': len(msgs)
    }), 200

# ============================================
# 其他接口
# ============================================
@app.route('/api/v1/cities', methods=['GET'])
def get_cities():
    return jsonify({
        'code': 200,
        'data': [
            {'id': 1, 'code': 'yangon', 'name': '仰光', 'nameEn': 'Yangon', 'nameMy': 'ရန်ကုန်'},
            {'id': 2, 'code': 'mandalay', 'name': '曼德勒', 'nameEn': 'Mandalay', 'nameMy': 'မန္တလေး'},
            {'id': 3, 'code': 'naypyitaw', 'name': '内比都', 'nameEn': 'Naypyitaw', 'nameMy': 'နေပြည်တော်'}
        ]
    }), 200

@app.route('/api/v1/cities/<code>/districts', methods=['GET'])
def get_districts(code):
    return jsonify({
        'code': 200,
        'data': [
            {'id': 1, 'code': f'{code}_001', 'name': '市中心', 'nameEn': 'City Center', 'nameMy': 'မြို့လယ်က'},
            {'id': 2, 'code': f'{code}_002', 'name': '郊区', 'nameEn': 'Suburbs', 'nameMy': 'မြို့မြတ'},
            {'id': 3, 'code': f'{code}_003', 'name': '开发区', 'nameEn': 'Development Zone', 'nameMy': 'ဖွံ့ဖြိုးရေးဇုန်'}
        ]
    }), 200

@app.route('/api/v1/stats', methods=['GET'])
def get_stats():
    return jsonify({
        'code': 200,
        'data': {
            'houses': len(houses),
            'agents': len(agents),
            'users': len(users),
            'companies': 5
        }
    }), 200

@app.route('/api/v1/agents', methods=['GET'])
def get_agents():
    agent_list = list(agents.values())
    return jsonify({
        'code': 200,
        'data': agent_list,
        'total': len(agent_list)
    }), 200

@app.route('/api/v1/agents/<agent_id>', methods=['GET'])
def get_agent(agent_id):
    agent = agents.get(agent_id)
    if not agent:
        return jsonify({'code': 404, 'message': '经纪人不存在'}), 404
    return jsonify({'code': 200, 'data': agent}), 200

@app.route('/api/v1/upload/token', methods=['GET'])
@require_auth
def get_upload_token():
    return jsonify({
        'code': 200,
        'data': {
            'token': str(uuid.uuid4()),
            'expire': int(time.time()) + 3600,
            'domain': 'https://cdn.example.com'
        }
    }), 200

@app.route('/api/v1/upload/image', methods=['POST'])
@require_auth
def upload_image():
    return jsonify({
        'code': 200,
        'message': '上传成功',
        'data': {
            'url': 'https://cdn.example.com/images/test.jpg',
            'name': 'test.jpg',
            'size': 1024
        }
    }), 200

# ============================================
# 管理后台 Dashboard 模块
# ============================================
@app.route('/api/v1/admin/dashboard/stats', methods=['GET'])
def admin_dashboard_stats():
    """仪表盘统计数据"""
    return jsonify({
        'code': 200,
        'data': {
            'totalUsers': 12580,
            'totalHouses': 3456,
            'monthDeals': 128,
            'monthGMV': 2580,
            'totalAgents': 892,
            'activeAgents': 456
        }
    }), 200

@app.route('/api/v1/admin/dashboard/trend/users', methods=['GET'])
def admin_dashboard_user_trend():
    """用户增长趋势"""
    days = request.args.get('days', 7, type=int)
    from datetime import datetime, timedelta
    data = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=days-1-i)).strftime('%m-%d')
        value = [120, 132, 101, 134, 90, 230, 210][i % 7]
        data.append({'date': date, 'value': value})
    return jsonify({'code': 200, 'data': data}), 200

@app.route('/api/v1/admin/dashboard/trend/houses', methods=['GET'])
def admin_dashboard_house_trend():
    """房源增长趋势"""
    days = request.args.get('days', 7, type=int)
    from datetime import datetime, timedelta
    data = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=days-1-i)).strftime('%m-%d')
        value = [45, 52, 38, 65, 48, 72, 58][i % 7]
        data.append({'date': date, 'value': value})
    return jsonify({'code': 200, 'data': data}), 200

@app.route('/api/v1/admin/dashboard/trend/deals', methods=['GET'])
def admin_dashboard_deal_trend():
    """交易趋势"""
    days = request.args.get('days', 7, type=int)
    from datetime import datetime, timedelta
    data = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=days-1-i)).strftime('%m-%d')
        value = [12, 15, 8, 18, 22, 25, 19][i % 7]
        data.append({'date': date, 'value': value})
    return jsonify({'code': 200, 'data': data}), 200

# ============================================
# 管理后台 Dashboard 模块 - 不带 /v1 前缀的版本
# 用于兼容前端直接访问 /api/admin/dashboard/...
# ============================================
@app.route('/api/admin/dashboard/stats', methods=['GET'])
def admin_dashboard_stats_no_v1():
    """仪表盘统计数据 (无v1前缀)"""
    return jsonify({
        'code': 200,
        'data': {
            'totalUsers': 12580,
            'totalHouses': 3456,
            'monthDeals': 128,
            'monthGMV': 2580,
            'totalAgents': 892,
            'activeAgents': 456
        }
    }), 200

@app.route('/api/admin/dashboard/trend/users', methods=['GET'])
def admin_dashboard_user_trend_no_v1():
    """用户增长趋势 (无v1前缀)"""
    days = request.args.get('days', 7, type=int)
    from datetime import datetime, timedelta
    data = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=days-1-i)).strftime('%m-%d')
        value = [120, 132, 101, 134, 90, 230, 210][i % 7]
        data.append({'date': date, 'value': value})
    return jsonify({'code': 200, 'data': data}), 200

@app.route('/api/admin/dashboard/trend/houses', methods=['GET'])
def admin_dashboard_house_trend_no_v1():
    """房源增长趋势 (无v1前缀)"""
    days = request.args.get('days', 7, type=int)
    from datetime import datetime, timedelta
    data = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=days-1-i)).strftime('%m-%d')
        value = [45, 52, 38, 65, 48, 72, 58][i % 7]
        data.append({'date': date, 'value': value})
    return jsonify({'code': 200, 'data': data}), 200

@app.route('/api/admin/dashboard/trend/deals', methods=['GET'])
def admin_dashboard_deal_trend_no_v1():
    """交易趋势 (无v1前缀)"""
    days = request.args.get('days', 7, type=int)
    from datetime import datetime, timedelta
    data = []
    for i in range(days):
        date = (datetime.now() - timedelta(days=days-1-i)).strftime('%m-%d')
        value = [12, 15, 8, 18, 22, 25, 19][i % 7]
        data.append({'date': date, 'value': value})
    return jsonify({'code': 200, 'data': data}), 200

# 错误处理
@app.errorhandler(404)
def not_found(e):
    return jsonify({'code': 404, 'message': '接口不存在'}), 404

@app.errorhandler(500)
def server_error(e):
    return jsonify({'code': 500, 'message': '服务器内部错误'}), 500

if __name__ == '__main__':
    init_mock_data()
    port = 8081
    print(f"Mock服务器启动在 http://0.0.0.0:{port}")
    app.run(host='0.0.0.0', port=port, debug=False, threaded=True)
