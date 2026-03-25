@echo off
REM ============================================================================
REM Paykari Bazar - Automated Release Script
REM ============================================================================
REM Usage: release.bat [version]
REM Example: release.bat 1.0.0
REM ============================================================================

setlocal enabledelayedexpansion

cls
echo.
echo ╔════════════════════════════════════════════════════════════════════════╗
echo ║           📦 Paykari Bazar - GitHub Release Automation              ║
echo ╚════════════════════════════════════════════════════════════════════════╝
echo.

REM Check if version is provided
if "%1"=="" (
    echo ❌ Error: Version number required
    echo.
    echo 📝 Usage:
    echo    release.bat 1.0.0
    echo    release.bat 1.0.1
    echo    release.bat 2.0.0
    echo.
    exit /b 1
)

set VERSION=%1
set TAG=v%VERSION%

echo 🔍 Checking requirements...
echo.

REM Check Git
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git not found. Install from: https://git-scm.com/
    exit /b 1
)
echo ✅ Git detected

REM Check if in repository
git rev-parse --git-dir >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Not in a Git repository. Navigate to project root first.
    exit /b 1
)
echo ✅ Git repository detected

echo.
echo =============================================================================
echo 📋 Release Details:
echo =============================================================================
echo Tag:     %TAG%
echo Version: %VERSION%
echo Commit:  %cd%
echo.

REM Show current status
echo 📊 Repository Status:
git status --short
echo.

REM Ask for confirmation
set /p confirm="✅ Ready to create release %TAG%? (y/n): "
if /i not "%confirm%"=="y" (
    echo ⚠️  Release cancelled.
    exit /b 0
)

echo.
echo =============================================================================
echo 🔨 Creating GitHub Release...
echo =============================================================================
echo.

REM Create tag
echo ⏳ Creating tag %TAG%...
git tag -a %TAG% -m "Release version %VERSION% - Customer and Admin apps"
if %errorlevel% neq 0 (
    echo ❌ Failed to create tag
    exit /b 1
)
echo ✅ Tag created locally

REM Push tag
echo ⏳ Pushing tag to GitHub...
git push origin %TAG%
if %errorlevel% neq 0 (
    echo ❌ Failed to push tag to GitHub
    echo 💡 Make sure you're connected to the internet and have push rights
    echo.
    echo To undo:
    echo   git tag -d %TAG%
    exit /b 1
)
echo ✅ Tag pushed to GitHub

echo.
echo =============================================================================
echo ✅ Release Created Successfully!
echo =============================================================================
echo.
echo 🤖 GitHub Actions is now building your APKs...
echo.
echo 📊 Check build progress at:
echo.
echo    🔗 https://github.com/YOUR_USERNAME/paykari_bazar/actions
echo.
echo ⏱️  Expected build time: 15-25 minutes (depends on GitHub server load)
echo.
echo 📋 Build steps:
echo   1. ✅ Pre-Release Checks (2-3 min)
echo   2. 🏗️  Build Release APKs (12-20 min)
echo      • 🛍️  Build Customer APK
echo      • 🏢 Build Admin APK
echo   3. 🎉 Create GitHub Release
echo.
echo 📥 When complete, download APKs from:
echo.
echo    🔗 https://github.com/YOUR_USERNAME/paykari_bazar/releases/%TAG%
echo.
echo 📱 Download both:
echo   • paykari_bazar_customer_%VERSION%.apk (🛍️  Customer App)
echo   • paykari_bazar_admin_%VERSION%.apk (🏢 Admin App)
echo.
echo =============================================================================
echo 💡 Next Steps:
echo =============================================================================
echo.
echo 1. Watch GitHub Actions:
echo    🔗 https://github.com/YOUR_USERNAME/paykari_bazar/actions
echo.
echo 2. After build completes (~20 min):
echo    • Download APKs from Releases page
echo    • Transfer to your phone
echo    • Install and test both apps
echo.
echo 3. Share release with your team:
echo    🔗 https://github.com/YOUR_USERNAME/paykari_bazar/releases/%TAG%
echo.
echo =============================================================================
echo.
pause
