# ============================================
# Flutter 开发环境一键安装脚本 (Windows)
# ============================================
# 以管理员身份运行 PowerShell，然后执行：
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# .\install-flutter-env.ps1
# ============================================

param(
    [string]$InstallPath = "C:\\Development",
    [switch]$SkipAndroidStudio = $false
)

$ErrorActionPreference = "Stop"

function Write-Step {
    param([string]$Message)
    Write-Host "`n[=== $Message ===]" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

# 创建安装目录
Write-Step "创建安装目录"
if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-Success "创建目录: $InstallPath"
} else {
    Write-Success "目录已存在: $InstallPath"
}

# 1. 安装 Java JDK (OpenJDK)
Write-Step "安装 Java JDK 17"
$javaPath = "$InstallPath\\openjdk"
if (!(Test-Path "$javaPath\\bin\\java.exe")) {
    Write-Host "正在下载 OpenJDK 17..."
    $jdkUrl = "https://aka.ms/download-jdk/microsoft-jdk-17.0.9-windows-x64.zip"
    $jdkZip = "$env:TEMP\\openjdk17.zip"

    try {
        Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkZip -UseBasicParsing
        Expand-Archive -Path $jdkZip -DestinationPath $InstallPath -Force

        # 查找解压后的目录
        $jdkDir = Get-ChildItem -Path $InstallPath -Filter "jdk-17*" -Directory | Select-Object -First 1
        if ($jdkDir) {
            Rename-Item -Path $jdkDir.FullName -NewName "openjdk" -Force -ErrorAction SilentlyContinue
        }

        Remove-Item $jdkZip -Force -ErrorAction SilentlyContinue
        Write-Success "Java JDK 17 安装完成"
    } catch {
        Write-Error "Java 安装失败: $_"
        Write-Host "请手动下载安装: https://learn.microsoft.com/java/openjdk/download"
    }
} else {
    Write-Success "Java 已安装"
}

# 2. 安装 Flutter SDK
Write-Step "安装 Flutter SDK"
$flutterPath = "$InstallPath\\flutter"
if (!(Test-Path "$flutterPath\\bin\\flutter.bat")) {
    Write-Host "正在下载 Flutter SDK..."
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip"
    $flutterZip = "$env:TEMP\\flutter.zip"

    try {
        Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip -UseBasicParsing
        Expand-Archive -Path $flutterZip -DestinationPath $InstallPath -Force
        Remove-Item $flutterZip -Force -ErrorAction SilentlyContinue
        Write-Success "Flutter SDK 安装完成"
    } catch {
        Write-Error "Flutter 下载失败: $_"
        Write-Host "请手动下载: https://docs.flutter.dev/release/archive"
    }
} else {
    Write-Success "Flutter 已安装"
}

# 3. 安装 Android Studio
if (!$SkipAndroidStudio) {
    Write-Step "安装 Android Studio"
    $androidStudioPath = "${env:ProgramFiles}\\Android\\Android Studio"

    if (!(Test-Path $androidStudioPath)) {
        Write-Host "正在下载 Android Studio..."
        $asUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2023.1.1.28/android-studio-2023.1.1.28-windows.exe"
        $asInstaller = "$env:TEMP\\android-studio.exe"

        try {
            Invoke-WebRequest -Uri $asUrl -OutFile $asInstaller -UseBasicParsing
            Write-Host "启动 Android Studio 安装程序..."
            Write-Host "请按照向导完成安装，确保勾选："
            Write-Host "  - Android SDK"
            Write-Host "  - Android Virtual Device (AVD)"
            Start-Process -FilePath $asInstaller -Wait
            Remove-Item $asInstaller -Force -ErrorAction SilentlyContinue
            Write-Success "Android Studio 安装完成"
        } catch {
            Write-Error "Android Studio 下载失败: $_"
            Write-Host "请手动下载: https://developer.android.com/studio"
        }
    } else {
        Write-Success "Android Studio 已安装"
    }
}

# 4. 配置环境变量
Write-Step "配置环境变量"

$envPaths = @()
if (Test-Path "$javaPath\\bin") {
    $envPaths += "$javaPath\\bin"
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
}
if (Test-Path "$flutterPath\\bin") {
    $envPaths += "$flutterPath\\bin"
}

# Android SDK 路径 (如果已安装)
$androidSdkPath = "${env:LocalAppData}\\Android\\Sdk"
if (Test-Path $androidSdkPath) {
    $envPaths += "$androidSdkPath\\cmdline-tools\\latest\\bin"
    $envPaths += "$androidSdkPath\\platform-tools"
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $androidSdkPath, "User")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $androidSdkPath, "User")
}

# 更新 Path
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
foreach ($path in $envPaths) {
    if ($currentPath -notlike "*$path*") {
        $currentPath = "$path;$currentPath"
        Write-Success "添加到 Path: $path"
    }
}
[Environment]::SetEnvironmentVariable("Path", $currentPath, "User")

# 5. 创建项目运行脚本
Write-Step "创建快捷脚本"

$buyerScript = @"
@echo off
cd /d "D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter"
flutter run -t lib\main_buyer.dart
pause
"@

$agentScript = @"
@echo off
cd /d "D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter"
flutter run -t lib\main_agent.dart
pause
"@

$buyerScript | Out-File -FilePath "$InstallPath\\run-buyer-app.bat" -Encoding ASCII
$agentScript | Out-File -FilePath "$InstallPath\\run-agent-app.bat" -Encoding ASCII
Write-Success "创建运行脚本: run-buyer-app.bat, run-agent-app.bat"

# 6. 输出安装摘要
Write-Step "安装摘要"
Write-Host ""
Write-Host "==============================================" -ForegroundColor Yellow
Write-Host "Flutter 开发环境安装完成!" -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "安装路径: $InstallPath" -ForegroundColor White
Write-Host ""
Write-Host "【重要】请完成以下步骤:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 重启终端或 IDE" -ForegroundColor Cyan
Write-Host "2. 运行: flutter doctor" -ForegroundColor Cyan
Write-Host "3. 根据提示安装缺失的组件" -ForegroundColor Cyan
Write-Host ""
Write-Host "【运行项目】" -ForegroundColor Green
Write-Host "  买家APP: 双击 $InstallPath\\run-buyer-app.bat" -ForegroundColor White
Write-Host "  经纪人APP: 双击 $InstallPath\\run-agent-app.bat" -ForegroundColor White
Write-Host ""
Write-Host "【环境变量】已自动配置:" -ForegroundColor Green
Write-Host "  - JAVA_HOME" -ForegroundColor Gray
Write-Host "  - ANDROID_HOME" -ForegroundColor Gray
Write-Host "  - Flutter, Java, Android SDK 已添加到 Path" -ForegroundColor Gray
Write-Host ""
Write-Host "==============================================" -ForegroundColor Yellow

# 提示重启
Write-Host ""
$restart = Read-Host "需要重启计算机才能使环境变量生效。是否现在重启? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer
}
