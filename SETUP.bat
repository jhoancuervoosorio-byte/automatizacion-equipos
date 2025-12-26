@echo off
title INSTALADOR - AUTOMATIZACION PHANTOM
color 0B

echo.
echo ================================================
echo      INSTALADOR AUTOMATICO - v2.0
echo ================================================
echo.
echo Este instalador configurara el sistema en este PC.
echo Se creara un acceso directo en el escritorio.
echo.
pause

:: Crear directorio de trabajo
set "INSTALL_DIR=%USERPROFILE%\Documents\AutomatizacionPhantom"
echo [SETUP] Creando directorio: %INSTALL_DIR%
mkdir "%INSTALL_DIR%" 2>nul

:: Copiar archivos actuales
echo [SETUP] Copiando archivos...
xcopy /E /Y "%~dp0*" "%INSTALL_DIR%\" >nul 2>&1

:: Crear acceso directo
echo [SETUP] Creando acceso directo...
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\shortcut.vbs"
echo sLinkFile = "%USERPROFILE%\Desktop\Automatizacion Phantom.lnk" >> "%TEMP%\shortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\shortcut.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\launcher.bat" >> "%TEMP%\shortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\shortcut.vbs"
echo oLink.Description = "Automatizacion Phantom" >> "%TEMP%\shortcut.vbs"
echo oLink.IconLocation = "%SystemRoot%\System32\SHELL32.dll,165" >> "%TEMP%\shortcut.vbs"
echo oLink.Save >> "%TEMP%\shortcut.vbs"
cscript //nologo "%TEMP%\shortcut.vbs" >nul
del "%TEMP%\shortcut.vbs" >nul

:: Verificar Python
echo.
echo [PYTHON] Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python no encontrado
    echo.
    echo [INFO] Descarga e instala Python desde:
    echo        https://www.python.org/downloads/
    echo [IMPORTANTE] Marca 'Add Python to PATH'
) else (
    python --version
    echo [OK] Python instalado
)

:: Instalar dependencias
echo.
echo [PYTHON] Instalando dependencias...
pip install asyncssh requests python-dotenv >nul 2>&1
if errorlevel 1 (
    echo [INFO] Intentando con pip3...
    pip3 install asyncssh requests python-dotenv >nul 2>&1
)

:: Crear estructura de carpetas
echo [SETUP] Creando carpetas del sistema...
mkdir "%INSTALL_DIR%\backups_macs" 2>nul
mkdir "%INSTALL_DIR%\logs" 2>nul
mkdir "%INSTALL_DIR%\scripts_phantom_nuevos" 2>nul
mkdir "%INSTALL_DIR%\scripts_phantom" 2>nul

:: Crear archivos basicos si no existen
if not exist "%INSTALL_DIR%\.env" (
    echo [SETUP] Creando archivo .env...
    echo # Credenciales del portal ISP > "%INSTALL_DIR%\.env"
    echo ISP_USERNAME=tu_usuario@ejemplo.com >> "%INSTALL_DIR%\.env"
    echo ISP_PASSWORD=tu_contrasena >> "%INSTALL_DIR%\.env"
    echo PORTAL_URL=https://isp.somosinternet.com >> "%INSTALL_DIR%\.env"
    echo MAC_FILE_PATH=macs.txt >> "%INSTALL_DIR%\.env"
)

if not exist "%INSTALL_DIR%\config_rangos.json" (
    echo [SETUP] Creando config_rangos.json...
    echo { > "%INSTALL_DIR%\config_rangos.json"
    echo     "PhantomNuevo_IP": "192.168.1.1", >> "%INSTALL_DIR%\config_rangos.json"
    echo     "PhantomReintegro_Base": "192.168.10.", >> "%INSTALL_DIR%\config_rangos.json"
    echo     "PhantomReintegro_Inicio": 212, >> "%INSTALL_DIR%\config_rangos.json"
    echo     "PhantomReintegro_Fin": 215 >> "%INSTALL_DIR%\config_rangos.json"
    echo } >> "%INSTALL_DIR%\config_rangos.json"
)

:: Mensaje final
echo.
echo ================================================
echo         INSTALACION COMPLETADA
echo ================================================
echo.
echo [OK] Directorio instalado: %INSTALL_DIR%
echo [OK] Acceso directo creado en el escritorio
echo [OK] Estructura de carpetas creada
echo [OK] Archivos de configuracion creados
echo.
echo [SIGUIENTES PASOS]
echo 1. Ejecuta el acceso directo del escritorio
echo 2. Ve a 'Configurar Sistema' (opcion 3)
echo 3. Edita el archivo .env con tus credenciales
echo 4. Listo para usar!
echo.
pause

:: Preguntar si ejecutar ahora
echo.
set /p "run_now=Ejecutar Automatizacion Phantom ahora? (s/n): "
if /i "%run_now%"=="s" (
    cd /d "%INSTALL_DIR%"
    start "" "launcher.bat"
)

exit
