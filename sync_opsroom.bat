@echo off
setlocal enabledelayedexpansion

:MENU
cls
echo.
echo ========================================
echo   OPERATIONS ROOM - SYNC TOOL
echo ========================================
echo.
echo Source: C:\Users\Brown\Desktop\OpsRoom_Dev\
echo.

REM Auto-detect missions
set count=0
set "missionPath[0]="

for /d %%D in ("C:\Users\Brown\Documents\Arma 3\missions\*") do (
    set /a count+=1
    set "missionPath[!count!]=%%D"
    set "missionName[!count!]=%%~nxD"
    echo   [!count!] %%~nxD
)

if %count%==0 (
    echo   No missions found!
    echo.
    echo   Create a mission in ARMA 3 Eden Editor first.
    echo.
    pause
    exit
)

echo.
echo Options:
echo   [A] Quick Sync - OpsRoom folder only
echo   [B] Full Sync - OpsRoom + mission files
echo   [S] Scan again
echo   [X] Exit
echo.
echo ========================================
echo.

set /p mission="Enter mission number (1-%count%): "
if "%mission%"=="" goto MENU
if "%mission%"=="S" goto MENU
if "%mission%"=="s" goto MENU
if "%mission%"=="X" goto EXIT
if "%mission%"=="x" goto EXIT

if %mission% LEQ 0 goto INVALID
if %mission% GTR %count% goto INVALID

set /p option="Enter option (A/B): "
if "%option%"=="" goto MENU

if /i "%option%"=="A" goto QUICK_SYNC
if /i "%option%"=="B" goto FULL_SYNC

:INVALID
echo.
echo Invalid choice! Press any key to try again...
pause >nul
goto MENU

:QUICK_SYNC
echo.
echo ========================================
echo   QUICK SYNC - OpsRoom Folder Only
echo ========================================
echo.
echo Mission: !missionName[%mission%]!
echo.
echo Syncing OpsRoom folder...
xcopy "C:\Users\Brown\Desktop\OpsRoom_Dev\OpsRoom\*" "!missionPath[%mission%]!\OpsRoom\" /E /I /Y /Q
echo.
if %ERRORLEVEL%==0 (
    echo ✓ Sync complete!
    echo.
    echo Next: Open mission in ARMA 3 and reload.
) else (
    echo ✗ Sync failed! Check paths.
)
echo.
pause
goto MENU

:FULL_SYNC
echo.
echo ========================================
echo   FULL SYNC - OpsRoom + Mission Files
echo ========================================
echo.
echo Mission: !missionName[%mission%]!
echo.

REM Sync OpsRoom folder
echo [1/3] Syncing OpsRoom folder...
xcopy "C:\Users\Brown\Desktop\OpsRoom_Dev\OpsRoom\*" "!missionPath[%mission%]!\OpsRoom\" /E /I /Y /Q

REM Check and copy description.ext
echo [2/3] Checking description.ext...
if not exist "!missionPath[%mission%]!\description.ext" (
    echo   Creating description.ext...
    copy "C:\Users\Brown\Desktop\OpsRoom_Dev\description.ext" "!missionPath[%mission%]!\description.ext" >nul
    echo   ✓ Created
) else (
    findstr /C:"OpsRoom\config.hpp" "!missionPath[%mission%]!\description.ext" >nul
    if errorlevel 1 (
        echo   WARNING: description.ext exists but missing OpsRoom include!
        echo   Skipping to avoid overwriting your config.
        echo   Manually add: #include "OpsRoom\config.hpp"
    ) else (
        echo   ✓ Already configured
    )
)

REM Check and copy init.sqf
echo [3/3] Checking init.sqf...
if not exist "!missionPath[%mission%]!\init.sqf" (
    echo   Creating init.sqf...
    copy "C:\Users\Brown\Desktop\OpsRoom_Dev\init.sqf" "!missionPath[%mission%]!\init.sqf" >nul
    echo   ✓ Created
) else (
    findstr /C:"OpsRoom\init.sqf" "!missionPath[%mission%]!\init.sqf" >nul
    if errorlevel 1 (
        echo   WARNING: init.sqf exists but missing OpsRoom init!
        echo   Skipping to avoid overwriting your scripts.
        echo   Manually add: [] execVM "OpsRoom\init.sqf";
    ) else (
        echo   ✓ Already configured
    )
)

echo.
echo ========================================
echo   SYNC COMPLETE
echo ========================================
echo.
echo Next: Open mission in ARMA 3 and reload.
echo.
pause
goto MENU

:EXIT
echo.
echo Goodbye!
timeout /t 2 >nul
exit
