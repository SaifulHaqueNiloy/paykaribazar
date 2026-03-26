@echo off
REM Build app bundles for Google Play Store submission

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   BUILD APP BUNDLE (PLAY STORE)
echo ========================================
echo.
echo This builds optimized bundles for Play Store.
echo Smaller download size, dynamic feature delivery.
echo.

set /p TARGET_APP="Build which app? (c=customer, a=admin): "

if /i "!TARGET_APP!"=="c" (
    set TARGET=-t lib/main_customer.dart
    set APP_NAME=Customer
    set OUTPUT_NAME=customer
) else if /i "!TARGET_APP!"=="a" (
    set TARGET=-t lib/main_admin.dart
    set APP_NAME=Admin
    set OUTPUT_NAME=admin
) else (
    echo Invalid choice. Using customer by default.
    set TARGET=-t lib/main_customer.dart
    set APP_NAME=Customer
    set OUTPUT_NAME=customer
)

echo.
echo Building %APP_NAME% App Bundle...
echo.

flutter build appbundle !TARGET! ^
    --release ^
    --target-platform=android-arm,android-arm64,android-x64

if errorlevel 1 (
    echo ERROR: App bundle build failed
    pause
    exit /b 1
)

REM Optional: Rename bundle
if exist build\app\outputs\bundle\release\app-release.aab (
    copy build\app\outputs\bundle\release\app-release.aab build\app\outputs\bundle\release\%OUTPUT_NAME%-release.aab
)

echo.
echo ✅ SUCCESS: %APP_NAME% app bundle built!
echo.
echo Bundle artifact: build/app/outputs/bundle/release/app-release.aab
echo.
echo Next steps:
echo   1. Open Google Play Console
echo   2. Navigate to internal testing / staging
echo   3. Upload this AAB file
echo   4. Review and publish
echo.
pause
