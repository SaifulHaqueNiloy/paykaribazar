@echo off
echo ==========================================
echo   Generating Test Coverage Report
echo ==========================================
echo.

REM Run tests with coverage
flutter test test/ --coverage
if %errorlevel% neq 0 (
  echo.
  echo [ERROR] flutter test failed. Fix failing tests before generating coverage.
  pause
  exit /b 1
)

echo.
echo Tests completed. Coverage data generated in coverage/lcov.info

REM Generate HTML report if lcov is available
where genhtml >nul 2>nul
if %errorlevel% equ 0 (
  echo Generating HTML report...
  genhtml coverage/lcov.info -o coverage/html
  echo.
  echo ==========================================
  echo   Coverage report generated successfully!
  echo   Open coverage/html/index.html in a browser
  echo ==========================================
) else (
  echo [INFO] lcov/genhtml not found. Install lcov to generate HTML dashboard:
  echo   - Windows (with Chocolatey): choco install lcov
  echo   - macOS (with Homebrew):    brew install lcov
  echo   - Ubuntu/Debian:            sudo apt install lcov
  echo.
  echo Raw coverage data is available at coverage/lcov.info
)

echo.
pause
