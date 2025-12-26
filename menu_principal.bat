@echo off
cls
title MENU PRINCIPAL
echo.
echo ============================
echo     MENU PRINCIPAL
echo ============================
echo   1. PHANTOM REINTEGRO
echo   2. PHANTOM NUEVOS
echo   3. SALIR
echo ============================
echo.
set /p "opcion=Seleccione: "
if "%opcion%"=="1" goto phantom
if "%opcion%"=="2" goto phantom_nuevos
if "%opcion%"=="3" exit
echo Opcion no valida
pause
exit

:phantom
echo Iniciando Phantom Reintegro...
cd scripts_phantom
if exist "menu_phantom.bat" (
    call menu_phantom.bat
) else (
    echo ERROR: No se encuentra menu_phantom.bat
    pause
)
cd ..
exit

:phantom_nuevos
echo Iniciando Phantom Nuevos...
cd "scripts_phantom nuevos"
if exist "menu_phantom_nuevos.bat" (
    call menu_phantom_nuevos.bat
) else (
    echo Creando menu para Phantom Nuevos...
    echo.
    echo ============================
    echo     PHANTOM NUEVOS
    echo ============================
    echo   1. EJECUTAR PHANTOM NUEVOS
    echo   2. VOLVER AL MENU
    echo ============================
    echo.
    set /p "opcion_phantom=Seleccione: "
    if "%opcion_phantom%"=="1" goto ejecutar_phantom
    if "%opcion_phantom%"=="2" goto volver_menu
    echo Opcion no valida
    pause
    goto phantom_nuevos
    
    :ejecutar_phantom
    if exist "phantom.py" (
        echo Ejecutando phantom.py...
        python phantom.py
    ) else (
        echo ERROR: No se encuentra phantom.py
    )
    pause
    goto phantom_nuevos
    
    :volver_menu
    cd ..
    menu_principal.bat
)
cd ..