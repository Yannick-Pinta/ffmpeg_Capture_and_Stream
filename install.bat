@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

REM ============================================================
REM  INSTALLATION AUTOMATIQUE - FFmpeg SRT ReStreamer
REM ============================================================

set INSTALL_DIR=%~dp0
set FFMPEG_VERSION=2025-12-07-git-c4d22f2d2c-full_build
set FFMPEG_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full.7z
set MEDIAMTX_VERSION=v1.15.2
set MEDIAMTX_URL=https://github.com/bluenviron/mediamtx/releases/download/%MEDIAMTX_VERSION%/mediamtx_%MEDIAMTX_VERSION%_windows_amd64.zip

echo.
echo ============================================================
echo  INSTALLATION - FFmpeg SRT ReStreamer
echo ============================================================
echo.
echo  Ce script va installer :
echo    - FFmpeg (encodage video)
echo    - MediaMTX (serveur de redistribution)
echo.
echo  Dossier d'installation : %INSTALL_DIR%
echo.
echo ============================================================
echo.

REM --- Verification de curl ---
where curl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  ERREUR: curl n'est pas disponible.
    echo  curl est inclus dans Windows 10/11.
    pause
    exit /b 1
)

REM --- Verification de tar ---
where tar >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo  ATTENTION: tar n'est pas disponible.
    echo  L'extraction automatique pourrait echouer.
)

REM ============================================================
REM  INSTALLATION DE FFMPEG
REM ============================================================

if exist "%INSTALL_DIR%ffmpeg\bin\ffmpeg.exe" (
    echo  [OK] FFmpeg deja installe.
) else (
    echo  [1/4] Telechargement de FFmpeg...
    echo        Cela peut prendre quelques minutes...

    if not exist "%INSTALL_DIR%ffmpeg" mkdir "%INSTALL_DIR%ffmpeg"

    REM Telecharger le zip release (plus petit que 7z)
    curl -L -o "%INSTALL_DIR%ffmpeg\ffmpeg.zip" "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

    if !ERRORLEVEL! NEQ 0 (
        echo  ERREUR: Echec du telechargement de FFmpeg.
        echo  Telechargez manuellement depuis: https://www.gyan.dev/ffmpeg/builds/
        pause
        exit /b 1
    )

    echo  [2/4] Extraction de FFmpeg...

    REM Extraire avec PowerShell
    powershell -Command "Expand-Archive -Force '%INSTALL_DIR%ffmpeg\ffmpeg.zip' '%INSTALL_DIR%ffmpeg\temp'"

    REM Deplacer les fichiers du sous-dossier
    for /d %%D in ("%INSTALL_DIR%ffmpeg\temp\ffmpeg-*") do (
        xcopy /E /Y "%%D\*" "%INSTALL_DIR%ffmpeg\" >nul
    )

    REM Nettoyer
    rmdir /S /Q "%INSTALL_DIR%ffmpeg\temp" 2>nul
    del "%INSTALL_DIR%ffmpeg\ffmpeg.zip" 2>nul

    if exist "%INSTALL_DIR%ffmpeg\bin\ffmpeg.exe" (
        echo  [OK] FFmpeg installe avec succes.
    ) else (
        echo  ERREUR: L'installation de FFmpeg a echoue.
        pause
        exit /b 1
    )
)

REM ============================================================
REM  INSTALLATION DE MEDIAMTX
REM ============================================================

if exist "%INSTALL_DIR%mediamtx\mediamtx.exe" (
    echo  [OK] MediaMTX deja installe.
) else (
    echo  [3/4] Telechargement de MediaMTX %MEDIAMTX_VERSION%...

    if not exist "%INSTALL_DIR%mediamtx" mkdir "%INSTALL_DIR%mediamtx"

    curl -L -o "%INSTALL_DIR%mediamtx\mediamtx.zip" "%MEDIAMTX_URL%"

    if !ERRORLEVEL! NEQ 0 (
        echo  ERREUR: Echec du telechargement de MediaMTX.
        echo  Telechargez manuellement depuis: https://github.com/bluenviron/mediamtx/releases
        pause
        exit /b 1
    )

    echo  [4/4] Extraction de MediaMTX...

    powershell -Command "Expand-Archive -Force '%INSTALL_DIR%mediamtx\mediamtx.zip' '%INSTALL_DIR%mediamtx'"

    del "%INSTALL_DIR%mediamtx\mediamtx.zip" 2>nul

    if exist "%INSTALL_DIR%mediamtx\mediamtx.exe" (
        echo  [OK] MediaMTX installe avec succes.
    ) else (
        echo  ERREUR: L'installation de MediaMTX a echoue.
        pause
        exit /b 1
    )
)

REM ============================================================
REM  CREATION DE LA CONFIGURATION MEDIAMTX
REM ============================================================

if not exist "%INSTALL_DIR%mediamtx\mediamtx.yml" (
    echo  [OK] Creation de la configuration MediaMTX...
    (
        echo # MediaMTX Configuration
        echo # Accepte tous les streams dynamiquement
        echo.
        echo logLevel: info
        echo.
        echo # Ports
        echo rtsp: yes
        echo rtspAddress: :8554
        echo.
        echo rtmp: yes
        echo rtmpAddress: :1935
        echo.
        echo hls: yes
        echo hlsAddress: :8888
        echo.
        echo webrtc: yes
        echo webrtcAddress: :8889
        echo.
        echo srt: yes
        echo srtAddress: :8890
        echo.
        echo # Accepter TOUS les chemins dynamiquement
        echo paths:
        echo   all:
    ) > "%INSTALL_DIR%mediamtx\mediamtx.yml"
)

REM ============================================================
REM  VERIFICATION NVENC
REM ============================================================

echo.
echo  Verification du support NVENC (GPU NVIDIA)...
"%INSTALL_DIR%ffmpeg\bin\ffmpeg.exe" -encoders 2>nul | findstr /C:"h264_nvenc" >nul
if %ERRORLEVEL% EQU 0 (
    echo  [OK] NVENC disponible - encodage GPU active.
    set NVENC_AVAILABLE=1
) else (
    echo  [!!] NVENC non disponible - encodage CPU sera utilise.
    set NVENC_AVAILABLE=0
)

REM ============================================================
REM  FIN DE L'INSTALLATION
REM ============================================================

echo.
echo ============================================================
echo  INSTALLATION TERMINEE
echo ============================================================
echo.
echo  Prochaines etapes :
echo.
echo  1. Lancez list_devices.bat pour detecter vos peripheriques
echo.
echo  2. Editez config.bat avec les noms de votre webcam/micro
echo.
echo  3. Testez avec :
echo     - start_mediamtx.bat  (Terminal 1)
echo     - stream_to_mediamtx.bat  (Terminal 2)
echo.
echo  4. Connectez-vous via VLC :
echo     rtsp://VOTRE_IP:8554/webcam
echo.
echo ============================================================
echo.

pause
