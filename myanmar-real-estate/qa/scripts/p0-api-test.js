/**
 * P0 API 测试脚本
 * 测试环境: 43.163.122.42
 * 执行命令: node p0-api-test.js
 */

const BASE_URL = 'http://43.163.122.42:8080/v1';

// 测试结果
const results = {
  passed: 0,
  failed: 0,
  total: 0,
  details: []
};

// 简单 HTTP 请求函数
async function request(method, path, options = {}) {
  const url = `${BASE_URL}${path}`;

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

// 测试用例执行
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

// ==================== 测试用例 ====================

const tests = [
  // 公开接口
  {
    id: 'API-P001',
    name: '健康检查',
    fn: async () => {
          const res = await fetch('http://43.163.122.42:8080/health');
      const data = await res.json();
      return { success: data.code === 200, reason: `code=${data.code}` };
    }
  },
  {
    id: 'API-P002',
    name: '获取地区列表',
    fn: async () => {
      const res = await request('GET', '/regions');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P003',
    name: '获取全局配置',
    fn: async () => {
      const res = await request('GET', '/config');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P004',
    name: '房源列表',
    fn: async () => {
      const res = await request('GET', '/houses?page=1&page_size=10');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P005',
    name: '房源搜索',
    fn: async () => {
      const res = await request('GET', '/houses/search?keyword=Yangon&page=1');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P006',
    name: '房源详情',
    fn: async () => {
      const res = await request('GET', '/houses/3');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P007',
    name: '用户公开信息',
    fn: async () => {
      const res = await request('GET', '/users/1/public');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P008',
    name: 'ACN角色列表',
    fn: async () => {
      const res = await request('GET', '/acn/roles');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P009',
    name: '经纪人日程',
    fn: async () => {
      const res = await request('GET', '/agents/1/schedules');
      return { success: res.code === 200, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P010',
    name: '发送验证码',
    fn: async () => {
      const res = await request('POST', '/auth/send-verification-code', {
        body: { phone: '+959999999999', type: 'login' }
      });
      // 可能返回200（发送成功）或429（发送过于频繁）
      return { success: res.code === 200 || res.code === 429, reason: `code=${res.code}` };
    }
  },
  {
    id: 'API-P011',
    name: '密码登录-参数校验',
    fn: async () => {
      const res = await request('POST', '/auth/login-with-password', {
        body: { phone: '+959123456789' } // 缺少password字段
      });
      return { success: res.code === 400, reason: `code=${res.code}` };
    }
  }
];

// 主函数
async function main() {
  console.log('=== P0 API 测试开始 ===');
  console.log(`测试地址: ${BASE_URL}`);
  console.log(`测试时间: ${new Date().toISOString()}`);
  console.log('');

  for (const test of tests) {
    await runTest(test.id, test.name, test.fn);
  }

  console.log('');
  console.log('=== 测试总结 ===');
  console.log(`总用例: ${results.total}`);
  console.log(`通过: ${results.passed}`);
  console.log(`失败: ${results.failed}`);
  console.log(`通过率: ${Math.round(results.passed * 100 / results.total)}%`);
  console.log('');

  // 保存结果
  const fs = await import('fs');
  const output = {
    timestamp: new Date().toISOString(),
    url: BASE_URL,
    ...results
  };
  const filename = `p0-test-result-${Date.now()}.json`;
  fs.writeFileSync(filename, JSON.stringify(output, null, 2));
  console.log(`结果已保存到: ${filename}`);
}

main().catch(console.error);
