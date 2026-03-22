# 缅甸房产平台 - PC端测试启动脚本
# 使用方法: 右键 "使用 PowerShell 运行"

Write-Host "========================================" -ForegroundColor Green
Write-Host "缅甸房产平台 - PC端测试启动" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# 获取当前目录
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# 检查Flutter项目路径
$flutterPath = "myanmar-real-estate/flutter"
$backendPath = "myanmar-real-estate/backend"

if (-not (Test-Path $flutterPath)) {
    Write-Host "错误: 找不到Flutter项目目录: $flutterPath" -ForegroundColor Red
    Write-Host "请确保在正确的目录运行此脚本" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

# 1. 检查后端API
Write-Host "`n[1/4] 检查后端API..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET -TimeoutSec 3 -ErrorAction Stop
    if ($response.code -eq 200) {
        Write-Host "  ✅ 后端API运行中 (http://localhost:8080)" -ForegroundColor Green
    } else {
        throw "API返回错误"
    }
} catch {
    Write-Host "  ⚠️ 后端API未启动" -ForegroundColor Yellow
    Write-Host "  请手动启动: $backendPath/server.exe" -ForegroundColor Cyan

    $startBackend = Read-Host "是否现在启动后端API? (y/n)"
    if ($startBackend -eq 'y') {
        if (Test-Path "$backendPath/server.exe") {
            Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $backendPath; .\server.exe"
            Write-Host "  正在启动后端API，请等待..." -ForegroundColor Yellow
            Start-Sleep 5

            # 再次检查
            try {
                $response = Invoke-RestMethod -Uri "http://localhost:8080/health" -Method GET -TimeoutSec 3
                Write-Host "  ✅ 后端API已启动" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ 后端API启动失败，请手动检查" -ForegroundColor Red
            }
        } else {
            Write-Host "  ❌ 找不到 server.exe" -ForegroundColor Red
        }
    }
}

# 2. 检查Web Admin
Write-Host "`n[2/4] 检查Web Admin..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000" -Method GET -TimeoutSec 3 -ErrorAction Stop
    Write-Host "  ✅ Web Admin运行中 (http://localhost:8000)" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️ Web Admin未启动" -ForegroundColor Yellow
}

# 3. 获取本机IP
Write-Host "`n[3/4] 网络配置..." -ForegroundColor Yellow
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {
    $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*"
} | Select-Object -First 1).IPAddress

if ($ipAddress) {
    Write-Host "  本机IP: $ipAddress" -ForegroundColor Cyan
    Write-Host "  请确保Flutter配置中的API地址为此IP" -ForegroundColor Yellow
} else {
    Write-Host "  无法获取本机IP，请检查网络连接" -ForegroundColor Red
}

# 4. 启动C端APP
Write-Host "`n[4/4] 启动C端APP..." -ForegroundColor Yellow
Write-Host "  正在启动Buyer App (C端)..." -ForegroundColor Cyan

# 检查端口8081是否被占用
$port8081 = Get-NetTCPConnection -LocalPort 8081 -ErrorAction SilentlyContinue
if ($port8081) {
    Write-Host "  ⚠️ 端口8081已被占用，尝试使用8083..." -ForegroundColor Yellow
    $cPort = 8083
} else {
    $cPort = 8081
}

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $flutterPath; flutter run -d chrome -t lib/main_buyer.dart --web-port=$cPort"

# 5. 启动B端APP
Write-Host "`n启动B端APP..." -ForegroundColor Yellow
Write-Host "  正在启动Agent App (B端)..." -ForegroundColor Cyan
Start-Sleep 3

# 检查端口8082是否被占用
$port8082 = Get-NetTCPConnection -LocalPort 8082 -ErrorAction SilentlyContinue
if ($port8082) {
    Write-Host "  ⚠️ 端口8082已被占用，尝试使用8084..." -ForegroundColor Yellow
    $bPort = 8084
} else {
    $bPort = 8082
}

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd $flutterPath; flutter run -d chrome -t lib/main_agent.dart --web-port=$bPort"

# 6. 完成提示
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "启动完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "访问地址:" -ForegroundColor Cyan
Write-Host "  C端APP:    http://localhost:$cPort" -ForegroundColor White
Write-Host "  B端APP:    http://localhost:$bPort" -ForegroundColor White
Write-Host "  Web Admin: http://localhost:8000" -ForegroundColor White
Write-Host "  API:       http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "测试账号:" -ForegroundColor Cyan
Write-Host "  C端: +95111111111 (验证码动态生成)" -ForegroundColor White
Write-Host "  B端: +95333333333 (验证码动态生成)" -ForegroundColor White
Write-Host ""
Write-Host "提示:" -ForegroundColor Yellow
Write-Host "  1. 首次启动可能需要下载依赖，请耐心等待" -ForegroundColor Gray
Write-Host "  2. 使用Chrome DevTools可以模拟手机尺寸" -ForegroundColor Gray
Write-Host "  3. 按 F12 打开开发者工具，Ctrl+Shift+M 切换设备模拟" -ForegroundColor Gray
Write-Host ""

Read-Host "按回车键关闭此窗口"
