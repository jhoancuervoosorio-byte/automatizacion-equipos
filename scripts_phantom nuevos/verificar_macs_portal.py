# verificar_macs_portal.py - CON REINTENTOS DE LOGIN
import os
import shutil
import requests
import time
from bs4 import BeautifulSoup
from dotenv import load_dotenv

# =========================
# CONFIGURACIÓN
# =========================
# Cargar variables desde .env en la ruta específica
env_path = r"C:\Users\Administrador\Documents\automatizacion\.env"
load_dotenv(dotenv_path=env_path)

# Variables del portal ISP
USERNAME = os.getenv("ISP_USERNAME")
PASSWORD = os.getenv("ISP_PASSWORD")
PORTAL_URL = os.getenv("PORTAL_URL")
MAC_FILE_PATH = os.getenv("MAC_FILE_PATH")

# Configuración de reintentos
MAX_LOGIN_ATTEMPTS = 3
LOGIN_RETRY_DELAY = 5  # segundos

# Si MAC_FILE_PATH es relativo, convertirlo a absoluto
if not os.path.isabs(MAC_FILE_PATH):
    MAC_FILE_PATH = os.path.join(r"C:\Users\Administrador\Documents\automatizacion", MAC_FILE_PATH)

LOGIN_URL = f"{PORTAL_URL}/admin/login/"
MAC_SEARCH_URL = f"{PORTAL_URL}/admin/config/device/?q="

# =========================
# FUNCIONES
# =========================
def normalize_mac(mac):
    """Normaliza la MAC eliminando espacios, puntos, guiones y convirtiendo a mayúsculas."""
    if not mac:
        return ""
    return mac.replace(" ", "").replace("-", "").replace(":", "").replace(".", "").strip().upper()

def read_and_clean_macs():
    """Lee el archivo de MACs, limpia duplicados y hace backup."""
    try:
        print(f"📖 Leyendo archivo: {MAC_FILE_PATH}")
        
        # Verificar si el archivo existe
        if not os.path.exists(MAC_FILE_PATH):
            raise FileNotFoundError(f"El archivo {MAC_FILE_PATH} no existe")
        
        # Leer todas las líneas
        with open(MAC_FILE_PATH, 'r', encoding='utf-8') as file:
            original_lines = [line.strip() for line in file if line.strip()]
        
        if not original_lines:
            raise ValueError("El archivo de MACs está vacío")
        
        print(f"📊 Líneas leídas: {len(original_lines)}")
        
        # Procesar MACs
        processed_data = []
        seen_macs = set()
        duplicates = 0
        
        for line in original_lines:
            # Extraer MAC (primer elemento antes del espacio)
            parts = line.split()
            if parts:
                raw_mac = parts[0].strip()
                normalized_mac = normalize_mac(raw_mac)
                
                # Verificar si es una MAC válida (12 caracteres hex)
                if len(normalized_mac) == 12 and all(c in '0123456789ABCDEF' for c in normalized_mac):
                    if normalized_mac not in seen_macs:
                        seen_macs.add(normalized_mac)
                        # Mantener la línea original (MAC + cualquier comentario)
                        processed_data.append(line)
                    else:
                        duplicates += 1
                        print(f"  ⚠️  Duplicado eliminado: {raw_mac}")
                else:
                    print(f"  ⚠️  Formato MAC inválido: {raw_mac}")
                    processed_data.append(line)  # Mantener línea aunque tenga formato inválido
        
        print(f"📊 MACs únicas: {len(processed_data)}, Duplicados: {duplicates}")
        
        # Crear backup
        backup_path = MAC_FILE_PATH + ".backup"
        shutil.copy2(MAC_FILE_PATH, backup_path)
        print(f"💾 Backup creado: {backup_path}")
        
        # Reescribir archivo limpio
        with open(MAC_FILE_PATH, 'w', encoding='utf-8') as file:
            file.write("\n".join(processed_data))
        
        print("✅ Archivo de MACs limpiado exitosamente")
        
        # Devolver MACs normalizadas para búsqueda
        macs_to_check = []
        for line in processed_data:
            parts = line.split()
            if parts:
                macs_to_check.append(normalize_mac(parts[0]))
        
        return macs_to_check, processed_data
        
    except Exception as e:
        print(f"❌ Error procesando MACs: {e}")
        return [], []

def login_session():
    """Inicia sesión y devuelve la sesión autenticada (sin reintentos)."""
    try:
        session = requests.Session()
        session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        
        print(f"🔐 Conectando a: {LOGIN_URL}")
        
        # 1. Obtener página de login para capturar csrfmiddlewaretoken
        resp = session.get(LOGIN_URL, timeout=10)
        
        if resp.status_code != 200:
            print(f"❌ Error al cargar login page: {resp.status_code}")
            return None
        
        soup = BeautifulSoup(resp.text, "html.parser")
        csrf_input = soup.find("input", {"name": "csrfmiddlewaretoken"})
        
        if not csrf_input:
            print("❌ No se encontró csrfmiddlewaretoken en la página")
            return None
        
        csrf_token = csrf_input["value"]
        print(f"✅ CSRF token obtenido")
        
        # 2. Enviar POST para iniciar sesión
        payload = {
            "username": USERNAME,
            "password": PASSWORD,
            "csrfmiddlewaretoken": csrf_token,
            "next": "/admin/"
        }
        
        headers = {
            "Referer": LOGIN_URL,
            "Origin": PORTAL_URL
        }
        
        login_resp = session.post(LOGIN_URL, data=payload, headers=headers, timeout=10)
        
        # Verificar login exitoso
        if login_resp.status_code == 200:
            if "logout" in login_resp.text.lower() or "cerrar sesión" in login_resp.text.lower():
                print("✅ Login correcto - Sesión iniciada")
                return session
            else:
                print("❌ Login fallido - Credenciales incorrectas o portal inaccesible")
                return None
        else:
            print(f"❌ Error HTTP en login: {login_resp.status_code}")
            return None
            
    except requests.exceptions.Timeout:
        print("❌ Timeout al intentar conectar con el portal")
        return None
    except requests.exceptions.ConnectionError:
        print("❌ Error de conexión - Verifica la URL y tu conexión a internet")
        return None
    except Exception as e:
        print(f"❌ Error inesperado en login: {e}")
        return None

def login_session_with_retry(max_attempts=3, retry_delay=5):
    """Inicia sesión con reintentos automáticos."""
    print(f"\n🔄 CONFIGURACIÓN DE REINTENTOS: {max_attempts} intentos")
    print("=" * 50)
    
    for attempt in range(1, max_attempts + 1):
        print(f"\n🔄 INTENTO {attempt}/{max_attempts}")
        print("-" * 30)
        
        session = login_session()
        
        if session:
            print(f"✅ Login exitoso en el intento {attempt}")
            return session
        elif attempt < max_attempts:
            print(f"⏳ Login fallido. Reintentando en {retry_delay} segundos...")
            for i in range(retry_delay, 0, -1):
                print(f"   {i}...", end="\r")
                time.sleep(1)
            print("   ¡Reintentando ahora!     ")
        else:
            print(f"❌ Login fallido después de {max_attempts} intentos")
    
    return None

def validate_mac_request(session, mac):
    """Consulta la MAC y valida si existe en la tabla."""
    try:
        # Formatear MAC para búsqueda (con guiones)
        formatted_mac = ':'.join([mac[i:i+2] for i in range(0, 12, 2)])
        url = MAC_SEARCH_URL + formatted_mac
        
        print(f"  🔍 Buscando: {formatted_mac}...")
        
        resp = session.get(url, timeout=10)
        
        if resp.status_code != 200:
            print(f"  ❌ Error HTTP {resp.status_code} al buscar MAC")
            return "error"
        
        soup = BeautifulSoup(resp.text, "html.parser")
        
        # Buscar tabla de resultados
        table = soup.find("table", class_="table")
        if not table:
            # Intentar buscar cualquier tabla
            table = soup.find("table")
        
        if not table:
            print(f"  ❌ MAC no encontrada (sin tabla): {formatted_mac}")
            return "not_found"
        
        # Buscar celdas con direcciones MAC
        # Diferentes formas en que podría estar la MAC
        mac_cells = []
        
        # Buscar por clase común
        mac_cells = table.find_all("td", class_="field-mac_address")
        
        # Si no encuentra por clase, buscar por contenido
        if not mac_cells:
            all_cells = table.find_all("td")
            for cell in all_cells:
                text = cell.get_text().strip()
                if len(normalize_mac(text)) == 12:
                    mac_cells.append(cell)
        
        if not mac_cells:
            print(f"  ❌ MAC no encontrada (sin celdas MAC): {formatted_mac}")
            return "not_found"
        
        # Comparar MACs
        for cell in mac_cells:
            displayed_mac = normalize_mac(cell.get_text())
            if displayed_mac == mac:
                print(f"  ✅ MAC encontrada: {formatted_mac}")
                return True
        
        # Si llegamos aquí, la MAC no coincide
        print(f"  ❌ MAC no coincide: {formatted_mac}")
        return False
        
    except requests.exceptions.Timeout:
        print(f"  ⚠️  Timeout al validar MAC: {mac}")
        return "error"
    except Exception as e:
        print(f"  ⚠️  Error validando {mac}: {e}")
        return "error"

# =========================
# MAIN
# =========================
def main():
    print("=" * 60)
    print("🔍 VERIFICADOR DE MACs EN PORTAL ISP - CON REINTENTOS")
    print("=" * 60)
    
    # 1. Limpiar y leer MACs
    macs, original_lines = read_and_clean_macs()
    if not macs:
        print("❌ No hay MACs para verificar")
        return
    
    # 2. Iniciar sesión CON REINTENTOS
    session = login_session_with_retry(max_attempts=MAX_LOGIN_ATTEMPTS, retry_delay=LOGIN_RETRY_DELAY)
    if not session:
        print("❌ No se pudo iniciar sesión después de varios intentos. Abortando.")
        return
    
    print(f"\n📋 Verificando {len(macs)} MACs en el portal...")
    
    # 3. Verificar cada MAC
    updated_lines = []
    stats = {
        "found": 0,
        "not_found": 0,
        "mismatch": 0,
        "error": 0
    }
    
    for idx, (mac, original_line) in enumerate(zip(macs, original_lines), 1):
        print(f"\n[{idx}/{len(macs)}] ", end="")
        
        result = validate_mac_request(session, mac)
        
        # Actualizar estadísticas
        if result is True:
            stats["found"] += 1
            # Mantener línea original sin cambios
            updated_lines.append(original_line)
        elif result == "not_found":
            stats["not_found"] += 1
            # Agregar etiqueta
            parts = original_line.split()
            if len(parts) > 1 and parts[1] not in ["ENCONTRADA", "NO", "ERROR"]:
                # Mantener comentarios existentes y agregar etiqueta
                updated_lines.append(f"{parts[0]} {' '.join(parts[1:])} - NO ENCONTRADA")
            else:
                updated_lines.append(f"{parts[0]} NO ENCONTRADA")
        elif result is False:
            stats["mismatch"] += 1
            parts = original_line.split()
            if len(parts) > 1 and parts[1] not in ["ENCONTRADA", "NO", "ERROR"]:
                updated_lines.append(f"{parts[0]} {' '.join(parts[1:])} - NO COINCIDE")
            else:
                updated_lines.append(f"{parts[0]} NO COINCIDE")
        else:  # error
            stats["error"] += 1
            parts = original_line.split()
            if len(parts) > 1 and parts[1] not in ["ENCONTRADA", "NO", "ERROR"]:
                updated_lines.append(f"{parts[0]} {' '.join(parts[1:])} - ERROR")
            else:
                updated_lines.append(f"{parts[0]} ERROR")
        
        # Pequeña pausa para no sobrecargar el servidor
        if idx < len(macs):
            time.sleep(1)
    
    # 4. Escribir resultados
    print(f"\n{'='*60}")
    print("📊 RESULTADOS:")
    print(f"   ✅ Encontradas: {stats['found']}")
    print(f"   ❌ No encontradas: {stats['not_found']}")
    print(f"   ⚠️  No coinciden: {stats['mismatch']}")
    print(f"   🔧 Errores: {stats['error']}")
    print(f"{'='*60}")
    
    try:
        with open(MAC_FILE_PATH, 'w', encoding='utf-8') as file:
            file.write("\n".join(updated_lines))
        print(f"💾 Archivo actualizado: {MAC_FILE_PATH}")
        
        # Crear archivo de reporte
        report_path = os.path.join(os.path.dirname(MAC_FILE_PATH), "reporte_macs.txt")
        with open(report_path, 'w', encoding='utf-8') as report:
            report.write("REPORTE DE VERIFICACIÓN DE MACs\n")
            report.write("=" * 40 + "\n")
            report.write(f"Fecha: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
            report.write(f"Total MACs verificadas: {len(macs)}\n")
            report.write(f"✅ Encontradas: {stats['found']}\n")
            report.write(f"❌ No encontradas: {stats['not_found']}\n")
            report.write(f"⚠️  No coinciden: {stats['mismatch']}\n")
            report.write(f"🔧 Errores: {stats['error']}\n")
            report.write("=" * 40 + "\n")
            for line in updated_lines:
                report.write(line + "\n")
        
        print(f"📄 Reporte generado: {report_path}")
        
    except Exception as e:
        print(f"❌ Error al guardar resultados: {e}")

if __name__ == "__main__":
    main()
    print("\n✨ Proceso completado")
    input("Presiona Enter para salir...")