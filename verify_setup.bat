@echo off
REM Verify complete deployment setup

cls
echo.
echo ================================================================
echo   PAYKARI BAZAR - DEPLOYMENT SETUP VERIFICATION
echo ================================================================
echo.

set PASS=0
set FAIL=0

REM Check Flutter
echo [*] Checking Flutter...
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [X] Flutter NOT found
    set /a FAIL+=1
) else (
    echo [OK] Flutter found
    set /a PASS+=1
)

REM Check Dart
echo [*] Checking Dart...
dart --version >nul 2>&1
if errorlevel 1 (
    echo [X] Dart NOT found
    set /a FAIL+=1
) else (
    echo [OK] Dart found
    set /a PASS+=1
)

REM Check Firebase CLI
echo [*] Checking Firebase CLI...
firebase --version >nul 2>&1
if errorlevel 1 (
    echo [X] Firebase CLI NOT found
    set /a FAIL+=1
) else (
    echo [OK] Firebase CLI found
    set /a PASS+=1
)

REM Check Shorebird
echo [*] Checking Shorebird...
shorebird --version >nul 2>&1
if errorlevel 1 (
    echo [X] Shorebird NOT found
    set /a FAIL+=1
) else (
    echo [OK] Shorebird found
    set /a PASS+=1
)

REM Check Java
echo [*] Checking Java...
java -version >nul 2>&1
if errorlevel 1 (
    echo [X] Java NOT found
    set /a FAIL+=1
) else (
    echo [OK] Java found
    set /a PASS+=1
)

REM Check config files
echo [*] Checking configuration files...
set CONFIG_OK=1

if not exist firebase.json (
    echo [X] firebase.json NOT found
    set CONFIG_OK=0
    set /a FAIL+=1
) else (
    echo [OK] firebase.json found
    set /a PASS+=1
)

if not exist .firebaserc (
    echo [X] .firebaserc NOT found
    set CONFIG_OK=0
    set /a FAIL+=1
) else (
    echo [OK] .firebaserc found
    set /a PASS+=1
)

if not exist shorebird.yaml (
    echo [X] shorebird.yaml NOT found
    set CONFIG_OK=0
    set /a FAIL+=1
) else (
    echo [OK] shorebird.yaml found
    set /a PASS+=1
)

if not exist shorebird_customer.yaml (
    echo [X] shorebird_customer.yaml NOT found
    set /a FAIL+=1
) else (
    echo [OK] shorebird_customer.yaml found
    set /a PASS+=1
)

if not exist shorebird_admin.yaml (
    echo [X] shorebird_admin.yaml NOT found
    set /a FAIL+=1
) else (
    echo [OK] shorebird_admin.yaml found
    set /a PASS+=1
)

if not exist pubspec.yaml (
    echo [X] pubspec.yaml NOT found
    set CONFIG_OK=0
    set /a FAIL+=1
) else (
    echo [OK] pubspec.yaml found
    set /a PASS+=1
)

REM Check deployment scripts
echo [*] Checking deployment scripts...
set SCRIPTS_OK=1

if not exist DEPLOY.bat (
    echo [X] DEPLOY.bat NOT found
    set SCRIPTS_OK=0
    set /a FAIL+=1
) else (
    echo [OK] DEPLOY.bat found
    set /a PASS+=1
)

if not exist deploy_complete.bat (
    echo [X] deploy_complete.bat NOT found
    set /a FAIL+=1
) else (
    echo [OK] deploy_complete.bat found
    set /a PASS+=1
)

if not exist deploy_web_all.bat (
    echo [X] deploy_web_all.bat NOT found
    set /a FAIL+=1
) else (
    echo [OK] deploy_web_all.bat found
    set /a PASS+=1
)

if not exist deploy_shorebird_patch.bat (
    echo [X] deploy_shorebird_patch.bat NOT found
    set /a FAIL+=1
) else (
    echo [OK] deploy_shorebird_patch.bat found
    set /a PASS+=1
)

if not exist deploy_shorebird_release.bat (
    echo [X] deploy_shorebird_release.bat NOT found
    set /a FAIL+=1
) else (
    echo [OK] deploy_shorebird_release.bat found
    set /a PASS+=1
)

REM Summary
echo.
echo ================================================================
echo   VERIFICATION SUMMARY
echo ================================================================
echo.
echo Passed: %PASS%
echo Failed: %FAIL%
echo.

if %FAIL% equ 0 (
    echo ✅ ALL CHECKS PASSED!
    echo.
    echo Your deployment environment is fully configured.
    echo You can now use: DEPLOY.bat
    echo.
) else (
    echo ⚠️  SOME CHECKS FAILED
    echo.
    echo Please install missing components:
    echo   - Flutter: https://flutter.dev/docs/get-started/install
    echo   - Firebase CLI: npm install -g firebase-tools
    echo   - Shorebird: https://docs.shorebird.dev/install
    echo   - Java 17: Download from oracle.com
    echo.
)

echo ================================================================
echo.
pause
