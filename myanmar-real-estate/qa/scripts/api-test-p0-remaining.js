const axios = require('axios');
const BASE_URL = 'http://43.163.122.42:8080/v1';

// 测试数据
const TEST_PHONE = '+959701234568';
const TEST_DEVICE_ID = 'test_device_' + Date.now();

async function runExtendedTests() {
    console.log('=== 缅甸房产平台 - P0接口测试续（剩余用例）===\n');

    let results = {
        passed: 0,
        failed: 0,
        total: 0,
        details: []
    };

    // 先登录获取token
    let accessToken = '';
    try {
        const loginResp = await axios.post(`${BASE_URL}/auth/login-with-password`, {
            phone: TEST_PHONE,
            password: 'Test123456',
            device_id: TEST_DEVICE_ID
        });
        if (loginResp.data.code === 200) {
            accessToken = loginResp.data.data.access_token;
            console.log('✓ 登录成功，获取到access_token\n');
        }
    } catch (e) {
        console.log('⚠ 登录失败，部分需要认证的测试将无法执行\n');
    }

    const authHeaders = accessToken ? { Authorization: `Bearer ${accessToken}` } : {};

    // ========== IM模块测试 ==========
    console.log('--- IM消息模块 ---\n');

    // API-041: 获取会话列表
    try {
        console.log('[API-041] 获取会话列表...');
        const resp = await axios.get(`${BASE_URL}/im/conversations`, {
            headers: authHeaders,
            params: { page: 1 }
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-041', name: '获取会话列表', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-041', name: '获取会话列表', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-041', name: '获取会话列表', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-042: 获取消息记录
    try {
        console.log('[API-042] 获取消息记录...');
        const resp = await axios.get(`${BASE_URL}/im/messages`, {
            headers: authHeaders,
            params: { conversationId: 'test', targetId: 'test', limit: 20 }
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-042', name: '获取消息记录', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-042', name: '获取消息记录', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-042', name: '获取消息记录', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-043: 发送消息
    try {
        console.log('[API-043] 发送消息接口...');
        const resp = await axios.post(`${BASE_URL}/im/messages/send`, {
            targetId: 'test',
            type: 'text',
            content: '测试消息'
        }, { headers: authHeaders });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-043', name: '发送消息', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-043', name: '发送消息', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-043', name: '发送消息', status: 'failed', error: e.message});
        }
    }
    results.total++;

    console.log('');

    // ========== 预约模块测试 ==========
    console.log('--- 预约带看模块 ---\n');

    // API-061: 获取可预约时间段
    try {
        console.log('[API-061] 获取可预约时间段...');
        const resp = await axios.get(`${BASE_URL}/appointments/slots`, {
            params: {
                houseId: 1,
                agentId: 1,
                startDate: '2026-03-30',
                endDate: '2026-04-05'
            }
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-061', name: '获取可预约时间段', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-061', name: '获取可预约时间段', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-061', name: '获取可预约时间段', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-062: 创建预约
    try {
        console.log('[API-062] 创建预约接口...');
        const resp = await axios.post(`${BASE_URL}/appointments`, {
            houseId: 1,
            agentId: 1,
            appointmentTime: '2026-04-01T10:00:00Z',
            remark: '测试预约'
        }, { headers: authHeaders });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-062', name: '创建预约', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-062', name: '创建预约', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-062', name: '创建预约', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-063: 获取预约列表
    try {
        console.log('[API-063] 获取预约列表...');
        const resp = await axios.get(`${BASE_URL}/appointments`, {
            headers: authHeaders,
            params: { page: 1, role: 'user' }
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-063', name: '获取预约列表', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-063', name: '获取预约列表', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-063', name: '获取预约列表', status: 'failed', error: e.message});
        }
    }
    results.total++;

    console.log('');

    // ========== ACN模块测试 ==========
    console.log('--- ACN分佣模块 ---\n');

    // API-088: 获取ACN分佣规则
    try {
        console.log('[API-088] 获取ACN分佣规则...');
        const resp = await axios.get(`${BASE_URL}/acn/roles`);
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-088', name: '获取ACN分佣规则', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-088', name: '获取ACN分佣规则', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-088', name: '获取ACN分佣规则', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-082: 成交列表查询
    try {
        console.log('[API-082] 成交列表查询...');
        const resp = await axios.get(`${BASE_URL}/deals`, {
            headers: authHeaders,
            params: { page: 1 }
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-082', name: '成交列表查询', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-082', name: '成交列表查询', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-082', name: '成交列表查询', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-085: 查询佣金余额
    try {
        console.log('[API-085] 查询佣金余额...');
        const resp = await axios.get(`${BASE_URL}/commission/balance`, {
            headers: authHeaders
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-085', name: '查询佣金余额', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-085', name: '查询佣金余额', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-085', name: '查询佣金余额', status: 'failed', error: e.message});
        }
    }
    results.total++;

    console.log('');

    // ========== 通用模块测试 ==========
    console.log('--- 通用模块 ---\n');

    // API-092: 获取地区列表
    try {
        console.log('[API-092] 获取地区列表...');
        const resp = await axios.get(`${BASE_URL}/regions`, {
            params: { parentCode: '' }
        });
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-092', name: '获取地区列表', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-092', name: '获取地区列表', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-092', name: '获取地区列表', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // API-093: 获取全局配置
    try {
        console.log('[API-093] 获取全局配置...');
        const resp = await axios.get(`${BASE_URL}/config`);
        if (resp.data.code === 200) {
            console.log('  ✅ 通过 - 返回200');
            results.passed++;
            results.details.push({id: 'API-093', name: '获取全局配置', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-093', name: '获取全局配置', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-093', name: '获取全局配置', status: 'failed', error: e.message});
        }
    }
    results.total++;

    console.log('');

    // ========== 其他关键接口测试 ==========
    console.log('--- 其他关键接口 ---\n');

    // 测试经纪人注册接口
    try {
        console.log('[API-008] 经纪人注册...');
        const resp = await axios.post(`${BASE_URL}/agent/register`, {
            phone: '+959701234599',
            verifyCode: '123456',
            name: '测试经纪人',
            idCardNumber: '123456789'
        });
        if (resp.data.code === 200 || resp.data.code === 1003) {
            console.log('  ✅ 通过 - 返回', resp.data.code);
            results.passed++;
            results.details.push({id: 'API-008', name: '经纪人注册', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 404) {
            console.log('  ❌ 失败 - 接口404未实现');
            results.failed++;
            results.details.push({id: 'API-008', name: '经纪人注册', status: 'failed', error: '接口404'});
        } else {
            console.log('  ⚠️ 需确认:', e.message);
            results.failed++;
            results.details.push({id: 'API-008', name: '经纪人注册', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // 打印汇总
    console.log('\n=== 测试汇总 ===');
    console.log(`总计: ${results.total} 个用例`);
    console.log(`通过: ${results.passed} 个`);
    console.log(`失败: ${results.failed} 个`);
    console.log(`通过率: ${(results.passed/results.total*100).toFixed(1)}%`);

    console.log('\n=== 详细结果 ===');
    const passed = results.details.filter(d => d.status === 'passed');
    const failed = results.details.filter(d => d.status === 'failed');

    if (passed.length > 0) {
        console.log('\n✅ 通过:');
        passed.forEach(d => console.log(`  ${d.id}: ${d.name}`));
    }
    if (failed.length > 0) {
        console.log('\n❌ 失败:');
        failed.forEach(d => console.log(`  ${d.id}: ${d.name} - ${d.error || ''}`));
    }

    return results;
}

runExtendedTests().catch(console.error);
