const http = require('http');
const url = require('url');

const PORT = 8080;

// 存储验证码
const verificationCodes = {};

// CORS headers
const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Request-ID, X-Device-ID',
};

const server = http.createServer((req, res) => {
    // Set CORS headers
    Object.entries(corsHeaders).forEach(([key, value]) => {
        res.setHeader(key, value);
    });

    // Handle preflight
    if (req.method === 'OPTIONS') {
        res.writeHead(204);
        res.end();
        return;
    }

    const parsedUrl = url.parse(req.url, true);
    const path = parsedUrl.pathname;

    console.log(`${req.method} ${path}`);

    // Health check
    if (path === '/health') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            code: 200,
            message: 'success',
            data: { status: 'ok', time: Math.floor(Date.now() / 1000) },
            timestamp: Math.floor(Date.now() / 1000),
            request_id: Date.now().toString()
        }));
        return;
    }

    // Send verification code
    if (path === '/v1/auth/send-verification-code' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                const phone = data.phone || data.phone_number;

                if (!phone) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({
                        code: 1001,
                        message: '手机号不能为空',
                        timestamp: Math.floor(Date.now() / 1000),
                        request_id: Date.now().toString()
                    }));
                    return;
                }

                // Generate 6-digit code
                const code = Math.floor(100000 + Math.random() * 900000).toString();
                verificationCodes[phone] = code;

                console.log(`[验证码] ${phone}: ${code}`);

                res.writeHead(200, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    code: 200,
                    message: '验证码发送成功',
                    data: {
                        expired_at: Math.floor(Date.now() / 1000) + 300,
                        interval: 60
                    },
                    timestamp: Math.floor(Date.now() / 1000),
                    request_id: Date.now().toString()
                }));
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    code: 1001,
                    message: '请求参数错误',
                    timestamp: Math.floor(Date.now() / 1000),
                    request_id: Date.now().toString()
                }));
            }
        });
        return;
    }

    // Login
    if (path === '/v1/auth/login' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            try {
                const data = JSON.parse(body);
                const { phone, code } = data;

                // For testing, accept '123456' as valid code
                if (code === '123456' || verificationCodes[phone] === code) {
                    const userId = Math.floor(10000 + Math.random() * 90000);
                    const token = `mock_token_${userId}_${Date.now()}`;

                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({
                        code: 200,
                        message: '登录成功',
                        data: {
                            user_id: userId,
                            token: token,
                            refresh_token: `refresh_${token}`,
                            expires_at: Math.floor(Date.now() / 1000) + 86400,
                            is_new_user: false
                        },
                        timestamp: Math.floor(Date.now() / 1000),
                        request_id: Date.now().toString()
                    }));
                } else {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({
                        code: 1101,
                        message: '验证码错误或已过期',
                        timestamp: Math.floor(Date.now() / 1000),
                        request_id: Date.now().toString()
                    }));
                }
            } catch (e) {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({
                    code: 1001,
                    message: '请求参数错误',
                    timestamp: Math.floor(Date.now() / 1000),
                    request_id: Date.now().toString()
                }));
            }
        });
        return;
    }

    // Get current user
    if (path === '/v1/users/me' && req.method === 'GET') {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            code: 200,
            message: 'success',
            data: {
                user_id: 12345,
                uuid: 'mock-uuid-12345',
                phone: '+959123456789',
                email: null,
                status: 'active',
                is_verified: true,
                profile: {
                    nickname: '测试用户',
                    avatar: '',
                    gender: null,
                    birthday: null,
                    bio: null
                },
                verification: null,
                agent_info: null
            },
            timestamp: Math.floor(Date.now() / 1000),
            request_id: Date.now().toString()
        }));
        return;
    }

    // Houses
    if (path === '/v1/houses/recommendations' && req.method === 'GET') {
        const houses = [];
        for (let i = 1; i <= 10; i++) {
            houses.push({
                house_id: i,
                house_code: `H${String(i).padStart(6, '0')}`,
                title: `仰光市中心优质公寓 - ${i}号`,
                transaction_type: i % 2 === 0 ? 'sale' : 'rent',
                price: 50000000 + i * 10000000,
                price_unit: 'MMK',
                house_type: 'apartment',
                area: 80.0 + i * 5,
                bedrooms: 2 + i % 3,
                living_rooms: 1,
                bathrooms: 1 + i % 2,
                location: {
                    city: { code: 'YGN', name: '仰光' },
                    district: { code: 'TAMWE', name: 'Tamwe' },
                    address: `Test Street ${i}`
                },
                images: [{ id: 1, url: 'https://via.placeholder.com/400x300', is_main: true }],
                is_favorited: false,
                status: 'online',
                created_at: '2024-01-01T00:00:00Z'
            });
        }

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            code: 200,
            message: 'success',
            data: {
                list: houses,
                pagination: {
                    page: 1,
                    page_size: 20,
                    total: houses.length,
                    has_more: false
                }
            },
            timestamp: Math.floor(Date.now() / 1000),
            request_id: Date.now().toString()
        }));
        return;
    }

    // 404
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        code: 404,
        message: '接口不存在: ' + path,
        timestamp: Math.floor(Date.now() / 1000),
        request_id: Date.now().toString()
    }));
});

server.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log('缅甸房产平台 - Mock API服务器 (Node.js)');
    console.log('='.repeat(50));
    console.log(`API地址: http://localhost:${PORT}`);
    console.log('测试手机号: 任意手机号');
    console.log('测试验证码: 123456');
    console.log('='.repeat(50));
});
