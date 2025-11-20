# Sistema Geoespacial de Aulas ITCR

Este documento explica cómo usar el sistema de replicación PostgreSQL con Docker y cómo configurar PostGIS manualmente.

---

## Configuración con Docker Compose

Esta es la forma **recomendada** de levantar el sistema. Incluye:

- 2 servidores PostgreSQL 16 + PostGIS 3.4
- Replicación streaming automática (primario → réplica)
- Base de datos precargada con tablas, datos y permisos

---

### Levantar el Sistema Completo

#### Requisitos Previos

- **Docker Desktop** instalado y corriendo
- **PowerShell** (Windows) o terminal compatible

#### Comando para Iniciar

```powershell
docker-compose up -d
```

#### ¿Qué sucede al ejecutar este comando?

1. **Se crea contenedor primario**: PostgreSQL 16 + PostGIS en puerto `5432`
2. **Se crea contenedor réplica**: Copia sincronizada en puerto `5433`
3. **Carga automática**:
   - Base de datos: `sistema_db_geografico_tec`
   - Tablas de estudiantes, aulas, edificios
   - Datos de 12 estudiantes + ubicaciones geoespaciales
   - Permisos y usuarios
4. **Inicia replicación streaming**: Sincronización en tiempo real

**Tiempo esperado:** 2-3 minutos

#### Verificación

```powershell
# Ver estado de ambos servidores
docker-compose ps
```

Ambos deben aparecer en estado `running`.

---

### Acceso a los Servidores

| Servidor     | Host      | Puerto | Usuario | Contraseña | Acceso            |
| ------------ | --------- | ------ | ------- | ---------- | ----------------- |
| **Primario** | localhost | 5432   | admin   | admin123   | Lectura/Escritura |
| **Réplica**  | localhost | 5433   | admin   | admin123   | Solo Lectura      |

#### Explicación

- **El PRIMARIO** acepta `INSERT`, `UPDATE`, `DELETE` (escritura completa)
- **La RÉPLICA** solo acepta `SELECT` (lectura) - sincronización automática desde primario
- **Ambos tienen la misma BD:** `sistema_db_geografico_tec`

#### Usuarios Especiales

- **`replicator`**: Usuario interno para replicación (no usar manualmente)
- **`app_user`**: Usuario para aplicaciones QGIS/Python
  - Permisos: `SELECT`, `INSERT`, `UPDATE`, `DELETE`
  - Password: `app_password123`

---

### Conectarse desde Python/QGIS

#### OPCIÓN 1: Primario (para escritura de datos)

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="sistema_db_geografico_tec",
    user="app_user",
    password="app_password123"
)

# Puedes hacer INSERT, UPDATE, DELETE, SELECT
cursor = conn.cursor()
cursor.execute("SELECT * FROM estudiantes LIMIT 5;")
print(cursor.fetchall())
conn.close()
```

#### OPCIÓN 2: Réplica (para consultas pesadas - lectura)

```python
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port=5433,
    database="sistema_db_geografico_tec",
    user="app_user",
    password="app_password123"
)

# Solo SELECT (read-only)
cursor = conn.cursor()
cursor.execute("SELECT * FROM estudiantes LIMIT 5;")
print(cursor.fetchall())
conn.close()
```

#### OPCIÓN 3: Desde QGIS

**Data Source URI:**

```
postgresql://app_user:app_password123@localhost:5432/sistema_db_geografico_tec
```

**Pasos en QGIS:**

1. Layer → Add Layer → Add PostGIS Layers
2. New Connection
3. Name: `ITCR Primario`
4. Host: `localhost`
5. Port: `5432`
6. Database: `sistema_db_geografico_tec`
7. Username: `app_user`
8. Password: `app_password123`
9. Test Connection → OK

---

### Estructura del Proyecto

```
C:\Users\Daniel\Dev\Bases\Proyecto3Bases2/
├── docker-compose.yml          ← 2 servidores PostgreSQL
├── .env                         ← Credenciales (no en git)
│
├── sql/                         ← Scripts de inicialización
│   ├── 01_CREACION_TABLAS.sql
│   ├── 02_INSERCION_DATOS.sql
│   ├── 03_VISTAS.sql
│   └── 04_USUARIOS_PERMISOS.sql
│
├── scripts/                     ← Automatización
│   ├── backup_completo.sh
│   ├── backup_incremental_wal.sh
│   └── verif_integridad_backup.sh
│
├── backups/                     ← Almacenamiento de backups
│   ├── backup_completo_*.sql.gz
│   ├── archive/                 ← Archivos WAL
│   └── logs/                    ← Registros de operaciones
│
├── logs/                        ← Logs de verificación
│   └── PASO8_RESUMEN.txt
│
└── 02-Actualizaciones/
    └── 01-Ajustes_Aulas_QGis.sql
```

#### Explicación de Carpetas

- **`docker-compose.yml`**: Define 2 servicios PostgreSQL (primario y réplica)
- **`sql/`**: Scripts ejecutados automáticamente al iniciar contenedores
- **`scripts/`**: Herramientas para backup (pueden usarse manualmente)
- **`backups/`**: Datos persistentes (no se pierden si reinicias Docker)
- **`logs/`**: Evidencia de operaciones de verificación

---

### Estado Actual del Sistema

✅ **Implementado:**

- Replicación streaming configurada (primario → réplica)
- Sincronización en tiempo real (< 2 segundos)
- 2 servidores PostgreSQL 16 + PostGIS 3.4
- Usuarios con permisos específicos:
  - `replicator`: solo replicación
  - `app_user`: lectura/escritura de datos
- Backups automáticos (completos + incrementales)
- Verificación de replicación: ✅ **FUNCIONAL**
- Base de datos con 12 estudiantes sincronizados entre servidores

#### Cómo Verificar que Funciona

```powershell
# Ver estado de ambos servidores
docker-compose ps

# Conectar al primario
docker-compose exec postgres-primario psql -U admin -d sistema_db_geografico_tec

# Ver replicación activa
SELECT client_addr, state FROM pg_stat_replication;

# Conectar a réplica
docker-compose exec postgres-replica psql -U admin -d sistema_db_geografico_tec

# Verificar que es réplica (modo standby)
SELECT pg_is_in_recovery();  -- Debe retornar: t (true)
```

---

### Preguntas Frecuentes (FAQ)

**Q: ¿Cómo conecto desde QGIS?**  
R: Usa puerto `5432` (primario) con usuario `app_user` / `app_password123`

**Q: ¿Puedo escribir en la réplica?**  
R: No, intentar escribir rechazará con error "read-only transaction". Usa primario (`5432`) para escritura.

**Q: ¿Se sincronizan automáticamente los datos?**  
R: Sí, cualquier cambio en primario aparece en réplica en < 2 segundos.

**Q: ¿Se pierden los datos si apago Docker?**  
R: No, están en volúmenes persistentes. `docker-compose up -d` recupera todo.

**Q: ¿Cómo creo copias de seguridad?**  
R: Ejecuta manualmente:

```powershell
docker-compose exec postgres-primario bash /backups/scripts/backup_completo.sh
```

**Q: ¿Qué hago si un contenedor no inicia?**  
R: Revisa logs con:

```powershell
docker-compose logs postgres-primario
docker-compose logs postgres-replica
```

---

## Configuración y Preparación del Proyecto Geoespacial (con PostGIS)

Esta sección es para instalación **manual** de PostgreSQL + PostGIS (sin Docker).
Si usas Docker Compose (sección anterior), **no necesitas seguir estos pasos**.

---

## Instalación de PostGIS mediante StackBuilder

### 1. Abrir StackBuilder

Luego de instalar PostgreSQL, ejecutar:

- **Start Menu → PostgreSQL → StackBuilder**
- Seleccionar la versión instalada de PostgreSQL.

---

### 2. Seleccionar componentes

En la pantalla de categorías, ir a:

- #### Spatial Extensions

Allí seleccionar:

- #### PostGIS X.Y for PostgreSQL

_(Ejemplo: “PostGIS 3.4 for PostgreSQL 16”)_

---

### 3. Continuar y descargar

- Hacer clic en **Next**.
- StackBuilder descargará el instalador de PostGIS.

---

### 4. Ejecutar instalador de PostGIS

El instalador de PostGIS se abrirá aparte. Debe configurarse así:

✔ Aceptar términos  
✔ Mantener las rutas por defecto  
✔ Verificar que las opciones seleccionadas incluyan:

- **PostGIS**
- **pgRouting** _(si aparece)_
- **Create PostGIS Extension templates** _(opcional)_

Finalizar la instalación.

---

### 5. Verificar instalación dentro de PostgreSQL

Entrar a **pgAdmin** o a un cliente SQL y ejecutar:

```sql
SELECT * FROM pg_available_extensions WHERE name = 'postgis';
```

Si aparece en la tabla, significa que PostGIS ya está disponible en esta instancia.

---

### 6. Activar PostGIS en la base de datos específica

```sql
CREATE EXTENSION postgis CASCADE;
```

Con esto queda lista la preparación del entorno.
