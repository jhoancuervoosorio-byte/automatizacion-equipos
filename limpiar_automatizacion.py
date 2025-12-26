import os
import shutil
import sys

def confirmar_accion(pregunta):
    """Pide confirmación al usuario"""
    respuesta = input(f"{pregunta} (S/N): ").upper()
    return respuesta == 'S'

def listar_archivos_py():
    """Lista todos los archivos .py en la carpeta"""
    print("\n📂 ARCHIVOS .py ENCONTRADOS:")
    print("-" * 50)
    
    archivos = []
    for archivo in os.listdir('.'):
        if archivo.endswith('.py'):
            tamaño = os.path.getsize(archivo)
            archivos.append((archivo, tamaño))
            print(f"  • {archivo:30} ({tamaño:,} bytes)")
    
    return archivos

def crear_backup(archivos):
    """Crea una carpeta de backup con los archivos"""
    backup_dir = "backup_scripts"
    
    if not os.path.exists(backup_dir):
        os.makedirs(backup_dir)
    
    print(f"\n💾 Creando backup en carpeta: {backup_dir}")
    for archivo, _ in archivos:
        try:
            shutil.copy2(archivo, os.path.join(backup_dir, archivo))
            print(f"  ✓ {archivo}")
        except:
            print(f"  ✗ {archivo} (error al copiar)")

def eliminar_archivos_temporales():
    """Elimina archivos temporales y problemáticos"""
    patrones_problematicos = [
        "*temp*.py",
        "*Temp*.py",
        "*TEMP*.py",
        "*_old.py",
        "*_backup.py",
        "*_error.py"
    ]
    
    import glob
    print("\n🗑️  BUSCANDO ARCHIVOS TEMPORALES/PROBLEMÁTICOS:")
    
    eliminados = []
    for patron in patrones_problematicos:
        for archivo in glob.glob(patron):
            try:
                os.remove(archivo)
                eliminados.append(archivo)
                print(f"  ✓ Eliminado: {archivo}")
            except:
                print(f"  ✗ Error eliminando: {archivo}")
    
    return eliminados

def conservar_archivos_esenciales():
    """Define qué archivos debemos conservar"""
    archivos_esenciales = [
        "phantom_reintegro.py",  # Tu script principal de reintegro
        "verificarMACs.py",      # Para verificar MACs
        "nuevosPhantomF2.py",    # Para nuevos dispositivos
    ]
    
    print("\n📋 ARCHIVOS ESENCIALES (se conservarán):")
    for archivo in archivos_esenciales:
        if os.path.exists(archivo):
            print(f"  • {archivo}")
        else:
            print(f"  • {archivo} (no encontrado)")
    
    return archivos_esenciales

def reorganizar_carpeta():
    """Reorganiza la carpeta en subdirectorios lógicos"""
    directorios = {
        "scripts_phantom": ["*phantom*.py", "*reintegro*.py"],
        "scripts_mac": ["*mac*.py", "*MAC*.py"],
        "scripts_utilidades": ["*check*.py", "*verif*.py", "*util*.py"],
        "backups": []  # Para backups manuales
    }
    
    print("\n📁 CREANDO ESTRUCTURA DE CARPETAS:")
    
    for directorio in directorios:
        if not os.path.exists(directorio):
            os.makedirs(directorio)
            print(f"  ✓ Carpeta creada: {directorio}/")

def main():
    print("=" * 70)
    print("           LIMPIADOR Y ORGANIZADOR DE SCRIPTS")
    print("=" * 70)
    
    # 1. Mostrar archivos actuales
    archivos = listar_archivos_py()
    
    if not archivos:
        print("\n✅ No hay archivos .py en esta carpeta.")
        return
    
    # 2. Preguntar antes de proceder
    print("\n⚠️  ADVERTENCIA: Este script ayudará a organizar tu carpeta.")
    print("   Se recomienda hacer backup primero.")
    
    if not confirmar_accion("\n¿Deseas continuar?"):
        print("Operación cancelada.")
        return
    
    # 3. Crear backup
    if confirmar_accion("\n¿Crear backup de todos los scripts?"):
        crear_backup(archivos)
    
    # 4. Eliminar temporales
    if confirmar_accion("\n¿Eliminar archivos temporales (*temp*.py, *_old.py)?"):
        eliminados = eliminar_archivos_temporales()
        if eliminados:
            print(f"\n✅ Se eliminaron {len(eliminados)} archivos temporales.")
    
    # 5. Mostrar archivos esenciales
    esenciales = conservar_archivos_esenciales()
    
    # 6. Reorganizar
    if confirmar_accion("\n¿Crear estructura organizada de carpetas?"):
        reorganizar_carpeta()
    
    # 7. Mostrar resultado final
    print("\n" + "=" * 70)
    print("                    RESUMEN FINAL")
    print("=" * 70)
    
    print("\n🎯 RECOMENDACIONES PARA ORGANIZAR:")
    print("   1. phantom_reintegro.py      → Script principal de reintegro")
    print("   2. verificarMACs.py          → Para verificación de MACs")
    print("   3. nuevosPhantomF2.py        → Para nuevos dispositivos")
    print("   4. Crear menu_principal.py   → Nuevo menú unificado")
    
    print("\n📝 SIGUIENTES PASOS:")
    print("   1. Revisa la carpeta 'backup_scripts/' si necesitas recuperar algo")
    print("   2. Empezaremos con phantom_reintegro.py como base")
    print("   3. Luego crearemos un menú principal robusto")
    
    print("\n✅ Proceso completado. Tu carpeta está lista para organizar.")

if __name__ == "__main__":
    main()
    input("\nPresiona Enter para salir...")