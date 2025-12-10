@echo off
chcp 65001 >nul

REM ============================================================
REM  DESINSTALLATION DES SERVICES WINDOWS
REM  NECESSITE D'ETRE LANCE EN ADMINISTRATEUR
REM ============================================================

REM Verifier les droits admin
net session >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo.
    echo ============================================================
    echo  ERREUR: Ce script doit etre lance en Administrateur
    echo ============================================================
    echo.
    echo  Clic droit sur le script ^> "Executer en tant qu'administrateur"
    echo.
    pause
    exit /b 1
)

set NSSM_PATH=%~dp0nssm.exe
set SVC_MEDIAMTX=FFmpeg_MediaMTX
set SVC_STREAM=FFmpeg_Stream
set SVC_WEBRTC=FFmpeg_WebRTC

echo.
echo ============================================================
echo  DESINSTALLATION DES SERVICES DE STREAMING
echo ============================================================
echo.
echo  Les services suivants vont etre supprimes:
echo    - %SVC_MEDIAMTX%
echo    - %SVC_STREAM%
echo    - %SVC_WEBRTC%
echo.
echo  Les logs ne seront PAS supprimes.
echo.
echo  Continuer ? (O/N)
set /p CONFIRM="> "
if /i not "%CONFIRM%"=="O" (
    echo  Annule.
    pause
    exit /b 0
)

echo.

REM Verifier si NSSM existe
if not exist "%NSSM_PATH%" (
    echo  ERREUR: NSSM non trouve a %NSSM_PATH%
    echo  Les services n'ont peut-etre pas ete installes via ce script.
    pause
    exit /b 1
)

REM Arreter et supprimer les services (ordre inverse)
echo  Arret et suppression des services...
echo.

echo  [1/3] Suppression %SVC_WEBRTC%...
"%NSSM_PATH%" stop %SVC_WEBRTC% >nul 2>&1
"%NSSM_PATH%" remove %SVC_WEBRTC% confirm >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo        OK
) else (
    echo        Service non trouve ou deja supprime
)

echo  [2/3] Suppression %SVC_STREAM%...
"%NSSM_PATH%" stop %SVC_STREAM% >nul 2>&1
"%NSSM_PATH%" remove %SVC_STREAM% confirm >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo        OK
) else (
    echo        Service non trouve ou deja supprime
)

echo  [3/3] Suppression %SVC_MEDIAMTX%...
"%NSSM_PATH%" stop %SVC_MEDIAMTX% >nul 2>&1
"%NSSM_PATH%" remove %SVC_MEDIAMTX% confirm >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo        OK
) else (
    echo        Service non trouve ou deja supprime
)

echo.
echo ============================================================
echo  DESINSTALLATION TERMINEE
echo ============================================================
echo.
echo  Les services ont ete supprimes.
echo.
echo  Notes:
echo    - Les logs sont conserves dans le dossier logs\
echo    - NSSM est conserve dans services\
echo    - Pour reinstaller: install_services.bat
echo.
pause
