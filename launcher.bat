@echo off
title AUTOMATIZACION PHANTOM - LANZADOR UNIVERSAL
color 0A

:: ============================================
:: CONFIGURACIÓN INTELIGENTE PARA CUALQUIER PC
:: ============================================
echo.
echo ╔══════════════════════════════════════════╗
echo ║   AUTOMATIZACION PHANTOM - UNIVERSAL     ║
echo ║   Versión: 2.0 - GitHub Edition          ║
echo ╚══════════════════════════════════════════╝
echo.

:: Detectar directorio actual
set "SCRIPT_DIR=%~dp0"
set "USER_DIR=%USERPROFILE%\Documents\AutomatizacionPhantom"

echo 📁 Directorio del script: %SCRIPT_DIR%
echo 👤 Directorio de usuario: %USER_DIR%
echo.

:: Verificar si estamos en modo portátil o instalado
if exist "%USER_DIR%\phantom.py" (
    set "MODE=INSTALADO"
    set "WORK_DIR=%USER_DIR%"
) else (
    set "MODE=PORTATIL"
    set "WORK_DIR=%SCRIPT_DIR%"
)

echo 🔧 Modo: %MODE%
echo 📂 Directorio de trabajo: %WORK_DIR%
echo.

:: Crear acceso directo en escritorio si no existe
set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\Automatizacion Phantom.lnk"
if not exist "%DESKTOP_SHORTCUT%" (
    echo 📋 Creando acceso directo en el escritorio...
    echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\create_shortcut.vbs"
    echo sLinkFile = "%DESKTOP_SHORTCUT%" >> "%TEMP%\create_shortcut.vbs"
    echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\create_shortcut.vbs"
    echo oLink.TargetPath = "%~f0" >> "%TEMP%\create_shortcut.vbs"
    echo oLink.WorkingDirectory = "%WORK_DIR%" >> "%TEMP%\create_shortcut.vbs"
    echo oLink.Description = "Automatizacion Phantom" >> "%TEMP%\create_shortcut.vbs"
    echo oLink.Save >> "%TEMP%\create_shortcut.vbs"
    cscript //nologo "%TEMP%\create_shortcut.vbs"
    del "%TEMP%\create_shortcut.vbs"
    echo ✅ Acceso directo creado
)

:: Navegar al directorio de trabajo
cd /d "%WORK_DIR%"

:: MENÚ PRINCIPAL
:menu
cls
echo ╔══════════════════════════════════════════╗
echo ║          MENU PRINCIPAL - v2.0           ║
echo ╚══════════════════════════════════════════╝
echo.
echo 📂 Directorio: %WORK_DIR%
echo 🔧 Modo: %MODE%
echo.
echo ┌──────────────────────────────────────────┐
echo │  1. 🚀 EJECUTAR PHANTOM NUEVOS           │
echo │  2. 🔍 VERIFICAR EN PORTAL ISP          │
echo │  3. ⚙️  CONFIGURAR SISTEMA              │
echo │  4. 📥 ACTUALIZAR DESDE GITHUB          │
echo │  5. 📁 ABRIR CARPETA DE TRABAJO         │
echo │  6. 🌐 IR A REPOSITORIO GITHUB          │
echo │  7. 🚪 SALIR                            │
echo └──────────────────────────────────────────┘
echo.
set /p "choice=👉 Seleccione una opción (1-7): "

if "%choice%"=="1" goto run_phantom
if "%choice%"=="2" goto verify_portal
if "%choice%"=="3" goto configure
if "%choice%"=="4" goto update_github
if "%choice%"=="5" goto open_folder
if "%choice%"=="6" goto open_github
if "%choice%"=="7" goto exit

echo ❌ Opción inválida
timeout /t 2 /nobreak >nul
goto menu

:run_phantom
echo.
echo 🚀 INICIANDO PHANTOM NUEVOS...
echo.
if exist "phantom.py" (
    python phantom.py
) else (
    echo ❌ No se encuentra phantom.py
    echo.
    echo 📥 Descargando desde GitHub...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TU_USUARIO/Automatizacion-Phantom/main/src/scripts_phantom_nuevos/phantom.py' -OutFile 'phantom.py'"
    if exist "phantom.py" (
        echo ✅ Descargado. Ejecutando...
        python phantom.py
    ) else (
        echo ❌ Error al descargar
    )
)
echo.
pause
goto menu

:verify_portal
echo.
echo 🔍 VERIFICANDO EN PORTAL ISP...
echo.
if exist "verificar_macs_portal.py" (
    python verificar_macs_portal.py
) else (
    echo ❌ No se encuentra el script
    echo 📥 Descargando...
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TU_USUARIO/Automatizacion-Phantom/main/src/scripts_phantom_nuevos/verificar_macs_portal.py' -OutFile 'verificar_macs_portal.py'"
    if exist "verificar_macs_portal.py" (
        python verificar_macs_portal.py
    )
)
echo.
pause
goto menu

:configure
cls
echo ╔══════════════════════════════════════════╗
echo ║          CONFIGURACION DEL SISTEMA       ║
echo ╚══════════════════════════════════════════╝
echo.
echo 1. 🔑 Configurar credenciales (.env)
echo 2. 📡 Configurar rangos de IPs
echo 3. 🐍 Verificar/Instalar Python
echo 4. 📦 Instalar dependencias
echo 5. 🗂️  Crear estructura de carpetas
echo 6. ↩️  Volver al menú principal
echo.
set /p "config_choice=👉 Seleccione (1-6): "

if "%config_choice%"=="1" goto config_env
if "%config_choice%"=="2" goto config_ips
if "%config_choice%"=="3" goto check_python
if "%config_choice%"=="4" goto install_deps
if "%config_choice%"=="5" goto create_structure
if "%config_choice%"=="6" goto menu

goto configure

:config_env
echo.
echo 🔑 CONFIGURANDO CREDENCIALES...
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env"
    ) else (
        echo # Credenciales del portal ISP > .env
        echo ISP_USERNAME=tu_usuario@ejemplo.com >> .env
        echo ISP_PASSWORD=tu_contraseña >> .env
        echo PORTAL_URL=https://isp.somosinternet.com >> .env
        echo MAC_FILE_PATH=macs.txt >> .env
    )
)
notepad .env
goto configure

:config_ips
echo.
echo 📡 CONFIGURANDO RANGOS DE IPs...
if not exist "config_rangos.json" (
    powershell -Command "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/TU_USUARIO/Automatizacion-Phantom/main/config_rangos.json' -OutFile 'config_rangos.json'"
)
notepad config_rangos.json
goto configure

:check_python
echo.
echo 🐍 VERIFICANDO PYTHON...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python no encontrado
    echo.
    echo 📥 ¿Instalar Python automáticamente?
    set /p "install_python=   (s/n): "
    if /i "%install_python%"=="s" (
        echo Descargando Python...
        powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe' -OutFile '%TEMP%\python_installer.exe'"
        echo Ejecuta el instalador manualmente
        start "" "%TEMP%\python_installer.exe"
    )
) else (
    python --version
    echo ✅ Python instalado
)
echo.
pause
goto configure

:install_deps
echo.
echo 📦 INSTALANDO DEPENDENCIAS...
pip install asyncssh requests python-dotenv
echo.
echo ✅ Dependencias instaladas
pause
goto configure

:create_structure
echo.
echo 🗂️ CREANDO ESTRUCTURA...
mkdir backups_macs 2>nul
mkdir logs 2>nul
mkdir scripts_phantom_nuevos 2>nul
mkdir scripts_phantom 2>nul
echo ✅ Estructura creada
echo.
dir /ad
pause
goto configure

:update_github
echo.
echo 📥 ACTUALIZANDO DESDE GITHUB...
echo.
echo 🔄 Descargando última versión...
powershell -Command "
try {
    # Descargar archivos principales
    $files = @(
        'src/scripts_phantom_nuevos/phantom.py',
        'src/scripts_phantom_nuevos/verificar_macs_portal.py',
        'src/scripts_phantom_nuevos/menu_phantom_nuevos.bat',
        'config_rangos.json',
        '.env.example'
    )
    
    $baseUrl = 'https://raw.githubusercontent.com/TU_USUARIO/Automatizacion-Phantom/main/'
    
    foreach ($file in $files) {
        $outFile = Split-Path $file -Leaf
        $url = $baseUrl + $file
        Invoke-WebRequest -Uri $url -OutFile $outFile
        Write-Host \"✅ $outFile actualizado\" -ForegroundColor Green
    }
    
    Write-Host \"`n🎉 Actualización completada\" -ForegroundColor Cyan
} catch {
    Write-Host \"❌ Error: $_\" -ForegroundColor Red
}
"
echo.
pause
goto menu

:open_folder
echo.
echo 📁 ABRIENDO CARPETA DE TRABAJO...
explorer "%WORK_DIR%"
goto menu

:open_github
echo.
echo 🌐 ABRIENDO REPOSITORIO GITHUB...
start "" "https://github.com/TU_USUARIO/Automatizacion-Phantom"
goto menu

:exit
echo.
echo 👋 ¡Hasta pronto!
echo.
echo 💡 Recuerda: Tienes un acceso directo en el escritorio
echo    para ejecutar rápidamente en cualquier momento.
echo.
timeout /t 3 /nobreak >nul
exit