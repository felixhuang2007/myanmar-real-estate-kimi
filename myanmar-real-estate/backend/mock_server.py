# 缅甸房产平台 - Mock后端服务
# 用于测试环境演示

from flask import Flask, jsonify, request
import psycopg2
import redis
import json
from datetime import datetime
import os

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

def get_db_connection():
    return psycopg2.connect(**DB_CONFIG)

def get_redis_connection():
    return redis.Redis(**REDIS_CONFIG)

@app.route('/health', methods=['GET'])
def health_check():
    """健康检查端点"""
    try:
        # 检查数据库连接
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT 1')
        cursor.close()
        conn.close()
        
        # 检查Redis连接
        r = get_redis_connection()
        r.ping()
        
        return jsonify({
            'status': 'healthy',
            'timestamp': datetime.now().isoformat(),
            'services': {
                'database': 'connected',
                'redis': 'connected'
            }
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

@app.route('/api/v1/cities', methods=['GET'])
def get_cities():
    """获取城市列表"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT id, code, name, name_en, name_my FROM cities WHERE is_active = TRUE ORDER BY sort_order')
        cities = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'code': 200,
            'data': [{
                'id': c[0],
                'code': c[1],
                'name': c[2],
                'nameEn': c[3],
                'nameMy': c[4]
            } for c in cities]
        }), 200
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)}), 500

@app.route('/api/v1/houses', methods=['GET'])
def get_houses():
    """获取房源列表"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            SELECT h.id, h.house_code, h.title, h.title_my, h.transaction_type, 
                   h.price, h.price_unit, h.house_type, h.area, h.rooms, 
                   h.bedrooms, h.bathrooms, h.floor, h.address, h.status,
                   c.name as city_name, d.name as district_name
            FROM houses h
            JOIN cities c ON h.city_id = c.id
            JOIN districts d ON h.district_id = d.id
            WHERE h.status = 'online'
            ORDER BY h.created_at DESC
        ''')
        houses = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'code': 200,
            'data': [{
                'id': h[0],
                'houseCode': h[1],
                'title': h[2],
                'titleMy': h[3],
                'transactionType': h[4],
                'price': h[5],
                'priceUnit': h[6],
                'houseType': h[7],
                'area': float(h[8]) if h[8] else None,
                'rooms': h[9],
                'bedrooms': h[10],
                'bathrooms': h[11],
                'floor': h[12],
                'address': h[13],
                'status': h[14],
                'cityName': h[15],
                'districtName': h[16]
            } for h in houses],
            'total': len(houses)
        }), 200
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)}), 500

@app.route('/api/v1/houses/<int:house_id>', methods=['GET'])
def get_house_detail(house_id):
    """获取房源详情"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            SELECT h.*, c.name as city_name, d.name as district_name,
                   a.real_name as agent_name, a.phone as agent_phone
            FROM houses h
            JOIN cities c ON h.city_id = c.id
            JOIN districts d ON h.district_id = d.id
            LEFT JOIN agents a ON h.maintainer_id = a.id
            WHERE h.id = %s
        ''', (house_id,))
        house = cursor.fetchone()
        cursor.close()
        conn.close()
        
        if not house:
            return jsonify({'code': 404, 'message': '房源不存在'}), 404
        
        return jsonify({
            'code': 200,
            'data': {
                'id': house[0],
                'houseCode': house[1],
                'title': house[2],
                'titleMy': house[3],
                'transactionType': house[6],
                'price': house[7],
                'priceUnit': house[8],
                'houseType': house[11],
                'area': float(house[13]) if house[13] else None,
                'rooms': house[16],
                'bedrooms': house[17],
                'bathrooms': house[19],
                'floor': house[22],
                'address': house[32],
                'description': house[34],
                'cityName': house[-3],
                'districtName': house[-2],
                'agentName': house[-1]
            }
        }), 200
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)}), 500

@app.route('/api/v1/agents', methods=['GET'])
def get_agents():
    """获取经纪人列表"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('''
            SELECT a.id, a.real_name, a.work_city, a.bio, a.specialties, 
                   a.level, a.rating, a.total_deals, c.name as company_name
            FROM agents a
            LEFT JOIN companies c ON a.company_id = c.id
            WHERE a.status = 'active'
        ''')
        agents = cursor.fetchall()
        cursor.close()
        conn.close()
        
        return jsonify({
            'code': 200,
            'data': [{
                'id': a[0],
                'realName': a[1],
                'workCity': a[2],
                'bio': a[3],
                'specialties': a[4],
                'level': a[5],
                'rating': float(a[6]) if a[6] else None,
                'totalDeals': a[7],
                'companyName': a[8]
            } for a in agents]
        }), 200
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)}), 500

@app.route('/api/v1/stats', methods=['GET'])
def get_stats():
    """获取统计数据"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # 获取各表数量
        cursor.execute('SELECT count(*) FROM houses WHERE status = %s', ('online',))
        house_count = cursor.fetchone()[0]
        
        cursor.execute('SELECT count(*) FROM agents WHERE status = %s', ('active',))
        agent_count = cursor.fetchone()[0]
        
        cursor.execute('SELECT count(*) FROM users')
        user_count = cursor.fetchone()[0]
        
        cursor.execute('SELECT count(*) FROM companies')
        company_count = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'code': 200,
            'data': {
                'houses': house_count,
                'agents': agent_count,
                'users': user_count,
                'companies': company_count
            }
        }), 200
    except Exception as e:
        return jsonify({'code': 500, 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
