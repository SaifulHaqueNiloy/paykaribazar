@echo off
REM Build APK split per ABI for local testing (no Shorebird/store upload)

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   BUILD APK (LOCAL TESTING)
echo ========================================
echo.
echo This builds split APKs for quick local testing.
echo Output: 
echo   - app-armeabi-v7a-release.apk (33.1 MB)
echo   - app-arm64-v8a-release.apk (34.5 MB)
echo   - app-x86_64-release.apk (36.0 MB)
echo.

set /p TARGET_APP="Build which app? (c=customer, a=admin): "

if /i "!TARGET_APP!"=="c" (
    set TARGET=-t lib/main_customer.dart
    set APP_NAME=Customer
) else if /i "!TARGET_APP!"=="a" (
    set TARGET=-t lib/main_admin.dart
    set APP_NAME=Admin
) else (
    echo Invalid choice. Using customer by default.
    set TARGET=-t lib/main_customer.dart
    set APP_NAME=Customer
)

echo.
echo Building %APP_NAME% APK (split per ABI)...
echo.

flutter build apk --split-per-abi !TARGET! --release
if errorlevel 1 (
    echo ERROR: APK build failed
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS: %APP_NAME% APKs built!
echo.
echo Artifacts in: build/app/outputs/flutter-apk/
echo.
dir /b build\app\outputs\flutter-apk\*-release.apk
echo.
pause
