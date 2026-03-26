@echo off
REM Shorebird OTA patch deployment for both customer and admin

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   SHOREBIRD OTA PATCH - CUSTOMER & ADMIN
echo ========================================
echo.
echo This patches the current release (1.0.0+1) with OTA updates.
echo No new app store submission required.
echo.

REM Prompt for version
set /p PATCH_VERSION="Enter patch version (e.g., 1.0.0+2): "

REM Customer patch
echo [1/2] Building CUSTOMER OTA patch for version %PATCH_VERSION%...
copy shorebird_customer.yaml shorebird.yaml
if errorlevel 1 (
    echo ERROR: Failed to copy customer Shorebird config
    pause
    exit /b 1
)

shorebird patch android -t lib/main_customer.dart --release-version=%PATCH_VERSION%
if errorlevel 1 (
    echo ERROR: Customer patch build failed
    pause
    exit /b 1
)

echo Customer patch completed and uploaded to Shorebird.
echo.

REM Admin patch
echo [2/2] Building ADMIN OTA patch for version %PATCH_VERSION%...
copy shorebird_admin.yaml shorebird.yaml
if errorlevel 1 (
    echo ERROR: Failed to copy admin Shorebird config
    pause
    exit /b 1
)

shorebird patch android -t lib/main_admin.dart --release-version=%PATCH_VERSION%
if errorlevel 1 (
    echo ERROR: Admin patch build failed
    pause
    exit /b 1
)

REM Restore default config
copy shorebird_customer.yaml shorebird.yaml

echo.
echo ✅ SUCCESS: Both apps patched via Shorebird OTA!
echo.
echo Devices with 1.0.0+1 will receive the OTA update on next app restart.
echo.
pause
