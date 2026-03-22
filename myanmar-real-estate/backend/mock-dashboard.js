const http = require('http');
const url = require('url');
const port = 8081;

// CORS 头
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Content-Type': 'application/json'
};

// 生成趋势数据
function generateTrendData(days, values) {
  const data = [];
  for (let i = 0; i < days; i++) {
    const date = new Date();
    date.setDate(date.getDate() - (days - 1 - i));
    data.push({
      date: date.toISOString().slice(5, 10),
      value: values[i % 7]
    });
  }
  return data;
}

const server = http.createServer((req, res) => {
  // 设置 CORS 头
  Object.entries(corsHeaders).forEach(([key, value]) => {
    res.setHeader(key, value);
  });

  // 处理 OPTIONS 请求
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;

  console.log(`${new Date().toISOString()} ${req.method} ${path}`);

  // Dashboard 统计数据 (同时支持 /api/admin 和 /api/v1/admin)
  if (path === '/api/admin/dashboard/stats' || path === '/api/v1/admin/dashboard/stats') {
    res.writeHead(200);
    res.end(JSON.stringify({
      code: 200,
      data: {
        totalUsers: 12580,
        totalHouses: 3456,
        monthDeals: 128,
        monthGMV: 2580,
        totalAgents: 892,
        activeAgents: 456
      }
    }));
    return;
  }

  // 用户增长趋势
  if (path === '/api/admin/dashboard/trend/users' || path === '/api/v1/admin/dashboard/trend/users') {
    const days = parseInt(parsedUrl.query.days) || 7;
    res.writeHead(200);
    res.end(JSON.stringify({
      code: 200,
      data: generateTrendData(days, [120, 132, 101, 134, 90, 230, 210])
    }));
    return;
  }

  // 房源增长趋势
  if (path === '/api/admin/dashboard/trend/houses' || path === '/api/v1/admin/dashboard/trend/houses') {
    const days = parseInt(parsedUrl.query.days) || 7;
    res.writeHead(200);
    res.end(JSON.stringify({
      code: 200,
      data: generateTrendData(days, [45, 52, 38, 65, 48, 72, 58])
    }));
    return;
  }

  // 交易趋势
  if (path === '/api/admin/dashboard/trend/deals' || path === '/api/v1/admin/dashboard/trend/deals') {
    const days = parseInt(parsedUrl.query.days) || 7;
    res.writeHead(200);
    res.end(JSON.stringify({
      code: 200,
      data: generateTrendData(days, [12, 15, 8, 18, 22, 25, 19])
    }));
    return;
  }

  // 健康检查
  if (path === '/health') {
    res.writeHead(200);
    res.end(JSON.stringify({ code: 200, message: 'success', data: { status: 'ok' } }));
    return;
  }

  // 根路径 - 返回可用接口列表
  if (path === '/') {
    res.writeHead(200);
    res.end(JSON.stringify({
      code: 200,
      message: 'Dashboard Mock Server is running',
      endpoints: [
        'GET /api/v1/admin/dashboard/stats',
        'GET /api/v1/admin/dashboard/trend/users?days=7',
        'GET /api/v1/admin/dashboard/trend/houses?days=7',
        'GET /api/v1/admin/dashboard/trend/deals?days=7',
        'GET /health'
      ]
    }));
    return;
  }

  // 404
  res.writeHead(404);
  res.end(JSON.stringify({ code: 404, message: 'Not found' }));
});

server.listen(port, () => {
  console.log(`Dashboard Mock Server running at http://localhost:${port}`);
});
