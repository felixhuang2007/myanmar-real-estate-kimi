@echo off
chcp 65001 >nul
echo ==========================================
echo   启动 C端买家 APP
echo ==========================================
echo.

:: 检查 Flutter
call flutter --version >nul 2>&1
if errorlevel 1 (
    echo [错误] Flutter 未安装或未添加到环境变量
    echo 请按照 环境安装指南.md 安装 Flutter
    pause
    exit /b 1
)

:: 检查后端服务
echo [检查] 正在检查后端服务...
curl -s http://localhost:8081/health >nul 2>&1
if errorlevel 1 (
    echo [警告] 后端服务未启动！
    echo 请先启动后端服务: myanmar-real-estate/backend/server.exe
    echo.
    choice /C YN /M "是否继续启动 APP"
    if errorlevel 2 exit /b 1
)

:: 进入项目目录
cd /d "D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter"
if errorlevel 1 (
    echo [错误] 找不到项目目录
    pause
    exit /b 1
)

:: 获取依赖
echo [步骤] 获取项目依赖...
call flutter pub get
if errorlevel 1 (
    echo [错误] 获取依赖失败
    pause
    exit /b 1
)

:: 检查设备
echo [检查] 正在检查可用设备...
call flutter devices

echo.
echo ==========================================
echo   即将启动买家 APP
echo   如果没有设备，请先启动 Android 模拟器
necho ==========================================
echo.
pause

:: 运行 APP
echo [启动] 正在启动买家 APP...
call flutter run -t lib/main_buyer.dart

pause
