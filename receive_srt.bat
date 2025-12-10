@echo off
chcp 65001 >nul
REM ============================================================
REM  RECEPTEUR SRT (MODE LISTENER/SERVEUR)
REM  Reste ouvert et attend les connexions du streamer
REM ============================================================

REM Charger la configuration
call "%~dp0config.bat"

:loop
echo.
echo ============================================================
echo  RECEPTEUR SRT (MODE SERVEUR)
echo ============================================================
echo.
echo  En ecoute sur le port %SRT_PORT%
echo  Le streamer peut se connecter/deconnecter librement.
echo.
echo  Touches ffplay:
echo    Q/ESC = quitter
echo    9/0   = volume +/-
echo    M     = mute/unmute
echo.
echo ============================================================
echo.

"%FFPLAY_PATH%" ^
    -hide_banner ^
    -loglevel info ^
    -fflags nobuffer ^
    -flags low_delay ^
    -framedrop ^
    -volume 100 ^
    "srt://0.0.0.0:%SRT_PORT%?mode=listener&latency=%SRT_LATENCY%&transtype=live"

echo.
echo  Flux termine. Relance dans 2 secondes...
echo  (Ctrl+C pour quitter)
echo.
timeout /t 2 /nobreak >nul
goto loop
