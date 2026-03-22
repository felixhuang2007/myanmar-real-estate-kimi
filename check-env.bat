@echo off
chcp 65001 >nul
echo ============================================
echo   Flutter 开发环境检查工具
echo ============================================
echo.

set ALL_OK=1

:: 检查 Git
echo [检查] Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo   ✗ Git 未安装
    set ALL_OK=0
) else (
    for /f "tokens=*" %%a in ('git --version') do echo   ✓ %%a
)
echo.

:: 检查 Java
echo [检查] Java...
java -version >nul 2>&1
if errorlevel 1 (
    echo   ✗ Java 未安装
    echo     请安装: https://learn.microsoft.com/java/openjdk/download
    set ALL_OK=0
) else (
    for /f "tokens=*" %%a in ('java -version 2^>^&1 ^| find "version"') do echo   ✓ %%a
)
echo.

:: 检查 Flutter
echo [检查] Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo   ✗ Flutter 未安装
    echo     请安装: https://docs.flutter.dev/get-started/install/windows
    set ALL_OK=0
) else (
    for /f "tokens=*" %%a in ('flutter --version ^| find "Flutter"') do echo   ✓ %%a
)
echo.

:: 检查 Android Studio
echo [检查] Android Studio...
if exist "C:\Program Files\Android\Android Studio\bin\studio64.exe" (
    echo   ✓ Android Studio 已安装
) else if exist "%LOCALAPPDATA%\Android\Android Studio\bin\studio64.exe" (
    echo   ✓ Android Studio 已安装 (用户目录)
) else (
    echo   ✗ Android Studio 未安装
    echo     请安装: https://developer.android.com/studio
    set ALL_OK=0
)
echo.

:: 检查后端服务
echo [检查] 后端 API 服务...
curl -s http://localhost:8081/health >nul 2>&1
if errorlevel 1 (
    echo   ✗ 后端服务未启动 (http://localhost:8081)
    echo     请先运行: myanmar-real-estate/backend/server.exe
) else (
    echo   ✓ 后端服务运行正常
)
echo.

:: 检查项目目录
echo [检查] 项目目录...
if exist "D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter\pubspec.yaml" (
    echo   ✓ 项目目录存在
) else (
    echo   ✗ 项目目录不存在或路径错误
    set ALL_OK=0
)
echo.

:: 总结
echo ============================================
if %ALL_OK%==1 (
    echo   ✓ 所有必需软件已安装！
    echo.
    echo   您可以:
    echo   1. 启动 Android 模拟器
    echo   2. 双击运行: run-buyer-app.bat
    echo   3. 或运行: run-agent-app.bat
) else (
    echo   ✗ 部分软件未安装
    echo.
    echo   请按照 环境安装指南.md 完成安装
)
echo ============================================
echo.
pause
