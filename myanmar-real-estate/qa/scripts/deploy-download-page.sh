#!/bin/bash
# 部署APK下载页面（在服务器上执行）

set -e

echo "部署APK下载服务..."

# 创建下载目录
sudo mkdir -p /var/www/downloads
sudo chown ubuntu:ubuntu /var/www/downloads

# 创建下载页面
sudo tee /var/www/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>缅甸房产平台 - 测试包下载</title>
<style>
body{font-family:Arial,sans-serif;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh;margin:0;padding:20px}
.container{max-width:800px;margin:0 auto}
.header{text-align:center;color:white;padding:40px 0}
.card{background:white;border-radius:16px;padding:30px;margin-bottom:20px;box-shadow:0 10px 40px rgba(0,0,0,0.1)}
.app-item{display:flex;align-items:center;padding:20px;background:#f8f9fa;border-radius:12px;margin-bottom:15px;flex-wrap:wrap}
.download-btn{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;padding:12px 24px;border-radius:8px;text-decoration:none;font-weight:500}
.notice{background:#fff3cd;border-left:4px solid #ffc107;padding:15px;border-radius:8px;margin-bottom:20px}
h2{margin-top:0}
a{color:#667eea}
@media(max-width:600px){.app-item{flex-direction:column;text-align:center}.app-item div{margin-bottom:10px}}
</style>
</head>
<body>
<div class='container'>
<div class='header'>
<h1>🏠 缅甸房产平台</h1>
<p>测试环境 Android 安装包下载</p>
</div>
<div class='notice'>
<strong>⚠️ 测试环境说明</strong><br>
• 此版本为测试版本，仅供内部测试使用<br>
• 测试数据会定期清理<br>
• 服务器地址：43.163.122.42
</div>
<div class='card'>
<h2>📱 应用下载</h2>
<div class='app-item'>
<div style='flex:1;min-width:200px'>
<strong>缅甸房产 - C端（买家版）</strong><br>
找房、看房、预约带看<br>
<small style='color:#999'>包名: com.myanmarhome.buyer</small>
</div>
<a href='/downloads/缅甸房产-C端-测试版.apk' class='download-btn' download>⬇️ 下载安装</a>
</div>
<div class='app-item'>
<div style='flex:1;min-width:200px'>
<strong>缅甸房产 - B端（经纪人版）</strong><br>
录房、客户管理、业绩统计<br>
<small style='color:#999'>包名: com.myanmarhome.agent</small>
</div>
<a href='/downloads/缅甸房产-B端-测试版.apk' class='download-btn' download>⬇️ 下载安装</a>
</div>
</div>
<div class='card'>
<h2>🔑 测试账号</h2>
<p><strong>C端账号：</strong> +959999999999（验证码：123456）</p>
<p><strong>B端账号：</strong> +959888888888（验证码：123456）</p>
<p><strong>管理后台：</strong> <a href='http://43.163.122.42:8000'>http://43.163.122.42:8000</a>（admin / admin123）</p>
</div>
<div class='card'>
<h2>📋 系统要求</h2>
<ul>
<li>Android 7.0 (API 24) 及以上</li>
<li>至少 100MB 可用空间</li>
<li>需要联网访问测试服务器</li>
</ul>
</div>
<div class='footer' style='text-align:center;color:rgba(255,255,255,0.8);padding:20px'>
<p>缅甸房产平台测试环境 © 2026</p>
</div>
</div>
</body>
</html>
EOF

# 配置Nginx（如果存在）
if command -v nginx > /dev/null; then
    echo "配置Nginx..."
    sudo tee /etc/nginx/sites-available/downloads << 'EOF'
server {
    listen 8081;
    server_name _;
    root /var/www;
    index index.html;

    location /downloads {
        alias /var/www/downloads;
        autoindex on;
        add_header Content-Disposition 'attachment';
    }
}
EOF
    sudo ln -sf /etc/nginx/sites-available/downloads /etc/nginx/sites-enabled/ 2>/dev/null || true
    sudo nginx -s reload 2>/dev/null || echo "Nginx reload skipped"
fi

echo "✅ 下载页面已部署到: /var/www/index.html"
echo "✅ 下载目录: /var/www/downloads"
echo ""
echo "访问地址: http://43.163.122.42:8000/downloads/"
