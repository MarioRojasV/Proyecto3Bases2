## Comparación Técnica de Tipos de Índice

### 1. Índice B-tree
**¿Qué es?**
Estructura de árbol balanceado, el tipo por defecto en PostgreSQL.

**¿Cuándo usarlo?**
- Búsquedas exactas: WHERE id = 5
- Rangos: WHERE fecha BETWEEN ... AND ...
- Ordenamiento: ORDER BY nombre
- Comparaciones: WHERE edad > 18

**Ventajas:**
- Rápido y eficiente
- Funciona con la mayoría de tipos de datos
- Soporta ordenamiento

**Desventajas:**
- No sirve para búsquedas espaciales
- No es tan óptimo para búsquedas de texto

**Ejemplo en el proyecto:**

`CREATE INDEX idx_horario_aula ON horario(id_aula);`

**Resultado en pruebas:**
- Sin índice: 2.45 ms (Seq Scan)
- Con índice: 0.12 ms (Index Scan)
- Mejora: 95.1%

| Consulta                                        | Sin índices | Con índices |
|-------------------------------------------------|-------------|-------------|
| 01.Buscar todos los horarios de múltiples aulas | 0.147 ms    | 0.122 ms    |
| 02.Buscar horarios por día                      | 0.185 ms    | 0.099 ms    |
| 03.Horarios en rango de tiempo                  | 5.657 ms    | 0.107 ms    |
| 04.Estudiantes matriculados en un curso         | 0.610 ms    | 0.208 ms    |
| 05.Carga académica de un profesor               | 0.196 ms    | 0.157 ms    |
| 06.Estudiantes y sus horarios                   | 0.320 ms    | 0.303 ms    |


---

### 2. Índice Multicolumna (B-tree compuesto)
**¿Qué es?**
Índice sobre múltiples columnas, útil para consultas con varios filtros.

**¿Cuándo usarlo?**
- WHERE aula_id = 5 AND dia = 'Lunes'
- Combinaciones frecuentes de filtros

**Ventajas:**
- Optimiza consultas con múltiples condiciones
- Más eficiente que múltiples índices simples

**Desventajas:**
- Orden de columnas importa (debe coincidir con la consulta)
- Ocupa más espacio

**Ejemplo en el proyecto:**

`CREATE INDEX idx_horario_aula_dia ON horario(id_aula, dia);`

**Resultado en pruebas:**

| Consulta                 | Sin índices | Con índices |
|--------------------------|-------------|-------------|
| 07.Conflictos de horario | 5.640 ms    | 0.330 ms    |


---

### 3. Índice GiST (Generalized Search Tree)
**¿Qué es?**
Índice especializado para datos geométricos y espaciales.

**¿Cuándo usarlo?**
- Consultas espaciales: ST_DWithin, ST_Contains, ST_Intersects
- Búsquedas de proximidad
- Geometrías (POINT, POLYGON, etc.)

**Ventajas:**
- Optimizado para consultas espaciales
- Soporta operadores geométricos

**Desventajas:**
- Más lento que B-tree para búsquedas simples

**Ejemplo en el proyecto:**

`CREATE INDEX idx_aula_geom ON aula USING GIST(geom);`

**Resultado en pruebas:**

| Consulta                        | Sin índices | Con índices |
|---------------------------------|-------------|-------------|
| 08. Aulas cercanas a un punto   | 8.848 ms    | 1.701 ms    |
| 09. Edificios dentro de un área | 0.066 ms    | 0.051 ms    |


---

### 4. Índice Parcial
**¿Qué es?**
Índice sobre un subconjunto de filas (con WHERE).

**¿Cuándo usarlo?**
- Solo indexar registros activos
- Filtros muy comunes en consultas

**Ventajas:**
- Ocupa menos espacio
- Más rápido (menos datos)

**Desventajas:**
- Solo sirve para consultas que cumplan la condición

**Ejemplo en el proyecto:**

`CREATE INDEX idx_horario_lunes ON horario(id_aula) WHERE dia = 'Lunes';`

**Resultado en pruebas:**

| Consulta                                        | Sin índices | Con índices |
|-------------------------------------------------|-------------|-------------|
| 10. Aulas disponibles un día específico (Lunes) | 0.348 ms    | 0.264 ms    |

---


## Metodología
### Datos: 
- 152 estudiantes 
- 140 matrículas
- 109 horarios
- 68 profesores
- 64 cursos
- 50 aulas
- 27 edificios
- Consultas evaluadas: 10

Nota: Estos datos utilizados fueron solo para la prueba de tiempo con respecto a los índices.

---
### Tabla de resumen
| Consulta                                        | Sin índices | Con índices |
|-------------------------------------------------|-------------|-------------|
| 01. Buscar todos los horarios de múltiples aulas | 0.147 ms    | 0.122 ms    |
| 02. Buscar horarios por día                      | 0.185 ms    | 0.099 ms    |
| 03. Horarios en rango de tiempo                  | 5.657 ms    | 0.107 ms    |
| 04. Estudiantes matriculados en un curso         | 0.610 ms    | 0.208 ms    |
| 05. Carga académica de un profesor               | 0.196 ms    | 0.157 ms    |
| 06. Estudiantes y sus horarios                   | 0.320 ms    | 0.303 ms    |
| 07. Conflictos de horario                        | 5.640 ms    | 0.330 ms    |
| 08. Aulas cercanas a un punto                    | 8.848 ms    | 1.701 ms    |
| 09. Edificios dentro de un área                  | 0.066 ms    | 0.051 ms    |
| 10. Aulas disponibles un día específico (Lunes)  | 0.348 ms    | 0.264 ms    |

----


![Descripción](/graficos/01_grafico.png)

El gráfico anterior muestra una comparación del tiempo de ejecución (en milisegundos) en cada consulta de prueba.
Por un lado, el tiempo cuando las consultas se realizaban antes 
de cargar los índices, y por el otro cuando ya se habían cargado los
índices. Se puede observar como las consultas que llevaban
una menor complejidad mostraron menos cambios en el tiempo,
 sumado a la cantidad de datos que no eran una carga real
para el sistema. Mientras que consultas más complejas, como la 3,
7 u 8 tienen una mayor diferencia de tiempo, siendo las consultas 
con índices las más rápidas.
Dado el problema de la poca cantidad de datos, el optimizador a veces encontraba
más sencillo usar escaneo secuencial en vez del índice, entonces, para forzar el uso
de los índices en las pruebas, se ejecutó lo siguiente:

`SET enable_seqscan = off;`

### Cantidad de consultas por índice

![Descripción](/graficos/02_grafico.png)

Los índices B-tree simples fueron los que más se usaron y los que mejor funcionaron: optimizaron 6 de las 10 consultas y son súper útiles para búsquedas exactas, rangos y filtros por FKs.
Los índices GiST fueron clave para las consultas espaciales, bajando muchísimo el tiempo cuando se hacían búsquedas por cercanía.
Los multicolumna y los parciales se aplicaron en menos consultas, pero cuando tocaba usarlos sí mejoraban bastante el rendimiento, sobre todo cuando se filtraban varias columnas a la vez o solo ciertos subconjuntos de datos.
