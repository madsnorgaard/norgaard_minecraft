@echo off
echo =======================================
echo   Minecraft Server Modpack Installer
echo =======================================
echo.

:: Check for Minecraft directory
if not exist "%APPDATA%\.minecraft" (
    echo ERROR: Minecraft not found! Please install Minecraft first.
    pause
    exit
)

:: Create mods folder
if not exist "%APPDATA%\.minecraft\mods" mkdir "%APPDATA%\.minecraft\mods"

:: Backup existing mods
echo Backing up existing mods...
if exist "%APPDATA%\.minecraft\mods" (
    mkdir "%APPDATA%\.minecraft\mods_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%"
    xcopy "%APPDATA%\.minecraft\mods\*" "%APPDATA%\.minecraft\mods_backup_%date:~-4,4%%date:~-10,2%%date:~-7,2%\" /E /Q
)

:: Copy new mods
echo Installing Minecraft Server mods...
xcopy "client\mods\*" "%APPDATA%\.minecraft\mods\" /Y /E /Q

echo.
echo ✅ Installation complete!
echo.
echo Next steps:
echo 1. Open Minecraft Launcher
echo 2. Select "Fabric 1.21.5" profile
echo 3. Click Play
echo 4. Go to Multiplayer and add server
echo.
pause
