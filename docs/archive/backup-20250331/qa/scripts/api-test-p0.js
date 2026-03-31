const axios = require('axios');
const BASE_URL = 'http://43.163.122.42:8080/v1';

// 测试数据
const TEST_PHONE = '+959701234568'; // 使用新手机号避免冲突
const TEST_DEVICE_ID = 'test_device_' + Date.now();

async function runTests() {
    console.log('=== 缅甸房产平台 - 接口功能测试-P0 ===\n');

    let results = {
        passed: 0,
        failed: 0,
        total: 0,
        details: []
    };

    // TC-USER-001: 发送验证码
    try {
        console.log('[TC-USER-001] 发送验证码接口...');
        const resp1 = await axios.post(`${BASE_URL}/auth/send-verification-code`, {
            phone: TEST_PHONE,
            type: 'register'
        });
        if (resp1.data.code === 200) {
            console.log('  ✅ 通过 - 返回200，验证码:', resp1.data.data.code);
            results.passed++;
            results.details.push({id: 'TC-USER-001', name: '发送验证码', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp1.data.code}`);
        }
    } catch (e) {
        console.log('  ❌ 失败:', e.message);
        results.failed++;
        results.details.push({id: 'TC-USER-001', name: '发送验证码', status: 'failed', error: e.message});
    }
    results.total++;

    // TC-USER-002: 用户注册
    try {
        console.log('[TC-USER-002] 用户注册接口...');
        const resp2 = await axios.post(`${BASE_URL}/auth/register`, {
            phone: TEST_PHONE,
            code: '245605',
            password: 'Test123456'
        });
        if (resp2.data.code === 200 || resp2.data.code === 1003) {
            console.log('  ✅ 通过 - 返回', resp2.data.code === 200 ? '200(注册成功)' : '1003(用户已存在)');
            results.passed++;
            results.details.push({id: 'TC-USER-002', name: '用户注册', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp2.data.code}`);
        }
    } catch (e) {
        console.log('  ❌ 失败:', e.message);
        results.failed++;
        results.details.push({id: 'TC-USER-002', name: '用户注册', status: 'failed', error: e.message});
    }
    results.total++;

    // TC-USER-003: 密码登录
    try {
        console.log('[TC-USER-003] 密码登录接口...');
        const resp3 = await axios.post(`${BASE_URL}/auth/login-with-password`, {
            phone: TEST_PHONE,
            password: 'Test123456',
            device_id: TEST_DEVICE_ID
        });
        if (resp3.data.code === 200) {
            console.log('  ✅ 通过 - 返回200，获取token成功');
            results.passed++;
            results.details.push({id: 'TC-USER-003', name: '密码登录', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp3.data.code}`);
        }
    } catch (e) {
        console.log('  ❌ 失败:', e.message);
        results.failed++;
        results.details.push({id: 'TC-USER-003', name: '密码登录', status: 'failed', error: e.message});
    }
    results.total++;

    // TC-USER-004: 刷新Token
    try {
        console.log('[TC-USER-004] 刷新Token接口...');
        const resp4 = await axios.post(`${BASE_URL}/auth/refresh-token`, {
            refresh_token: 'invalid_token_test'
        });
        // 预期返回401，因为token无效
        if (resp4.data.code === 2001 || resp4.data.code === 401) {
            console.log('  ✅ 通过 - 正确返回401未授权');
            results.passed++;
            results.details.push({id: 'TC-USER-004', name: '刷新Token', status: 'passed'});
        } else {
            throw new Error(`返回码错误: ${resp4.data.code}`);
        }
    } catch (e) {
        if (e.response && e.response.status === 401) {
            console.log('  ✅ 通过 - 正确返回401未授权');
            results.passed++;
            results.details.push({id: 'TC-USER-004', name: '刷新Token', status: 'passed'});
        } else {
            console.log('  ❌ 失败:', e.message);
            results.failed++;
            results.details.push({id: 'TC-USER-004', name: '刷新Token', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // TC-USER-005: 获取当前用户（无token）
    try {
        console.log('[TC-USER-005] 获取当前用户接口（无token）...');
        const resp5 = await axios.get(`${BASE_URL}/users/me`);
        console.log('  ❌ 失败 - 未返回401');
        results.failed++;
        results.details.push({id: 'TC-USER-005', name: '获取当前用户-无token', status: 'failed'});
    } catch (e) {
        if (e.response && (e.response.status === 401 || e.response.data.code === 2001)) {
            console.log('  ✅ 通过 - 正确返回401未授权');
            results.passed++;
            results.details.push({id: 'TC-USER-005', name: '获取当前用户-无token', status: 'passed'});
        } else {
            console.log('  ❌ 失败:', e.message);
            results.failed++;
            results.details.push({id: 'TC-USER-005', name: '获取当前用户-无token', status: 'failed', error: e.message});
        }
    }
    results.total++;

    // 打印汇总
    console.log('\n=== 测试汇总 ===');
    console.log(`总计: ${results.total} 个用例`);
    console.log(`通过: ${results.passed} 个`);
    console.log(`失败: ${results.failed} 个`);
    console.log(`通过率: ${(results.passed/results.total*100).toFixed(1)}%`);

    return results;
}

runTests().catch(console.error);
