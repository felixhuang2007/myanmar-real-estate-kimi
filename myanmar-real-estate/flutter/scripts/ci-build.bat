@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ========================================
:: 缅甸房产平台 - CI 构建流程
:: 用法: ci-build.bat [buyer|agent] [debug|release]
:: 流程: 构建 → API测试 → 安装到手机 → 收集日志
:: ========================================

set FLAVOR=%1
set MODE=%2
set TIMESTAMP=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=!TIMESTAMP: =0!

if "%FLAVOR%"=="" set FLAVOR=buyer
if "%MODE%"=="" set MODE=debug

echo ========================================
echo   CI 构建流程
echo ========================================
echo   版本 : %FLAVOR%
echo   模式 : %MODE%
echo   时间 : %TIMESTAMP%
echo ========================================
echo.

cd /d "%~dp0\.."

:: Step 1: P0 API 回归测试
echo [Step 1/5] 运行 API 回归测试...
if exist "..\qa\scripts\p0-regression-test.js" (
    echo   运行 P0 回归测试...
    node "..\qa\scripts\p0-regression-test.js" > "build\outputs\%TIMESTAMP%\p0-test.log" 2>&1
    if errorlevel 1 (
        echo   [警告] P0 测试未通过，继续构建...
    ) else (
        echo   P0 测试通过
    )
) else (
    echo   跳过: 测试脚本不存在
)
echo.

:: Step 2: 构建 APK
echo [Step 2/5] 构建 APK...
call scripts\build-apk.bat %FLAVOR% %MODE%
if errorlevel 1 (
    echo [错误] 构建失败，CI 流程终止
    exit /b 1
)
echo.

:: Step 3: 安装到手机
echo [Step 3/5] 安装到手机...
call scripts\adb-install.bat
if errorlevel 1 (
    echo [警告] 安装到手机失败，继续上传...
)
echo.

:: Step 4: 上传到服务器
echo [Step 4/5] 上传到远程服务器...
for /f "delims=" %%a in ('dir /s /b /o-d "build\outputs\%TIMESTAMP%\*.apk" 2^>nul') do (
    call scripts\deploy-apk.bat "%%a"
    goto :uploaded
)
echo   [警告] 未找到 APK 上传
:uploaded
echo.

:: Step 5: 收集日志
echo [Step 5/5] 收集设备日志...
adb logcat -d -t 5000 > "build\outputs\%TIMESTAMP%\logcat.log" 2>nul
echo   日志已保存到: build\outputs\%TIMESTAMP%\logcat.log
echo.

echo ========================================
echo   CI 流程完成!
echo ========================================
echo.
echo 构建产物: build\outputs\%TIMESTAMP%\
echo.

endlocal
