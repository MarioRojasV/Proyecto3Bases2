CREATE OR REPLACE VIEW vista_horarios_completos AS
SELECT
    h.id_horario,
    c.nombre AS curso,
    c.codigo AS codigo_curso,
    p.nombre AS profesor,
    a.nombre AS aula,
    e.nombre AS edificio,
    h.dia,
    h.hora_inicio,
    h.hora_fin
FROM horario h
JOIN curso c ON h.id_curso = c.id_curso
JOIN profesor p ON h.id_profesor = p.id_profesor
JOIN aula a ON h.id_aula = a.id_aula
JOIN edificio e ON a.id_edificio = e.id_edificio;



CREATE OR REPLACE VIEW vista_estudiantes_horarios AS
SELECT
    est.id_estudiante,
    est.nombre AS estudiante,
    est.carrera,
    c.nombre AS curso,
    h.dia,
    h.hora_inicio,
    h.hora_fin,
    a.nombre AS aula,
    e.nombre AS edificio
FROM matricula m
JOIN estudiante est ON m.id_estudiante = est.id_estudiante
JOIN horario h ON m.id_horario = h.id_horario
JOIN curso c ON h.id_curso = c.id_curso
JOIN aula a ON h.id_aula = a.id_aula
JOIN edificio e ON a.id_edificio = e.id_edificio;



SELECT * FROM public.vista_horarios_completos

SELECT * FROM public.vista_estudiantes_horarios