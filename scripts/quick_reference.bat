@echo off
REM Quick Reference Card for Deployment and Utility Scripts

cls
echo.
echo ================================================================
echo   PAYKARI BAZAR - DEPLOYMENT & UTILITY QUICK REFERENCE
echo ================================================================
echo.
echo SCRIPT NAME                  PURPOSE
echo ================================================================
echo.
echo DEPLOY.bat                   MASTER MENU - Start here
echo.
echo install_to_device.bat        ULTIMATE INSTALLER - Install APK to
echo                              Cable, Wireless, or Emulator
echo.
echo start_emulator.bat           EMULATOR MENU - Start Small Phone
echo                              or Resizable Emulator
echo.
echo deploy_shorebird_release.bat Full release for Play Store
echo                              (Generates customer-release.apk)
echo.
echo deploy_shorebird_patch.bat   Hotfix (OTA) via Shorebird
echo.
echo deploy_web_all.bat           Deploy both apps to Web Hosting
echo.
echo build_apk_local.bat          Build APK for local testing
echo.
echo clean_build.bat              Clear cache and rebuild project
echo.
echo ================================================================
echo.
echo QUICK DECISION TREE:
echo.
echo   Installing on a Phone/Emulator?
echo     -> Use install_to_device.bat
echo.
echo   Want to start an Emulator?
echo     -> Use start_emulator.bat
echo.
echo   Deploying to App Store?
echo     -> Use deploy_shorebird_release.bat
echo.
echo   Fixing a bug in production?
echo     -> Use deploy_shorebird_patch.bat
echo.
echo   Deploying to Web?
echo     -> Use deploy_web_all.bat
echo.
echo ================================================================
echo.
echo REQUIREMENTS:
echo   ✓ Flutter 3.27.0+
echo   ✓ ADB (Android Debug Bridge)
echo   ✓ Firebase CLI
echo   ✓ Shorebird CLI
echo.
echo LOCATION:
echo   C:\Users\Nazifa\paykari_bazar\bat\
echo.
echo ================================================================
echo.
pause
