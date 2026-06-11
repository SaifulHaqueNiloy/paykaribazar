@echo off
setlocal enabledelayedexpansion

:: Anchor to project root regardless of where script is called from
pushd %~dp0..

:main_menu
cls
echo ================================================================
echo   PAYKARI BAZAR - DEPLOYMENT & RELEASE
echo ================================================================
echo.
echo  [1] SHOREBIRD RELEASE (Full app update for Play Store)
echo  [2] SHOREBIRD PATCH   (Quick over-the-air hotfix)
echo  [3] FIREBASE WEB      (Deploy to Hosting)
echo.
echo  [4] BUILD LOCAL APK   (Testing on physical devices)
echo  [5] BUILD APP BUNDLE  (For manual Play Store upload)
echo.
echo  [6] CLEAN BUILD       (Wipe cache and rebuild)
echo.
echo  [q] Exit
echo.
echo  TIP: You can chain multiple options (e.g., 6,3,1)
echo.
set /p INPUT="Selection: "

:: Process chained input (remove commas/spaces and process one by one)
set "INPUT=%INPUT:,= %"

for %%C in (%INPUT%) do (
    set "CHOICE=%%C"

    if "!CHOICE!"=="1" call :release_workflow
    if "!CHOICE!"=="2" call :patch_workflow
    if "!CHOICE!"=="3" call :web_workflow
    if "!CHOICE!"=="4" call :apk_workflow
    if "!CHOICE!"=="5" call :bundle_workflow
    if "!CHOICE!"=="6" call :clean_workflow
    if /i "!CHOICE!"=="q" ( popd & exit /b 0 )
)

goto main_menu

:: --- WORKFLOW WRAPPERS ---
:release_workflow
cls
echo ========================================
echo    SHOREBIRD RELEASE OPTIONS
echo ========================================
echo  [1] Customer  [2] Admin  [3] Both  [b] Back
set /p SUB="Choice: "
if "%SUB%"=="1" call :release_customer_logic
if "%SUB%"=="2" call :release_admin_logic
if "%SUB%"=="3" ( call :release_customer_logic && call :release_admin_logic )
copy /y shorebird_customer.yaml shorebird.yaml >nul
exit /b

:patch_workflow
cls
echo ========================================
echo    SHOREBIRD PATCH OPTIONS
echo ========================================
echo  [1] Customer  [2] Admin  [3] Both  [b] Back
set /p SUB="Choice: "
if /i "%SUB%"=="b" exit /b
set /p VER="Release Version (e.g., 1.0.0+1): "
if "%SUB%"=="1" call :patch_customer_logic %VER%
if "%SUB%"=="2" call :patch_admin_logic %VER%
if "%SUB%"=="3" ( call :patch_customer_logic %VER% && call :patch_admin_logic %VER% )
copy /y shorebird_customer.yaml shorebird.yaml >nul
exit /b

:web_workflow
cls
echo ========================================
echo    FIREBASE WEB DEPLOY OPTIONS
echo ========================================
echo  [1] Customer  [2] Admin  [3] Both  [b] Back
set /p SUB="Choice: "
if "%SUB%"=="1" call :web_customer_logic
if "%SUB%"=="2" call :web_admin_logic
if "%SUB%"=="3" ( call :web_customer_logic && call :web_admin_logic )
exit /b

:apk_workflow
echo [Building local APK...]
call %~dp0build_apk_local.bat
exit /b

:bundle_workflow
echo [Generating App Bundle...]
call %~dp0build_appbundle.bat
exit /b

:clean_workflow
echo [Performing Clean Build...]
call %~dp0clean_build.bat
exit /b

:: --- LOGIC BLOCKS ---
:release_customer_logic
echo [Building CUSTOMER Shorebird Release...]
if exist build\app\outputs\flutter-apk\customer-release.apk del /q build\app\outputs\flutter-apk\customer-release.apk
copy /y shorebird_customer.yaml shorebird.yaml >nul
call shorebird release android -t lib/main_customer.dart --artifact apk -- --target-platform android-arm64 --obfuscate --split-debug-info=build/app/outputs/symbols
if exist build\app\outputs\flutter-apk\app-release.apk move /y build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\customer-release.apk
exit /b

:release_admin_logic
echo [Building ADMIN Shorebird Release...]
if exist build\app\outputs\flutter-apk\admin-release.apk del /q build\app\outputs\flutter-apk\admin-release.apk
copy /y shorebird_admin.yaml shorebird.yaml >nul
call shorebird release android -t lib/main_admin.dart --artifact apk -- --target-platform android-arm64 --obfuscate --split-debug-info=build/app/outputs/symbols
if exist build\app\outputs\flutter-apk\app-release.apk move /y build\app\outputs\flutter-apk\app-release.apk build\app\outputs\flutter-apk\admin-release.apk
exit /b

:patch_customer_logic
echo [Pushing CUSTOMER Patch for %1...]
copy /y shorebird_customer.yaml shorebird.yaml >nul
call shorebird patch android -t lib/main_customer.dart --release-version=%1
exit /b

:patch_admin_logic
echo [Pushing ADMIN Patch for %1...]
copy /y shorebird_admin.yaml shorebird.yaml >nul
call shorebird patch android -t lib/main_admin.dart --release-version=%1
exit /b

:web_customer_logic
echo [Deploying CUSTOMER Web...]
call flutter build web -t lib/main_customer.dart --release --output=build/web_customer
call firebase target:apply hosting customer paykari-bazar-app
call firebase deploy --only hosting:customer
exit /b

:web_admin_logic
echo [Deploying ADMIN Web...]
call flutter build web -t lib/main_admin.dart --release --output=build/web_admin
call firebase target:apply hosting admin paykari-bazar-admin
call firebase deploy --only hosting:admin
exit /b
