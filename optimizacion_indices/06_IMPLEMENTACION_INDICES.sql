-- -- --------------------------------------------------------
-- 06_IMPLEMENTACION_INDICES.sql
-- Creación sistemática de índices para optimización
-- --------------------------------------------------------

-- ============================================
-- ÍNDICES B-TREE (búsquedas exactas y rangos)
-- ============================================

-- Índice en horario.id_aula (FK muy consultada)
CREATE INDEX idx_horario_aula
ON horario(id_aula);

-- Índice en horario.dia
CREATE INDEX idx_horario_dia
ON horario(dia);

-- Índice en horario por rango de horas
CREATE INDEX idx_horario_hora_inicio
ON horario(hora_inicio);

-- Índice en matricula.id_estudiante
CREATE INDEX idx_matricula_estudiante
ON matricula(id_estudiante);

-- Índice en matricula.id_horario
CREATE INDEX idx_matricula_horario
ON matricula(id_horario);

-- Índice para acelerar búsquedas de horarios por profesor
CREATE INDEX idx_horario_profesor
ON horario(id_profesor);

-- ============================================
-- ÍNDICES MULTICOLUMNA
-- ============================================

-- Índice compuesto: aula + día (para buscar disponibilidad)
CREATE INDEX idx_horario_aula_dia
ON horario(id_aula, dia);

-- Índice compuesto: día + hora (para buscar franjas horarias)
CREATE INDEX idx_horario_dia_hora
ON horario(dia, hora_inicio, hora_fin);

-- Índice compuesto: profesor + curso
CREATE INDEX idx_horario_profesor_curso
ON horario(id_profesor, id_curso);

-- ============================================
-- ÍNDICES ESPACIALES GiST (geometrías)
-- ============================================

-- Índice espacial en aulas
CREATE INDEX idx_aula_geom
ON aula USING GIST(geom);

-- Índice espacial en edificios
CREATE INDEX idx_edificio_geom
ON edificio USING GIST(geom);

-- ============================================
-- ÍNDICES PARCIALES (subconjuntos específicos)
-- ============================================

-- Solo horarios de Lunes (si se consultan mucho)
CREATE INDEX idx_horario_lunes
ON horario(id_aula, hora_inicio)
WHERE dia = 'Lunes';

-- Solo aulas tipo Laboratorio
CREATE INDEX idx_aula_laboratorio
ON aula(capacidad)
WHERE tipo = 'Laboratorio';


----------------------------------------
-- Borrar los índices para hacer pruebas
----------------------------------------

-- DROP INDEX IF EXISTS
--     idx_horario_aula,
--     idx_horario_dia,
--     idx_horario_hora_inicio,
--     idx_matricula_estudiante,
--     idx_matricula_horario,
--     idx_horario_aula_dia,
--     idx_horario_dia_hora,
--     idx_horario_profesor_curso,
--     idx_aula_geom,
--     idx_edificio_geom,
--     idx_horario_lunes,
--     idx_aula_laboratorio;