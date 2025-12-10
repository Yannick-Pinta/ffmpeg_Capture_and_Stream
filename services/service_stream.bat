@echo off
REM ============================================================
REM  SERVICE FFMPEG STREAM - Version sans boucle pour NSSM
REM  Capture webcam + micro et envoie vers MediaMTX
REM  NE PAS LANCER MANUELLEMENT - utiliser manage_services.bat
REM ============================================================

REM Charger la configuration
call "%~dp0..\config.bat"

REM Changer vers le repertoire du projet
cd /d "%~dp0.."

REM Lancer FFmpeg (sans boucle - NSSM gere le redemarrage)
"%FFMPEG_PATH%" ^
    -hide_banner ^
    -loglevel warning ^
    -rtbufsize 50M ^
    -f dshow -video_size %VIDEO_RESOLUTION% -framerate %VIDEO_FPS% -i video="%WEBCAM_NAME%":audio="%MICRO_NAME%" ^
    -pix_fmt yuv420p ^
    -c:v %VIDEO_ENCODER% -preset %VIDEO_PRESET% -tune ll -b:v %VIDEO_BITRATE% -g 15 -keyint_min 15 ^
    -c:a aac -b:a %AUDIO_BITRATE% ^
    -f mpegts "srt://%MEDIAMTX_HOST%:%MEDIAMTX_PORT%?streamid=publish:%STREAM_NAME%&pkt_size=1316"

REM Code de sortie pour NSSM
exit /b %ERRORLEVEL%
