@echo off
REM Build and deploy web for BOTH customer and admin apps

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   WEB DEPLOYMENT - CUSTOMER & ADMIN
echo ========================================
echo.

REM Build customer web
echo [1/4] Building customer web app...
flutter build web -t lib/main_customer.dart --release
if errorlevel 1 (
    echo ERROR: Customer web build failed
    pause
    exit /b 1
)

REM Rename customer build
if exist build\web_customer (
    rmdir /s /q build\web_customer
)
move build\web build\web_customer
if errorlevel 1 (
    echo ERROR: Failed to rename customer web output
    pause
    exit /b 1
)

REM Deploy customer
echo [2/4] Deploying customer web to Firebase...
firebase deploy --only hosting:customer
if errorlevel 1 (
    echo ERROR: Customer Firebase deployment failed
    pause
    exit /b 1
)

REM Build admin web
echo [3/4] Building admin web app...
flutter build web -t lib/main_admin.dart --release
if errorlevel 1 (
    echo ERROR: Admin web build failed
    pause
    exit /b 1
)

REM Rename admin build
if exist build\web_admin (
    rmdir /s /q build\web_admin
)
move build\web build\web_admin
if errorlevel 1 (
    echo ERROR: Failed to rename admin web output
    pause
    exit /b 1
)

REM Deploy admin
echo [4/4] Deploying admin web to Firebase...
firebase deploy --only hosting:admin
if errorlevel 1 (
    echo ERROR: Admin Firebase deployment failed
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS: Both apps deployed to Firebase Hosting!
echo.
pause
