@echo off
chcp 65001 >nul
REM ============================================================
REM  STREAMING WEBCAM vers SRT (point-a-point)
REM  Mode: CALLER - se connecte a un recepteur
REM  Redemarre automatiquement en cas de deconnexion
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

:loop
echo.
echo ============================================================
echo  STREAMING SRT - WEBCAM + MICRO (point-a-point)
echo ============================================================
echo.
echo  Source: %WEBCAM_NAME% + %MICRO_NAME%
echo  Encodeur: %VIDEO_ENCODER%
echo  Video: %VIDEO_RESOLUTION% @ %VIDEO_FPS% fps, %VIDEO_BITRATE%
echo.
echo  Destination: srt://127.0.0.1:%SRT_PORT% (mode caller)
echo.
echo  IMPORTANT: Le recepteur doit etre demarre EN PREMIER !
echo    - ffplay: receive_srt.bat
echo    - VLC: srt://@:%SRT_PORT%?mode=listener
echo.
echo  Reconnexion automatique en cas de coupure.
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
    -f mpegts "srt://127.0.0.1:%SRT_PORT%?mode=caller&latency=%SRT_LATENCY%&connect_timeout=5000000"

echo.
echo  Connexion perdue. Nouvelle tentative dans 3 secondes...
echo.
timeout /t 3 /nobreak >nul
goto loop
