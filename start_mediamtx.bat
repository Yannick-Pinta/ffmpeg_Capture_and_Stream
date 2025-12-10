@echo off
chcp 65001 >nul
REM ============================================================
REM  DEMARRAGE DU SERVEUR MEDIAMTX
REM  Redistribue le flux vers plusieurs clients
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

echo.
echo ============================================================
echo  SERVEUR MEDIAMTX - REDISTRIBUTION MULTI-CLIENTS
echo ============================================================
echo.
echo  Le serveur ecoute sur :
echo.
echo    SRT     : port 8890
echo    RTSP    : port 8554
echo    RTMP    : port 1935
echo    HLS     : port 8888
echo    WebRTC  : port 8889
echo.
echo ============================================================
echo.
echo  COMMENT UTILISER:
echo.
echo  1. Garder ce serveur ouvert
echo  2. Lancer stream_to_mediamtx.bat
echo  3. Connecter les clients :
echo.
echo     SRT:   srt://%MY_IP%:8890?streamid=read:%STREAM_NAME%
echo     RTSP:  rtsp://%MY_IP%:8554/%STREAM_NAME%
echo     HLS:   http://%MY_IP%:8888/%STREAM_NAME%
echo.
echo  Ctrl+C pour arreter le serveur.
echo.
echo ============================================================
echo.

"%MEDIAMTX_PATH%" "%MEDIAMTX_CONFIG%"

pause
