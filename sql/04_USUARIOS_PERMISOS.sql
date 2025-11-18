-- ============================
-- CREAR USUARIO REPLICATOR
-- ============================
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'replicator123';

-- ============================
-- CREAR USUARIO APLICACION
-- ============================
CREATE USER app_user WITH ENCRYPTED PASSWORD 'app_password123';

-- ============================
-- OTORGAR PERMISOS
-- ============================
GRANT CONNECT ON DATABASE sistema_db_geografico_tec TO replicator;
GRANT CONNECT ON DATABASE sistema_db_geografico_tec TO app_user;

-- Permisos para replicator (solo replicación)
GRANT USAGE ON SCHEMA public TO replicator;

-- Permisos para app_user (lectura/escritura)
GRANT USAGE ON SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO app_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO app_user;

-- Permisos por defecto para futuras tablas
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO app_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO app_user;
