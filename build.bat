@echo off
setlocal EnableExtensions
REM Build script for Clipline (streamer video editor)
REM Creates a standalone EXE using PyInstaller

set "EXE_PATH=dist\clipline.exe"
set "EXE_NAME=clipline.exe"
set "PYTHON_EXE=python"

echo ========================================
echo Clipline - Build EXE
echo ========================================
echo.

REM Check if PyInstaller is installed
%PYTHON_EXE% -m pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo Installing PyInstaller...
    %PYTHON_EXE% -m pip install pyinstaller
    if errorlevel 1 (
        echo ERROR: Failed to install PyInstaller.
        pause
        exit /b 1
    )
)

REM Check if PySide6 is installed (desktop shell runtime)
%PYTHON_EXE% -m pip show pyside6 >nul 2>&1
if errorlevel 1 (
    echo Installing PySide6 for desktop build...
    %PYTHON_EXE% -m pip install PySide6
    if errorlevel 1 (
        echo ERROR: Failed to install PySide6.
        pause
        exit /b 1
    )
)

REM Resolve common WinError 5 by ensuring previous EXE is not running/locked.
if exist "%EXE_PATH%" (
    echo Existing EXE detected. Attempting to release file lock...
    taskkill /F /IM "%EXE_NAME%" >nul 2>&1

    for /L %%I in (1,1,10) do (
        attrib -r -s -h "%EXE_PATH%" >nul 2>&1
        del /F /Q "%EXE_PATH%" >nul 2>&1
        if not exist "%EXE_PATH%" goto :exe_unlocked
        echo Waiting for EXE lock to release... (%%I/10)
        timeout /t 1 /nobreak >nul
    )

    echo.
    echo ERROR: Could not remove "%EXE_PATH%".
    echo Close the running app and any Explorer window previewing the EXE, then retry.
    pause
    exit /b 1
)

:exe_unlocked
echo.
echo Building EXE from Clipline.spec...
echo.

%PYTHON_EXE% -m PyInstaller --clean --noconfirm Clipline.spec
if errorlevel 1 (
    echo.
    echo ========================================
    echo Build failed.
    echo See: build\Clipline\warn-Clipline.txt
    echo ========================================
    pause
    exit /b 1
)

echo.
echo ========================================
echo Build complete!
echo.
echo EXE location: dist\clipline.exe
echo.
echo NOTE: EXE now auto-installs missing FFmpeg/yt-dlp at runtime.
echo Manual fallback (if needed):
echo   - FFmpeg: winget install Gyan.FFmpeg
echo   - yt-dlp: pip install -U yt-dlp
echo ========================================

pause
