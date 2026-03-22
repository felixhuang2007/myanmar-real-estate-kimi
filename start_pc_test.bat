@echo off
chcp 65001 >nul
echo ========================================
echo 缅甸房产平台 - PC端测试启动
echo ========================================
echo.

REM 检查后端API
echo [1/3] 检查后端API...
curl -s http://localhost:8080/health >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] 后端API运行中 (http://localhost:8080)
) else (
    echo   [警告] 后端API未启动
    echo   请先运行: myanmar-real-estate/backend/server.exe
    pause
    exit /b 1
)

REM 启动C端
echo.
echo [2/3] 启动C端APP (Buyer)...
echo   正在启动，请稍候...
start "C端 - Buyer App" cmd /k "cd myanmar-real-estate/flutter && flutter run -d chrome -t lib/main_buyer.dart --web-port=8081"

timeout /t 5 /nobreak >nul

REM 启动B端
echo.
echo [3/3] 启动B端APP (Agent)...
echo   正在启动，请稍候...
start "B端 - Agent App" cmd /k "cd myanmar-real-estate/flutter && flutter run -d chrome -t lib/main_agent.dart --web-port=8082"

timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo 启动完成!
echo ========================================
echo.
echo 访问地址:
echo   C端APP:    http://localhost:8081
echo   B端APP:    http://localhost:8082
echo   Web Admin: http://localhost:8000
echo   API:       http://localhost:8080
echo.
echo 测试账号:
echo   C端: +95111111111 (验证码动态生成)
echo   B端: +95333333333 (验证码动态生成)
echo.
pause
