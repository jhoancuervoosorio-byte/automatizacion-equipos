@echo off
title AUTOMATIZACION PHANTOM
color 0A
echo.
echo ============================
echo    AUTOMATIZACION PHANTOM
echo ============================
echo.
echo 1. PHANTOM NUEVOS
echo 2. VERIFICAR PORTAL
echo 3. SALIR
echo.
set /p opcion=Seleccione: 
if "%opcion%"=="1" goto uno
if "%opcion%"=="2" goto dos
if "%opcion%"=="3" exit
echo Opcion no valida
pause
exit
:uno
if exist phantom.py (
    python phantom.py
) else (
    echo ERROR: No hay phantom.py
)
pause
exit
:dos
if exist verificar_macs_portal.py (
    python verificar_macs_portal.py
) else (
    echo ERROR: No hay verificar_macs_portal.py
)
pause
exit
