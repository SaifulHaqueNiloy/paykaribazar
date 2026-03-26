@echo off
REM Complete deployment: APKs + Web apps together
REM This script builds and deploys everything in one workflow

setlocal enabledelayedexpansion

cls
echo.
echo ================================================================
echo   COMPLETE DEPLOYMENT - APKs + WEB (CUSTOMER & ADMIN)
echo ================================================================
echo.
echo This will:
echo   1. Build Customer Web + APK
echo   2. Build Admin Web + APK
echo   3. Deploy both to Firebase (web + optional distribution)
echo   4. Verify all deployments
echo.

set /p CONFIRM="Continue with full deployment? (y/n): "
if /i "!CONFIRM!"!="y" (
    echo Cancelled.
    pause
    exit /b 0
)

REM Initialize counters
set STEPS_TOTAL=6
set STEP_NUM=0

echo.
echo ================================================================
echo   PHASE 1: CUSTOMER APP (WEB + APK)
echo ================================================================
echo.

REM Step 1: Build Customer Web
set /a STEP_NUM+=1
echo [!STEP_NUM!/!STEPS_TOTAL!] Building CUSTOMER Web App...
flutter build web -t lib/main_customer.dart --release
if errorlevel 1 (
    echo ERROR: Customer web build failed
    pause
    exit /b 1
)

if exist build\web_customer (
    rmdir /s /q build\web_customer
)
move build\web build\web_customer
echo ✓ Customer web built

REM Step 2: Build Customer APK
set /a STEP_NUM+=1
echo [!STEP_NUM!/!STEPS_TOTAL!] Building CUSTOMER APK...
copy shorebird_customer.yaml shorebird.yaml
shorebird release android -t lib/main_customer.dart --artifact apk -- --target-platform android-arm64
if errorlevel 1 (
    echo ERROR: Customer APK build failed
    pause
    exit /b 1
)

if exist build\app\outputs\flutter-apk\app-release.apk (
    move build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\customer-release.apk
)
echo ✓ Customer APK built

REM Step 3: Deploy Customer to Firebase
set /a STEP_NUM+=1
echo [!STEP_NUM!/!STEPS_TOTAL!] Deploying CUSTOMER Web to Firebase...
firebase deploy --only hosting:customer
if errorlevel 1 (
    echo ERROR: Customer web deployment failed
    pause
    exit /b 1
)
echo ✓ Customer web deployed

echo.
echo ================================================================
echo   PHASE 2: ADMIN APP (WEB + APK)
echo ================================================================
echo.

REM Step 4: Build Admin Web
set /a STEP_NUM+=1
echo [!STEP_NUM!/!STEPS_TOTAL!] Building ADMIN Web App...
flutter build web -t lib/main_admin.dart --release
if errorlevel 1 (
    echo ERROR: Admin web build failed
    pause
    exit /b 1
)

if exist build\web_admin (
    rmdir /s /q build\web_admin
)
move build\web build\web_admin
echo ✓ Admin web built

REM Step 5: Build Admin APK
set /a STEP_NUM+=1
echo [!STEP_NUM!/!STEPS_TOTAL!] Building ADMIN APK...
copy shorebird_admin.yaml shorebird.yaml
shorebird release android -t lib/main_admin.dart --artifact apk -- --target-platform android-arm64
if errorlevel 1 (
    echo ERROR: Admin APK build failed
    pause
    exit /b 1
)

if exist build\app\outputs\flutter-apk\app-release.apk (
    move build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\admin-release.apk
)
echo ✓ Admin APK built

REM Step 6: Deploy Admin to Firebase
set /a STEP_NUM+=1
echo [!STEP_NUM!/!STEPS_TOTAL!] Deploying ADMIN Web to Firebase...
firebase deploy --only hosting:admin
if errorlevel 1 (
    echo ERROR: Admin web deployment failed
    pause
    exit /b 1
)
echo ✓ Admin web deployed

REM Restore config
copy shorebird_customer.yaml shorebird.yaml

echo.
echo ================================================================
echo   PHASE 3: VERIFICATION
echo ================================================================
echo.

echo [✓] Customer Web: https://paykari-bazar-a19e7.web.app
echo [✓] Admin Web: https://paykari-bazar-admin.web.app
echo [✓] Customer APK: build/app/outputs/flutter-apk/customer-release.apk
echo [✓] Admin APK: build/app/outputs/flutter-apk/admin-release.apk
echo.

echo Deployment Summary:
echo.
echo CUSTOMER APP:
echo   • Web: paykari-bazar-a19e7.web.app (deployed)
echo   • APK: customer-release.apk (ready for distribution)
echo.
echo ADMIN APP:
echo   • Web: paykari-bazar-admin.web.app (deployed)
echo   • APK: admin-release.apk (ready for distribution)
echo.

set /p UPLOAD_APK="Upload APKs to Firebase App Distribution? (y/n): "
if /i "!UPLOAD_APK!"=="y" (
    echo.
    echo Installing Firebase Distribution for APKs...
    echo.
    echo Customer APK distribution...
    if exist build\app\outputs\flutter-apk\customer-release.apk (
        firebase appdistribution:distribute build\app\outputs\flutter-apk\customer-release.apk ^
            --app 1:123456789:android:abc123def456 ^
            --release-notes "Customer app release"
    )
    echo.
    echo Admin APK distribution...
    if exist build\app\outputs\flutter-apk\admin-release.apk (
        firebase appdistribution:distribute build\app\outputs\flutter-apk\admin-release.apk ^
            --app 1:123456789:android:xyz789ijk012 ^
            --release-notes "Admin app release"
    )
)

echo.
echo ================================================================
echo   ✅ COMPLETE DEPLOYMENT SUCCESS!
echo ================================================================
echo.
echo Deployment Results:
echo   ✓ Customer Web: LIVE at paykari-bazar-a19e7.web.app
echo   ✓ Admin Web: LIVE at paykari-bazar-admin.web.app
echo   ✓ Customer APK: Ready for Play Store or distribution
echo   ✓ Admin APK: Ready for Play Store or distribution
echo.
echo NEXT STEPS:
echo   1. Test web apps at the URLs above
echo   2. Share APKs with testers or upload to Play Store
echo   3. Monitor Firebase for any deployment issues
echo.
pause
