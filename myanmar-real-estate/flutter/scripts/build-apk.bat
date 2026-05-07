@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ========================================
:: 缅甸房产平台 - APK 一键构建脚本
:: 用法: build-apk.bat [buyer|agent] [debug|release]
:: 默认: buyer debug
:: ========================================

set FLAVOR=%1
set MODE=%2
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=!TIMESTAMP: =0!

if "%FLAVOR%"=="" set FLAVOR=buyer
if "%MODE%"=="" set MODE=debug

echo ========================================
echo   缅甸房产平台 - APK 构建
echo ========================================
echo.
echo 构建配置:
echo   版本: %FLAVOR%
echo   模式: %MODE%
echo   时间: %TIMESTAMP%
echo.

cd /d "%~dp0\.."

echo [1/4] 清理旧构建...
flutter clean >nul 2>&1

echo [2/4] 获取依赖...
flutter pub get
if errorlevel 1 (
    echo [错误] 依赖获取失败
    exit /b 1
)

echo [3/4] 构建 APK (%FLAVOR% %MODE%)...
if "%MODE%"=="release" (
    flutter build apk --flavor %FLAVOR% --release -t lib/main_%FLAVOR%.dart
) else (
    flutter build apk --flavor %FLAVOR% --debug -t lib/main_%FLAVOR%.dart
)

if errorlevel 1 (
    echo [错误] APK 构建失败
    exit /b 1
)

echo [4/4] 复制产物...
set OUTPUT_DIR=build\outputs\%TIMESTAMP%
mkdir "%OUTPUT_DIR%" 2>nul

if "%FLAVOR%"=="buyer" (
    if "%MODE%"=="release" (
        copy /Y "build\app\outputs\flutter-apk\app-buyer-release.apk" "%OUTPUT_DIR%\缅甸房产-C端-%MODE%-%TIMESTAMP%.apk" >nul
    ) else (
        copy /Y "build\app\outputs\flutter-apk\app-buyer-debug.apk" "%OUTPUT_DIR%\缅甸房产-C端-%MODE%-%TIMESTAMP%.apk" >nul
    )
) else (
    if "%MODE%"=="release" (
        copy /Y "build\app\outputs\flutter-apk\app-agent-release.apk" "%OUTPUT_DIR%\缅甸房产-B端-%MODE%-%TIMESTAMP%.apk" >nul
    ) else (
        copy /Y "build\app\outputs\flutter-apk\app-agent-debug.apk" "%OUTPUT_DIR%\缅甸房产-B端-%MODE%-%TIMESTAMP%.apk" >nul
    )
)

echo.
echo ========================================
echo   构建成功!
echo ========================================
echo.
echo 输出文件:
for %%f in ("%OUTPUT_DIR%\*.apk") do (
    echo   %%~nxf
    echo   大小: %%~zf bytes
)
echo.
echo 完整路径: %cd%\%OUTPUT_DIR%
echo.

endlocal
