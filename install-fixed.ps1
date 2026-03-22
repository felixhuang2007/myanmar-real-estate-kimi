# Flutter Environment Setup Script
Write-Host "========================================"
Write-Host "Flutter Development Environment Setup"
Write-Host "========================================"

$InstallDir = "C:\Development"

# Create directory
if (!(Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

# Install Java
Write-Host "`n[Step 1/3] Installing Java JDK..."
$javaDir = "$InstallDir\jdk-17"

if (!(Test-Path "$javaDir\bin\java.exe")) {
    Write-Host "Downloading Java..."
    $jdkUrl = "https://download.java.net/openjdk/jdk17/ri/openjdk-17+35_windows-x64_bin.zip"
    $jdkFile = "$env:TEMP\jdk17.zip"
    
    Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkFile -UseBasicParsing
    
    Write-Host "Extracting..."
    Expand-Archive -Path $jdkFile -DestinationPath $InstallDir -Force
    Remove-Item $jdkFile -ErrorAction SilentlyContinue
    
    # Set environment variables
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaDir, "User")
    
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $newPath = "$javaDir\bin;$userPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    Write-Host "Java installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Java already installed" -ForegroundColor Green
}

# Install Flutter
Write-Host "`n[Step 2/3] Installing Flutter SDK..."
$flutterDir = "$InstallDir\flutter"

if (!(Test-Path "$flutterDir\bin\flutter.bat")) {
    Write-Host "Downloading Flutter (about 1GB, please wait)..."
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.0-stable.zip"
    $flutterFile = "$env:TEMP\flutter.zip"
    
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterFile -UseBasicParsing
    
    Write-Host "Extracting (may take 5 minutes)..."
    Expand-Archive -Path $flutterFile -DestinationPath $InstallDir -Force
    Remove-Item $flutterFile -ErrorAction SilentlyContinue
    
    # Set environment variables
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $newPath = "$flutterDir\bin;$userPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    
    Write-Host "Flutter installed successfully!" -ForegroundColor Green
} else {
    Write-Host "Flutter already installed" -ForegroundColor Green
}

# Download Android Studio
Write-Host "`n[Step 3/3] Downloading Android Studio..."
$asFile = "$env:USERPROFILE\Downloads\android-studio.exe"

if (!(Test-Path $asFile)) {
    Write-Host "Downloading Android Studio..."
    $asUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2023.1.1.28/android-studio-2023.1.1.28-windows.exe"
    Invoke-WebRequest -Uri $asUrl -OutFile $asFile -UseBasicParsing
    Write-Host "Android Studio downloaded!" -ForegroundColor Green
} else {
    Write-Host "Android Studio installer already exists" -ForegroundColor Green
}

# Summary
Write-Host "`n========================================"
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Install Android Studio:"
Write-Host "   Double-click: $asFile"
Write-Host ""
Write-Host "2. During installation, select:"
Write-Host "   - Standard installation"
Write-Host "   - Wait for components download (about 15 min)"
Write-Host ""
Write-Host "3. Restart your computer"
Write-Host ""
Write-Host "4. After restart, open new PowerShell and run:"
Write-Host "   flutter doctor"
Write-Host ""
Write-Host "5. Then run the project:"
Write-Host "   cd D:\work\myanmar-real-estate-kimi\myanmar-real-estate\flutter"
Write-Host "   flutter pub get"
Write-Host "   flutter run -t lib/main_buyer.dart"
Write-Host ""

# Open download folder
Start-Process "explorer.exe" -ArgumentList "/select,$asFile"

$restart = Read-Host "`nRestart computer now? (Y/N)"
if ($restart -eq "Y" -or $restart -eq "y") {
    Restart-Computer
}
