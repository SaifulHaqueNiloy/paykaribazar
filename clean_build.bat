@echo off
REM Clean build - remove all generated files and rebuild

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   CLEAN BUILD
echo ========================================
echo.
echo This will:
echo   1. Delete build/ directories
echo   2. Delete pubspec.lock
echo   3. Clean Flutter cache
echo   4. Rebuild from scratch
echo.

set /p CONFIRM="WARNING: This may take several minutes. Continue? (y/n): "
if /i "!CONFIRM!"!="y" (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo [1/5] Cleaning build directories...
if exist build (
    rmdir /s /q build
)

echo [2/5] Cleaning Flutter...
flutter clean

echo [3/5] Removing pubspec.lock...
if exist pubspec.lock (
    del pubspec.lock
)

echo [4/5] Running pub get...
flutter pub get
if errorlevel 1 (
    echo ERROR: pub get failed
    pause
    exit /b 1
)

echo [5/5] Generating code...
flutter pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 (
    echo ERROR: Code generation failed
    pause
    exit /b 1
)

echo.
echo ✅ SUCCESS: Clean build ready!
echo.
echo You can now run:
echo   - deploy_web_all.bat (for web)
echo   - deploy_shorebird_release.bat (for app release)
echo   - deploy_shorebird_patch.bat (for OTA patch)
echo.
pause
