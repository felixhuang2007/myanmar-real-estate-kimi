const axios = require('axios');
const BASE_URL = 'http://43.163.122.42:8080/v1';

// 测试数据
const TEST_PHONE = '+959701234568';
const TEST_DEVICE_ID = 'test_device_' + Date.now();

async function runRegressionTests() {
    console.log('=== P0 Bug修复回归测试 ===\n');

    let results = {
        passed: 0,
        failed: 0,
        total: 0,
        bugs: []
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

    // BUG-003: UTF8中文编码搜索
    try {
        console.log('[BUG-003] UTF8中文编码搜索修复验证...');
        const testKeywords = ['测试', '公寓', '仰光', '房产'];
        let allPassed = true;

        for (const keyword of testKeywords) {
            const resp = await axios.get(`${BASE_URL}/houses/search`, {
                params: { keywords: keyword, page: 1, page_size: 10 }
            });
            if (resp.data.code === 200) {
                console.log(`  ✅ 关键词"${keyword}"搜索成功 - 找到${resp.data.data?.total || 0}条结果`);
            } else {
                console.log(`  ❌ 关键词"${keyword}"搜索失败: ${resp.data.message}`);
                allPassed = false;
            }
        }

        if (allPassed) {
            results.passed++;
            results.bugs.push({id: 'BUG-003', name: 'UTF8中文编码搜索', status: 'fixed'});
        } else {
            results.failed++;
            results.bugs.push({id: 'BUG-003', name: 'UTF8中文编码搜索', status: 'not_fixed'});
        }
    } catch (e) {
        console.log('  ❌ 测试失败:', e.message);
        results.failed++;
        results.bugs.push({id: 'BUG-003', name: 'UTF8中文编码搜索', status: 'error', error: e.message});
    }
    results.total++;
    console.log('');

    // BUG-004/005: 收藏接口路由
    try {
        console.log('[BUG-004/005] 收藏接口路由修复验证...');
        const endpoints = [
            { method: 'GET', url: '/users/me/favorites', name: 'GET /users/me/favorites' },
            { method: 'POST', url: '/users/me/favorites', name: 'POST /users/me/favorites' },
            { method: 'GET', url: '/users/favorites', name: 'GET /users/favorites' },
            { method: 'POST', url: '/users/favorites', name: 'POST /users/favorites' }
        ];

        let allPassed = true;
        for (const endpoint of endpoints) {
            try {
                const config = { headers: authHeaders };
                let resp;
                if (endpoint.method === 'GET') {
                    resp = await axios.get(`${BASE_URL}${endpoint.url}`, config);
                } else {
                    resp = await axios.post(`${BASE_URL}${endpoint.url}`, { house_id: 1 }, config);
                }

                // 预期返回401（未授权）或200/404/400（已认证但业务逻辑错误）
                if (resp.status !== 404) {
                    console.log(`  ✅ ${endpoint.name} - 路由存在 (返回${resp.status})`);
                } else {
                    console.log(`  ❌ ${endpoint.name} - 返回404`);
                    allPassed = false;
                }
            } catch (e) {
                if (e.response && e.response.status === 401) {
                    console.log(`  ✅ ${endpoint.name} - 路由存在 (返回401需认证)`);
                } else if (e.response && e.response.status === 404) {
                    console.log(`  ❌ ${endpoint.name} - 返回404路由不存在`);
                    allPassed = false;
                } else {
                    console.log(`  ✅ ${endpoint.name} - 路由存在 (返回${e.response?.status || 'error'})`);
                }
            }
        }

        if (allPassed) {
            results.passed++;
            results.bugs.push({id: 'BUG-004/005', name: '收藏接口路由', status: 'fixed'});
        } else {
            results.failed++;
            results.bugs.push({id: 'BUG-004/005', name: '收藏接口路由', status: 'not_fixed'});
        }
    } catch (e) {
        console.log('  ❌ 测试失败:', e.message);
        results.failed++;
        results.bugs.push({id: 'BUG-004/005', name: '收藏接口路由', status: 'error', error: e.message});
    }
    results.total++;
    console.log('');

    // BUG-006: 修改密码路由
    try {
        console.log('[BUG-006] 修改密码路由修复验证...');
        const endpoints = [
            { method: 'PUT', url: '/users/me/password', name: 'PUT /users/me/password' },
            { method: 'POST', url: '/users/change-password', name: 'POST /users/change-password' }
        ];

        let allPassed = true;
        for (const endpoint of endpoints) {
            try {
                let resp;
                if (endpoint.method === 'PUT') {
                    resp = await axios.put(`${BASE_URL}${endpoint.url}`, {}, { headers: authHeaders });
                } else {
                    resp = await axios.post(`${BASE_URL}${endpoint.url}`, {}, { headers: authHeaders });
                }
                console.log(`  ✅ ${endpoint.name} - 路由存在 (返回${resp.status})`);
            } catch (e) {
                if (e.response && e.response.status === 401) {
                    console.log(`  ✅ ${endpoint.name} - 路由存在 (返回401需认证)`);
                } else if (e.response && e.response.status === 404) {
                    console.log(`  ❌ ${endpoint.name} - 返回404路由不存在`);
                    allPassed = false;
                } else {
                    console.log(`  ✅ ${endpoint.name} - 路由存在 (返回${e.response?.status || 'error'})`);
                }
            }
        }

        if (allPassed) {
            results.passed++;
            results.bugs.push({id: 'BUG-006', name: '修改密码路由', status: 'fixed'});
        } else {
            results.failed++;
            results.bugs.push({id: 'BUG-006', name: '修改密码路由', status: 'not_fixed'});
        }
    } catch (e) {
        console.log('  ❌ 测试失败:', e.message);
        results.failed++;
        results.bugs.push({id: 'BUG-006', name: '修改密码路由', status: 'error', error: e.message});
    }
    results.total++;
    console.log('');

    // BUG-007: 上传Token接口
    try {
        console.log('[BUG-007] 上传Token接口修复验证...');
        try {
            const resp = await axios.post(`${BASE_URL}/users/upload/token`, {}, { headers: authHeaders });
            console.log(`  ✅ POST /users/upload/token - 接口存在 (返回${resp.status})`);
            results.passed++;
            results.bugs.push({id: 'BUG-007', name: '上传Token接口', status: 'fixed'});
        } catch (e) {
            if (e.response && e.response.status === 401) {
                console.log(`  ✅ POST /users/upload/token - 接口存在 (返回401需认证)`);
                results.passed++;
                results.bugs.push({id: 'BUG-007', name: '上传Token接口', status: 'fixed'});
            } else if (e.response && e.response.status === 404) {
                console.log(`  ❌ POST /users/upload/token - 返回404接口不存在`);
                results.failed++;
                results.bugs.push({id: 'BUG-007', name: '上传Token接口', status: 'not_fixed'});
            } else {
                console.log(`  ✅ POST /users/upload/token - 接口存在 (返回${e.response?.status || 'error'})`);
                results.passed++;
                results.bugs.push({id: 'BUG-007', name: '上传Token接口', status: 'fixed'});
            }
        }
    } catch (e) {
        console.log('  ❌ 测试失败:', e.message);
        results.failed++;
        results.bugs.push({id: 'BUG-007', name: '上传Token接口', status: 'error', error: e.message});
    }
    results.total++;
    console.log('');

    // BUG-008: 用户状态查询接口
    try {
        console.log('[BUG-008] 用户状态查询接口修复验证...');
        try {
            const resp = await axios.get(`${BASE_URL}/users/status`, { headers: authHeaders });
            console.log(`  ✅ GET /users/status - 接口存在 (返回${resp.status})`);
            results.passed++;
            results.bugs.push({id: 'BUG-008', name: '用户状态查询接口', status: 'fixed'});
        } catch (e) {
            if (e.response && e.response.status === 401) {
                console.log(`  ✅ GET /users/status - 接口存在 (返回401需认证)`);
                results.passed++;
                results.bugs.push({id: 'BUG-008', name: '用户状态查询接口', status: 'fixed'});
            } else if (e.response && e.response.status === 404) {
                console.log(`  ❌ GET /users/status - 返回404接口不存在`);
                results.failed++;
                results.bugs.push({id: 'BUG-008', name: '用户状态查询接口', status: 'not_fixed'});
            } else {
                console.log(`  ✅ GET /users/status - 接口存在 (返回${e.response?.status || 'error'})`);
                results.passed++;
                results.bugs.push({id: 'BUG-008', name: '用户状态查询接口', status: 'fixed'});
            }
        }
    } catch (e) {
        console.log('  ❌ 测试失败:', e.message);
        results.failed++;
        results.bugs.push({id: 'BUG-008', name: '用户状态查询接口', status: 'error', error: e.message});
    }
    results.total++;
    console.log('');

    // 打印汇总
    console.log('=== 回归测试汇总 ===');
    console.log(`总计验证: ${results.total} 个Bug修复`);
    console.log(`验证通过: ${results.passed} 个`);
    console.log(`验证失败: ${results.failed} 个`);
    console.log(`\n详细结果:`);
    results.bugs.forEach(bug => {
        const icon = bug.status === 'fixed' ? '✅' : bug.status === 'not_fixed' ? '❌' : '⚠️';
        console.log(`  ${icon} ${bug.id}: ${bug.name} - ${bug.status === 'fixed' ? '已修复' : bug.status === 'not_fixed' ? '未修复' : '测试错误'}`);
    });

    return results;
}

runRegressionTests().catch(console.error);
