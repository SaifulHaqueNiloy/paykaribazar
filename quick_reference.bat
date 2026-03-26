@echo off
REM Quick Reference Card for Deployment Scripts

cls
echo.
echo ================================================================
echo   PAYKARI BAZAR - DEPLOYMENT QUICK REFERENCE
echo ================================================================
echo.
echo SCRIPT NAME                  PURPOSE
echo ================================================================
echo.
echo DEPLOY.bat                   MASTER MENU - Start here
echo.
echo deploy_web_all.bat           Deploy customer + admin to web
echo                              (Firebase Hosting)
echo                              Time: ~15 min
echo.
echo deploy_shorebird_patch.bat   Push OTA patch (hotfix)
echo                              Version: 1.0.0+ increments
echo                              Time: ~20 min
echo.
echo deploy_shorebird_release.bat Full app release for Play Store
echo                              Generates .apk files
echo                              Time: ~30 min
echo.
echo build_apk_local.bat          Local testing APKs
echo                              Split per ABI (arm64, armv7, x86)
echo                              Time: ~10 min
echo.
echo build_appbundle.bat          Play Store optimized bundle
echo                              Generate .aab file
echo                              Time: ~15 min
echo.
echo clean_build.bat              Full rebuild from scratch
echo                              Clears build/ and pubspec.lock
echo                              Time: ~10 min
echo.
echo ================================================================
echo.
echo QUICK DECISION TREE:
echo.
echo What are you doing?
echo.
echo   Is it web?
echo     YES -> deploy_web_all.bat
echo     NO  -> Continue below
echo.
echo   Is it a quick bugfix?
echo     YES -> deploy_shorebird_patch.bat
echo     NO  -> Is it a full feature release?
echo       YES -> deploy_shorebird_release.bat
echo       NO  -> Are you testing locally?
echo         YES -> build_apk_local.bat
echo         NO  -> Are you submitting to Play Store?
echo           YES -> build_appbundle.bat
echo.
echo ================================================================
echo.
echo REQUIREMENTS:
echo   ✓ Flutter 3.27.0+
echo   ✓ Firebase CLI (firebase login)
echo   ✓ Shorebird CLI (shorebird login)
echo   ✓ Java 17+
echo.
echo LOCATED AT:
echo   C:\Users\Nazifa\paykari_bazar\
echo.
echo ================================================================
echo.
pause
