#!/bin/bash

################################################################################
# SCRIPT: verif_integridad_backup.sh
# DESCRIPCIÓN: Verifica integridad de backups y genera reportes
# AUTOR: Sistema de Backups Automatizados
# FECHA: 2025-11-20
################################################################################

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURACIÓN
# ═══════════════════════════════════════════════════════════════════════════
BACKUP_DIR="/backups"
LOG_DIR="${BACKUP_DIR}/logs"
LOG_FILE="${LOG_DIR}/backup_verificacion.log"
REPORT_FILE="${LOG_DIR}/BACKUPS_REPORTE.txt"
ARCHIVE_DIR="${BACKUP_DIR}/archive"
MIN_DISK_SPACE_MB=500

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

format_date() {
    local timestamp=$1
    date -d "@${timestamp}" +'%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "N/A"
}

# ═══════════════════════════════════════════════════════════════════════════
# PREPARACIÓN
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "Iniciando verificación de integridad de backups"
log_info "═══════════════════════════════════════════════════════════════"

# Crear directorios si no existen
mkdir -p ${LOG_DIR}

# ═══════════════════════════════════════════════════════════════════════════
# VERIFICAR EXISTENCIA DE BACKUPS
# ═══════════════════════════════════════════════════════════════════════════
log_info "Buscando archivos de backup..."

# Contar backups completos
backup_count=$(find ${BACKUP_DIR} -maxdepth 1 -name "backup_completo_*.sql.gz" -type f 2>/dev/null | wc -l)

if [ ${backup_count} -eq 0 ]; then
    log_error "No se encontraron archivos de backup (.sql.gz)"
    log_warning "Ejecute el script backup_completo.sh para crear un backup"
    exit 1
else
    log_success "Archivos de backup encontrados: ${backup_count}"
fi

# ═══════════════════════════════════════════════════════════════════════════
# VERIFICAR INTEGRIDAD DE CADA BACKUP
# ═══════════════════════════════════════════════════════════════════════════
log_info "Verificando integridad de archivos de backup..."

backups_ok=0
backups_corrupted=0
total_lines=0

while IFS= read -r backup_file; do
    filename=$(basename "${backup_file}")
    log_info "Verificando: ${filename}"
    
    # Obtener información del archivo
    file_size=$(stat -c%s "${backup_file}" 2>/dev/null || stat -f%z "${backup_file}" 2>/dev/null || echo "0")
    file_size_kb=$((file_size / 1024))
    file_size_readable=$(human_readable_size ${file_size_kb})
    
    file_date=$(stat -c%Y "${backup_file}" 2>/dev/null || stat -f%m "${backup_file}" 2>/dev/null || echo "0")
    file_date_formatted=$(format_date ${file_date})
    
    log_info "  Tamaño: ${file_size_readable}"
    log_info "  Fecha: ${file_date_formatted}"
    
    # Verificar integridad del archivo comprimido
    if gzip -t "${backup_file}" 2>/dev/null; then
        log_success "  Integridad: ✓ OK"
        ((backups_ok++))
        
        # Contar líneas del contenido (indicador de integridad del SQL)
        line_count=$(gunzip -c "${backup_file}" 2>/dev/null | wc -l)
        log_info "  Líneas de SQL: ${line_count}"
        total_lines=$((total_lines + line_count))
        
        # Verificar que tenga contenido significativo
        if [ ${line_count} -lt 10 ]; then
            log_warning "  ⚠ Advertencia: Backup con pocas líneas (posible problema)"
        fi
    else
        log_error "  Integridad: ✗ CORRUPTO"
        log_error "  El archivo está dañado y no se puede descomprimir"
        ((backups_corrupted++))
    fi
    
    echo ""
done < <(find ${BACKUP_DIR} -maxdepth 1 -name "backup_completo_*.sql.gz" -type f 2>/dev/null | sort)

log_info "Resumen de verificación:"
log_info "  Backups correctos: ${backups_ok}"
log_info "  Backups corruptos: ${backups_corrupted}"

if [ ${backups_corrupted} -gt 0 ]; then
    log_warning "¡ADVERTENCIA! Se encontraron ${backups_corrupted} backup(s) corrupto(s)"
fi

# ═══════════════════════════════════════════════════════════════════════════
# LISTAR BACKUPS MÁS RECIENTES
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "Los 5 backups más recientes:"
log_info "═══════════════════════════════════════════════════════════════"

recent_backups=$(find ${BACKUP_DIR} -maxdepth 1 -name "backup_completo_*.sql.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -5)

if [ -n "${recent_backups}" ]; then
    echo "${recent_backups}" | while read timestamp filepath; do
        filename=$(basename "${filepath}")
        size=$(stat -c%s "${filepath}" 2>/dev/null || echo "0")
        size_kb=$((size / 1024))
        size_readable=$(human_readable_size ${size_kb})
        date_formatted=$(format_date ${timestamp%.*})
        
        log_info "  ${filename}"
        log_info "    Tamaño: ${size_readable} | Fecha: ${date_formatted}"
    done
else
    log_warning "No se encontraron backups recientes"
fi

# ═══════════════════════════════════════════════════════════════════════════
# CALCULAR ESPACIO TOTAL USADO
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_info "Estadísticas de espacio en disco"
log_info "═══════════════════════════════════════════════════════════════"

# Espacio usado por backups completos
backup_size=0
while IFS= read -r backup; do
    size=$(stat -c%s "${backup}" 2>/dev/null || echo "0")
    backup_size=$((backup_size + size))
done < <(find ${BACKUP_DIR} -maxdepth 1 -name "backup_completo_*.sql.gz" -type f)

backup_size_kb=$((backup_size / 1024))
backup_size_readable=$(human_readable_size ${backup_size_kb})

log_info "Espacio usado por backups completos: ${backup_size_readable}"

# Espacio usado por archivos WAL (si existen)
if [ -d "${ARCHIVE_DIR}" ]; then
    archive_size=0
    archive_count=$(find ${ARCHIVE_DIR} -name "wal_*.tar.gz" -type f 2>/dev/null | wc -l)
    
    if [ ${archive_count} -gt 0 ]; then
        while IFS= read -r archive; do
            size=$(stat -c%s "${archive}" 2>/dev/null || echo "0")
            archive_size=$((archive_size + size))
        done < <(find ${ARCHIVE_DIR} -name "wal_*.tar.gz" -type f)
        
        archive_size_kb=$((archive_size / 1024))
        archive_size_readable=$(human_readable_size ${archive_size_kb})
        
        log_info "Espacio usado por archivos WAL: ${archive_size_readable} (${archive_count} archivos)"
    else
        log_info "Espacio usado por archivos WAL: 0 KB (0 archivos)"
    fi
fi

# Espacio total
total_size_kb=$((backup_size_kb + archive_size_kb))
total_size_readable=$(human_readable_size ${total_size_kb})

log_info "Espacio total usado por backups: ${total_size_readable}"

# Verificar espacio disponible
available_space=$(df -m /backups 2>/dev/null | awk 'NR==2 {print $4}')
used_percent=$(df -h /backups 2>/dev/null | awk 'NR==2 {print $5}')

log_info "Espacio disponible: ${available_space} MB (${used_percent} usado)"

# Advertencia si espacio < 500MB
backup_status="ÓPTIMO"
if [ ${available_space} -lt ${MIN_DISK_SPACE_MB} ]; then
    log_warning "═══════════════════════════════════════════════════════════════"
    log_warning "¡ADVERTENCIA! Espacio en disco bajo"
    log_warning "Espacio disponible: ${available_space} MB"
    log_warning "Mínimo recomendado: ${MIN_DISK_SPACE_MB} MB"
    log_warning "Acciones sugeridas:"
    log_warning "  1. Eliminar backups antiguos manualmente"
    log_warning "  2. Aumentar el espacio del volumen Docker"
    log_warning "  3. Reducir el período de retención de backups"
    log_warning "═══════════════════════════════════════════════════════════════"
    backup_status="ADVERTENCIA - ESPACIO BAJO"
fi

# ═══════════════════════════════════════════════════════════════════════════
# GENERAR REPORTE EJECUTIVO
# ═══════════════════════════════════════════════════════════════════════════
log_info "Generando reporte ejecutivo..."

# Obtener fecha del backup más antiguo y más reciente
oldest_backup=$(find ${BACKUP_DIR} -maxdepth 1 -name "backup_completo_*.sql.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -n | head -1)
newest_backup=$(find ${BACKUP_DIR} -maxdepth 1 -name "backup_completo_*.sql.gz" -type f -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1)

if [ -n "${oldest_backup}" ]; then
    oldest_date=$(format_date ${oldest_backup%% *})
else
    oldest_date="N/A"
fi

if [ -n "${newest_backup}" ]; then
    newest_date=$(format_date ${newest_backup%% *})
else
    newest_date="N/A"
fi

# Crear reporte
cat > "${REPORT_FILE}" <<'REPORT_END'
═══════════════════════════════════════════════════════════════════════════
REPORTE EJECUTIVO DE BACKUPS - SISTEMA DB GEOGRÁFICO TEC
═══════════════════════════════════════════════════════════════════════════
REPORT_END

cat >> "${REPORT_FILE}" <<EOF

Fecha del reporte: $(date +'%Y-%m-%d %H:%M:%S')

═══════════════════════════════════════════════════════════════════════════
RESUMEN
═══════════════════════════════════════════════════════════════════════════

Total de backups:              ${backup_count}
Backups correctos:             ${backups_ok}
Backups corruptos:             ${backups_corrupted}
Archivos WAL comprimidos:      ${archive_count:-0}

═══════════════════════════════════════════════════════════════════════════
FECHAS
═══════════════════════════════════════════════════════════════════════════

Backup más antiguo:            ${oldest_date}
Backup más reciente:           ${newest_date}

═══════════════════════════════════════════════════════════════════════════
ESPACIO EN DISCO
═══════════════════════════════════════════════════════════════════════════

Backups completos:             ${backup_size_readable}
Archivos WAL:                  ${archive_size_readable:-0 KB}
Total usado:                   ${total_size_readable}
Espacio disponible:            ${available_space} MB
Porcentaje usado:              ${used_percent}

═══════════════════════════════════════════════════════════════════════════
ESTADO GENERAL
═══════════════════════════════════════════════════════════════════════════

Estado: ${backup_status}

EOF

# Agregar advertencias si hay backups corruptos
if [ ${backups_corrupted} -gt 0 ]; then
    cat >> "${REPORT_FILE}" <<EOF
⚠ ADVERTENCIAS:
  - Se detectaron ${backups_corrupted} backup(s) corrupto(s)
  - Se recomienda revisar y regenerar los backups dañados

EOF
fi

# Agregar advertencia de espacio
if [ ${available_space} -lt ${MIN_DISK_SPACE_MB} ]; then
    cat >> "${REPORT_FILE}" <<EOF
⚠ ADVERTENCIA DE ESPACIO EN DISCO:
  - Espacio disponible: ${available_space} MB
  - Mínimo recomendado: ${MIN_DISK_SPACE_MB} MB
  - Acción requerida: Liberar espacio o aumentar volumen

EOF
fi

# Listar backups recientes en el reporte
cat >> "${REPORT_FILE}" <<EOF
═══════════════════════════════════════════════════════════════════════════
ÚLTIMOS 5 BACKUPS
═══════════════════════════════════════════════════════════════════════════

EOF

if [ -n "${recent_backups}" ]; then
    echo "${recent_backups}" | while read timestamp filepath; do
        filename=$(basename "${filepath}")
        size=$(stat -c%s "${filepath}" 2>/dev/null || echo "0")
        size_kb=$((size / 1024))
        size_readable=$(human_readable_size ${size_kb})
        date_formatted=$(format_date ${timestamp%.*})
        
        echo "${filename}" >> "${REPORT_FILE}"
        echo "  Tamaño: ${size_readable} | Fecha: ${date_formatted}" >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
    done
else
    echo "No se encontraron backups" >> "${REPORT_FILE}"
fi

cat >> "${REPORT_FILE}" <<EOF

═══════════════════════════════════════════════════════════════════════════
FIN DEL REPORTE
═══════════════════════════════════════════════════════════════════════════
EOF

log_success "Reporte ejecutivo generado: ${REPORT_FILE}"

# Mostrar el reporte
log_info "═══════════════════════════════════════════════════════════════"
log_info "CONTENIDO DEL REPORTE:"
log_info "═══════════════════════════════════════════════════════════════"
cat "${REPORT_FILE}"

# ═══════════════════════════════════════════════════════════════════════════
# FINALIZACIÓN
# ═══════════════════════════════════════════════════════════════════════════
log_info "═══════════════════════════════════════════════════════════════"
log_success "Verificación de integridad completada"
log_info "Logs guardados en: ${LOG_FILE}"
log_info "Reporte guardado en: ${REPORT_FILE}"
log_info "═══════════════════════════════════════════════════════════════"

# Código de salida basado en el estado
if [ ${backups_corrupted} -gt 0 ] || [ ${available_space} -lt ${MIN_DISK_SPACE_MB} ]; then
    exit 1
else
    exit 0
fi
