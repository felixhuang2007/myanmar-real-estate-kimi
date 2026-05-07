@echo off
chcp 65001 >nul
setlocal

:: ========================================
:: 缅甸房产平台 - APK 安装到手机
:: 用法: adb-install.bat [APK文件路径]
:: 默认: 安装最新的构建产物
:: ========================================

set APK_PATH=%1

echo ========================================
echo   APK 安装到 Android 手机
echo ========================================
echo.

:: 检查 adb
where adb >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 adb 命令
    echo 请确保 Android SDK platform-tools 已安装并添加到 PATH
    exit /b 1
)

:: 检查设备连接
echo [1/3] 检查设备连接...
adb devices | findstr /V "List" | findstr /V "^$" >nul
if errorlevel 1 (
    echo [错误] 未检测到 Android 设备
    echo.
    echo 请检查:
    echo   1. 手机已通过 USB 连接到电脑
    echo   2. 手机已开启 USB 调试（设置 → 开发者选项 → USB调试）
    echo   3. 已允许电脑调试授权
    echo.
    adb devices
    exit /b 1
)

echo 已连接设备:
adb devices | findstr /V "List" | findstr /V "^$"
echo.

:: 如果没有指定 APK 路径，查找最新的构建产物
if "%APK_PATH%"=="" (
    echo 查找最新的构建产物...
    for /f "delims=" %%a in ('dir /s /b /o-d "%~dp0..\build\outputs\*.apk" 2^>nul') do (
        set APK_PATH=%%a
        goto :found
    )
    :: 备选: 查找 flutter 默认输出目录
    for /f "delims=" %%a in ('dir /s /b /o-d "%~dp0..\build\app\outputs\flutter-apk\*.apk" 2^>nul') do (
        set APK_PATH=%%a
        goto :found
    )
    echo [错误] 未找到 APK 文件，请先运行 build-apk.bat
    exit /b 1
)
:found

echo 安装文件: %APK_PATH%
echo.

:: 安装 APK
echo [2/3] 安装 APK...
adb install -r -d "%APK_PATH%"
if errorlevel 1 (
    echo.
    echo [错误] 安装失败
    echo.
    echo 常见原因:
    echo   1. APK 与设备架构不兼容
    echo   2. 设备存储空间不足
    echo   3. 已安装同名应用但签名不同（先卸载旧版本）
    echo.
    exit /b 1
)

:: 获取包名并启动应用
echo [3/3] 启动应用...
for %%f in ("%APK_PATH%") do set APK_NAME=%%~nxf

:: 尝试启动 buyer 或 agent
adb shell am start -n "com.myanmarhome.buyer.debug/com.myanmarhome.buyer.MainActivity" >nul 2>&1
if errorlevel 1 (
    adb shell am start -n "com.myanmarhome.agent.debug/com.myanmarhome.agent.MainActivity" >nul 2>&1
)

echo.
echo ========================================
echo   安装完成!
echo ========================================
echo.
echo 应用已安装并尝试启动。
echo 如果应用闪退，请运行以下命令查看日志:
echo   adb logcat -d ^| findstr flutter
echo.

endlocal
