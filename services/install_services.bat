@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ============================================================
REM  INSTALLATION DES SERVICES WINDOWS
REM  Utilise NSSM pour creer les services avec:
REM  - Demarrage automatique au boot
REM  - Redemarrage auto en cas de crash
REM  - Logs avec rotation
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

REM Charger la configuration
call "%~dp0..\config.bat"

REM Chemins
set SERVICES_DIR=%~dp0
set PROJECT_DIR=%~dp0..
set NSSM_PATH=%SERVICES_DIR%nssm.exe
set LOGS_DIR=%PROJECT_DIR%\logs

REM Noms des services
set SVC_MEDIAMTX=FFmpeg_MediaMTX
set SVC_STREAM=FFmpeg_Stream
set SVC_WEBRTC=FFmpeg_WebRTC

echo.
echo ============================================================
echo  INSTALLATION DES SERVICES DE STREAMING
echo ============================================================
echo.

REM Verifier si NSSM est present
if not exist "%NSSM_PATH%" (
    echo  NSSM non trouve. Telechargement en cours...
    echo.

    REM Telecharger NSSM
    set NSSM_URL=https://nssm.cc/release/nssm-2.24.zip
    set NSSM_ZIP=%TEMP%\nssm.zip
    set NSSM_EXTRACT=%TEMP%\nssm-extract

    powershell -Command "Invoke-WebRequest -Uri '!NSSM_URL!' -OutFile '!NSSM_ZIP!'"
    if !ERRORLEVEL! neq 0 (
        echo  ERREUR: Impossible de telecharger NSSM
        echo  Telechargez manuellement depuis https://nssm.cc/download
        echo  et placez nssm.exe dans le dossier services\
        pause
        exit /b 1
    )

    REM Extraire NSSM
    powershell -Command "Expand-Archive -Path '!NSSM_ZIP!' -DestinationPath '!NSSM_EXTRACT!' -Force"

    REM Copier le bon executable (64-bit)
    copy "!NSSM_EXTRACT!\nssm-2.24\win64\nssm.exe" "%NSSM_PATH%" >nul

    REM Nettoyer
    del "!NSSM_ZIP!" >nul 2>&1
    rmdir /s /q "!NSSM_EXTRACT!" >nul 2>&1

    echo  NSSM installe avec succes.
    echo.
)

REM Creer le dossier de logs
if not exist "%LOGS_DIR%" (
    mkdir "%LOGS_DIR%"
    echo  Dossier de logs cree: %LOGS_DIR%
)

echo.
echo  Installation des services...
echo.

REM ============================================================
REM  SERVICE 1: MediaMTX
REM ============================================================
echo  [1/3] Installation du service MediaMTX...

REM Supprimer si existe deja
"%NSSM_PATH%" stop %SVC_MEDIAMTX% >nul 2>&1
"%NSSM_PATH%" remove %SVC_MEDIAMTX% confirm >nul 2>&1

REM Installer le service
"%NSSM_PATH%" install %SVC_MEDIAMTX% "%SERVICES_DIR%service_mediamtx.bat"

REM Configuration
"%NSSM_PATH%" set %SVC_MEDIAMTX% DisplayName "FFmpeg ReStreamer - MediaMTX Server"
"%NSSM_PATH%" set %SVC_MEDIAMTX% Description "Serveur de redistribution MediaMTX pour streaming multi-clients"
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppDirectory "%PROJECT_DIR%"
"%NSSM_PATH%" set %SVC_MEDIAMTX% Start SERVICE_AUTO_START

REM Logs avec rotation (10 Mo, garder 5 fichiers)
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppStdout "%LOGS_DIR%\mediamtx.log"
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppStderr "%LOGS_DIR%\mediamtx.log"
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppStdoutCreationDisposition 4
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppStderrCreationDisposition 4
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppRotateFiles 1
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppRotateOnline 1
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppRotateBytes 10485760

REM Redemarrage automatique (delai 5 secondes)
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppExit Default Restart
"%NSSM_PATH%" set %SVC_MEDIAMTX% AppRestartDelay 5000

echo        OK - %SVC_MEDIAMTX%

REM ============================================================
REM  SERVICE 2: FFmpeg Stream (capture webcam)
REM ============================================================
echo  [2/3] Installation du service FFmpeg Stream...

REM Supprimer si existe deja
"%NSSM_PATH%" stop %SVC_STREAM% >nul 2>&1
"%NSSM_PATH%" remove %SVC_STREAM% confirm >nul 2>&1

REM Installer le service
"%NSSM_PATH%" install %SVC_STREAM% "%SERVICES_DIR%service_stream.bat"

REM Configuration
"%NSSM_PATH%" set %SVC_STREAM% DisplayName "FFmpeg ReStreamer - Webcam Capture"
"%NSSM_PATH%" set %SVC_STREAM% Description "Capture webcam et streaming vers MediaMTX"
"%NSSM_PATH%" set %SVC_STREAM% AppDirectory "%PROJECT_DIR%"
"%NSSM_PATH%" set %SVC_STREAM% Start SERVICE_AUTO_START

REM Dependance: demarrer apres MediaMTX
"%NSSM_PATH%" set %SVC_STREAM% DependOnService %SVC_MEDIAMTX%

REM Logs avec rotation
"%NSSM_PATH%" set %SVC_STREAM% AppStdout "%LOGS_DIR%\ffmpeg_stream.log"
"%NSSM_PATH%" set %SVC_STREAM% AppStderr "%LOGS_DIR%\ffmpeg_stream.log"
"%NSSM_PATH%" set %SVC_STREAM% AppStdoutCreationDisposition 4
"%NSSM_PATH%" set %SVC_STREAM% AppStderrCreationDisposition 4
"%NSSM_PATH%" set %SVC_STREAM% AppRotateFiles 1
"%NSSM_PATH%" set %SVC_STREAM% AppRotateOnline 1
"%NSSM_PATH%" set %SVC_STREAM% AppRotateBytes 10485760

REM Redemarrage automatique (delai 5 secondes)
"%NSSM_PATH%" set %SVC_STREAM% AppExit Default Restart
"%NSSM_PATH%" set %SVC_STREAM% AppRestartDelay 5000

echo        OK - %SVC_STREAM%

REM ============================================================
REM  SERVICE 3: FFmpeg WebRTC (transcoder Opus) - OPTIONNEL
REM ============================================================
echo  [3/3] Installation du service FFmpeg WebRTC (optionnel)...

REM Supprimer si existe deja
"%NSSM_PATH%" stop %SVC_WEBRTC% >nul 2>&1
"%NSSM_PATH%" remove %SVC_WEBRTC% confirm >nul 2>&1

REM Installer le service
"%NSSM_PATH%" install %SVC_WEBRTC% "%SERVICES_DIR%service_webrtc.bat"

REM Configuration
"%NSSM_PATH%" set %SVC_WEBRTC% DisplayName "FFmpeg ReStreamer - WebRTC Transcoder"
"%NSSM_PATH%" set %SVC_WEBRTC% Description "Transcodeur AAC vers Opus pour WebRTC avec audio"
"%NSSM_PATH%" set %SVC_WEBRTC% AppDirectory "%PROJECT_DIR%"
"%NSSM_PATH%" set %SVC_WEBRTC% Start SERVICE_DEMAND_START

REM Dependance: demarrer apres Stream
"%NSSM_PATH%" set %SVC_WEBRTC% DependOnService %SVC_STREAM%

REM Logs avec rotation
"%NSSM_PATH%" set %SVC_WEBRTC% AppStdout "%LOGS_DIR%\ffmpeg_webrtc.log"
"%NSSM_PATH%" set %SVC_WEBRTC% AppStderr "%LOGS_DIR%\ffmpeg_webrtc.log"
"%NSSM_PATH%" set %SVC_WEBRTC% AppStdoutCreationDisposition 4
"%NSSM_PATH%" set %SVC_WEBRTC% AppStderrCreationDisposition 4
"%NSSM_PATH%" set %SVC_WEBRTC% AppRotateFiles 1
"%NSSM_PATH%" set %SVC_WEBRTC% AppRotateOnline 1
"%NSSM_PATH%" set %SVC_WEBRTC% AppRotateBytes 10485760

REM Redemarrage automatique (delai 5 secondes)
"%NSSM_PATH%" set %SVC_WEBRTC% AppExit Default Restart
"%NSSM_PATH%" set %SVC_WEBRTC% AppRestartDelay 5000

echo        OK - %SVC_WEBRTC% (demarrage manuel)

echo.
echo ============================================================
echo  INSTALLATION TERMINEE
echo ============================================================
echo.
echo  Services installes:
echo    - %SVC_MEDIAMTX% (auto)
echo    - %SVC_STREAM% (auto, depend de MediaMTX)
echo    - %SVC_WEBRTC% (manuel, depend de Stream)
echo.
echo  Logs dans: %LOGS_DIR%
echo    - mediamtx.log
echo    - ffmpeg_stream.log
echo    - ffmpeg_webrtc.log
echo.
echo  Pour gerer les services:
echo    - manage_services.bat
echo    - Ou: services.msc
echo.
echo  Les services MediaMTX et Stream demarreront
echo  automatiquement au prochain redemarrage.
echo.
echo  Demarrer maintenant ? (O/N)
set /p START_NOW="> "
if /i "%START_NOW%"=="O" (
    echo.
    echo  Demarrage des services...
    net start %SVC_MEDIAMTX%
    timeout /t 3 /nobreak >nul
    net start %SVC_STREAM%
    echo.
    echo  Services demarres.
)

echo.
pause
