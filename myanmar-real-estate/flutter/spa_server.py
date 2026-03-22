#!/usr/bin/env python3
"""支持SPA路由的HTTP服务器"""

import http.server
import socketserver
import os
import sys

class SPARedirectHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # 如果请求的是静态文件，直接返回
        if self.path.startswith('/assets/') or \
           self.path.startswith('/canvaskit/') or \
           self.path.startswith('/icons/') or \
           self.path.startswith('/flutter') or \
           self.path.endswith(('.js', '.json', '.png', '.ico', '.otf', '.ttf')):
            return super().do_GET()

        # 否则返回index.html（SPA路由处理）
        self.path = '/index.html'
        return super().do_GET()

    def end_headers(self):
        # 添加CORS头
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    directory = sys.argv[2] if len(sys.argv) > 2 else 'build/web'

    os.chdir(directory)

    with socketserver.TCPServer(("", port), SPARedirectHandler) as httpd:
        print(f"SPA Server serving {directory} at http://localhost:{port}")
        httpd.serve_forever()
