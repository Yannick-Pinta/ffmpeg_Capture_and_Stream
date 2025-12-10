@echo off
chcp 65001 >nul
REM ============================================================
REM  VERIFICATION DU SUPPORT NVENC (encodage GPU NVIDIA)
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

echo.
echo ============================================================
echo  VERIFICATION DU SUPPORT NVENC
echo ============================================================
echo.

echo --- Encodeurs NVIDIA disponibles ---
"%FFMPEG_PATH%" -encoders 2>nul | findstr nvenc

echo.
echo --- Decodeurs NVIDIA disponibles ---
"%FFMPEG_PATH%" -decoders 2>nul | findstr cuvid

echo.
echo ============================================================
echo  INTERPRETATION :
echo ============================================================
echo.
echo  Si tu vois "h264_nvenc" dans la liste ci-dessus,
echo  ton GPU NVIDIA est supporte.
echo.
echo  Si la liste est vide, modifie config.bat :
echo    set VIDEO_ENCODER=libx264
echo.
echo ============================================================
pause
