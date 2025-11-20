#!/bin/bash

################################################################################
# SCRIPT: backup_completo.sh
# DESCRIPCIÓN: Realiza backup completo de PostgreSQL con rotación automática
# AUTOR: Sistema de Backups Automatizados
# FECHA: 2025-11-20
################################################################################

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════════════════
export PGPASSWORD='admin123'
DB_NAME="sistema_db_geografico_tec"
DB_USER="admin"
BACKUP_DIR="/backups"
LOG_DIR="/backups/logs"
LOG_FILE="${LOG_DIR}/backup_completo.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="backup_completo_${TIMESTAMP}.sql.gz"
RETENTION_DAYS=7
MAX_LOG_ENTRIES=10

# ═══════════════════════════════════════════════════════════════════════════
# FUNCIONES DE LOGGING
# ═══════════════════════════════════════════════════════════════════════════
log_message() {
    local level=$1
    shift
    local message="$@"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    log_message "INFO" "$@"
}

log_success() {
    log_message "SUCCESS" "$@"
}

log_error() {
    log_message "ERROR" "$@"
}

log_warning() {
    log_message "WARNING" "$@"
}

# ═══════════════════════════════════════════════════════════════════════════
# FUNCIONES AUXILIARES
# ═══════════════════════════════════════════════════════════════════════════
check_disk_space() {
    local available=$(df -m /backups | awk 'NR==2 {print $4}')
    if [ ${available} -lt 500 ]; then
        log_warning "Espacio en disco bajo: ${available} MB disponibles"
        return 1
    fi
    log_info "Espacio disponible: ${available} MB"
    return 0
}

human_readable_size() {
    local size_kb=$1
    if [ ${size_kb} -lt 1024 ]; then
        echo "${size_kb} KB"
    else
        echo "$((size_kb / 1024)) MB"
    fi
}

rotate_log() {
    if [ -f "${LOG_FILE}" ]; then
        local line_count=$(wc -l < "${LOG_FILE}")
        if [ ${line_count} -gt 1000 ]; then
            log_info "Rotando archivo de log (${line_count} líneas)"
            tail -n 500 "${LOG_FILE}" > "${LOG_FILE}.tmp"
            mv "${LOG_FILE}.tmp" "${LOG_FILE}"
        fi
    fi
}

# ═══════════════════════════════════════════════════════════════════════════
# PREPARACIÓN
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "Iniciando backup completo de PostgreSQL"
log_info "Base de datos: ${DB_NAME}"
log_info "═══════════════════════════════════════════════════════════════"

# Crear directorios si no existen
mkdir -p ${BACKUP_DIR}
mkdir -p ${LOG_DIR}

# Verificar espacio en disco
if ! check_disk_space; then
    log_error "Espacio insuficiente en disco. Backup cancelado."
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
# REALIZAR BACKUP
# ═══════════════════════════════════════════════════════════════════════════
log_info "Generando backup: ${BACKUP_FILE}"

# Ejecutar pg_dump con compresión
if pg_dump -U ${DB_USER} -d ${DB_NAME} --verbose 2>> "${LOG_FILE}" | gzip > "${BACKUP_DIR}/${BACKUP_FILE}"; then
    
    # Verificar que el archivo se creó correctamente
    if [ -f "${BACKUP_DIR}/${BACKUP_FILE}" ]; then
        # Obtener tamaño del archivo
        size_bytes=$(stat -c%s "${BACKUP_DIR}/${BACKUP_FILE}" 2>/dev/null || stat -f%z "${BACKUP_DIR}/${BACKUP_FILE}" 2>/dev/null || echo "0")
        size_kb=$((size_bytes / 1024))
        size_readable=$(human_readable_size ${size_kb})
        
        log_success "Backup completado exitosamente: ${BACKUP_FILE} (${size_readable})"
        
        # Verificar integridad básica del archivo comprimido
        if gzip -t "${BACKUP_DIR}/${BACKUP_FILE}" 2>/dev/null; then
            log_success "Verificación de integridad: OK"
        else
            log_error "Advertencia: El archivo comprimido podría estar corrupto"
        fi
    else
        log_error "El archivo de backup no se creó correctamente"
        exit 1
    fi
else
    log_error "Error al ejecutar pg_dump"
    log_error "Código de salida: $?"
    exit 1
fi

# ═══════════════════════════════════════════════════════════════════════════
# ROTACIÓN DE BACKUPS (Eliminar backups antiguos)
# ═══════════════════════════════════════════════════════════════════════════
log_info "Iniciando rotación de backups (retención: ${RETENTION_DAYS} días)"

# Contar backups antes de la limpieza
backups_before=$(find ${BACKUP_DIR} -name "backup_completo_*.sql.gz" -type f | wc -l)

# Eliminar backups más antiguos que RETENTION_DAYS
deleted_count=0
while IFS= read -r old_backup; do
    if [ -n "${old_backup}" ]; then
        log_info "Eliminando backup antiguo: $(basename ${old_backup})"
        rm -f "${old_backup}"
        ((deleted_count++))
    fi
done < <(find ${BACKUP_DIR} -name "backup_completo_*.sql.gz" -type f -mtime +${RETENTION_DAYS})

if [ ${deleted_count} -gt 0 ]; then
    log_success "Rotación completada: ${deleted_count} backup(s) antiguo(s) eliminado(s)"
else
    log_info "No hay backups antiguos para eliminar"
fi

backups_after=$(find ${BACKUP_DIR} -name "backup_completo_*.sql.gz" -type f | wc -l)
log_info "Total de backups actuales: ${backups_after}"

# ═══════════════════════════════════════════════════════════════════════════
# RESUMEN Y ESTADÍSTICAS
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "RESUMEN DEL BACKUP"
log_info "═══════════════════════════════════════════════════════════════"

# Calcular espacio total usado por backups
total_size=0
while IFS= read -r backup; do
    size=$(stat -c%s "${backup}" 2>/dev/null || stat -f%z "${backup}" 2>/dev/null || echo "0")
    total_size=$((total_size + size))
done < <(find ${BACKUP_DIR} -name "backup_completo_*.sql.gz" -type f)

total_size_kb=$((total_size / 1024))
total_size_readable=$(human_readable_size ${total_size_kb})

log_info "Backups totales: ${backups_after}"
log_info "Espacio total usado: ${total_size_readable}"
log_info "Archivo más reciente: ${BACKUP_FILE}"

# Listar últimos 5 backups
log_info "Últimos 5 backups:"
find ${BACKUP_DIR} -name "backup_completo_*.sql.gz" -type f -printf "%T@ %p\n" | \
    sort -rn | head -5 | while read timestamp filepath; do
    filename=$(basename "${filepath}")
    size=$(stat -c%s "${filepath}" 2>/dev/null || stat -f%z "${filepath}" 2>/dev/null || echo "0")
    size_kb=$((size / 1024))
    size_readable=$(human_readable_size ${size_kb})
    log_info "  - ${filename} (${size_readable})"
done

# ═══════════════════════════════════════════════════════════════════════════
# FINALIZACIÓN
# ═══════════════════════════════════════════════════════════════════════════
rotate_log

log_info "═══════════════════════════════════════════════════════════════"
log_success "Proceso de backup completado exitosamente"
log_info "═══════════════════════════════════════════════════════════════"

# Limpiar variable de contraseña
unset PGPASSWORD

exit 0