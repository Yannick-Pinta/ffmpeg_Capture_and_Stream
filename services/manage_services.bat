@echo off
chcp 65001 >nul

REM ============================================================
REM  GESTION DES SERVICES DE STREAMING
REM  Start / Stop / Status / Logs
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

set NSSM_PATH=%~dp0nssm.exe
set LOGS_DIR=%~dp0..\logs
set SVC_MEDIAMTX=FFmpeg_MediaMTX
set SVC_STREAM=FFmpeg_Stream
set SVC_WEBRTC=FFmpeg_WebRTC

:menu
cls
echo.
echo ============================================================
echo  GESTION DES SERVICES DE STREAMING
echo ============================================================
echo.

REM Afficher le statut des services
echo  STATUT DES SERVICES:
echo  -------------------
for %%s in (%SVC_MEDIAMTX% %SVC_STREAM% %SVC_WEBRTC%) do (
    sc query "%%s" >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        for /f "tokens=4" %%a in ('sc query "%%s" ^| findstr STATE') do (
            if "%%a"=="RUNNING" (
                echo    [EN MARCHE]  %%s
            ) else if "%%a"=="STOPPED" (
                echo    [ARRETE]     %%s
            ) else (
                echo    [%%a]  %%s
            )
        )
    ) else (
        echo    [NON INSTALLE]  %%s
    )
)

echo.
echo  -------------------
echo.
echo  ACTIONS:
echo.
echo    1. Demarrer tous les services
echo    2. Arreter tous les services
echo    3. Redemarrer tous les services
echo.
echo    4. Demarrer service WebRTC (optionnel)
echo    5. Arreter service WebRTC
echo.
echo    6. Voir les logs (derniere 50 lignes)
echo    7. Ouvrir le dossier des logs
echo    8. Ouvrir services.msc
echo.
echo    9. Configurer demarrage auto WebRTC
echo    0. Quitter
echo.
echo ============================================================
echo.
set /p CHOICE="  Choix: "

if "%CHOICE%"=="1" goto start_all
if "%CHOICE%"=="2" goto stop_all
if "%CHOICE%"=="3" goto restart_all
if "%CHOICE%"=="4" goto start_webrtc
if "%CHOICE%"=="5" goto stop_webrtc
if "%CHOICE%"=="6" goto show_logs
if "%CHOICE%"=="7" goto open_logs
if "%CHOICE%"=="8" goto open_services
if "%CHOICE%"=="9" goto config_webrtc
if "%CHOICE%"=="0" goto end
goto menu

:start_all
echo.
echo  Demarrage des services...
net start %SVC_MEDIAMTX% 2>nul
timeout /t 2 /nobreak >nul
net start %SVC_STREAM% 2>nul
echo  Services demarres.
timeout /t 2 /nobreak >nul
goto menu

:stop_all
echo.
echo  Arret des services...
net stop %SVC_WEBRTC% 2>nul
net stop %SVC_STREAM% 2>nul
net stop %SVC_MEDIAMTX% 2>nul
echo  Services arretes.
timeout /t 2 /nobreak >nul
goto menu

:restart_all
echo.
echo  Redemarrage des services...
net stop %SVC_WEBRTC% 2>nul
net stop %SVC_STREAM% 2>nul
net stop %SVC_MEDIAMTX% 2>nul
timeout /t 2 /nobreak >nul
net start %SVC_MEDIAMTX% 2>nul
timeout /t 2 /nobreak >nul
net start %SVC_STREAM% 2>nul
echo  Services redemarres.
timeout /t 2 /nobreak >nul
goto menu

:start_webrtc
echo.
echo  Demarrage du service WebRTC...
net start %SVC_WEBRTC% 2>nul
echo  Service WebRTC demarre.
timeout /t 2 /nobreak >nul
goto menu

:stop_webrtc
echo.
echo  Arret du service WebRTC...
net stop %SVC_WEBRTC% 2>nul
echo  Service WebRTC arrete.
timeout /t 2 /nobreak >nul
goto menu

:show_logs
cls
echo.
echo ============================================================
echo  LOGS - 50 dernieres lignes
echo ============================================================
echo.
echo  --- MediaMTX ---
if exist "%LOGS_DIR%\mediamtx.log" (
    powershell -Command "Get-Content '%LOGS_DIR%\mediamtx.log' -Tail 15"
) else (
    echo  (pas de log)
)
echo.
echo  --- FFmpeg Stream ---
if exist "%LOGS_DIR%\ffmpeg_stream.log" (
    powershell -Command "Get-Content '%LOGS_DIR%\ffmpeg_stream.log' -Tail 15"
) else (
    echo  (pas de log)
)
echo.
echo  --- FFmpeg WebRTC ---
if exist "%LOGS_DIR%\ffmpeg_webrtc.log" (
    powershell -Command "Get-Content '%LOGS_DIR%\ffmpeg_webrtc.log' -Tail 15"
) else (
    echo  (pas de log)
)
echo.
echo ============================================================
pause
goto menu

:open_logs
start "" "%LOGS_DIR%"
goto menu

:open_services
start services.msc
goto menu

:config_webrtc
echo.
echo  Configuration du demarrage automatique pour WebRTC:
echo.
echo    1. Activer demarrage auto
echo    2. Desactiver demarrage auto (manuel)
echo    3. Retour
echo.
set /p WR_CHOICE="  Choix: "
if "%WR_CHOICE%"=="1" (
    "%NSSM_PATH%" set %SVC_WEBRTC% Start SERVICE_AUTO_START
    echo  WebRTC configure en demarrage automatique.
)
if "%WR_CHOICE%"=="2" (
    "%NSSM_PATH%" set %SVC_WEBRTC% Start SERVICE_DEMAND_START
    echo  WebRTC configure en demarrage manuel.
)
timeout /t 2 /nobreak >nul
goto menu

:end
exit /b 0
