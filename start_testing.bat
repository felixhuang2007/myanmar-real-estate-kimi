@echo off
chcp 65001 >nul
title 缅甸房产平台 - 开始验证
cls

echo ========================================
echo    缅甸房产平台 - PC端验证启动工具
echo ========================================
echo.

REM 检查后端API
echo [1/4] 检查后端API状态...
curl -s http://7.249.154.50:8080/health >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] 后端API运行中 (http://7.249.154.50:8080)
) else (
    echo    [X] 后端API未启动!
    echo.
    echo    请先启动后端:
    echo    cd myanmar-real-estate/backend
    echo    server.exe
    echo.
    pause
    exit /b 1
)

REM 检查Flutter
echo.
echo [2/4] 检查Flutter环境...
flutter --version >nul 2>&1
if %errorlevel% equ 0 (
    echo    [OK] Flutter已安装
) else (
    echo    [X] Flutter未安装或未配置PATH
    echo    请访问: https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

REM 检查项目目录
echo.
echo [3/4] 检查项目目录...
if exist "myanmar-real-estate\flutter\lib\main_buyer.dart" (
    echo    [OK] 项目目录正确
) else (
    echo    [X] 找不到项目目录
    echo    请确保在正确的工作目录运行此脚本
    pause
    exit /b 1
)

REM 显示配置信息
echo.
echo [4/4] 配置信息
echo    API地址: http://7.249.154.50:8080
echo    C端端口: 8081
echo    B端端口: 8082
echo.

REM 启动C端
echo ========================================
echo    正在启动C端APP (Buyer)...
echo    请等待1-3分钟编译完成
echo ========================================
start "C端APP - Buyer" cmd /k "cd myanmar-real-estate/flutter && echo 正在编译C端APP，请稍候... && flutter run -d chrome -t lib/main_buyer.dart --web-port=8081"

timeout /t 5 /nobreak >nul

REM 启动B端
echo.
echo ========================================
echo    正在启动B端APP (Agent)...
echo    请等待1-3分钟编译完成
echo ========================================
start "B端APP - Agent" cmd /k "cd myanmar-real-estate/flutter && echo 正在编译B端APP，请稍候... && flutter run -d chrome -t lib/main_agent.dart --web-port=8082"

timeout /t 3 /nul

REM 完成提示
cls
echo ========================================
echo    启动命令已发送!
echo ========================================
echo.
echo 正在等待Chrome打开...
echo.
echo 访问地址:
echo   C端APP (Buyer):  http://localhost:8081
echo   B端APP (Agent):  http://localhost:8082
echo   API健康检查:     http://7.249.154.50:8080/health
echo.
echo 测试账号:
echo   C端用户:  +95111111111
echo   B端经纪人: +95333333333
echo   验证码:   动态生成(查看后端控制台)
echo.
echo 验证清单:
echo   [ ] 启动页显示正常
echo   [ ] 可以发送验证码
echo   [ ] 可以登录成功
echo   [ ] 首页加载正常
echo.
echo 提示:
echo   - 首次编译需要1-3分钟，请耐心等待
echo   - 编译完成后Chrome会自动打开
echo   - 按F12可以打开开发者工具调试
echo   - 详情查看: READY_TO_TEST.md
echo.
pause
