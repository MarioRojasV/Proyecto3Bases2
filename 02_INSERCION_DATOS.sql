INSERT INTO edificio (nombre, descripcion, geom) VALUES
('Laboratorios de Matemática', 'Edificio donde se ubican las aulas de matemática', 
 ST_SetSRID(ST_MakePoint(-84.50992, 10.36226), 4326)
),
('Laboratorios de Computación', 'Edificio con laboratorios y miniauditorio', 
 ST_SetSRID(ST_MakePoint(-84.51039, 10.36274), 4326)
)
('Ecuela de Ciencias Naturales y Exactas', 'Edificio donde se ubican las aulas de matemáticas y otras', 
 ST_SetSRID(ST_MakePoint(-84.51000, 10.36119), 4326)
),
('Biblioteca', 'Edificio de la biblioteca, los cubículos y algunas salas', 
 ST_SetSRID(ST_MakePoint(-84.50978, 10.36040), 4326)
),
('CTEC', 'Centro de Transferencia Tecnológica y Educación Continua del Campus Tecnológico Local San Carlos', 
 ST_SetSRID(ST_MakePoint(-84.50904, 10.36078), 4326)
),
('Gimnasio', 'Gimnasio del TEC', 
 ST_SetSRID(ST_MakePoint(-84.51080, 10.36220), 4326)
),
('Unidad de Arte y Cultura', 
 ST_SetSRID(ST_MakePoint(-84.51152, 10.36167), 4326)
);




INSERT INTO aula (nombre, capacidad, tipo, id_edificio, geom) VALUES
-- Aula 1 (Mate)
('Aula 1', 30, 'Aula', 1,
 ST_SetSRID(ST_GeomFromText(
 'POLYGON((
 -84.509914 10.362207,
 -84.509965 10.362272,
 -84.509885 10.362317,
 -84.509831 10.362249,
 -84.509914 10.362207
 ))'), 4326)
),

-- Aula 2 (Mate)
('Aula 2', 30, 'Aula', 1,
 ST_SetSRID(ST_GeomFromText(
 'POLYGON((
 -84.509831 10.362249,
 -84.509885 10.362317,
 -84.509815 10.362355,
 -84.509761 10.362286,
 -84.509831 10.362249
 ))'), 4326)
),

-- Miniauditorio (Compu)
('Miniauditorio', 50, 'Auditorio', 2,
 ST_SetSRID(ST_GeomFromText(
 'POLYGON((
 -84.5104159 10.3626493,
 -84.5104675 10.3627225,
 -84.5103998 10.3627662,
 -84.5103511 10.3626915,
 -84.5104159 10.3626493
 ))'), 4326)
),

-- Lab 2 (Compu)
('Lab 2', 25, 'Laboratorio', 2,
 ST_SetSRID(ST_GeomFromText(
 'POLYGON((
 -84.5103511 10.3626915,
 -84.5103998 10.3627662,
 -84.5103444 10.3628005,
 -84.5102949 10.3627241,
 -84.5103511 10.3626915
 ))'), 4326)
),

-- Lab 1 (Compu)
('Lab 1', 25, 'Laboratorio', 2,
 ST_SetSRID(ST_GeomFromText(
 'POLYGON((
 -84.5102949 10.3627241,
 -84.5103444 10.3628005,
 -84.5102945 10.3628296,
 -84.5102446 10.3627509,
 -84.5102949 10.3627241
 ))'), 4326)
),

-- Aula 3 (Mate)
('Aula 3', 30, 'Aula', 3, 
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5098959 10.3612017,
  -84.5099364 10.3612691,
  -84.5100326 10.3612185,
  -84.5099861 10.3611510,
  -84.5098959 10.3612017
 ))'), 4326)
),

-- Aula 4 (Mate)
('Aula 4', 30, 'Aula', 3, 
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5100326 10.3612185,
  -84.5099861 10.3611510,
  -84.5100862 10.3610880,
  -84.5101313 10.3611611,
  -84.5100326 10.3612185
 ))'), 4326)
),

-- Aula 5 (Mate)
('Aula 5', 30, 'Aula', 3, 
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5100862 10.3610880,
  -84.5101313 10.3611611,
  -84.5102269 10.3611112,
  -84.5101851 10.3610438,
  -84.5100862 10.3610880
 ))'), 4326)
),

-- Móviles (Compu)
('Aula de móviles', 20, 'Aula', 3,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5100587 10.3614636,
  -84.5101220 10.3614300,
  -84.5100938 10.3613850,
  -84.5100351 10.3614188,
  -84.5100587 10.3614636
 ))'), 4326)
),

-- 24/7 (Biblioteca)
('Sala 24/7', 48, 'Sala', 4,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5098289 10.3604162,
  -84.5097662 10.3604479,
  -84.5097380 10.3603977,
  -84.5097986 10.3603650,
  -84.5098289 10.3604162
 ))'), 4326)
),

-- Auditorio CTEC (CTEC)
('Auditorio CTEC', 335, 'Auditorio', 5,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5092135 10.3608400,
  -84.5090409 10.3609415,
  -84.5088816 10.3607249,
  -84.5090609 10.3606243,
  -84.5092135 10.3608400
 ))'), 4326)
),

-- Gimnaiso (GymTEC)
('Gimnasio', 200, 'Gimnasio', 6,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5107890 10.3620355,
  -84.5106481 10.3621153,
  -84.5108049 10.3623728,
  -84.5109391 10.3622970,
  -84.5107890 10.3620355
 ))'), 4326)
),

-- Salón 3 (Culturales)
('Salón 3', 30, 'Sala', 7,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5115836 10.3617412,
  -84.5115211 10.3617790,
  -84.5115517 10.3616846,
  -84.5114842 10.3617246,
  -84.5115836 10.3617412
 ))'), 4326)
),

-- Salón 2 (Culturales)
('Salón 2', 30, 'Sala', 7,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5115517 10.3616846,
  -84.5114842 10.3617246,
  -84.5114521 10.3616747,
  -84.5115206 10.3616367,
  -84.5115517 10.3616846
 ))'), 4326)
),

-- Salón 1 (Culturales)
('Salón 1', 30, 'Sala', 7,
 ST_SetSRID(ST_GeomFromText('POLYGON((
  -84.5114521 10.3616747,
  -84.5115206 10.3616367,
  -84.5114933 10.3615898,
  -84.5114266 10.3616291,
  -84.5114521 10.3616747
 ))'), 4326)
);






INSERT INTO curso (nombre, codigo) VALUES
('Introducción a la Programación', 'IC1001'),
('Taller de Programación', 'IC1002'),
('Lenguajes de Programación', 'IC3001'),
('Análisis de Algoritmos', 'IC3002'),
('Matemática Discreta', 'MA1002'),
('Matemática General', 'MA1001'),
('Cálculo Diferencial e Integral', 'MA1003'),
('Artes Visuales', 'SE1201'),
('Fútbol Sala', 'SE1204');


INSERT INTO profesor (nombre, correo, telefono, fecha_nacimiento)
VALUES
('Leonardo Víquez Acuña', 'leonardo.viquez@itcr.ac.cr', '88871234', '1981-04-12'),
('Óscar Víquez Acuña', 'oscar.viquez@itcr.ac.cr', '88562345', '1979-09-30'),
('Luis Ernesto Carrera Retana', 'ernesto.carrera@itcr.ac.cr', '87013452', '1975-02-18'),
('Lorena Valerio', 'lorena.valerio@itcr.ac.cr', '89994512', '1976-07-05'),
('Jéssica Navarro', 'jessica.navarro@itcr.ac.cr', '82389472', '1982-07-02'),
('Esteban Ballestero', 'esteban.ballestero@itcr.ac.cr', '81112222', '1981-01-03'),
('Boris Allan Larios', 'boris.larios@itcr.ac.cr', '78224569', '1980-11-17'),
('Óscar Chanis', 'oscar.chanis@itcr.ac.cr', '88224433', '1972-04-28');


INSERT INTO estudiante (nombre, correo, telefono, fecha_nacimiento, carrera, carnet)
VALUES
('Mario Solano', 'm.solano@estudiantec.cr', '88881111', '2005-03-21', 'Ingeniería en Computación', '2025001122'),
('Ana Fernández Ramírez', 'a.fernandez@estudiantec.cr', '87651234', '2004-11-10', 'Ingeniería en Computación', '2024036122'),
('Valeria Campos Brenes', 'v.campos@estudiantec.cr', '89112233', '2005-08-14', 'Ingeniería en Computación', '2022905673'),
('Diego Araya Jiménez', 'd.araya@estudiantec.cr', '88997766', '2004-05-08', 'Ingeniería en Computación', '2025008122'),
('Mónica Mora Arrieta', 'm.mora@estudiantec.cr', '80472087', '2006-10-03', 'Ingeniería en Electrónica', '2025625455'),
('Jorge Soto Morales', 'j.soto@estudiantec.cr', '87443322', '2003-12-01', 'Ingeniería en Producción Industrial', '2023734327'),
('Elena Gutiérrez Mata', 'e.gutierrez@estudiantec.cr', '83664589', '2004-03-11', 'Ingeniería en Producción Industrial', '2024047781'),
('Raúl Castillo Hernández', 'r.castillo@estudiantec.cr', '89117744', '2003-10-07', 'Ingeniería en Producción Industrial', '2023059012'),
('Melissa Chacón Ruiz', 'm.chacon@estudiantec.cr', '88346722', '2005-09-15', 'Administración de Empresas', '2025016222'),
('Fernando Méndez Solano', 'f.mendez@estudiantec.cr', '88009944', '2003-05-28', 'Administración de Empresas', '2023024451'),
('César Barrantes Céspedes', 'c.barrantes@estudiantec.cr', '89113322', '2004-12-13', 'Ingeniería en Producción Industrial', '2024009482'),
('Rebeca Jiménez Alpízar', 'r.jimenez@estudiantec.cr', '87644321', '2005-07-04', 'Ingeniería en Producción Industrial', '2025012244');


INSERT INTO horario (id_curso, id_profesor, id_aula, dia, hora_inicio, hora_fin) VALUES
(1, 1, 3, 'Lunes',     '07:55', '11:30'),
(1, 1, 9, 'Viernes',   '13:00', '16:00'),
(2, 1, 4, 'Martes',    '07:55', '11:30'),
(2, 1, 10, 'Lunes',    '12:30', '16:05'),
(3, 2, 1, 'Miércoles', '12:30', '16:05'),
(3, 2, 8, 'Martes',    '12:30', '16:05')
(4, 4, 5, 'Miércoles', '07:55', '11:30'),
(4, 4, 3, 'Lunes',     '16:00', '17:50'),
(5, 3, 5, 'Jueves',    '16:05', '17:50'),
(5, 6, 5, 'Viernes',   '12:30', '14:30'),
(6, 3, 2, 'Viernes',   '09:45', '11:30'),
(6, 5, 1, 'Martes',    '13:00', '14:45'),
(6, 6, 2, 'Viernes',   '07:55', '09:40'),
(7, 3, 3, 'Lunes',     '13:00', '16:00'),
(7, 5, 4, 'Jueves',    '07:55', '11:30'),
(8, 8, 14, 'Viernes',  '13:00', '15:00'),
(9, 7, 13, 'Martes',   '15:00', '17:00');



INSERT INTO matricula (id_estudiante, id_horario)
VALUES
-- ***** Compu *****
-- Mario Solano
(1, 1),  -- Intro
(1, 3),  -- Taller
(1, 5),  -- Lenguajes
(1, 7),  -- Análisis
(1, 9),  -- Discreta
(1, 11), -- Mate General
(1, 14), -- Cálculo

-- Ana Fernández
(2, 2),
(2, 4),
(2, 6),
(2, 8),
(2, 10),
(2, 12),
(2, 15),

-- Valeria Campos
(3, 1),
(3, 4),
(3, 5),
(3, 7),
(3, 9),
(3, 11),
(3, 14),

-- Diego Araya
(4, 2),
(4, 3),
(4, 6),
(4, 8),
(4, 10),
(4, 12),
(4, 15),


-- ***** Electro *****
-- Mónica Mora
(5, 11), -- Mate General
(5, 12),
(5, 14), -- Cálculo
(5, 15);


-- ***** Produ *****
-- Jorge Soto
(6, 11),
(6, 12),
(6, 13),
(6, 14),
(6, 15),

-- Elena Gutiérrez
(7, 11),
(7, 12),
(7, 14),

-- Raúl Castillo
(8, 11),
(8, 13),
(8, 15),

-- César Barrantes
(11, 12),
(11, 13),
(11, 14),

-- Rebeca Jiménez
(12, 11),
(12, 12),
(12, 15),


-- ***** Admin *****
-- Melissa Chacón
(9, 11),
(9, 12),
(9, 15),
(9, 16), -- Artes visuales

-- Fernando Méndez
(10, 11),
(10, 14),
(10, 16),
