#!/usr/bin/env python3
"""
MENÚ PRINCIPAL - SISTEMA DE AUTOMATIZACIÓN
Ubicación: C:\Users\Administrador\Documents\automatizacion\menu_principal.py
"""

import os
import sys
import subprocess
from pathlib import Path

# Configuración de rutas
BASE_DIR = Path(__file__).parent.absolute()
SCRIPTS_PHANTOM = BASE_DIR / "scripts_phantom"
SCRIPTS_PHANTOM_NUEVOS = BASE_DIR / "scripts_phantom nuevos"

def clear_screen():
    """Limpia la pantalla según el sistema operativo"""
    os.system('cls' if os.name == 'nt' else 'clear')

def display_header():
    """Muestra el encabezado del menú"""
    clear_screen()
    print("\n" + "="*70)
    print("           SISTEMA DE AUTOMATIZACIÓN - MENÚ PRINCIPAL")
    print("="*70)
    print(f"📂 Directorio: {BASE_DIR}")
    print("="*70)

def display_menu():
    """Muestra las opciones del menú"""
    print("\n📋 OPCIONES DISPONIBLES:")
    print("-" * 40)
    
    options = [
        ("1", "PHANTOM REINTEGRO", "Reintegrar dispositivos Phantom"),
        ("2", "PHANTOM NUEVOS", "Configurar nuevos dispositivos Phantom"),
        ("3", "VERIFICAR MACs", "Verificar y gestionar direcciones MAC"),
        ("4", "NUEVOS PHANTOM F2", "Configurar nuevos dispositivos F2"),
        ("5", "CHECK MACs AUTO", "Verificación automática de MACs"),
        ("6", "SCAN RED", "Escanear red en busca de dispositivos"),
        ("7", "GESTIÓN DE LOGS", "Ver y gestionar archivos de log"),
        ("8", "CONFIGURACIÓN", "Configurar sistema"),
        ("9", "SALIR", "Salir del sistema")
    ]
    
    for num, title, desc in options:
        print(f"   {num}. {title:20} - {desc}")

def run_script(script_name, script_path=None, script_dir=None):
    """Ejecuta un script de Python"""
    if script_path is None and script_dir is not None:
        script_path = script_dir / script_name
    elif script_path is None:
        script_path = SCRIPTS_PHANTOM / script_name
    
    if not script_path.exists():
        print(f"\n❌ ERROR: No se encuentra {script_path}")
        input("Presiona Enter para continuar...")
        return False
    
    print(f"\n🚀 Ejecutando: {script_path.name}")
    print("-" * 40)
    
    try:
        # Cambiar al directorio del script
        original_dir = os.getcwd()
        os.chdir(script_path.parent)
        
        # Ejecutar script
        result = subprocess.run(
            [sys.executable, script_path.name],
            capture_output=False,
            text=True
        )
        
        # Volver al directorio original
        os.chdir(original_dir)
        
        return result.returncode == 0
        
    except Exception as e:
        print(f"❌ Error ejecutando script: {e}")
        return False
    finally:
        input("\n🎯 Presiona Enter para volver al menú...")

def run_bat_menu(menu_bat, menu_dir):
    """Ejecuta un menú .bat"""
    if not menu_dir.exists():
        print(f"\n❌ ERROR: No se encuentra directorio {menu_dir}")
        input("Presiona Enter para continuar...")
        return False
    
    menu_path = menu_dir / menu_bat
    if not menu_path.exists():
        print(f"\n❌ ERROR: No se encuentra {menu_bat}")
        input("Presiona Enter para continuar...")
        return False
    
    print(f"\n🚀 Ejecutando: {menu_bat}")
    print("-" * 40)
    
    try:
        # Cambiar al directorio del menú
        original_dir = os.getcwd()
        os.chdir(menu_dir)
        
        # Ejecutar menú .bat
        os.system(menu_bat)
        
        # Volver al directorio original
        os.chdir(original_dir)
        
        return True
        
    except Exception as e:
        print(f"❌ Error ejecutando menú: {e}")
        return False

def manage_logs():
    """Gestiona archivos de log"""
    logs_dir = BASE_DIR / "logs"
    
    if not logs_dir.exists():
        print(f"\n📂 No existe la carpeta de logs: {logs_dir}")
        return
    
    log_files = list(logs_dir.glob("*.txt"))
    
    if not log_files:
        print("\n📭 No hay archivos de log")
        return
    
    print(f"\n📁 ARCHIVOS DE LOG ({len(log_files)}):")
    print("-" * 40)
    
    for i, log_file in enumerate(log_files, 1):
        size = log_file.stat().st_size
        modified = log_file.stat().st_mtime
        from datetime import datetime
        mod_time = datetime.fromtimestamp(modified).strftime("%Y-%m-%d %H:%M")
        print(f"   {i}. {log_file.name:30} ({size:,} bytes) - {mod_time}")
    
    print(f"\n   {len(log_files)+1}. VOLVER AL MENÚ")
    
    try:
        choice = input(f"\n   Seleccione archivo (1-{len(log_files)+1}): ").strip()
        
        if choice.isdigit():
            choice_num = int(choice)
            
            if 1 <= choice_num <= len(log_files):
                log_file = log_files[choice_num - 1]
                print(f"\n📄 CONTENIDO DE {log_file.name}:")
                print("-" * 60)
                
                try:
                    with open(log_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                        print(content[-2000:] if len(content) > 2000 else content)
                except:
                    print("❌ Error leyendo archivo")
            
            elif choice_num == len(log_files) + 1:
                return
        
    except:
        pass

def system_configuration():
    """Configuración del sistema"""
    print("\n⚙️  CONFIGURACIÓN DEL SISTEMA")
    print("-" * 40)
    
    config_options = [
        ("1", "Verificar estructura de carpetas"),
        ("2", "Verificar scripts disponibles"),
        ("3", "Verificar conexión SSH"),
        ("4", "Verificar firmware Phantom"),
        ("5", "Verificar firmware Phantom Nuevos"),
        ("6", "Limpiar logs antiguos"),
        ("7", "Volver al menú principal")
    ]
    
    for num, desc in config_options:
        print(f"   {num}. {desc}")
    
    choice = input(f"\n   Seleccione opción (1-7): ").strip()
    
    if choice == "1":
        print(f"\n📁 ESTRUCTURA DE CARPETAS:")
        print(f"   • {BASE_DIR}/")
        print(f"   • {SCRIPTS_PHANTOM}/")
        print(f"   • {SCRIPTS_PHANTOM_NUEVOS}/")
        print(f"   • {BASE_DIR}/logs/")
        
        # Verificar si existen
        folders = [
            (BASE_DIR, "Directorio principal"),
            (SCRIPTS_PHANTOM, "Scripts Phantom Reintegro"),
            (SCRIPTS_PHANTOM_NUEVOS, "Scripts Phantom Nuevos"),
            (BASE_DIR / "logs", "Logs del sistema")
        ]
        
        for folder, desc in folders:
            status = "✅ EXISTE" if folder.exists() else "❌ NO EXISTE"
            print(f"      {desc:25} - {status}")
    
    elif choice == "2":
        print(f"\n📜 SCRIPTS EN {SCRIPTS_PHANTOM}:")
        scripts = list(SCRIPTS_PHANTOM.glob("*.py"))
        
        if scripts:
            for script in scripts:
                size = script.stat().st_size
                print(f"   • {script.name:25} ({size:,} bytes)")
        else:
            print("   No hay scripts en esta carpeta")
        
        print(f"\n📜 SCRIPTS EN {SCRIPTS_PHANTOM_NUEVOS}:")
        scripts_nuevos = list(SCRIPTS_PHANTOM_NUEVOS.glob("*.py"))
        
        if scripts_nuevos:
            for script in scripts_nuevos:
                size = script.stat().st_size
                print(f"   • {script.name:25} ({size:,} bytes)")
        else:
            print("   No hay scripts en esta carpeta")
    
    elif choice == "3":
        print("\n🔌 Prueba de conexión SSH")
        ip = input("   Ingrese IP para probar (ej: 192.168.10.212): ").strip()
        
        if ip:
            print(f"   Probando conexión a {ip}...")
            # Aquí podrías agregar una prueba SSH real
            print("   (Función en desarrollo)")
    
    elif choice == "4":
        firmware_file = SCRIPTS_PHANTOM / "Firmware_PHANTOM.bin"
        if firmware_file.exists():
            size = firmware_file.stat().st_size
            print(f"\n✅ FIRMWARE PHANTOM REINTEGRO:")
            print(f"   • Archivo: {firmware_file.name}")
            print(f"   • Tamaño: {size:,} bytes")
            print(f"   • Ruta: {firmware_file}")
        else:
            print(f"\n❌ NO SE ENCUENTRA FIRMWARE PHANTOM")
            print(f"   Buscado en: {firmware_file}")
    
    elif choice == "5":
        firmware_file = SCRIPTS_PHANTOM_NUEVOS / "FIMWAREPHANTOM.bin"
        if firmware_file.exists():
            size = firmware_file.stat().st_size
            print(f"\n✅ FIRMWARE PHANTOM NUEVOS:")
            print(f"   • Archivo: {firmware_file.name}")
            print(f"   • Tamaño: {size:,} bytes")
            print(f"   • Ruta: {firmware_file}")
        else:
            print(f"\n❌ NO SE ENCUENTRA FIRMWARE PHANTOM NUEVOS")
            print(f"   Buscado en: {firmware_file}")
            print(f"   Buscar archivo: FIMWAREPHANTOM.bin")
    
    elif choice == "6":
        print("\n🗑️  Limpieza de logs")
        # Aquí podrías agregar lógica para eliminar logs antiguos
        print("   (Función en desarrollo)")
    
    input("\n🎯 Presiona Enter para continuar...")

def main():
    """Función principal del menú"""
    while True:
        try:
            display_header()
            display_menu()
            
            choice = input("\n🎯 Seleccione una opción (1-9): ").strip()
            
            if choice == "1":
                # Phantom Reintegro - Ejecutar menú .bat
                run_bat_menu("menu_phantom.bat", SCRIPTS_PHANTOM)
            
            elif choice == "2":
                # Phantom Nuevos - Ejecutar menú .bat o script directo
                if (SCRIPTS_PHANTOM_NUEVOS / "menu_phantom_nuevos.bat").exists():
                    run_bat_menu("menu_phantom_nuevos.bat", SCRIPTS_PHANTOM_NUEVOS)
                elif (SCRIPTS_PHANTOM_NUEVOS / "phantom.py").exists():
                    run_script("phantom.py", script_dir=SCRIPTS_PHANTOM_NUEVOS)
                else:
                    print(f"\n❌ No se encuentra phantom.py en {SCRIPTS_PHANTOM_NUEVOS}")
                    input("Presiona Enter para continuar...")
            
            elif choice == "3":
                # Verificar MACs
                macs_script = BASE_DIR / "verificarMACs.py"
                if macs_script.exists():
                    run_script("verificarMACs.py", macs_script)
                else:
                    print(f"\n❌ No se encuentra verificarMACs.py")
                    input("Presiona Enter para continuar...")
            
            elif choice == "4":
                # Nuevos Phantom F2
                f2_script = BASE_DIR / "nuevosPhantomF2.py"
                if f2_script.exists():
                    run_script("nuevosPhantomF2.py", f2_script)
                else:
                    print(f"\n❌ No se encuentra nuevosPhantomF2.py")
                    input("Presiona Enter para continuar...")
            
            elif choice == "5":
                # Check MACs Auto
                check_script = BASE_DIR / "CheckMacs_AutoDelete.py"
                if check_script.exists():
                    run_script("CheckMacs_AutoDelete.py", check_script)
                else:
                    print(f"\n❌ No se encuentra CheckMacs_AutoDelete.py")
                    input("Presiona Enter para continuar...")
            
            elif choice == "6":
                print("\n🔍 Función de escaneo de red")
                print("   (En desarrollo)")
                input("Presiona Enter para continuar...")
            
            elif choice == "7":
                manage_logs()
            
            elif choice == "8":
                system_configuration()
            
            elif choice == "9":
                print("\n👋 ¡Hasta pronto!")
                print("="*70)
                sys.exit(0)
            
            else:
                print(f"\n❌ Opción '{choice}' no válida")
                input("Presiona Enter para continuar...")
                
        except KeyboardInterrupt:
            print("\n\n👋 Menú interrumpido por el usuario")
            sys.exit(0)
        except Exception as e:
            print(f"\n❌ Error en el menú: {e}")
            input("Presiona Enter para continuar...")

if __name__ == "__main__":
    # Verificar que estamos en el directorio correcto
    if not BASE_DIR.exists():
        print(f"❌ Error: No se puede acceder a {BASE_DIR}")
        input("Presiona Enter para salir...")
        sys.exit(1)
    
    # Ejecutar menú principal
    main()