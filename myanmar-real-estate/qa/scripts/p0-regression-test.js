/**
 * P0 回归测试脚本
 * 验证所有Bug修复和P0接口
 */

const BASE_URL = 'http://43.163.122.42:8080';
const V1_URL = `${BASE_URL}/v1`;

// 测试结果
const results = {
  passed: 0,
  failed: 0,
  total: 0,
  details: []
};

// HTTP请求函数
async function request(method, path, options = {}) {
  const url = path.startsWith('http') ? path : `${V1_URL}${path}`;
  const opts = {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...options.headers
    },
    ...options
  };

  if (options.body) {
    opts.body = typeof options.body === 'string' ? options.body : JSON.stringify(options.body);
  }

  try {
    const response = await fetch(url, opts);
    const data = await response.json().catch(() => null);
    return {
      status: response.status,
      code: data?.code,
      data: data?.data,
      raw: data
    };
  } catch (error) {
    return { error: error.message };
  }
}

// 测试执行函数
async function runTest(id, name, testFn) {
  results.total++;
  try {
    const result = await testFn();
    if (result.success) {
      results.passed++;
      results.details.push({ id, name, status: 'passed' });
      console.log(`✅ [${id}] ${name}`);
    } else {
      results.failed++;
      results.details.push({ id, name, status: 'failed', reason: result.reason });
      console.log(`❌ [${id}] ${name}: ${result.reason}`);
    }
  } catch (error) {
    results.failed++;
    results.details.push({ id, name, status: 'error', reason: error.message });
    console.log(`❌ [${id}] ${name}: ${error.message}`);
  }
}

// 主测试函数
async function main() {
  console.log('=== P0 回归测试套件 ===');
  console.log(`测试地址: ${BASE_URL}`);
  console.log(`测试时间: ${new Date().toISOString()}`);
  console.log('');

  // 1. 公开接口测试
  console.log('--- 公开接口测试 ---');

  await runTest('REG-P001', '健康检查', async () => {
    const res = await fetch(`${BASE_URL}/health`).then(r => r.json());
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P002', '获取地区列表', async () => {
    const res = await request('GET', '/regions');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P003', '获取全局配置', async () => {
    const res = await request('GET', '/config');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P004', '房源列表', async () => {
    const res = await request('GET', '/houses?page=1&page_size=10');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P005', '房源搜索', async () => {
    const res = await request('GET', '/houses/search?keywords=Yangon&page=1');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P006', '房源详情', async () => {
    const res = await request('GET', '/houses/3');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P007', '用户公开信息', async () => {
    const res = await request('GET', '/users/1/public');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P008', 'ACN角色列表 (BUG-015验证)', async () => {
    const res = await request('GET', '/acn/roles');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P009', '经纪人日程', async () => {
    const res = await request('GET', '/agents/1/schedules');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P010', '城市列表', async () => {
    const res = await request('GET', '/houses/cities');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  await runTest('REG-P011', '区域列表', async () => {
    const res = await request('GET', '/houses/districts?city_code=YGN');
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  // 2. 认证接口测试
  console.log('');
  console.log('--- 认证接口测试 ---');

  // 发送验证码
  let verifyCode = '123456';
  await runTest('REG-P012', '发送验证码', async () => {
    const res = await request('POST', '/auth/send-verification-code', {
      body: { phone: '+959999999996', type: 'login' }
    });
    if (res.code === 200 && res.data?.code) {
      verifyCode = res.data.code;
    }
    return { success: res.code === 200 || res.code === 429, reason: `code=${res.code}` };
  });

  // 登录获取token
  let token = '';
  await runTest('REG-P013', '用户登录', async () => {
    const res = await request('POST', '/auth/login', {
      body: { phone: '+959999999996', code: verifyCode, device_id: 'test-device' }
    });
    if (res.code === 200 && res.data?.token) {
      token = res.data.token;
    }
    return { success: res.code === 200, reason: `code=${res.code}` };
  });

  // 需要认证的接口测试
  if (token) {
    console.log('');
    console.log('--- 认证接口测试 (需Token) ---');

    await runTest('REG-P014', '获取当前用户', async () => {
      const res = await request('GET', '/users/me', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P015', '获取用户状态', async () => {
      const res = await request('GET', '/users/status', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P016', '预约列表', async () => {
      const res = await request('GET', '/appointments', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P017', '收藏列表', async () => {
      const res = await request('GET', '/users/me/favorites', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P018', '会话列表', async () => {
      const res = await request('GET', '/conversations', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P019', 'ACN佣金统计', async () => {
      const res = await request('GET', '/acn/commission/statistics', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P020', 'ACN佣金明细', async () => {
      const res = await request('GET', '/acn/commission/details', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    await runTest('REG-P021', 'C端成交列表', async () => {
      const res = await request('GET', '/deals', { headers: { 'Authorization': `Bearer ${token}` } });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });

    // BUG-015 回归测试
    console.log('');
    console.log('--- BUG-015 回归测试 ---');

    await runTest('REG-P022', '创建成交单 (BUG-015修复验证)', async () => {
      const res = await request('POST', '/acn/transactions', {
        headers: { 'Authorization': `Bearer ${token}` },
        body: {
          house_id: 3,
          deal_price: 150000,
          commission_amount: 7500,
          deal_date: '2026-04-01',
          contract_image: 'https://example.com/contract.jpg',
          participants: [
            { role: 'ENTRANT', agent_id: 1, ratio: 1500 },
            { role: 'CLOSER', agent_id: 1, ratio: 7500 }
          ]
        }
      });
      return { success: res.code === 200, reason: `code=${res.code}` };
    });
  }

  // 3. 权限控制测试
  console.log('');
  console.log('--- 权限控制测试 ---');

  await runTest('REG-P023', '无Token访问用户接口', async () => {
    const res = await request('GET', '/users/me');
    return { success: res.code === 401, reason: `code=${res.code}` };
  });

  await runTest('REG-P024', '无Token访问ACN统计', async () => {
    const res = await request('GET', '/acn/commission/statistics');
    return { success: res.code === 401, reason: `code=${res.code}` };
  });

  await runTest('REG-P025', '无Token访问佣金余额', async () => {
    const res = await request('GET', '/acn/commission/balance');
    return { success: res.code === 401, reason: `code=${res.code}` };
  });

  // 测试总结
  console.log('');
  console.log('=== 测试总结 ===');
  console.log(`总用例: ${results.total}`);
  console.log(`通过: ${results.passed}`);
  console.log(`失败: ${results.failed}`);
  console.log(`通过率: ${Math.round(results.passed * 100 / results.total)}%`);
  console.log('');

  if (results.failed === 0) {
    console.log('🎉 所有测试用例通过！');
  } else {
    console.log(`⚠️ 有 ${results.failed} 个测试用例失败`);
  }

  // 保存结果
  const fs = await import('fs');
  const output = {
    timestamp: new Date().toISOString(),
    url: BASE_URL,
    ...results
  };
  const filename = `p0-regression-result-${Date.now()}.json`;
  fs.writeFileSync(filename, JSON.stringify(output, null, 2));
  console.log(`结果已保存到: ${filename}`);
}

main().catch(console.error);
