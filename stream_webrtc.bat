@echo off
chcp 65001 >nul
REM ============================================================
REM  TRANSCODEUR WEBRTC (AAC vers Opus)
REM  Lit le flux SRT et le republie avec Opus pour WebRTC
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

:loop
echo.
echo ============================================================
echo  TRANSCODEUR WEBRTC (AAC vers Opus)
echo ============================================================
echo.
echo  Source: srt://%MEDIAMTX_HOST%:%MEDIAMTX_PORT%/%STREAM_NAME% (AAC)
echo  Sortie: rtsp://%MEDIAMTX_HOST%:8554/%STREAM_NAME%_webrtc (Opus)
echo.
echo  WebRTC: http://%MY_IP%:8889/%STREAM_NAME%_webrtc
echo.
echo  IMPORTANT: stream_to_mediamtx.bat doit etre lance EN PREMIER
echo.
echo  Ctrl+C puis O pour arreter.
echo.
echo ============================================================
echo.

"%FFMPEG_PATH%" ^
    -hide_banner ^
    -loglevel error ^
    -i "srt://%MEDIAMTX_HOST%:%MEDIAMTX_PORT%?streamid=read:%STREAM_NAME%&latency=%SRT_LATENCY%" ^
    -c:v copy ^
    -c:a libopus -b:a %AUDIO_BITRATE% ^
    -f rtsp -rtsp_transport tcp "rtsp://%MEDIAMTX_HOST%:8554/%STREAM_NAME%_webrtc"

echo.
echo  Connexion perdue. Nouvelle tentative dans 3 secondes...
echo.
timeout /t 3 /nobreak >nul
goto loop
