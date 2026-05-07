@echo off
chcp 65001 >nul
setlocal

:: ========================================
:: 缅甸房产平台 - APK 上传到远程服务器
:: 用法: deploy-apk.bat [APK文件路径]
:: 默认: 上传最新的构建产物
:: ========================================

set APK_PATH=%1
set SERVER_IP=43.163.122.42
set SERVER_USER=ubuntu
set REMOTE_DIR=/var/www/downloads
set SSH_KEY=%USERPROFILE%\.ssh\id_rsa

echo ========================================
echo   APK 上传到远程服务器
echo ========================================
echo.

:: 如果没有指定 APK 路径，查找最新的构建产物
if "%APK_PATH%"=="" (
    echo 查找最新的构建产物...
    for /f "delims=" %%a in ('dir /s /b /o-d "%~dp0..\build\outputs\*.apk" 2^>nul') do (
        set APK_PATH=%%a
        goto :found
    )
    echo [错误] 未找到 APK 文件，请先运行 build-apk.bat
    exit /b 1
)
:found

echo 上传文件: %APK_PATH%
echo 目标服务器: %SERVER_USER%@%SERVER_IP%
echo 目标目录: %REMOTE_DIR%
echo.

:: 检查 scp 是否可用
where scp >nul 2>&1
if errorlevel 1 (
    echo [错误] 未找到 scp 命令
    echo 请确保已安装 OpenSSH 客户端（Windows 10/11 自带）
    exit /b 1
)

:: 上传 APK
echo [1/2] 上传 APK...
if exist "%SSH_KEY%" (
    scp -i "%SSH_KEY%" -o StrictHostKeyChecking=no "%APK_PATH%" %SERVER_USER%@%SERVER_IP%:%REMOTE_DIR%/
) else (
    echo 提示: 未找到 SSH 密钥，将使用密码认证
    scp -o StrictHostKeyChecking=no "%APK_PATH%" %SERVER_USER%@%SERVER_IP%:%REMOTE_DIR%/
)

if errorlevel 1 (
    echo [错误] 上传失败
    exit /b 1
)

:: 获取文件名
for %%f in ("%APK_PATH%") do set FILENAME=%%~nxf

echo [2/2] 更新下载链接...
echo.
echo ========================================
echo   上传成功!
echo ========================================
echo.
echo 下载地址:
echo   http://%SERVER_IP%/downloads/%FILENAME%
echo.
echo 注意: 如果 nginx 端口是 8000，使用:
echo   http://%SERVER_IP%:8000/downloads/%FILENAME%
echo.

endlocal
