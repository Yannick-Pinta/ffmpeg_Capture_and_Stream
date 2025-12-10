@echo off
chcp 65001 >nul
REM ============================================================
REM  SCRIPT DE STREAMING WEBCAM + MICRO vers SRT
REM  VERSION FALLBACK : ENCODAGE CPU (libx264)
REM  Utiliser si pas de carte NVIDIA ou si h264_nvenc echoue
REM ============================================================

REM ============================================================
REM  CONFIGURATION - ADAPTER CES VALEURS A TON SETUP
REM ============================================================

set FFMPEG_PATH=C:\Claude\ffmpeg_ReStreamer\ffmpeg\bin\ffmpeg.exe

REM --- Peripheriques d'entree ---
set WEBCAM_NAME=Logitech BRIO
set MICRO_NAME=Headset Microphone (HyperX 7.1 Audio)

REM --- Destination SRT ---
REM Pour test local : 127.0.0.1
REM Pour envoyer vers une autre machine : mettre son IP (ex: 192.168.1.xxx)
set SRT_IP=127.0.0.1
set SRT_PORT=9000
set SRT_LATENCY=120000

REM --- Parametres video (CPU) ---
REM Preset x264: ultrafast, superfast, veryfast, faster, fast, medium
REM Pour le live, utiliser veryfast ou faster
set VIDEO_PRESET=veryfast
set VIDEO_BITRATE=4000k
set VIDEO_RESOLUTION=1280x720
set VIDEO_FPS=30

REM --- Parametres audio ---
set AUDIO_BITRATE=128k

REM ============================================================
REM  LANCEMENT DU STREAM
REM ============================================================

echo.
echo ============================================================
echo  DEMARRAGE DU STREAM SRT (encodage CPU x264)
echo ============================================================
echo.
echo  Webcam    : %WEBCAM_NAME%
echo  Micro     : %MICRO_NAME%
echo  Encodeur  : libx264 (CPU)
echo  Preset    : %VIDEO_PRESET%
echo  Bitrate   : %VIDEO_BITRATE%
echo  Dest SRT  : srt://%SRT_IP%:%SRT_PORT%
echo.
echo  Appuyer sur Q pour arreter le stream.
echo.
echo ============================================================
echo.

"%FFMPEG_PATH%" ^
    -loglevel info ^
    -f dshow -i video="%WEBCAM_NAME%":audio="%MICRO_NAME%" ^
    -s %VIDEO_RESOLUTION% -r %VIDEO_FPS% ^
    -c:v libx264 -preset %VIDEO_PRESET% -tune zerolatency -b:v %VIDEO_BITRATE% ^
    -c:a aac -b:a %AUDIO_BITRATE% ^
    -f mpegts "srt://%SRT_IP%:%SRT_PORT%?mode=caller&latency=%SRT_LATENCY%"

echo.
echo  STREAM TERMINE
pause
