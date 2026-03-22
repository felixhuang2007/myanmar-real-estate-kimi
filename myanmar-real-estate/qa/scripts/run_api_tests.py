#!/usr/bin/env python3
# ============================================
# 缅甸房产平台 - 集成测试执行器
# 启动Mock服务器并执行API自动化测试
# ============================================

import subprocess
import time
import sys
import os
import signal
from datetime import datetime

# 配置
BASE_DIR = "/root/.openclaw/workspace"
MOCK_SERVER = f"{BASE_DIR}/backend/full_mock_server.py"
TEST_SCRIPT = f"{BASE_DIR}/qa/scripts/api-automation-test.sh"
REPORT_FILE = f"{BASE_DIR}/qa/reports/API自动化测试报告_2026-03-17.md"

def log(msg):
    print(f"[{datetime.now().strftime('%H:%M:%S')}] {msg}")

def start_mock_server():
    """启动Mock服务器"""
    log("启动Mock服务器...")
    proc = subprocess.Popen(
        [sys.executable, MOCK_SERVER],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        preexec_fn=os.setsid
    )
    # 等待服务器启动
    time.sleep(3)
    return proc

def check_server():
    """检查服务器状态"""
    try:
        import urllib.request
        response = urllib.request.urlopen('http://localhost:8080/health', timeout=5)
        return response.status == 200
    except:
        return False

def run_tests():
    """运行API测试"""
    log("开始执行API自动化测试...")
    
    # 创建报告目录
    os.makedirs(os.path.dirname(REPORT_FILE), exist_ok=True)
    
    # 测试结果
    results = {
        'total': 0,
        'passed': 0,
        'failed': 0,
        'details': []
    }
    
    # 测试配置: (method, endpoint, description, data, need_auth, expected_code)
    tests = [
        # 健康检查
        ('GET', '/health', '服务健康检查', None, False, 200),
        
        # 用户模块
        ('POST', '/api/v1/auth/register', '用户注册', '{"phone":"+8613800138001","password":"Test123456"}', False, 200),
        ('POST', '/api/v1/auth/login', '用户登录', '{"phone":"+8613800138000","password":"Test123456"}', False, 200),
        ('POST', '/api/v1/auth/logout', '用户登出', '{}', True, 200),
        ('GET', '/api/v1/auth/me', '获取当前用户', None, True, 200),
        ('POST', '/api/v1/users/verification', '实名认证', '{"realName":"测试用户"}', True, 200),
        ('GET', '/api/v1/users/1', '获取用户信息', None, True, 200),
        ('PUT', '/api/v1/users/1', '更新用户信息', '{"nickname":"新昵称"}', True, 200),
        ('POST', '/api/v1/auth/refresh', '刷新Token', '{"refreshToken":"test"}', False, 200),
        
        # 房源模块
        ('GET', '/api/v1/houses', '房源列表', None, False, 200),
        ('POST', '/api/v1/houses', '创建房源', '{"title":"测试房源","price":100000}', True, 200),
        ('GET', '/api/v1/houses/1', '房源详情', None, False, 200),
        ('PUT', '/api/v1/houses/1', '更新房源', '{"price":120000}', True, 200),
        ('DELETE', '/api/v1/houses/999', '删除房源', None, True, 200),
        ('POST', '/api/v1/houses/search', '搜索房源', '{"keyword":"公寓"}', False, 200),
        ('GET', '/api/v1/houses/map?lat=16.8661&lng=96.1951', '地图找房', None, False, 200),
        ('POST', '/api/v1/houses/1/favorite', '收藏房源', '{}', True, 200),
        ('GET', '/api/v1/houses/favorites', '收藏列表', None, True, 200),
        ('POST', '/api/v1/houses/1/report', '举报房源', '{"reason":"虚假信息"}', True, 200),
        
        # 预约模块
        ('POST', '/api/v1/appointments', '创建预约', '{"houseId":1,"appointmentDate":"2026-03-20"}', True, 200),
        ('GET', '/api/v1/appointments', '预约列表', None, True, 200),
        ('GET', '/api/v1/appointments/1', '预约详情', None, True, 200),
        ('PUT', '/api/v1/appointments/1/confirm', '确认预约', '{}', True, 200),
        ('PUT', '/api/v1/appointments/1/cancel', '取消预约', '{"reason":"时间冲突"}', True, 200),
        ('PUT', '/api/v1/appointments/1/complete', '完成预约', '{"feedback":"顺利"}', True, 200),
        
        # ACN模块
        ('POST', '/api/v1/acn/deals', '创建成交', '{"houseId":1,"dealPrice":95000}', True, 200),
        ('GET', '/api/v1/acn/deals', '成交列表', None, True, 200),
        ('GET', '/api/v1/acn/deals/1', '成交详情', None, True, 200),
        ('POST', '/api/v1/acn/deals/1/confirm', '确认成交', '{}', True, 200),
        ('GET', '/api/v1/acn/commission?dealPrice=100000', '佣金计算', None, True, 200),
        ('GET', '/api/v1/acn/stats', 'ACN统计', None, True, 200),
        
        # IM模块
        ('POST', '/api/v1/im/conversations', '创建会话', '{"type":"single"}', True, 200),
        ('GET', '/api/v1/im/conversations', '会话列表', None, True, 200),
        ('POST', '/api/v1/im/messages', '发送消息', '{"conversationId":"conv_1","type":"text","content":"你好"}', True, 200),
        ('GET', '/api/v1/im/messages/conv_1', '获取消息', None, True, 200),
        
        # 其他接口
        ('GET', '/api/v1/cities', '城市列表', None, False, 200),
        ('GET', '/api/v1/cities/yangon/districts', '区域列表', None, False, 200),
        ('GET', '/api/v1/stats', '统计数据', None, False, 200),
        ('GET', '/api/v1/agents', '经纪人列表', None, False, 200),
        ('GET', '/api/v1/agents/1', '经纪人详情', None, False, 200),
        ('GET', '/api/v1/upload/token', '上传Token', None, True, 200),
        ('POST', '/api/v1/upload/image', '上传图片', '{"image":"data:image/png;base64,iVBORw0KGgo"}', True, 200),
    ]
    
    # 获取Token
    import urllib.request
    import json
    
    token = ""
    try:
        req = urllib.request.Request(
            'http://localhost:8080/api/v1/auth/login',
            data=b'{"phone":"+8613800138000","password":"Test123456"}',
            headers={'Content-Type': 'application/json'},
            method='POST'
        )
        response = urllib.request.urlopen(req, timeout=5)
        data = json.loads(response.read().decode())
        token = data.get('data', {}).get('accessToken', 'test_token')
        log(f"获取Token成功: {token[:16]}...")
    except Exception as e:
        log(f"获取Token失败: {e}")
        token = "test_token"
    
    # 执行测试
    for method, endpoint, desc, data, need_auth, expected in tests:
        results['total'] += 1
        start_time = time.time()
        
        try:
            url = f'http://localhost:8080{endpoint}'
            req = urllib.request.Request(url, method=method)
            
            if need_auth:
                req.add_header('Authorization', f'Bearer {token}')
            
            if data:
                req.add_header('Content-Type', 'application/json')
                req.data = data.encode()
            
            response = urllib.request.urlopen(req, timeout=10)
            duration = int((time.time() - start_time) * 1000)
            
            if response.status == expected or (expected == 200 and response.status == 201):
                results['passed'] += 1
                status = '✓'
                log(f"✓ [{method}] {endpoint} - {desc} ({duration}ms)")
            else:
                results['failed'] += 1
                status = '✗'
                log(f"✗ [{method}] {endpoint} - {desc} (期望:{expected},实际:{response.status})")
            
            results['details'].append({
                'status': status,
                'method': method,
                'endpoint': endpoint,
                'desc': desc,
                'code': response.status,
                'duration': duration,
                'result': '通过' if status == '✓' else f'失败: 期望{expected}'
            })
            
        except Exception as e:
            results['failed'] += 1
            duration = int((time.time() - start_time) * 1000)
            log(f"✗ [{method}] {endpoint} - {desc} (错误: {e})")
            results['details'].append({
                'status': '✗',
                'method': method,
                'endpoint': endpoint,
                'desc': desc,
                'code': 0,
                'duration': duration,
                'result': f'错误: {str(e)[:50]}'
            })
    
    return results

def generate_report(results):
    """生成测试报告"""
    log("生成测试报告...")
    
    pass_rate = (results['passed'] / results['total'] * 100) if results['total'] > 0 else 0
    
    report = f"""# API自动化测试报告

## 测试概要

| 项目 | 内容 |
|------|------|
| 测试日期 | 2026-03-17 |
| 测试时间 | {datetime.now().strftime('%H:%M:%S')} |
| 测试环境 | http://localhost:8080 |
| 测试接口总数 | {results['total']} |
| 通过 | {results['passed']} |
| 失败 | {results['failed']} |
| 通过率 | {pass_rate:.2f}% |

## 详细测试结果

| 状态 | 方法 | 接口 | 描述 | HTTP状态 | 响应时间 | 结果 |
|------|------|------|------|----------|----------|------|
"""
    
    for detail in results['details']:
        report += f"| {detail['status']} | {detail['method']} | {detail['endpoint']} | {detail['desc']} | {detail['code']} | {detail['duration']}ms | {detail['result']} |\n"
    
    report += f"""
## 接口分类统计

### 用户模块 (8个接口)
- POST /api/v1/auth/register - 注册
- POST /api/v1/auth/login - 登录
- POST /api/v1/auth/logout - 登出
- GET /api/v1/auth/me - 获取当前用户
- POST /api/v1/users/verification - 实名认证
- GET /api/v1/users/{{id}} - 获取用户信息
- PUT /api/v1/users/{{id}} - 更新用户信息
- POST /api/v1/auth/refresh - 刷新Token

### 房源模块 (10个接口)
- GET /api/v1/houses - 房源列表
- POST /api/v1/houses - 创建房源
- GET /api/v1/houses/{{id}} - 房源详情
- PUT /api/v1/houses/{{id}} - 更新房源
- DELETE /api/v1/houses/{{id}} - 删除房源
- POST /api/v1/houses/search - 搜索房源
- GET /api/v1/houses/map - 地图找房
- POST /api/v1/houses/{{id}}/favorite - 收藏房源
- GET /api/v1/houses/favorites - 获取收藏列表
- POST /api/v1/houses/{{id}}/report - 举报房源

### 预约模块 (6个接口)
- POST /api/v1/appointments - 创建预约
- GET /api/v1/appointments - 预约列表
- GET /api/v1/appointments/{{id}} - 预约详情
- PUT /api/v1/appointments/{{id}}/confirm - 确认预约
- PUT /api/v1/appointments/{{id}}/cancel - 取消预约
- PUT /api/v1/appointments/{{id}}/complete - 完成预约

### ACN模块 (6个接口)
- POST /api/v1/acn/deals - 创建成交
- GET /api/v1/acn/deals - 成交列表
- GET /api/v1/acn/deals/{{id}} - 成交详情
- POST /api/v1/acn/deals/{{id}}/confirm - 确认成交
- GET /api/v1/acn/commission - 佣金计算
- GET /api/v1/acn/stats - ACN统计

### IM模块 (4个接口)
- POST /api/v1/im/conversations - 创建会话
- GET /api/v1/im/conversations - 会话列表
- POST /api/v1/im/messages - 发送消息
- GET /api/v1/im/messages/{{conversationId}} - 获取消息

### 其他接口 (13个接口)
- GET /api/v1/cities - 城市列表
- GET /api/v1/cities/{{code}}/districts - 区域列表
- GET /api/v1/stats - 统计数据
- GET /api/v1/agents - 经纪人列表
- GET /api/v1/agents/{{id}} - 经纪人详情
- GET /api/v1/upload/token - 获取上传Token
- POST /api/v1/upload/image - 上传图片

## 测试结论

"""
    
    if results['failed'] == 0:
        report += "✅ **所有接口测试通过！**\n"
    else:
        report += f"⚠️ **存在 {results['failed']} 个接口测试失败，需要修复。**\n"
    
    report += f"""
## 建议

1. 对于失败的接口，建议查看详细日志分析原因
2. 建议定期进行API自动化测试
3. 建议增加性能测试和并发测试
4. 建议补充边界值测试和异常测试

---
*报告生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
"""
    
    with open(REPORT_FILE, 'w', encoding='utf-8') as f:
        f.write(report)
    
    log(f"测试报告已保存: {REPORT_FILE}")

def main():
    """主函数"""
    print("=" * 50)
    print("  缅甸房产平台 - API自动化测试")
    print("=" * 50)
    
    # 启动Mock服务器
    server_proc = start_mock_server()
    
    # 检查服务器状态
    retries = 5
    while retries > 0:
        if check_server():
            log("Mock服务器运行正常")
            break
        retries -= 1
        time.sleep(1)
    
    if retries == 0:
        log("Mock服务器启动失败")
        return 1
    
    try:
        # 运行测试
        results = run_tests()
        
        # 生成报告
        generate_report(results)
        
        # 打印汇总
        print("\n" + "=" * 50)
        print(f"测试完成: 总计{results['total']}, 通过{results['passed']}, 失败{results['failed']}")
        print("=" * 50)
        
        return 0 if results['failed'] == 0 else 1
        
    finally:
        # 停止服务器
        log("停止Mock服务器...")
        os.killpg(os.getpgid(server_proc.pid), signal.SIGTERM)
        server_proc.wait()

if __name__ == '__main__':
    sys.exit(main())
