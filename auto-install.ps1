# ============================================
# Flutter 开发环境自动安装脚本
# 以管理员身份运行 PowerShell，然后执行本脚本
# ============================================

# 设置执行策略（如果未设置）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction SilentlyContinue

$InstallPath = "C:\Development"
$DownloadsPath = "$env:USERPROFILE\Downloads"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Flutter 开发环境自动安装" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# 创建安装目录
if (!(Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# 函数：下载文件并显示进度
function Download-File {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$Description
    )

    Write-Host "正在下载 $Description..." -ForegroundColor Yellow
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        Write-Host "  ✓ 下载完成" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "  ✗ 下载失败: $_" -ForegroundColor Red
        return $false
    }
}

# 1. 安装 Java (OpenJDK)
Write-Host "`n[1/4] 安装 Java JDK 17" -ForegroundColor Cyan
$javaPath = "$InstallPath\jdk-17"
if (!(Test-Path "$javaPath\bin\java.exe")) {
    $jdkUrl = "https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_windows-x64_bin.zip"
    $jdkZip = "$DownloadsPath\openjdk17.zip"

    if (Download-File -Url $jdkUrl -OutputPath $jdkZip -Description "OpenJDK 17") {
        Write-Host "  解压中..." -ForegroundColor Yellow
        Expand-Archive -Path $jdkZip -DestinationPath $InstallPath -Force
        Remove-Item $jdkZip -Force -ErrorAction SilentlyContinue

        # 设置环境变量
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, "User")
        $env:JAVA_HOME = $javaPath

        # 添加到 Path
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$javaPath\bin*") {
            [Environment]::SetEnvironmentVariable("Path", "$javaPath\bin;$userPath", "User")
        }

        Write-Host "  ✓ Java 安装完成" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ Java 已安装" -ForegroundColor Green
}

# 2. 安装 Flutter
Write-Host "`n[2/4] 安装 Flutter SDK" -ForegroundColor Cyan
$flutterPath = "$InstallPath\flutter"
if (!(Test-Path "$flutterPath\bin\flutter.bat")) {
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip"
    $flutterZip = "$DownloadsPath\flutter.zip"

    if (Download-File -Url $flutterUrl -OutputPath $flutterZip -Description "Flutter SDK") {
        Write-Host "  解压中（可能需要几分钟）..." -ForegroundColor Yellow
        Expand-Archive -Path $flutterZip -DestinationPath $InstallPath -Force
        Remove-Item $flutterZip -Force -ErrorAction SilentlyContinue

        # 添加到 Path
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$flutterPath\bin*") {
            [Environment]::SetEnvironmentVariable("Path", "$flutterPath\bin;$userPath", "User")
        }

        Write-Host "  ✓ Flutter 安装完成" -ForegroundColor Green
    }
} else {
    Write-Host "  ✓ Flutter 已安装" -ForegroundColor Green
}

# 3. 下载 Android Studio
Write-Host "`n[3/4] 准备 Android Studio" -ForegroundColor Cyan
$asPath = "${env:ProgramFiles}\Android\Android Studio"
if (!(Test-Path $asPath)) {
    $asUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2023.1.1.28/android-studio-2023.1.1.28-windows.exe"
    $asInstaller = "$DownloadsPath\android-studio.exe"

    if (!(Test-Path $asInstaller)) {
        Download-File -Url $asUrl -OutputPath $asInstaller -Description "Android Studio"
    }

    Write-Host "  Android Studio 安装程序已下载到: $asInstaller" -ForegroundColor Yellow
    Write-Host "  请手动运行安装程序完成安装" -ForegroundColor Cyan
    Write-Host "  安装完成后，请继续下一步" -ForegroundColor Cyan

    # 打开下载目录
    Start-Process "explorer.exe" -ArgumentList "/select,$asInstaller"
} else {
    Write-Host "  ✓ Android Studio 已安装" -ForegroundColor Green
}

# 4. 配置 Flutter
Write-Host "`n[4/4] 配置 Flutter" -ForegroundColor Cyan
if (Test-Path "$flutterPath\bin\flutter.bat") {
    # 临时添加环境变量（当前会话）
    $env:Path = "$flutterPath\bin;$env:Path"
    if ($env:JAVA_HOME) {
        $env:Path = "$env:JAVA_HOME\bin;$env:Path"
    }

    Write-Host "  运行 flutter doctor..." -ForegroundColor Yellow
    & "$flutterPath\bin\flutter.bat" doctor
}

# 输出完成信息
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  安装阶段完成！" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "【重要】请完成以下步骤：" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 如果 Android Studio 未安装，请运行：" -ForegroundColor White
Write-Host "   $DownloadsPath\android-studio.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. 重启计算机（必须）" -ForegroundColor White
Write-Host ""
Write-Host "3. 重启后打开 PowerShell，运行：" -ForegroundColor White
Write-Host "   flutter doctor" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. 根据提示解决剩余问题" -ForegroundColor White
Write-Host ""
Write-Host "5. 然后运行项目：" -ForegroundColor White
Write-Host "   cd D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter" -ForegroundColor Cyan
Write-Host "   flutter pub get" -ForegroundColor Cyan
Write-Host "   flutter run -t lib/main_buyer.dart" -ForegroundColor Cyan
Write-Host ""

$restart = Read-Host "是否现在重启计算机? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer
}
