@echo off
setlocal enabledelayedexpansion

:: Anchor to project root
pushd %~dp0..

echo.
echo ========================================
echo    FIREBASE WEB DEPLOYMENT (BOTH)
echo ========================================
echo.

:: 1. Build Customer Web
echo [1/4] Building CUSTOMER Web...
call flutter build web -t lib/main_customer.dart --release --output=build/web_customer
if %errorlevel% neq 0 ( echo ❌ Customer Web Build Failed. & pause & exit /b 1 )

:: 2. Build Admin Web
echo [2/4] Building ADMIN Web...
call flutter build web -t lib/main_admin.dart --release --output=build/web_admin
if %errorlevel% neq 0 ( echo ❌ Admin Web Build Failed. & pause & exit /b 1 )

:: 3. Set Firebase Targets (Ensures targets are mapped correctly)
echo [3/4] Configuring Firebase Hosting Targets...
call firebase target:apply hosting customer paykari-bazar-app
call firebase target:apply hosting admin paykari-bazar-admin

:: 4. Deploy
echo [4/4] Deploying to Firebase...
call firebase deploy --only hosting
if %errorlevel% neq 0 ( echo ❌ Firebase Deployment Failed. & pause & exit /b 1 )

echo.
echo ✅ SUCCESS: Both Customer and Admin sites are LIVE!
popd
