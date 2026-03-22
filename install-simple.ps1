# Flutter 环境安装脚本（简化版）
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Flutter 开发环境安装" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

$InstallDir = "C:\Development"

# 创建目录
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# 1. 安装 Java
Write-Host "`n[1/3] 安装 Java JDK..." -ForegroundColor Yellow
$javaDir = "$InstallDir\jdk-17"

if (!(Test-Path "$javaDir\bin\java.exe")) {
    Write-Host "  正在下载 Java..." -ForegroundColor Gray
    $jdkUrl = "https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_windows-x64_bin.zip"
    $jdkFile = "$env:TEMP\jdk17.zip"

    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkFile -UseBasicParsing

    Write-Host "  正在解压..." -ForegroundColor Gray
    Expand-Archive -Path $jdkFile -DestinationPath $InstallDir -Force
    Remove-Item $jdkFile -ErrorAction SilentlyContinue

    # 设置环境变量
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaDir, "User")

    $path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($path -notcontains "$javaDir\bin") {
        [Environment]::SetEnvironmentVariable("Path", "$javaDir\bin;$path", "User")
    }

    Write-Host "  Java 安装完成!" -ForegroundColor Green
} else {
    Write-Host "  Java 已安装" -ForegroundColor Green
}

# 2. 安装 Flutter
Write-Host "`n[2/3] 安装 Flutter SDK..." -ForegroundColor Yellow
$flutterDir = "$InstallDir\flutter"

if (!(Test-Path "$flutterDir\bin\flutter.bat")) {
    Write-Host "  正在下载 Flutter（约1GB，请耐心等待）..." -ForegroundColor Gray
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip"
    $flutterFile = "$env:TEMP\flutter.zip"

    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterFile -UseBasicParsing

    Write-Host "  正在解压（约需5分钟）..." -ForegroundColor Gray
    Expand-Archive -Path $flutterFile -DestinationPath $InstallDir -Force
    Remove-Item $flutterFile -ErrorAction SilentlyContinue

    # 设置环境变量
    $path = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($path -notcontains "$flutterDir\bin") {
        [Environment]::SetEnvironmentVariable("Path", "$flutterDir\bin;$path", "User")
    }

    Write-Host "  Flutter 安装完成!" -ForegroundColor Green
} else {
    Write-Host "  Flutter 已安装" -ForegroundColor Green
}

# 3. 下载 Android Studio
Write-Host "`n[3/3] 准备 Android Studio..." -ForegroundColor Yellow
$asFile = "$env:USERPROFILE\Downloads\android-studio.exe"

if (!(Test-Path $asFile)) {
    Write-Host "  正在下载 Android Studio..." -ForegroundColor Gray
    $asUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2023.1.1.28/android-studio-2023.1.1.28-windows.exe"
    Invoke-WebRequest -Uri $asUrl -OutFile $asFile -UseBasicParsing
    Write-Host "  Android Studio 下载完成!" -ForegroundColor Green
} else {
    Write-Host "  Android Studio 安装程序已存在" -ForegroundColor Green
}

# 完成
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "基础软件安装完成!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`n请完成以下步骤：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 安装 Android Studio：" -ForegroundColor White
Write-Host "   双击运行: $asFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. 安装时选择：" -ForegroundColor White
Write-Host "   - Standard 安装" -ForegroundColor Gray
Write-Host "   - 等待下载组件完成（约15分钟）" -ForegroundColor Gray
Write-Host ""
Write-Host "3. 重启电脑" -ForegroundColor White
Write-Host ""
Write-Host "4. 重启后打开新的 PowerShell，运行：" -ForegroundColor White
Write-Host "   flutter doctor" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. 然后运行项目：" -ForegroundColor White
Write-Host "   cd D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter" -ForegroundColor Cyan
Write-Host "   flutter pub get" -ForegroundColor Cyan
Write-Host "   flutter run -t lib/main_buyer.dart" -ForegroundColor Cyan
Write-Host ""

# 打开下载目录
Start-Process "explorer.exe" -ArgumentList "/select,$asFile"

$restart = Read-Host "`n是否现在重启电脑? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer
}
