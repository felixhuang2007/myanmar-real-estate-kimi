#!/usr/bin/env python3
"""带CORS支持的静态文件服务器"""

import http.server
import socketserver
import os

class CORSRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

if __name__ == '__main__':
    import sys
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
    os.chdir('build/web')

    with socketserver.TCPServer(("", port), CORSRequestHandler) as httpd:
        print(f"Serving at http://localhost:{port}")
        httpd.serve_forever()
