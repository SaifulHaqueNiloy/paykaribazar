@echo off
setlocal enabledelayedexpansion

:: Keep track of the selected device across menu loops
set "SELECTED_DEVICE="

:menu
cls
echo ========================================
echo    PAYKARI BAZAR - SMART RUNNER
echo ========================================

:: --- AUTO DEVICE DETECTION ---
set count=0
set "FOUND_SELECTED=0"
echo DETECTED DEVICES:
echo ----------------------------------------
for /f "skip=1 tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="device" (
        set /a count+=1
        set "device!count!=%%a"

        :: Check if our previously selected device is still connected
        if "%%a"=="%SELECTED_DEVICE%" (
            set "FOUND_SELECTED=1"
            echo  [!count!] %%a [ACTIVE TARGET]
        ) else (
            echo  [!count!] %%a
        )
    )
)

:: Logic for automatic selection
if %count%==0 (
    set "SELECTED_DEVICE="
    set "FOUND_SELECTED=0"
    echo  [!] No devices found.
) else if %count%==1 (
    :: If only one device, auto-select it
    set "SELECTED_DEVICE=%device1%"
    set "FOUND_SELECTED=1"
) else if "%FOUND_SELECTED%"=="0" (
    :: Multiple devices but none selected yet
    set "SELECTED_DEVICE="
)

echo ----------------------------------------
if not "%SELECTED_DEVICE%"=="" (
    echo  CURRENT TARGET: %SELECTED_DEVICE%
) else (
    echo  CURRENT TARGET: (None - Please select)
)
echo ----------------------------------------

echo.
echo  [1] Start Emulator (Small Phone)
echo  [2] Start Emulator (Resizable)
echo  [w] Connect Wireless Debugging (IP)
echo  [t] Select/Change Target Device
echo.
echo  [3] Install CUSTOMER (Release APK)
echo  [4] Install ADMIN (Release APK)
echo.
echo  [5] Run CUSTOMER (Debug Mode)
echo  [6] Run ADMIN (Debug Mode)
echo.
echo  [r] Refresh / [q] Exit
echo.

set /p CHOICE="Selection: "

if /i "%CHOICE%"=="r" goto menu
if /i "%CHOICE%"=="q" exit /b 0

:: --- HANDLE CONNECTIONS & TOOLS ---
if /i "%CHOICE%"=="1" ( start /b emulator -avd Small_Phone & timeout /t 2 >nul & goto menu )
if /i "%CHOICE%"=="2" ( start /b emulator -avd Resizable_Experimental & timeout /t 2 >nul & goto menu )
if /i "%CHOICE%"=="w" (
    set /p IP="Enter Device IP (e.g. 192.168.1.5:5555): "
    adb connect !IP!
    pause & goto menu
)
if /i "%CHOICE%"=="t" (
    if %count%==0 ( echo No devices to select. & pause & goto menu )
    set /p IDX="Select Device Number (1-%count%): "
    set "SELECTED_DEVICE=!device%IDX%!"
    goto menu
)

:: --- VALIDATE TARGET BEFORE RUNNING ---
if "%CHOICE%" GEQ "3" if "%CHOICE%" LEQ "6" (
    if "%SELECTED_DEVICE%"=="" (
        if %count% GTR 1 (
            echo.
            echo Multiple devices detected!
            set /p IDX="Select device number to use (1-%count%): "
            set "SELECTED_DEVICE=!device%IDX%!"
        ) else (
            echo.
            echo ERROR: No device detected. Start one first.
            pause & goto menu
        )
    )
)

:: --- EXECUTE ACTIONS ---
if "%CHOICE%"=="3" (
    if not exist "..\build\app\outputs\flutter-apk\customer-release.apk" ( echo ERROR: Build APK first in DEPLOY_PROJECT.bat! & pause & goto menu )
    echo.
    echo Installing Customer to %SELECTED_DEVICE%...
    adb -s %SELECTED_DEVICE% install -r "..\build\app\outputs\flutter-apk\customer-release.apk"
    pause & goto menu
)
if "%CHOICE%"=="4" (
    if not exist "..\build\app\outputs\flutter-apk\admin-release.apk" ( echo ERROR: Build APK first in DEPLOY_PROJECT.bat! & pause & goto menu )
    echo.
    echo Installing Admin to %SELECTED_DEVICE%...
    adb -s %SELECTED_DEVICE% install -r "..\build\app\outputs\flutter-apk\admin-release.apk"
    pause & goto menu
)
if "%CHOICE%"=="5" (
    echo.
    echo Launching Customer on %SELECTED_DEVICE%...
    flutter run -d %SELECTED_DEVICE% -t lib/main_customer.dart
    pause & goto menu
)
if "%CHOICE%"=="6" (
    echo.
    echo Launching Admin on %SELECTED_DEVICE%...
    flutter run -d %SELECTED_DEVICE% -t lib/main_admin.dart
    pause & goto menu
)

goto menu
