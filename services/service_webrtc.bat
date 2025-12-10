@echo off
REM ============================================================
REM  SERVICE FFMPEG WEBRTC - Version sans boucle pour NSSM
REM  Transcode AAC vers Opus pour WebRTC avec audio
REM  NE PAS LANCER MANUELLEMENT - utiliser manage_services.bat
REM ============================================================

REM Charger la configuration
call "%~dp0..\config.bat"

REM Changer vers le repertoire du projet
cd /d "%~dp0.."

REM Lancer FFmpeg transcoder (sans boucle - NSSM gere le redemarrage)
"%FFMPEG_PATH%" ^
    -hide_banner ^
    -loglevel warning ^
    -i "srt://%MEDIAMTX_HOST%:%MEDIAMTX_PORT%?streamid=read:%STREAM_NAME%&latency=%SRT_LATENCY%" ^
    -c:v copy ^
    -c:a libopus -b:a %AUDIO_BITRATE% ^
    -f rtsp -rtsp_transport tcp "rtsp://%MEDIAMTX_HOST%:8554/%STREAM_NAME%_webrtc"

REM Code de sortie pour NSSM
exit /b %ERRORLEVEL%
