
# Configuración y Preparación del Proyecto Geoespacial (con PostGIS)

Este documento explica paso a paso cómo preparar PostgreSQL + PostGIS, cómo instalar todo mediante StackBuilder.

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

*(Ejemplo: “PostGIS 3.4 for PostgreSQL 16”)*

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
- **pgRouting** *(si aparece)*
- **Create PostGIS Extension templates** *(opcional)*

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