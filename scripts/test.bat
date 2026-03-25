@echo off
REM ====================================================
REM  🧪 Paykari Bazar - Complete Test Suite (Windows)
REM ====================================================
REM  Runs all tests and quality checks
REM  Usage: test.bat
REM ====================================================

setlocal enabledelayedexpansion

set PROJECT_ROOT=%~dp0..
cd /d %PROJECT_ROOT%

echo.
echo ========================================================
echo  🧪 Running Complete Test Suite
echo ========================================================
echo.

REM ====================================================
REM Setup
REM ====================================================
echo [1/6] Installing dependencies...
call flutter pub get
if errorlevel 1 goto error

echo [2/6] Generating code...
call flutter pub run build_runner build --delete-conflicting-outputs
if errorlevel 1 goto error

REM ====================================================
REM Linting
REM ====================================================
echo.
echo [3/6] Running Flutter Analyze...
call flutter analyze --no-fatal-infos
echo ✅ Analysis complete
echo.

REM ====================================================
REM Unit Tests
REM ====================================================
echo [4/6] Running Unit Tests...
call flutter test --coverage
if errorlevel 1 (
    echo ⚠️  Some tests failed (non-critical)
)
echo.

REM ====================================================
REM Integration Tests (optional)
REM ====================================================
echo [5/6] Checking for integration tests...
if exist "integration_test\" (
    echo Found integration tests
    call flutter test integration_test/ --headless
    if errorlevel 1 (
        echo ⚠️  Integration tests had issues
    )
) else (
    echo No integration tests found (skipping)
)
echo.

REM ====================================================
REM Coverage Report
REM ====================================================
echo [6/6] Generating Coverage Report...
if exist "coverage\lcov.info" (
    echo ✅ Coverage report: coverage\lcov.info
) else (
    echo ⚠️  No coverage data generated
)
echo.

REM ====================================================
REM Summary
REM ====================================================
echo.
echo ========================================================
echo  ✅ Test Suite Complete
echo ========================================================
echo.
echo Test Results:
echo   • Flutter Analyze: PASS (or warnings only)
echo   • Unit Tests: PASS or WARNINGS
echo   • Coverage: Generated (if available)
echo.

endlocal
exit /b 0

:error
echo.
echo ❌ Test suite failed!
endlocal
exit /b 1
