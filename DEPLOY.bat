@echo off
REM Master deployment menu - easy navigation for all deployment options

:menu
cls
echo.
echo ================================================================
echo   PAYKARI BAZAR - DEPLOYMENT MENU
echo   Customer App + Admin App
echo ================================================================
echo.
echo QUICK DEPLOY OPTIONS:
echo.
echo   1. Deploy WEB (customer + admin to Firebase Hosting)
echo   2. Shorebird OTA PATCH (quick update, no app store)
echo   3. Shorebird FULL RELEASE (for app store submission)
echo   4. Build APK local (for testing)
echo   5. Build App Bundle (optimized for Play Store)
echo   6. Clean Build (fresh build from scratch)
echo.
echo   0. Exit
echo.
set /p CHOICE="Enter your choice (0-6): "

if "!CHOICE!"=="1" goto deploy_web
if "!CHOICE!"=="2" goto deploy_patch
if "!CHOICE!"=="3" goto deploy_release
if "!CHOICE!"=="4" goto build_apk
if "!CHOICE!"=="5" goto build_bundle
if "!CHOICE!"=="6" goto clean_build
if "!CHOICE!"=="0" exit /b 0

echo Invalid choice. Please try again.
pause
goto menu

:deploy_web
echo.
echo Starting web deployment...
call deploy_web_all.bat
goto menu

:deploy_patch
echo.
echo Starting OTA patch deployment...
call deploy_shorebird_patch.bat
goto menu

:deploy_release
echo.
echo Starting full release...
call deploy_shorebird_release.bat
goto menu

:build_apk
echo.
echo Starting APK build...
call build_apk_local.bat
goto menu

:build_bundle
echo.
echo Starting app bundle build...
call build_appbundle.bat
goto menu

:clean_build
echo.
echo Starting clean build...
call clean_build.bat
goto menu
