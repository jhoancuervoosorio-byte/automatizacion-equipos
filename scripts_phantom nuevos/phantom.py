# phantom.py - CON BACKUP ACUMULATIVO DIARIO
import asyncio
import asyncssh
import time
import subprocess
import re
import os
import sys
import shutil
from datetime import datetime

# =========================
# CONFIGURACIÓN DE BACKUP
# =========================
BACKUP_DIR = r"C:\Users\Administrador\Documents\automatizacion\backups_macs"
MAC_FILE_PATH = r"C:\Users\Administrador\Documents\automatizacion\macs.txt"

def setup_backup_system():
    """Configura el sistema de backup acumulativo diario."""
    
    # Crear directorio de backups si no existe
    if not os.path.exists(BACKUP_DIR):
        os.makedirs(BACKUP_DIR)
        print(f"📁 Carpeta de backups creada: {BACKUP_DIR}")
    
    # Verificar y eliminar backups de días anteriores
    cleanup_old_backups()
    
    # Inicializar o cargar backup del día
    init_daily_backup()

def cleanup_old_backups():
    """Elimina backups de días anteriores, mantiene solo hoy."""
    try:
        hoy = datetime.now().strftime("%Y-%m-%d")
        eliminados = 0
        
        for filename in os.listdir(BACKUP_DIR):
            filepath = os.path.join(BACKUP_DIR, filename)
            
            # Solo procesar archivos .txt
            if filename.endswith('.txt'):
                # Verificar si el archivo NO es del día de hoy
                if hoy not in filename:
                    os.remove(filepath)
                    eliminados += 1
                    print(f"   🗑️  Eliminado backup antiguo: {filename}")
        
        if eliminados > 0:
            print(f"✅ Eliminados {eliminados} backups antiguos")
            
    except Exception as e:
        print(f"⚠️  Error limpiando backups: {e}")

def init_daily_backup():
    """Inicializa o carga el backup acumulativo del día."""
    try:
        # Nombre del backup del día (solo fecha)
        hoy = datetime.now().strftime("%Y-%m-%d")
        backup_name = f"macs_backup_{hoy}.txt"
        backup_path = os.path.join(BACKUP_DIR, backup_name)
        
        # Si ya existe un backup de hoy, mostrarlo
        if os.path.exists(backup_path):
            with open(backup_path, 'r', encoding='utf-8') as f:
                lineas = f.readlines()
                macs_en_backup = len([l for l in lineas if l.strip()])
            
            print(f"📊 Backup del día encontrado: {backup_name}")
            print(f"   MACs en backup: {macs_en_backup}")
        else:
            # Crear nuevo backup vacío para hoy
            with open(backup_path, 'w', encoding='utf-8') as f:
                f.write(f"# BACKUP DIARIO - {hoy}\n")
                f.write(f"# Iniciado: {datetime.now().strftime('%H:%M:%S')}\n")
                f.write("=" * 40 + "\n\n")
            
            print(f"📄 Nuevo backup creado: {backup_name}")
        
        return backup_path
        
    except Exception as e:
        print(f"❌ Error inicializando backup: {e}")
        return None

def get_daily_backup_path():
    """Obtiene la ruta del backup del día actual."""
    hoy = datetime.now().strftime("%Y-%m-%d")
    backup_name = f"macs_backup_{hoy}.txt"
    return os.path.join(BACKUP_DIR, backup_name)

def add_to_daily_backup(mac_address, device_num):
    """Agrega una MAC al backup acumulativo del día."""
    try:
        backup_path = get_daily_backup_path()
        
        # Agregar MAC al backup
        with open(backup_path, 'a', encoding='utf-8') as f:
            timestamp = datetime.now().strftime("%H:%M:%S")
            f.write(f"{mac_address}  # Equipo {device_num} - {timestamp}\n")
        
        print(f"   📝 Backup actualizado")
        return True
        
    except Exception as e:
        print(f"   ❌ Error actualizando backup: {e}")
        return False

def clear_main_mac_file():
    """Limpia el archivo macs.txt principal."""
    try:
        with open(MAC_FILE_PATH, 'w', encoding='utf-8') as f:
            f.write("")  # Archivo vacío
        print(f"🧹 Archivo principal limpiado: {MAC_FILE_PATH}")
        return True
    except Exception as e:
        print(f"❌ Error limpiando archivo principal: {e}")
        return False

# =========================
# FUNCIONES PRINCIPALES
# =========================
async def connection_device(ip, user, port, timeout, command1, command2, device_num):
    try:
        print(f"\n📱 EQUIPO {device_num} - Conectando...")
        
        async with asyncssh.connect(
            host=ip,
            username=user,
            port=port,
            login_timeout=timeout,
            options=asyncssh.SSHClientConnectionOptions(known_hosts=None)
        ) as conn:

            result = await conn.run(command1)
            output = result.stdout
            print(f"   ✅ Conectado: {output}")
            
            if result:
                await conn.run(command2)
                print(f"   🚀 Firmware enviado")
                
            return output.upper()
            
    except asyncio.TimeoutError:
        print(f"   ⏰ Timeout")
        return "Timeout"
    except asyncssh.PermissionDenied:
        print(f"   🔒 Error de autenticación")
        return "Auth Error"
    except asyncssh.Error as e:
        print(f"   ⚠️ Error SSH: {e}")
        return "SSH Connection Error"
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return "Error"

def extract_mac_address(output):
    mac = re.search(r"'([0-9a-fA-F]{2}(?::[0-9a-fA-F]{2}){5})'", output)
    if mac:
        mac_extracted = mac.group(1).upper()
        return mac_extracted
    else:
        print("   ❌ No se pudo extraer MAC")
        return False

def write_macs(mac_address, device_num):
    """Guarda MAC en archivo principal y backup."""
    try:
        # 1. Agregar al archivo principal (modo append)
        with open(MAC_FILE_PATH, "a") as file:
            file.write(mac_address + "\n")
        
        print(f"   💾 MAC guardada en principal: {mac_address}")
        
        # 2. Agregar al backup acumulativo del día
        add_to_daily_backup(mac_address, device_num)
        
        return True
        
    except Exception as e:
        print(f"   ❌ Error guardando: {e}")
        return False

def upload_file():
    try:
        print(f"   📤 Enviando firmware...")
        
        result = subprocess.run([
            "scp", 
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "-O",
            "Firmware_PHANTOM.bin",
            "root@192.168.1.1:/tmp/"
        ], capture_output=True, text=True, timeout=15)
        
        if result.returncode == 0:
            print("   ✅ Firmware enviado")
            return True
        else:
            return False
            
    except subprocess.TimeoutExpired:
        print("   ⏰ Timeout")
        return False
    except Exception:
        return False

def open_macs_file():
    """Abre el archivo macs.txt automáticamente"""
    try:
        if os.path.exists(MAC_FILE_PATH):
            print(f"\n📂 Abriendo archivo principal: {MAC_FILE_PATH}")
            os.startfile(MAC_FILE_PATH)
    except:
        pass

def show_backup_info():
    """Muestra información del backup actual."""
    try:
        backup_path = get_daily_backup_path()
        
        if os.path.exists(backup_path):
            with open(backup_path, 'r', encoding='utf-8') as f:
                lineas = f.readlines()
                # Contar líneas con MACs (excluyendo encabezados y líneas vacías)
                macs_en_backup = 0
                for linea in lineas:
                    linea_limpia = linea.strip()
                    if linea_limpia and not linea_limpia.startswith('#') and not '=' in linea_limpia:
                        # Verificar si parece una MAC
                        if len(linea_limpia.split()) > 0:
                            macs_en_backup += 1
            
            hoy = datetime.now().strftime("%Y-%m-%d")
            print(f"📊 Backup del día ({hoy}): {macs_en_backup} MACs acumuladas")
            return macs_en_backup
        
        return 0
    except:
        return 0

# =========================
# PROGRAMA PRINCIPAL
# =========================
if __name__ == "__main__":
    print("=" * 60)
    print("🎯 PHANTOM - BACKUP ACUMULATIVO DIARIO")
    print("=" * 60)
    
    # Configurar sistema de backup
    print("\n🔄 CONFIGURANDO SISTEMA DE BACKUP...")
    setup_backup_system()
    
    # Mostrar info del backup actual
    macs_acumuladas = show_backup_info()
    
    # LIMPIAR archivo principal al inicio
    print("\n🧹 LIMPIANDO ARCHIVO PRINCIPAL...")
    clear_main_mac_file()
    
    # Preguntar cantidad de equipos
    print("\n📊 CONFIGURACIÓN INICIAL")
    print("-" * 30)
    
    cantidad_equipos = 0
    while True:
        try:
            entrada = input("¿Cuántos equipos Phantom vas a procesar? (1-99): ").strip()
            
            if not entrada.isdigit():
                print("❌ Ingresa un número")
                continue
                
            cantidad = int(entrada)
            
            if cantidad < 1 or cantidad > 99:
                print("❌ Ingresa entre 1 y 99")
                continue
                
            cantidad_equipos = cantidad
            break
            
        except KeyboardInterrupt:
            print("\n🛑 Cancelado")
            sys.exit(0)
        except:
            print("❌ Error")
            continue
    
    print(f"\n🎯 INICIANDO: {cantidad_equipos} equipo(s)")
    print(f"📁 Backup diario: {get_daily_backup_path()}")
    print(f"📄 Archivo principal se reinicia cada proceso")
    print("-" * 40)
    
    # Configuración
    delay_entre_equipos = 5
    delay_entre_intentos = 3
    successful_count = 0
    failed_count = 0
    
    print(f"\n⏳ Iniciando en 3 segundos...")
    time.sleep(3)
    
    print(f"\n{'='*60}")
    print("🚀 INICIANDO PROCESO AUTOMÁTICO")
    print(f"{'='*60}")
    
    try:
        # Procesar cada equipo
        for equipo_actual in range(1, cantidad_equipos + 1):
            print(f"\n{'='*50}")
            print(f"📦 EQUIPO {equipo_actual} de {cantidad_equipos}")
            print(f"{'='*50}")
            
            # Esperar entre equipos
            if equipo_actual > 1:
                print(f"⏳ Esperando {delay_entre_equipos} segundos...")
                time.sleep(delay_entre_equipos)
            
            # Intentar hasta 3 veces por equipo
            exito_equipo = False
            
            for intento in range(1, 4):
                print(f"\n   🔄 Intento {intento}/3")
                
                if upload_file():
                    output = asyncio.run(connection_device(
                        '192.168.1.1', 'root', 22, 10, 
                        'uci show network.@device[1].macaddr',
                        'sysupgrade -n /tmp/Firmware_PHANTOM.bin',
                        equipo_actual
                    ))
                    
                    if output and "ERROR" not in output and "TIMEOUT" not in output:
                        mac = extract_mac_address(output)
                        if mac:
                            if write_macs(mac, equipo_actual):
                                successful_count += 1
                                exito_equipo = True
                            break
                
                # Esperar entre intentos fallidos
                if intento < 3 and not exito_equipo:
                    print(f"   ⏳ Reintentando en {delay_entre_intentos} segundos...")
                    time.sleep(delay_entre_intentos)
            
            if not exito_equipo:
                failed_count += 1
                print(f"   ❌ Equipo {equipo_actual} falló")
        
        # RESULTADOS FINALES
        print(f"\n{'='*60}")
        print("🎉 PROCESO COMPLETADO")
        print(f"{'='*60}")
        print(f"✅ Éxitos: {successful_count}")
        print(f"❌ Fallos: {failed_count}")
        print(f"📊 Total: {cantidad_equipos}")
        
        # Mostrar estadísticas finales
        print(f"\n📊 RESUMEN FINAL:")
        print(f"   • MACs en este proceso: {successful_count}")
        
        macs_acumuladas_final = show_backup_info()
        print(f"   • MACs acumuladas hoy: {macs_acumuladas_final}")
        
        # Abrir archivo principal automáticamente
        if successful_count > 0:
            print(f"\n📂 Abriendo archivo principal...")
            time.sleep(2)
            open_macs_file()
        
    except KeyboardInterrupt:
        print(f"\n🛑 Proceso interrumpido")
        print(f"📊 Procesados: {successful_count + failed_count}/{cantidad_equipos}")
        
        # Mostrar backup actual
        macs_acumuladas_actual = show_backup_info()
        print(f"📊 MACs acumuladas en backup: {macs_acumuladas_actual}")
    
    except Exception as e:
        print(f"\n❌ Error: {e}")
    
    finally:
        print(f"\n✨ Proceso finalizado")
        print(f"💾 Backup acumulativo: {get_daily_backup_path()}")
        print(f"📄 Archivo principal: {MAC_FILE_PATH}")
        input("Presiona Enter para salir...")