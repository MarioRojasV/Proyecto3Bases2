-- ********************************************************
-- CREAR DASE DE DATOS
-- ********************************************************
CREATE DATABASE sistema_db_geografico_tec;



-- ********************************************************
-- CREAR DASE DE DATOS
-- ********************************************************
CREATE EXTENSION postgis CASCADE;

-- COMPROBAR INTEGRACIÓN EXITOSA DE LA EXTENSIÓN
SELECT postgis_version();



-- ********************************************************
-- CREACIÓN TABLAS
-- ********************************************************

-- ============================
-- TABLA: edificio
-- ============================
CREATE TABLE edificio (
    id_edificio SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    geom GEOMETRY(POINT, 4326) NOT NULL
);

-- ============================
-- TABLA: aula
-- ============================
CREATE TABLE aula (
    id_aula SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    capacidad INT,
    tipo VARCHAR(50),
    id_edificio INT REFERENCES edificio(id_edificio),
    geom GEOMETRY(POLYGON, 4326) NOT NULL
);

-- ============================
-- TABLA: profesor
-- ============================
CREATE TABLE profesor (
    id_profesor SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
	correo VARCHAR(150) NOT NULL,
	telefono VARCHAR(20),
	fecha_nacimiento DATE NOT NULL
);

-- ============================
-- TABLA: estudiante
-- ============================
CREATE TABLE estudiante (
    id_estudiante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    fecha_nacimiento DATE NOT NULL,
    carrera VARCHAR(100) NOT NULL,
	carnet VARCHAR(15) NOT NULL
);

-- ============================
-- TABLA: curso
-- ============================
CREATE TABLE curso (
    id_curso SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(20) NOT NULL
);

-- ============================
-- TABLA: horario
-- ============================
CREATE TABLE horario (
    id_horario SERIAL PRIMARY KEY,
    id_curso INT REFERENCES curso(id_curso),
    id_profesor INT REFERENCES profesor(id_profesor),
    id_aula INT REFERENCES aula(id_aula),
    dia VARCHAR(15) NOT NULL,   -- de la semana (Lunes, Martes, ...)
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

-- ============================
-- TABLA: matricula
-- (estudiantes matriculados en horarios)
-- ============================
CREATE TABLE matricula (
    id_estudiante INT REFERENCES estudiante(id_estudiante),
    id_horario INT REFERENCES horario(id_horario),
    PRIMARY KEY (id_estudiante, id_horario)
);