@echo off
REM Full Shorebird release for both customer and admin

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   SHOREBIRD FULL RELEASE - CUSTOMER & ADMIN
echo ========================================
echo.
echo This creates a full release (for app store submission).
echo APK artifacts will be available in: build/app/outputs/flutter-apk/
echo.

REM Customer release
echo [1/2] Building CUSTOMER release APK...
copy shorebird_customer.yaml shorebird.yaml
if errorlevel 1 (
    echo ERROR: Failed to copy customer Shorebird config
    pause
    exit /b 1
)

shorebird release android -t lib/main_customer.dart --artifact apk -- --target-platform android-arm64
if errorlevel 1 (
    echo ERROR: Customer release build failed
    pause
    exit /b 1
)

REM Rename and keep customer APK
if exist build\app\outputs\flutter-apk\app-release.apk (
    move build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\customer-release.apk
)

REM Check for optional preview
set /p PREVIEW="Generate preview build for customer? (y/n): "
if /i "!PREVIEW!"=="y" (
    echo Generating customer preview...
    shorebird preview -t lib/main_customer.dart
)

echo Customer release completed.
echo.

REM Admin release
echo [2/2] Building ADMIN release APK...
copy shorebird_admin.yaml shorebird.yaml
if errorlevel 1 (
    echo ERROR: Failed to copy admin Shorebird config
    pause
    exit /b 1
)

shorebird release android -t lib/main_admin.dart --artifact apk -- --target-platform android-arm64
if errorlevel 1 (
    echo ERROR: Admin release build failed
    pause
    exit /b 1
)

REM Rename and keep admin APK
if exist build\app\outputs\flutter-apk\app-release.apk (
    move build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\admin-release.apk
)

REM Check for optional preview
set /p PREVIEW_ADMIN="Generate preview build for admin? (y/n): "
if /i "!PREVIEW_ADMIN!"=="y" (
    echo Generating admin preview...
    shorebird preview -t lib/main_admin.dart
)

REM Restore default config
copy shorebird_customer.yaml shorebird.yaml

echo.
echo ✅ SUCCESS: Both apps built and ready for release!
echo.
echo Release artifacts:
echo   - build/app/outputs/flutter-apk/customer-release.apk
echo   - build/app/outputs/flutter-apk/admin-release.apk
echo.
echo Next steps:
echo   1. Upload customer APK to Google Play Store
echo   2. Upload admin APK to internal testing track
echo   3. Follow your release approval process
echo.
pause
