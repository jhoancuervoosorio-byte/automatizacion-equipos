@echo off
cls
title PHANTOM NUEVOS
echo.
echo ============================
echo     PHANTOM NUEVOS
echo ============================
echo   1. EJECUTAR PHANTOM NUEVOS
echo   2. VERIFICAR EN PORTAL
echo   3. VOLVER AL MENU PRINCIPAL
echo ============================
echo.
set /p "opcion=Seleccione: "
if "%opcion%"=="1" goto op1
if "%opcion%"=="2" goto op2
if "%opcion%"=="3" goto op3
echo Opcion no valida
pause
goto :eof

:menu
cls
title PHANTOM NUEVOS
echo.
echo ============================
echo     PHANTOM NUEVOS
echo ============================
echo   1. EJECUTAR PHANTOM NUEVOS
echo   2. VERIFICAR EN PORTAL
echo   3. VOLVER AL MENU PRINCIPAL
echo ============================
echo.
set /p "opcion=Seleccione: "
if "%opcion%"=="1" goto op1
if "%opcion%"=="2" goto op2
if "%opcion%"=="3" goto op3
echo Opcion no valida
pause
goto menu

:op1
echo.
echo EJECUTANDO PHANTOM NUEVOS
echo.
if exist "phantom.py" (
    python phantom.py
) else (
    echo ERROR: No se encuentra phantom.py
    echo.
    dir *.py
)
echo.
pause
goto menu

:op2
cls
echo ============================
echo   VERIFICAR MACs EN PORTAL
echo ============================
echo.
if exist "verificar_macs_portal.py" (
    echo Ejecutando verificacion en portal...
    echo.
    python verificar_macs_portal.py
) else (
    echo ERROR: No se encuentra verificar_macs_portal.py
    echo.
    echo Archivos disponibles:
    dir *.py
    echo.
    pause
    goto menu
)
echo.
goto menu

:op3
cd ..
menu_principal.bat