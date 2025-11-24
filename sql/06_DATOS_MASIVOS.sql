-- --------------------------------------------------------
-- 04_DATOS_MASIVOS_PARA_PRUEBAS.sql
-- Generador completo de datos masivos

-- Nota: Este archivo se creó con el único propósito de realizar pruebas comparativas
-- el archivo 02_INSERCION_DATOS.sql es suficiente para el correcto funcionamiento
-- de la base de datos
-- --------------------------------------------------------

-- ============================================
-- GENERAR MÁS EDIFICIOS (4 nuevos)
-- ============================================
INSERT INTO edificio (nombre, descripcion, geom) VALUES
('Centro de Innovación', 'Edificio de laboratorios de innovación y emprendimiento',
 ST_SetSRID(ST_MakePoint(-84.50950, 10.36180), 4326)
),
('Aulas de Ingeniería Electrónica', 'Edificio con laboratorios de circuitos y electrónica',
 ST_SetSRID(ST_MakePoint(-84.51090, 10.36150), 4326)
),
('Cafetería', 'Edificio de servicio alimentario para estudiantes y personal',
 ST_SetSRID(ST_MakePoint(-84.50920, 10.36090), 4326)
),
('Residencias Estudiantiles', 'Alojamiento para estudiantes del TEC',
 ST_SetSRID(ST_MakePoint(-84.51010, 10.36070), 4326)
);

-- ============================================
-- GENERAR MÁS AULAS (7 nuevas)
-- ============================================
INSERT INTO aula (nombre, capacidad, tipo, id_edificio, geom) VALUES
('Lab Innovación 1', 20, 'Laboratorio', 8,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.50955 10.36182,-84.50960 10.36188,-84.50948 10.36190,-84.50945 10.36183,-84.50955 10.36182))'),4326)
),
('Lab Innovación 2', 25, 'Laboratorio', 8,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.50960 10.36188,-84.50966 10.36193,-84.50955 10.36196,-84.50948 10.36190,-84.50960 10.36188))'),4326)
),
('Circuitos 1', 30, 'Laboratorio', 9,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.51088 10.36152,-84.51095 10.36157,-84.51085 10.36161,-84.51079 10.36154,-84.51088 10.36152))'),4326)
),
('Circuitos 2', 30, 'Laboratorio', 9,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.51095 10.36157,-84.51101 10.36161,-84.51093 10.36168,-84.51085 10.36161,-84.51095 10.36157))'),4326)
),
('Salón Cafetería 1', 40, 'Sala', 10,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.50925 10.36092,-84.50930 10.36098,-84.50920 10.36102,-84.50916 10.36094,-84.50925 10.36092))'),4326)
),
('Residencia Aula 1', 25, 'Aula', 11,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.51012 10.36071,-84.51017 10.36077,-84.51008 10.36080,-84.51003 10.36074,-84.51012 10.36071))'),4326)
),
('Residencia Aula 2', 25, 'Aula', 11,
 ST_SetSRID(ST_GeomFromText('POLYGON((-84.51017 10.36077,-84.51022 10.36082,-84.51013 10.36085,-84.51008 10.36080,-84.51017 10.36077))'),4326)
);

-- ============================================
-- GENERAR MÁS CURSOS (11 nuevos)
-- ============================================
INSERT INTO curso (nombre, codigo) VALUES
('Bases de Datos', 'IC4001'),
('Redes de Computadoras', 'IC4002'),
('Inteligencia Artificial', 'IC5001'),
('Sistemas Operativos', 'IC3003'),
('Probabilidad y Estadística', 'MA2001'),
('Química General', 'QA1001'),
('Física General', 'FI1001'),
('Taller de Creatividad', 'SE1301'),
('Taller de Liderazgo', 'SE1302'),
('Administración Financiera', 'AD2001'),
('Mercadeo I', 'AD2002');

-- ============================================
-- GENERAR MÁS PROFESORES (12 nuevos)
-- ============================================
INSERT INTO profesor (nombre, correo, telefono, fecha_nacimiento) VALUES
('Carlos Méndez', 'c.mendez@itcr.ac.cr', '89990011', '1980-06-11'),
('Karla Salas', 'k.salas@itcr.ac.cr', '88882267', '1984-02-05'),
('Victor Hernández', 'v.hernandez@itcr.ac.cr', '88123344', '1978-03-21'),
('Lucía Rojas', 'l.rojas@itcr.ac.cr', '88553219', '1983-09-12'),
('Andrés Porras', 'a.porras@itcr.ac.cr', '87124456', '1977-11-17'),
('Adriana Brenes', 'a.brenes@itcr.ac.cr', '89993322', '1982-12-04'),
('Patricia Mora', 'p.mora@itcr.ac.cr', '88221345', '1976-08-23'),
('Daniel Lagos', 'd.lagos@itcr.ac.cr', '88992211', '1985-10-19'),
('Iván Solís', 'i.solis@itcr.ac.cr', '87012299', '1981-05-14'),
('María Arce', 'm.arce@itcr.ac.cr', '88445566', '1979-07-22'),
('Esteban Muñoz', 'e.munoz@itcr.ac.cr', '88117722', '1984-09-29'),
('Sofía Álvarez', 's.alvarez@itcr.ac.cr', '88770022', '1986-03-12');

-- ============================================
-- GENERAR MÁS ESTUDIANTES (28 nuevos)
-- ============================================
INSERT INTO estudiante (nombre, correo, telefono, fecha_nacimiento, carrera, carnet) VALUES
('Laura Vargas', 'laura.vargas@estudiantec.cr', '88881122', '2005-04-10', 'Ingeniería en Computación', '2025800123'),
('Gabriel Mora', 'gabriel.mora@estudiantec.cr', '88776655', '2004-01-17', 'Ingeniería en Computación', '2024804456'),
('Esteban Hernández', 'esteban.h@estudiantec.cr', '89992255', '2003-07-07', 'Ingeniería en Computación', '2024012788'),
('Daniela Soto', 'daniela.soto@estudiantec.cr', '85664422', '2005-10-23', 'Ingeniería en Electrónica', '2025123301'),
('Ivanna Solís', 'ivanna.solis@estudiantec.cr', '87664433', '2004-08-29', 'Ingeniería en Electrónica', '2024993322'),
('Manuel Pérez', 'manuel.p@estudiantec.cr', '89994321', '2003-03-12', 'Ingeniería en Electrónica', '2024112988'),
('Rocío Campos', 'rocio.campos@estudiantec.cr', '88227811', '2004-09-13', 'Ingeniería en Producción Industrial', '2024782123'),
('Allan Jiménez', 'allan.j@estudiantec.cr', '89112255', '2005-02-24', 'Ingeniería en Producción Industrial', '2025127712'),
('Andrea Alpízar', 'andrea.alp@estudiantec.cr', '87778811', '2003-11-09', 'Ingeniería en Producción Industrial', '2023231233'),
('Julián Araya', 'julian.araya@estudiantec.cr', '89996633', '2004-06-05', 'Administración de Empresas', '2025019981'),
('Daniel Chaves', 'daniel.chaves@estudiantec.cr', '88001234', '2005-01-14', 'Administración de Empresas', '2025664321'),
('Carolina Guzmán', 'caro.guzman@estudiantec.cr', '89998877', '2003-12-30', 'Administración de Empresas', '2023771200'),
('Marcos Valverde', 'marcos.valverde@estudiantec.cr', '84336677', '2004-09-03', 'Ingeniería Ambiental', '2024667721'),
('Silvia Rojas', 'silvia.rojas@estudiantec.cr', '87661145', '2005-03-22', 'Ingeniería Ambiental', '2025771888'),
('Fabián Barboza', 'fabian.b@estudiantec.cr', '86554433', '2004-08-17', 'Ingeniería Ambiental', '2024998765'),
('Isaac Varela', 'isaac.varela@estudiantec.cr', '89117722', '2003-10-12', 'Ingeniería Ambiental', '2024223411'),
('Alonso Castro', 'alonso.c@estudiantec.cr', '86664455', '2005-06-30', 'Ingeniería en Computación', '2025331001'),
('Pablo Jiménez', 'pablo.jimenez@estudiantec.cr', '88667755', '2004-05-21', 'Ingeniería en Computación', '2024017882'),
('Susana Mora', 'susana.mora@estudiantec.cr', '87445678', '2004-09-28', 'Ingeniería en Computación', '2025119022'),
('Karina Céspedes', 'karina.cespedes@estudiantec.cr', '88004321', '2005-04-17', 'Ingeniería en Electrónica', '2025782344'),
('Josué Hernández', 'josue.h@estudiantec.cr', '87112233', '2004-03-26', 'Ingeniería en Electrónica', '2024009811'),
('Rafael Arguedas', 'rafael.a@estudiantec.cr', '87223344', '2003-11-01', 'Ingeniería en Producción Industrial', '2023662900'),
('Natalia Venegas', 'natalia.v@estudiantec.cr', '86667722', '2004-07-19', 'Ingeniería en Producción Industrial', '2025882301'),
('Sofía López', 'sofia.lopez@estudiantec.cr', '88229911', '2005-11-11', 'Administración de Empresas', '2025998302'),
('María Castillo', 'maria.castillo@estudiantec.cr', '88991177', '2004-09-07', 'Administración de Empresas', '2024663291'),
('Alberto Chacón', 'alberto.c@estudiantec.cr', '89553322', '2005-08-03', 'Ingeniería Ambiental', '2025590032'),
('Isaura Hidalgo', 'isaura.h@estudiantec.cr', '88553312', '2004-06-29', 'Ingeniería Ambiental', '2024109122'),
('Marcela Orozco', 'marcela.oro@estudiantec.cr', '89999112', '2003-05-18', 'Ingeniería en Computación', '2025009011');

-- ============================================
-- GENERAR MÁS HORARIOS (23 nuevos)
-- Usa IDs de cursos (1-20), profesores (1-20), aulas (1-22)
-- ============================================
INSERT INTO horario (id_curso, id_profesor, id_aula, dia, hora_inicio, hora_fin) VALUES
(10, 9, 16, 'Lunes', '07:55', '09:40'),
(11, 12, 17, 'Martes', '10:00', '12:00'),
(12, 14, 18, 'Miércoles', '13:00', '15:00'),
(13, 10, 19, 'Jueves', '09:00', '11:30'),
(14, 16, 20, 'Viernes', '07:55', '09:40'),
(15, 17, 21, 'Lunes', '12:30', '14:30'),
(16, 18, 22, 'Miércoles', '10:00', '12:00'),
(17, 19, 16, 'Martes', '13:00', '15:00'),
(18, 20, 17, 'Jueves', '16:00', '18:00'),
(19, 11, 18, 'Viernes', '10:00', '12:00'),
(20, 13, 19, 'Lunes', '15:00', '17:00'),
(4, 12, 16, 'Miércoles', '07:55', '11:30'),
(5, 11, 17, 'Martes', '12:30', '14:30'),
(6, 10, 18, 'Viernes', '13:00', '15:00'),
(7, 18, 19, 'Martes', '16:00', '18:00'),
(8, 17, 20, 'Jueves', '07:55', '09:40'),
(9, 15, 21, 'Viernes', '09:45', '11:30'),
(3, 9, 22, 'Jueves', '13:00', '16:00'),
(2, 14, 16, 'Martes', '07:55', '10:00'),
(1, 13, 17, 'Viernes', '16:00', '18:00'),
(11, 16, 18, 'Lunes', '09:00', '11:00'),
(12, 20, 19, 'Martes', '10:00', '12:00'),
(15, 19, 20, 'Viernes', '12:30', '14:30');

-- ============================================
-- GENERAR MÁS MATRÍCULAS
-- Usa IDs de estudiantes (1-40), horarios (1-40)
-- ============================================
SELECT id_horario FROM horario ORDER BY id_horario;

INSERT INTO matricula (id_estudiante, id_horario) VALUES
(13, 18), (13, 19), (13, 20),
(14, 21), (14, 10), (14, 22),
(15, 12), (15, 23), (15, 24),
(16, 8), (16, 14), (16, 25),
(17, 18), (17, 21), (17, 26),
(18, 11), (18, 16), (18, 27),
(19, 7), (19, 13), (19, 28),
(20, 19), (20, 23), (20, 29),
(21, 10), (21, 22), (21, 25),
(22, 14), (22, 21), (22, 26),
(23, 13), (23, 24), (23, 30),
(24, 12), (24, 18), (24, 27),
(25, 8), (25, 19), (25, 28),
(26, 16), (26, 25), (26, 29),
(27, 14), (27, 22), (27, 26),
(28, 21), (28, 23), (28, 30),
(29, 12), (29, 18), (29, 28),
(30, 11), (30, 21), (30, 27),
(31, 7), (31, 14), (31, 25),
(32, 10), (32, 23), (32, 29),
(33, 16), (33, 19), (33, 27),
(34, 13), (34, 24), (34, 26),
(35, 12), (35, 23), (35, 21),
(36, 18), (36, 28), (36, 27),
(37, 22), (37, 25), (37, 30),
(38, 19), (38, 24), (38, 29),
(39, 12), (39, 18), (39, 26),
(40, 16), (40, 25), (40, 27);

-- ============================================
-- ESTADÍSTICAS Y RESUMEN
-- ============================================
VACUUM ANALYZE edificio;
VACUUM ANALYZE aula;
VACUUM ANALYZE profesor;
VACUUM ANALYZE estudiante;
VACUUM ANALYZE curso;
VACUUM ANALYZE horario;
VACUUM ANALYZE matricula;

SELECT 'edificios' AS tabla, COUNT(*) AS total FROM edificio
UNION ALL SELECT 'aulas', COUNT(*) FROM aula
UNION ALL SELECT 'profesores', COUNT(*) FROM profesor
UNION ALL SELECT 'estudiantes', COUNT(*) FROM estudiante
UNION ALL SELECT 'cursos', COUNT(*) FROM curso
UNION ALL SELECT 'horarios', COUNT(*) FROM horario
UNION ALL SELECT 'matrículas', COUNT(*) FROM matricula
ORDER BY tabla;

-- ============================================
-- CONSULTA PARA OBTENER VOLUMEN EXACTO DE DATOS
-- ============================================

SELECT
    'Edificios' AS Tabla,
    COUNT(*) AS Total,
    pg_size_pretty(pg_total_relation_size('edificio')) AS Tamaño
FROM edificio

UNION ALL

SELECT
    'Aulas',
    COUNT(*),
    pg_size_pretty(pg_total_relation_size('aula'))
FROM aula

UNION ALL

SELECT
    'Profesores',
    COUNT(*),
    pg_size_pretty(pg_total_relation_size('profesor'))
FROM profesor

UNION ALL

SELECT
    'Estudiantes',
    COUNT(*),
    pg_size_pretty(pg_total_relation_size('estudiante'))
FROM estudiante

UNION ALL

SELECT
    'Cursos',
    COUNT(*),
    pg_size_pretty(pg_total_relation_size('curso'))
FROM curso

UNION ALL

SELECT
    'Horarios',
    COUNT(*),
    pg_size_pretty(pg_total_relation_size('horario'))
FROM horario

UNION ALL

SELECT
    'Matrículas',
    COUNT(*),
    pg_size_pretty(pg_total_relation_size('matricula'))
FROM matricula

ORDER BY Total DESC;