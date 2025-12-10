@echo off
REM ============================================================
REM  SERVICE MEDIAMTX - Version sans boucle pour NSSM
REM  Ce script est execute par le service Windows
REM  NE PAS LANCER MANUELLEMENT - utiliser manage_services.bat
REM ============================================================

REM Charger la configuration
call "%~dp0..\config.bat"

REM Changer vers le repertoire du projet
cd /d "%~dp0.."

REM Lancer MediaMTX (sans boucle - NSSM gere le redemarrage)
"%MEDIAMTX_PATH%" "%MEDIAMTX_CONFIG%"

REM Code de sortie pour NSSM
exit /b %ERRORLEVEL%
