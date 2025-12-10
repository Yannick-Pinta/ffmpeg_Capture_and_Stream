@echo off
chcp 65001 >nul
REM ============================================================
REM  STREAMING WEBCAM vers MEDIAMTX
REM  Envoie le flux au serveur qui le redistribue
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

:loop
echo.
echo ============================================================
echo  STREAMING WEBCAM vers MEDIAMTX
echo ============================================================
echo.
echo  Source: %WEBCAM_NAME% + %MICRO_NAME%
echo  Encodeur: %VIDEO_ENCODER%
echo  Video: %VIDEO_RESOLUTION% @ %VIDEO_FPS% fps, %VIDEO_BITRATE%
echo.
echo  Destination: srt://%MEDIAMTX_HOST%:%MEDIAMTX_PORT%/%STREAM_NAME%
echo.
echo  IMPORTANT: MediaMTX doit etre lance (start_mediamtx.bat)
echo.
echo  Les clients peuvent se connecter via:
echo    SRT:  srt://%MY_IP%:%MEDIAMTX_PORT%?streamid=read:%STREAM_NAME%
echo    RTSP: rtsp://%MY_IP%:8554/%STREAM_NAME%
echo    HLS:  http://%MY_IP%:8888/%STREAM_NAME%
echo.
echo  Ctrl+C puis O pour arreter.
echo.
echo ============================================================
echo.

"%FFMPEG_PATH%" ^
    -hide_banner ^
    -loglevel error ^
    -rtbufsize 50M ^
    -f dshow -video_size %VIDEO_RESOLUTION% -framerate %VIDEO_FPS% -i video="%WEBCAM_NAME%":audio="%MICRO_NAME%" ^
    -pix_fmt yuv420p ^
    -c:v %VIDEO_ENCODER% -preset %VIDEO_PRESET% -tune ll -b:v %VIDEO_BITRATE% -g 60 ^
    -c:a aac -b:a %AUDIO_BITRATE% ^
    -f mpegts "srt://%MEDIAMTX_HOST%:%MEDIAMTX_PORT%?streamid=publish:%STREAM_NAME%&pkt_size=1316"

echo.
echo  Connexion perdue. Nouvelle tentative dans 3 secondes...
echo.
timeout /t 3 /nobreak >nul
goto loop
