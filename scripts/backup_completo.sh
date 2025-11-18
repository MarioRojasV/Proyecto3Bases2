#!/bin/bash

BACKUP_DIR=/backups
TIMESTAMP=\$(date +%Y%m%d_%H%M%S)
BACKUP_FILE=\$BACKUP_DIR/backup_completo_\$TIMESTAMP.sql.gz

mkdir -p \$BACKUP_DIR/archive

echo "[INFO] Iniciando backup completo: \$TIMESTAMP"

pg_dump -U admin -d sistema_db_geografico_tec | gzip > \$BACKUP_FILE

if [ \$? -eq 0 ]; then
  echo "[SUCCESS] Backup completado: \$BACKUP_FILE"
  echo "[INFO] Tamaño: \$(du -h \$BACKUP_FILE | cut -f1)"
else
  echo "[ERROR] Falló el backup"
  exit 1
fi

# Limpiar backups más antiguos de 7 días
find \$BACKUP_DIR -name "backup_completo_*.sql.gz" -mtime +7 -delete
echo "[INFO] Backups antiguos eliminados"