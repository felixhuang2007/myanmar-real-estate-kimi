const http = require('http');
const fs = require('fs');
const path = require('path');

function createServer(port, dir, name) {
  const server = http.createServer((req, res) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    // 禁用缓存，防止Service Worker混淆
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    let filePath = path.join(dir, req.url === '/' ? 'index.html' : req.url);
    if (!fs.existsSync(filePath) || fs.statSync(filePath).isDirectory()) {
      filePath = path.join(dir, 'index.html');
    }
    const ext = path.extname(filePath);
    const contentType = {
      '.html': 'text/html', '.js': 'application/javascript',
      '.css': 'text/css', '.json': 'application/json',
      '.png': 'image/png', '.jpg': 'image/jpeg', '.ico': 'image/x-icon',
      '.otf': 'font/otf', '.ttf': 'font/ttf'
    }[ext] || 'application/octet-stream';
    fs.readFile(filePath, (err, data) => {
      if (err) { res.writeHead(404); res.end('Not found'); return; }
      res.writeHead(200, {'Content-Type': contentType});
      res.end(data);
    });
  });
  server.listen(port, () => {
    console.log(`${name} running at http://localhost:${port}`);
  });
  return server;
}

// C端 (Buyer) on 8081
createServer(8081, 'build/buyer', 'C端 (Buyer)');

// B端 (Agent) on 8082
createServer(8082, 'build/agent', 'B端 (Agent)');
