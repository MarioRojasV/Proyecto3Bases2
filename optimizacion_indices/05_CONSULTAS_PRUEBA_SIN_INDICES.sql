-- --------------------------------------------------------
-- 05_CONSULTAS_PRUEBA_SIN_INDICES.sql
-- Consultas típicas del sistema para medir rendimiento BASE
-- --------------------------------------------------------

SET enable_seqscan = off;

-- ====================
-- CONSULTA 1: Buscar horarios de un aula específica
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT h.*, c.nombre, p.nombre, a.nombre
FROM horario h
JOIN curso c ON h.id_curso = c.id_curso
JOIN profesor p ON h.id_profesor = p.id_profesor
JOIN aula a ON h.id_aula = a.id_aula
WHERE h.id_aula = 5;

-- ====================
-- CONSULTA 2: Buscar horarios por día
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT * FROM horario
WHERE dia = 'Lunes';

-- ====================
-- CONSULTA 3: Horarios en rango de tiempo
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT a.nombre, COUNT(*) as total_horarios,
       STRING_AGG(DISTINCT c.nombre, ', ') as cursos
FROM horario h
JOIN aula a ON h.id_aula = a.id_aula
JOIN curso c ON h.id_curso = c.id_curso
WHERE hora_inicio BETWEEN '07:00' AND '16:00'
GROUP BY a.nombre
HAVING COUNT(*) > 1
ORDER BY total_horarios DESC;

-- ====================
-- CONSULTA 4: Estudiantes matriculados en un curso
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT e.nombre, e.carrera, c.nombre AS curso
FROM matricula m
JOIN estudiante e ON m.id_estudiante = e.id_estudiante
JOIN horario h ON m.id_horario = h.id_horario
JOIN curso c ON h.id_curso = c.id_curso
WHERE h.id_curso = 20;

-- ====================
-- CONSULTA 5: Carga académica de un profesor
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT p.nombre AS profesor, c.nombre AS curso,
       a.nombre AS aula, h.dia, h.hora_inicio, h.hora_fin
FROM horario h
JOIN profesor p ON h.id_profesor = p.id_profesor
JOIN curso c ON h.id_curso = c.id_curso
JOIN aula a ON h.id_aula = a.id_aula
WHERE h.id_profesor = 3;

-- ====================
-- CONSULTA 6: Estudiantes y sus horarios (vista materializada potencial)
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT COUNT(*)
FROM vista_estudiantes_horarios
WHERE carrera = 'Ingeniería en Computación';

-- ====================
-- CONSULTA 7: Conflictos de horario (misma aula, mismo día, horas que se solapan)
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT h1.id_horario AS horario1, h2.id_horario AS horario2,
       a.nombre AS aula, h1.dia,
       h1.hora_inicio AS inicio1, h1.hora_fin AS fin1,
       h2.hora_inicio AS inicio2, h2.hora_fin AS fin2
FROM horario h1
JOIN horario h2 ON h1.id_aula = h2.id_aula
    AND h1.dia = h2.dia
    AND h1.id_horario < h2.id_horario
JOIN aula a ON h1.id_aula = a.id_aula
WHERE h1.hora_inicio < h2.hora_fin
  AND h2.hora_inicio < h1.hora_fin
LIMIT 100;

-- ====================
-- CONSULTA 8: Aulas cercanas a un punto (consulta espacial)
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT a.nombre, a.capacidad, e.nombre AS edificio,
       ST_Distance(a.geom::geography,
                   ST_SetSRID(ST_MakePoint(-84.51, 10.36), 4326)::geography) AS distancia_metros
FROM aula a
JOIN edificio e ON a.id_edificio = e.id_edificio
WHERE ST_DWithin(
    a.geom::geography,
    ST_SetSRID(ST_MakePoint(-84.51, 10.36), 4326)::geography,
    500  -- 500 metros de radio
)
ORDER BY distancia_metros;

-- ====================
-- CONSULTA 9: Edificios dentro de un área (consulta espacial)
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT e.nombre, e.descripcion
FROM edificio e
WHERE ST_Within(
    e.geom,
    ST_MakeEnvelope(-84.512, 10.359, -84.508, 10.364, 4326)
);

-- ====================
-- CONSULTA 10: Aulas disponibles (sin horario) un día específico
-- ====================
EXPLAIN (ANALYZE, BUFFERS, TIMING)
SELECT a.nombre, a.capacidad, a.tipo, e.nombre AS edificio
FROM aula a
JOIN edificio e ON a.id_edificio = e.id_edificio
WHERE a.id_aula NOT IN (
    SELECT id_aula FROM horario WHERE dia = 'Lunes'
);

