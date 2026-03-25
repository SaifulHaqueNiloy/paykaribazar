@echo off
REM ====================================================
REM  🏗️ Paykari Bazar - Complete Build Script (Windows)
REM ====================================================
REM  Builds all apps: Android (APK/AAB), Web
REM  Usage: build.bat [target] [mode]
REM         build.bat all release
REM         build.bat android debug
REM ====================================================

setlocal enabledelayedexpansion

set PROJECT_ROOT=%~dp0..
cd /d %PROJECT_ROOT%

if not exist "pubspec.yaml" (
    echo Error: pubspec.yaml not found. Run from project root.
    exit /b 1
)

REM Parse arguments
set BUILD_TARGET=%1
if "%BUILD_TARGET%"=="" set BUILD_TARGET=all

set BUILD_MODE=%2
if "%BUILD_MODE%"=="" set BUILD_MODE=release

set TIMESTAMP=%date:~-4%%date:~-10,2%%date:~-7,2%%time:~0,2%%time:~3,2%%time:~6,2%

REM ====================================================
REM Setup Phase
REM ====================================================
echo.
echo ========================================================
echo  🏗️  Build Setup
echo ========================================================
echo.

echo [1/3] Flutter version
flutter --version

echo [2/3] Installing dependencies
call flutter pub get
if errorlevel 1 goto error

echo [3/3] Generating code
call flutter pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 goto error

echo ✅ Setup complete
echo.

REM ====================================================
REM Validation Phase
REM ====================================================
echo.
echo ========================================================
echo  Code Validation
echo ========================================================
echo.

echo Running Flutter Analyze...
flutter analyze --no-fatal-infos
echo.

echo Running tests...
flutter test --coverage 2>&1 | findstr /v "^$" | more
echo ✅ Validation complete
echo.

REM ====================================================
REM Build Phase
REM ====================================================

if "%BUILD_TARGET%"=="all" goto build_all
if "%BUILD_TARGET%"=="android" goto build_android
if "%BUILD_TARGET%"=="apk" goto build_apk
if "%BUILD_TARGET%"=="aab" goto build_aab
if "%BUILD_TARGET%"=="web" goto build_web
goto usage

:build_all
echo.
echo ========================================================
echo  Building Android APK (Customer)
echo ========================================================
call flutter build apk -t lib/main_customer.dart --%BUILD_MODE%
if errorlevel 1 goto error
echo ✅ Customer APK built
echo.

echo.
echo ========================================================
echo  Building Android APK (Admin)
echo ========================================================
call flutter build apk -t lib/main_admin.dart --%BUILD_MODE%
if errorlevel 1 goto error
echo ✅ Admin APK built
echo.

:build_aab
echo.
echo ========================================================
echo  Building Android App Bundle (Customer)
echo ========================================================
call flutter build appbundle -t lib/main_customer.dart --%BUILD_MODE%
if errorlevel 1 goto error
echo ✅ Customer AAB built
echo.

echo.
echo ========================================================
echo  Building Android App Bundle (Admin)
echo ========================================================
call flutter build appbundle -t lib/main_admin.dart --%BUILD_MODE%
if errorlevel 1 goto error
echo ✅ Admin AAB built
echo.

:build_web
echo.
echo ========================================================
echo  Building Web (Customer)
echo ========================================================
call flutter build web -t lib/main_customer.dart --%BUILD_MODE%
if errorlevel 1 goto error
echo ✅ Web Customer built
echo.

echo.
echo ========================================================
echo  Building Web (Admin)
echo ========================================================
call flutter build web -t lib/main_admin.dart --%BUILD_MODE%
if errorlevel 1 goto error
echo ✅ Web Admin built
echo.

:build_complete
REM ====================================================
REM Summary
REM ====================================================
echo.
echo ========================================================
echo  Build Summary
echo ========================================================
echo.

echo Build artifacts:
echo.

if exist "build\app\outputs\flutter-apk\" (
    echo 📱 Android APK:
    for /f %%i in ('dir /b build\app\outputs\flutter-apk\*.apk 2^>nul ^| find /c /v ""') do (
        if %%i gtr 0 echo    ✓ build\app\outputs\flutter-apk\
    )
)

if exist "build\app\outputs\bundle\" (
    echo 📱 Android AAB:
    for /f %%i in ('dir /b build\app\outputs\bundle\*.aab 2^>nul ^| find /c /v ""') do (
        if %%i gtr 0 echo    ✓ build\app\outputs\bundle\
    )
)

if exist "build\web\" (
    echo 🌐 Web:
    echo    ✓ build\web\
)

echo.
echo ✅ Build completed successfully!
echo.
echo 📍 Output locations:
echo    • APK: build\app\outputs\flutter-apk\
echo    • AAB: build\app\outputs\bundle\
echo    • Web: build\web\
echo.

endlocal
exit /b 0

:usage
echo Usage: build.bat [target] [mode]
echo.
echo Targets:
echo   all        - Build everything (default)
echo   android    - Build Android APK and AAB
echo   apk        - Build Android APK only
echo   aab        - Build Android AAB only
echo   web        - Build Web only
echo.
echo Modes:
echo   release    - Release build (default, optimized)
echo   debug      - Debug build (smaller, faster)
echo.
exit /b 1

:error
echo.
echo ❌ Build failed!
endlocal
exit /b 1
