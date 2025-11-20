-- ================================================================
-- CONFIGURACIÓN DE USUARIOS Y PERMISOS
-- Sistema de Información Geográfico - ITCR
-- Base de datos: sistema_db_geografico_tec
-- ================================================================

-- ================================================================
-- 1. USUARIO REPLICATOR
--    Propósito: Replicación streaming entre servidor primario y réplica
--    Permisos: Solo replicación, sin acceso a datos
-- ================================================================

-- Crear usuario replicator (idempotente)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'replicator') THEN
        CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator123';
        RAISE NOTICE 'Usuario replicator creado exitosamente';
    ELSE
        -- Actualizar contraseña si el usuario ya existe
        ALTER USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator123';
        RAISE NOTICE 'Usuario replicator ya existe - contraseña actualizada';
    END IF;
END
$$;

-- Otorgar permiso de conexión a la base de datos
GRANT CONNECT ON DATABASE sistema_db_geografico_tec TO replicator;

-- Otorgar permiso de uso del esquema public (necesario para replicación)
GRANT USAGE ON SCHEMA public TO replicator;

-- NOTA: replicator NO tiene permisos SELECT/INSERT/UPDATE/DELETE
-- Solo puede leer el WAL (Write-Ahead Log) para sincronización


-- ================================================================
-- 2. USUARIO APP_USER
--    Propósito: Aplicación QGIS y Python para consultas y modificaciones
--    Permisos: DML completo (SELECT, INSERT, UPDATE, DELETE)
-- ================================================================

-- Crear usuario app_user (idempotente)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'app_user') THEN
        CREATE USER app_user WITH ENCRYPTED PASSWORD 'app_password123';
        RAISE NOTICE 'Usuario app_user creado exitosamente';
    ELSE
        -- Actualizar contraseña si el usuario ya existe
        ALTER USER app_user WITH ENCRYPTED PASSWORD 'app_password123';
        RAISE NOTICE 'Usuario app_user ya existe - contraseña actualizada';
    END IF;
END
$$;

-- Otorgar permiso de conexión a la base de datos
GRANT CONNECT ON DATABASE sistema_db_geografico_tec TO app_user;

-- Otorgar permiso de uso del esquema public
GRANT USAGE ON SCHEMA public TO app_user;

-- Otorgar permisos DML en todas las tablas existentes
-- (SELECT, INSERT, UPDATE, DELETE - NO incluye CREATE/DROP TABLE)
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;

-- Otorgar permisos en secuencias (para SERIAL/IDENTITY columns)
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- Otorgar permisos de ejecución en funciones PostGIS y personalizadas
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_user;


-- ================================================================
-- 3. PERMISOS POR DEFECTO PARA OBJETOS FUTUROS
--    Asegurar que nuevas tablas/funciones creadas por admin
--    hereden automáticamente los permisos
-- ================================================================

-- Permisos por defecto para tablas futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

-- Permisos por defecto para secuencias futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO app_user;

-- Permisos por defecto para funciones futuras
ALTER DEFAULT PRIVILEGES IN SCHEMA public 
    GRANT EXECUTE ON FUNCTIONS TO app_user;


-- ================================================================
-- 4. SEGURIDAD ADICIONAL
--    Configuraciones de seguridad recomendadas
-- ================================================================

-- Revocar permisos CREATE en el esquema public para usuarios no-admin
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO admin;

-- Asegurar que replicator NO tenga permisos de lectura/escritura
REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM replicator;


-- ================================================================
-- RESUMEN DE PERMISOS CONFIGURADOS
-- ================================================================
-- 
-- USUARIO: admin
--   - SUPERUSER (sin cambios)
--   - Control total sobre la base de datos
--
-- USUARIO: replicator
--   - CONNECT a sistema_db_geografico_tec
--   - USAGE en esquema public
--   - REPLICATION (streaming)
--   - NO puede leer/escribir datos
--
-- USUARIO: app_user
--   - CONNECT a sistema_db_geografico_tec
--   - USAGE en esquema public
--   - SELECT, INSERT, UPDATE, DELETE en todas las tablas
--   - EXECUTE en todas las funciones PostGIS
--   - NO puede CREATE/DROP tablas, esquemas o bases de datos
--
-- ================================================================
