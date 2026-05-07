@echo off
chcp 65001 >nul
setlocal

set OUTPUT_FILE=%1
for /f "tokens=1-4 delims=/ " %%a in ('date /t') do (set MYDATE=%%a%%b%%c)
for /f "tokens=1-3 delims=: " %%a in ('time /t') do (set MYTIME=%%a%%b%%c)
set MYTIME=%MYTIME: =%

if "%OUTPUT_FILE%"=="" set OUTPUT_FILE=logcat_%MYDATE%_%MYTIME%.log

echo ========================================
echo   Android Log Collection
echo ========================================
echo.

where adb >nul 2>nul
if errorlevel 1 (
    echo [ERROR] adb not found
    exit /b 1
)

echo [1/3] Checking device...
adb devices | findstr /V "List" | findstr /V "^$" >nul
if errorlevel 1 (
    echo [ERROR] No Android device detected
    echo Please connect phone and enable USB debugging
    exit /b 1
)

echo [2/3] Clearing old logs...
adb logcat -c

echo [3/3] Reproduce the crash, then press any key...
pause >nul

echo Collecting logs...
adb logcat -d -t 10000 > "%OUTPUT_FILE%" 2>nul

echo.
echo ========================================
echo   Log collection done!
echo ========================================
echo.
echo File: %cd%\%OUTPUT_FILE%
echo.
echo View Flutter logs:
echo   type "%OUTPUT_FILE%" ^| findstr flutter
echo.

endlocal
