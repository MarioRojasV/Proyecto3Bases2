#!/bin/bash

################################################################################
# SCRIPT: backup_incremental_wal.sh
# DESCRIPCIÓN: Gestiona archivos WAL para backups incrementales
# AUTOR: Sistema de Backups Automatizados
# FECHA: 2025-11-20
################################################################################

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════════════════
BACKUP_DIR="/backups"
ARCHIVE_DIR="${BACKUP_DIR}/archive"
LOG_DIR="${BACKUP_DIR}/logs"
LOG_FILE="${LOG_DIR}/backup_wal.log"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
WAL_ARCHIVE="wal_${TIMESTAMP}.tar.gz"
WAL_AGE_HOURS=1
RETENTION_DAYS=3

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
human_readable_size() {
    local size_kb=$1
    if [ ${size_kb} -lt 1024 ]; then
        echo "${size_kb} KB"
    else
        local size_mb=$((size_kb / 1024))
        if [ ${size_mb} -lt 1024 ]; then
            echo "${size_mb} MB"
        else
            echo "$((size_mb / 1024)) GB"
        fi
    fi
}

get_disk_usage() {
    local dir=$1
    local usage=$(du -sk "${dir}" 2>/dev/null | cut -f1)
    if [ -z "${usage}" ]; then
        echo "0"
    else
        echo "${usage}"
    fi
}

check_disk_space() {
    local available=$(df -m /backups | awk 'NR==2 {print $4}')
    log_info "Espacio disponible en disco: ${available} MB"
    
    if [ ${available} -lt 500 ]; then
        log_warning "Espacio en disco bajo: ${available} MB disponibles"
        return 1
    fi
    return 0
}

# ═══════════════════════════════════════════════════════════════════════════
# PREPARACIÓN
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "Iniciando gestión de archivos WAL"
log_info "═══════════════════════════════════════════════════════════════"

# Crear directorio de archivo si no existe
mkdir -p ${ARCHIVE_DIR}
mkdir -p ${LOG_DIR}

# Verificar espacio en disco
check_disk_space

# ═══════════════════════════════════════════════════════════════════════════
# BUSCAR Y LISTAR ARCHIVOS WAL
# ═══════════════════════════════════════════════════════════════════════════
log_info "Buscando archivos WAL en PostgreSQL..."

# Directorio típico de archivos WAL en PostgreSQL (puede variar según configuración)
WAL_DIRS=(
    "/var/lib/postgresql/data/pg_wal"
    "/var/lib/postgresql/16/main/pg_wal"
    "${ARCHIVE_DIR}"
)

WAL_FILES_FOUND=0
WAL_SOURCE_DIR=""

for wal_dir in "${WAL_DIRS[@]}"; do
    if [ -d "${wal_dir}" ]; then
        wal_count=$(find "${wal_dir}" -name "0*" -type f 2>/dev/null | wc -l)
        if [ ${wal_count} -gt 0 ]; then
            WAL_SOURCE_DIR="${wal_dir}"
            WAL_FILES_FOUND=${wal_count}
            log_info "Directorio WAL encontrado: ${wal_dir}"
            log_info "Archivos WAL disponibles: ${wal_count}"
            break
        fi
    fi
done

if [ ${WAL_FILES_FOUND} -eq 0 ]; then
    log_warning "No se encontraron archivos WAL para archivar"
    log_info "Nota: Los archivos WAL se generan cuando hay actividad en la base de datos"
    log_info "Directorios verificados: ${WAL_DIRS[@]}"
else
    # Listar archivos WAL recientes
    log_info "Últimos 5 archivos WAL:"
    find "${WAL_SOURCE_DIR}" -name "0*" -type f -printf "%T@ %p\n" 2>/dev/null | \
        sort -rn | head -5 | while read timestamp filepath; do
        filename=$(basename "${filepath}")
        size=$(stat -c%s "${filepath}" 2>/dev/null || echo "0")
        size_kb=$((size / 1024))
        log_info "  - ${filename} (${size_kb} KB)"
    done
fi

# ═══════════════════════════════════════════════════════════════════════════
# COMPRIMIR ARCHIVOS WAL ANTIGUOS
# ═══════════════════════════════════════════════════════════════════════════
log_info "Buscando archivos WAL más antiguos de ${WAL_AGE_HOURS} hora(s)..."

# Buscar archivos WAL más antiguos de WAL_AGE_HOURS horas
OLD_WAL_FILES=$(find "${ARCHIVE_DIR}" -name "0*" -type f -mmin +$((WAL_AGE_HOURS * 60)) 2>/dev/null)
OLD_WAL_COUNT=$(echo "${OLD_WAL_FILES}" | grep -c "^" 2>/dev/null || echo "0")

if [ ${OLD_WAL_COUNT} -gt 0 ] && [ -n "${OLD_WAL_FILES}" ]; then
    log_info "Archivos WAL a comprimir: ${OLD_WAL_COUNT}"
    
    # Crear archivo temporal con la lista de archivos
    TEMP_LIST=$(mktemp)
    echo "${OLD_WAL_FILES}" > "${TEMP_LIST}"
    
    # Comprimir archivos WAL
    if tar -czf "${ARCHIVE_DIR}/${WAL_ARCHIVE}" -T "${TEMP_LIST}" 2>/dev/null; then
        # Obtener tamaño del archivo comprimido
        archive_size=$(stat -c%s "${ARCHIVE_DIR}/${WAL_ARCHIVE}" 2>/dev/null || echo "0")
        archive_size_kb=$((archive_size / 1024))
        archive_size_readable=$(human_readable_size ${archive_size_kb})
        
        log_success "Archivos WAL comprimidos: ${WAL_ARCHIVE} (${archive_size_readable})"
        
        # Eliminar archivos WAL originales después de comprimir
        while IFS= read -r wal_file; do
            if [ -f "${wal_file}" ]; then
                rm -f "${wal_file}"
            fi
        done < "${TEMP_LIST}"
        
        log_success "Archivos WAL originales eliminados (${OLD_WAL_COUNT})"
    else
        log_error "Error al comprimir archivos WAL"
    fi
    
    # Limpiar archivo temporal
    rm -f "${TEMP_LIST}"
else
    log_info "No hay archivos WAL antiguos para comprimir"
fi

# ═══════════════════════════════════════════════════════════════════════════
# ROTACIÓN DE ARCHIVOS WAL COMPRIMIDOS
# ═══════════════════════════════════════════════════════════════════════════
log_info "Iniciando rotación de archivos WAL (retención: ${RETENTION_DAYS} días)"

# Contar archivos comprimidos antes de la limpieza
archives_before=$(find ${ARCHIVE_DIR} -name "wal_*.tar.gz" -type f | wc -l)

# Eliminar archivos comprimidos más antiguos que RETENTION_DAYS
deleted_count=0
while IFS= read -r old_archive; do
    if [ -n "${old_archive}" ]; then
        log_info "Eliminando archivo WAL antiguo: $(basename ${old_archive})"
        rm -f "${old_archive}"
        ((deleted_count++))
    fi
done < <(find ${ARCHIVE_DIR} -name "wal_*.tar.gz" -type f -mtime +${RETENTION_DAYS})

if [ ${deleted_count} -gt 0 ]; then
    log_success "Rotación completada: ${deleted_count} archivo(s) WAL eliminado(s)"
else
    log_info "No hay archivos WAL antiguos para eliminar"
fi

archives_after=$(find ${ARCHIVE_DIR} -name "wal_*.tar.gz" -type f | wc -l)
log_info "Total de archivos WAL comprimidos: ${archives_after}"

# ═══════════════════════════════════════════════════════════════════════════
# ESTADÍSTICAS Y ESPACIO EN DISCO
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "ESTADÍSTICAS DE ARCHIVOS WAL"
log_info "═══════════════════════════════════════════════════════════════"

# Calcular espacio usado por archivos WAL comprimidos
archive_space=$(get_disk_usage "${ARCHIVE_DIR}")
archive_space_readable=$(human_readable_size ${archive_space})

log_info "Archivos WAL comprimidos: ${archives_after}"
log_info "Espacio usado por archivos WAL: ${archive_space_readable}"

# Listar últimos 5 archivos WAL comprimidos
if [ ${archives_after} -gt 0 ]; then
    log_info "Últimos 5 archivos WAL comprimidos:"
    find ${ARCHIVE_DIR} -name "wal_*.tar.gz" -type f -printf "%T@ %p\n" | \
        sort -rn | head -5 | while read timestamp filepath; do
        filename=$(basename "${filepath}")
        size=$(stat -c%s "${filepath}" 2>/dev/null || echo "0")
        size_kb=$((size / 1024))
        size_readable=$(human_readable_size ${size_kb})
        file_date=$(date -d "@${timestamp%.*}" +'%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "N/A")
        log_info "  - ${filename} (${size_readable}) - ${file_date}"
    done
fi

# Espacio total en disco
total_backup_space=$(get_disk_usage "${BACKUP_DIR}")
total_backup_space_readable=$(human_readable_size ${total_backup_space})

log_info "Espacio total usado por backups: ${total_backup_space_readable}"

# Verificar espacio disponible
available_space=$(df -m /backups | awk 'NR==2 {print $4}')
used_percent=$(df -h /backups | awk 'NR==2 {print $5}')

log_info "Espacio disponible: ${available_space} MB (${used_percent} usado)"

if [ ${available_space} -lt 500 ]; then
    log_warning "¡ADVERTENCIA! Espacio en disco bajo"
    log_warning "Considere eliminar backups antiguos o aumentar espacio"
fi

# ═══════════════════════════════════════════════════════════════════════════
# FINALIZACIÓN
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_success "Gestión de archivos WAL completada"
log_info "═══════════════════════════════════════════════════════════════"

exit 0
