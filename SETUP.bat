@echo off
title INSTALADOR AUTOMATICO - AUTOMATIZACION PHANTOM
color 0B

echo ╔══════════════════════════════════════════╗
echo ║      INSTALADOR AUTOMATICO - v2.0        ║
echo ╚══════════════════════════════════════════╝
echo.
echo Este instalador configurará el sistema en este PC.
echo Se creará un acceso directo en el escritorio.
echo.
pause

:: Crear directorio de trabajo
set "INSTALL_DIR=%USERPROFILE%\Documents\AutomatizacionPhantom"
echo 📂 Creando directorio: %INSTALL_DIR%
mkdir "%INSTALL_DIR%" 2>nul

:: Copiar archivos actuales
echo 📥 Copiando archivos...
xcopy /E /Y "%~dp0*" "%INSTALL_DIR%\" >nul

:: Crear acceso directo
echo 📋 Creando acceso directo...
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\shortcut.vbs"
echo sLinkFile = "%USERPROFILE%\Desktop\Automatizacion Phantom.lnk" >> "%TEMP%\shortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\shortcut.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\launcher.bat" >> "%TEMP%\shortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\shortcut.vbs"
echo oLink.Description = "Automatizacion Phantom" >> "%TEMP%\shortcut.vbs"
echo oLink.IconLocation = "%SystemRoot%\System32\SHELL32.dll,165" >> "%TEMP%\shortcut.vbs"
echo oLink.Save >> "%TEMP%\shortcut.vbs"
cscript //nologo "%TEMP%\shortcut.vbs"
del "%TEMP%\shortcut.vbs"

:: Verificar Python
echo.
echo 🐍 Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python no encontrado
    echo.
    echo 📥 Descargando Python...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe' -OutFile '%TEMP%\python-setup.exe'"
    echo.
    echo Ejecuta el instalador y marca 'Add Python to PATH'
    start "" "%TEMP%\python-setup.exe"
    echo Espera a que termine la instalación de Python...
    pause
)

:: Instalar dependencias
echo 📦 Instalando dependencias...
pip install asyncssh requests python-dotenv >nul 2>&1
if errorlevel 1 (
    echo Intentando con pip3...
    pip3 install asyncssh requests python-dotenv
)

:: Mensaje final
echo.
echo ╔══════════════════════════════════════════╗
echo ║         INSTALACION COMPLETADA           ║
echo ╚══════════════════════════════════════════╝
echo.
echo ✅ Directorio instalado: %INSTALL_DIR%
echo ✅ Acceso directo creado en el escritorio
echo ✅ Python y dependencias configuradas
echo.
echo 📝 SIGUIENTES PASOS:
echo 1. Ejecuta el acceso directo del escritorio
echo 2. Ve a 'Configurar Sistema'
echo 3. Edita el archivo .env con tus credenciales
echo 4. ¡Listo para usar!
echo.
echo 🔗 Repositorio GitHub: 
echo https://github.com/TU_USUARIO/Automatizacion-Phantom
echo.
pause

:: Ejecutar el launcher
cd /d "%INSTALL_DIR%"
call launcher.bat