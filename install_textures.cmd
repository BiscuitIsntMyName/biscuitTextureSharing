@echo off
cls
setlocal EnableDelayedExpansion

set "dest=%USERPROFILE%\EphineaPSO\data\scene"
set "maps_base=%~dp0maps"

for /f "tokens=1-7 delims=/:., " %%a in ("%date% %time%") do (
    set "datetime=%%c-%%a-%%b_%%d-%%e-%%f"
)
set "datetime=%datetime: =0%"
set "current_backup_folder=%~dp0BACKUP_%datetime%"

echo.
echo Current values set in script:
echo.
echo Destination Folder:
echo    "%dest%"
echo.
echo IF THE GAME IS NOT INSTALLED IN THE DEFAULT PATH, PLEASE MODIFY THE "DEST" VARIABLE IN THE SCRIPT BEFORE CONTINUE.
echo.
echo Backup folder:
echo    "%current_backup_folder%"
echo.
echo Main Maps Folder (containing your choices):
echo    "%maps_base%"
echo.
echo -----------------------------------------------------
echo.
if not exist "%dest%" (
    echo The folder %dest% does not exist.
    echo.
    pause
    exit /b 1
)

if not exist "%maps_base%" (
    echo The source maps folder %maps_base% does not exist.
    echo Please ensure you have a 'maps' folder with your choices next to the script.
    echo.
    pause
    exit /b 1
)
echo Available Map Pack Choices:
echo ----------------------------------------
set /a count=0
for /d %%d in ("%maps_base%\*") do (
    set /a count+=1
    echo [!count!] %%~nxd
    set "map_choice[!count!]=%%d"
)
echo ----------------------------------------
echo.

if %count% equ 0 (
    echo No map folders found in "%maps_base%".
    echo Ensure your map packs are inside subfolders.
    echo.
    pause
    exit /b 1
)

:GET_CHOICE
set /p "user_choice=Enter the number of the map pack to install: "
if not defined user_choice goto GET_CHOICE
if !user_choice! LSS 1 goto GET_CHOICE
if !user_choice! GTR !count! goto GET_CHOICE

set "selected_map_folder=!map_choice[%user_choice%]!"

for %%A in ("!selected_map_folder!") do set "display_folder_name=%%~nxA"
echo.
echo You have chosen to install maps from: "%display_folder_name%"
echo.
pause
cls

echo.
echo Backing up existing maps (if present) to "%current_backup_folder%" ...
REM Create the dated backup folder directly
if not exist "%current_backup_folder%" (
    mkdir "%current_backup_folder%"
)
for %%f in ("%selected_map_folder%\*.xvm") do (
    if exist "%dest%\%%~nxf" (
        echo Backing up "%%~nxf" ...
        copy "%dest%\%%~nxf" "%current_backup_folder%\%%~nxf" >nul
    )
)
echo Backup complete.
echo.

echo Installing new maps to "%dest%" ...
copy "%selected_map_folder%\*.xvm" "%dest%" >nul
echo Installation complete.
echo.

echo End of script.
pause
endlocal
exit /b 0