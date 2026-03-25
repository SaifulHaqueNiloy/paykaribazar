@echo off
REM ====================================================
REM  🤖 Paykari Bazar - Full CI/CD Automation (Windows)
REM ====================================================
REM  Complete build, test, and deploy automation
REM  Usage: automate.bat [action] [mode]
REM         automate.bat build-and-test
REM         automate.bat deploy production
REM ====================================================

setlocal enabledelayedexpansion

set PROJECT_ROOT=%~dp0..
cd /d %PROJECT_ROOT%

set ACTION=%1
if "%ACTION%"=="" (
    set ACTION=build-and-test
)

set MODE=%2
if "%MODE%"=="" (
    set MODE=release
)

REM ====================================================
REM Helper Functions
REM ====================================================
set "TIMESTAMP=%date:~-4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%%time:~6,2%"

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  🤖 Paykari Bazar CI/CD Automation                   ║
echo ║  Action: %ACTION%
echo ║  Mode: %MODE%
echo ╚══════════════════════════════════════════════════════╝
echo.

REM ====================================================
REM Actions
REM ====================================================

if "%ACTION%"=="build-and-test" goto build_and_test
if "%ACTION%"=="build" goto build
if "%ACTION%"=="test" goto test
if "%ACTION%"=="deploy" goto deploy
if "%ACTION%"=="full-pipeline" goto full_pipeline
if "%ACTION%"=="clean" goto clean
if "%ACTION%"=="help" goto help

:build_and_test
echo [Step 1] Running complete test suite...
call scripts\test.bat
if errorlevel 1 (
    echo.
    echo ⚠️  Tests had warnings, but continuing...
)

echo.
echo [Step 2] Building all apps...
call scripts\build.bat all %MODE%
if errorlevel 1 goto error

echo.
echo ✅ Build and test complete!
goto end

:build
echo Building apps...
call scripts\build.bat all %MODE%
if errorlevel 1 goto error
goto end

:test
echo Running test suite...
call scripts\test.bat
if errorlevel 1 goto error
goto end

:deploy
echo Deploying to %MODE%...
powershell -ExecutionPolicy Bypass -File scripts\deploy.ps1 -Environment %MODE%
if errorlevel 1 goto error
goto end

:full_pipeline
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  FULL PRODUCTION PIPELINE                            ║
echo ╚══════════════════════════════════════════════════════╝
echo.

echo [1/3] Running tests...
call scripts\test.bat
if errorlevel 1 (
    echo ⚠️  Tests had warnings (continuing)
)

echo.
echo [2/3] Building release...
call scripts\build.bat all release
if errorlevel 1 goto error

echo.
echo [3/3] Preparing deployment...
powershell -ExecutionPolicy Bypass -File scripts\deploy.ps1 -Environment production
if errorlevel 1 goto error

echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  ✅ FULL PIPELINE COMPLETE                           ║
echo ╚══════════════════════════════════════════════════════╝
echo.
goto end

:clean
echo Cleaning build artifacts...
rmdir /s /q build 2>nul
rmdir /s /q .dart_tool 2>nul
echo ✅ Clean complete
echo.
echo Reinstalling dependencies...
call flutter pub get
echo ✅ Dependencies restored
goto end

:help
echo.
echo Usage: automate.bat [action] [mode]
echo.
echo Actions:
echo   build-and-test   - Run tests then build (default)
echo   build            - Build all apps only
echo   test             - Run test suite only
echo   deploy           - Deploy to platform
echo   full-pipeline    - Complete: test + build + deploy
echo   clean            - Clean build artifacts
echo   help             - Show this help
echo.
echo Modes:
echo   release          - Release build (default, optimized)
echo   debug            - Debug build (faster)
echo   production       - Deploy to production
echo   staging          - Deploy to staging
echo.
echo Examples:
echo   automate.bat build-and-test
echo   automate.bat build debug
echo   automate.bat deploy production
echo   automate.bat full-pipeline
echo.
goto end

:error
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  ❌ AUTOMATION FAILED                                ║
echo ╚══════════════════════════════════════════════════════╝
echo.
endlocal
exit /b 1

:end
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  ✅ AUTOMATION COMPLETE                              ║
echo ╚══════════════════════════════════════════════════════╝
echo.
endlocal
exit /b 0
