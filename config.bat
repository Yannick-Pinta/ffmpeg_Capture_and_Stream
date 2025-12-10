@echo off
REM ============================================================
REM  CONFIGURATION CENTRALE - FFmpeg SRT ReStreamer
REM  Editez ce fichier pour configurer votre setup
REM ============================================================

REM ============================================================
REM  PERIPHERIQUES D'ENTREE
REM  Lancez list_devices.bat pour trouver les noms exacts
REM ============================================================

set WEBCAM_NAME=Logitech BRIO
set MICRO_NAME=Microphone (Logitech BRIO)

REM ============================================================
REM  RESEAU
REM  Remplacez MY_IP par l'IP de cette machine
REM  (utilisez ipconfig pour la trouver)
REM ============================================================

set MY_IP=192.168.1.159
set SRT_PORT=9000
set SRT_LATENCY=120000

REM ============================================================
REM  MEDIAMTX
REM ============================================================

set MEDIAMTX_HOST=127.0.0.1
set MEDIAMTX_PORT=8890
set STREAM_NAME=webcam

REM ============================================================
REM  ENCODAGE VIDEO
REM  h264_nvenc = GPU NVIDIA (recommande)
REM  libx264 = CPU (fallback si pas de GPU NVIDIA)
REM ============================================================

set VIDEO_ENCODER=h264_nvenc
REM Presets NVENC: p1 (qualite) a p7 (vitesse), p4 recommande
set VIDEO_PRESET=p4
set VIDEO_BITRATE=4000k
set VIDEO_RESOLUTION=1280x720
set VIDEO_FPS=30

REM ============================================================
REM  ENCODAGE AUDIO
REM ============================================================

set AUDIO_BITRATE=128k

REM ============================================================
REM  CHEMINS (ne pas modifier sauf si structure differente)
REM ============================================================

set FFMPEG_PATH=%~dp0ffmpeg\bin\ffmpeg.exe
set FFPLAY_PATH=%~dp0ffmpeg\bin\ffplay.exe
set MEDIAMTX_PATH=%~dp0mediamtx\mediamtx.exe
set MEDIAMTX_CONFIG=%~dp0mediamtx\mediamtx.yml
