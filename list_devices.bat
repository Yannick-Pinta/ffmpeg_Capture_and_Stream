@echo off
chcp 65001 >nul
REM ============================================================
REM  LISTE DES PERIPHERIQUES DIRECTSHOW (webcam + micro)
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

echo.
echo ============================================================
echo  DETECTION DES PERIPHERIQUES DISPONIBLES
echo ============================================================
echo.
echo  Cherche dans la liste ci-dessous :
echo    - Section "video devices" : nom de ta WEBCAM
echo    - Section "audio devices" : nom de ton MICRO
echo.
echo  Copie les noms EXACTEMENT dans config.bat
echo ============================================================
echo.

"%FFMPEG_PATH%" -list_devices true -f dshow -i dummy 2>&1

echo.
pause
