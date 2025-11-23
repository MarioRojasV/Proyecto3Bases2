from qgis.PyQt.QtWidgets import (
    QAction, QMessageBox, QDialog, QVBoxLayout, QHBoxLayout,
    QLabel, QComboBox, QLineEdit, QPushButton, QTableWidget,
    QTableWidgetItem, QSpinBox
)
from qgis.PyQt.QtCore import Qt
from qgis.core import QgsProject
from datetime import datetime, time
import psycopg2

# ====== CONEXIÓN A BD ======
def conectar_bd():
    try:
        conn = psycopg2.connect(
            host="localhost",
            database="sistema_db_geografico_tec",
            user="fabian",
            password="1234",
            port=5432
        )
        return conn
    except Exception as e:
        QMessageBox.critical(iface.mainWindow(), "Error BD", str(e))
        return None


# ====== FUNCIONES DE CONSULTA ======
def obtener_profesores():
    conn = conectar_bd()
    if not conn:
        return []
    cursor = conn.cursor()
    cursor.execute("SELECT id_profesor, nombre FROM profesor ORDER BY nombre")
    resultado = cursor.fetchall()
    conn.close()
    return resultado


def obtener_estudiantes():
    conn = conectar_bd()
    if not conn:
        return []
    cursor = conn.cursor()
    cursor.execute("SELECT carnet, nombre FROM estudiante ORDER BY nombre")
    resultado = cursor.fetchall()
    conn.close()
    return resultado


def buscar_profesor_en_horario(profesor_id, dia, hora):
    """Busca profesor en un horario específico"""
    conn = conectar_bd()
    if not conn:
        return None, []

    cursor = conn.cursor()
    hora_obj = time(hora[0], hora[1])

    # Horario en esa hora
    cursor.execute("""
        SELECT p.nombre, a.nombre, h.hora_inicio, h.hora_fin
        FROM horario h
        JOIN profesor p ON h.id_profesor = p.id_profesor
        JOIN aula a ON h.id_aula = a.id_aula
        WHERE p.id_profesor = %s
        AND h.dia = %s
        AND h.hora_inicio <= %s
        AND h.hora_fin > %s
        LIMIT 1
    """, (profesor_id, dia, hora_obj, hora_obj))
    actual = cursor.fetchone()

    # Todos los horarios
    cursor.execute("""
        SELECT a.nombre, c.nombre, h.dia, h.hora_inicio, h.hora_fin
        FROM horario h
        JOIN aula a ON h.id_aula = a.id_aula
        JOIN curso c ON h.id_curso = c.id_curso
        WHERE h.id_profesor = %s
        ORDER BY h.dia
    """, (profesor_id,))
    todos = cursor.fetchall()

    conn.close()
    return actual, todos


def buscar_estudiante_en_horario(carnet, dia, hora):
    """Busca estudiante en un horario específico"""
    conn = conectar_bd()
    if not conn:
        return None, []

    cursor = conn.cursor()
    hora_obj = time(hora[0], hora[1])

    # Clase en esa hora
    cursor.execute("""
        SELECT e.nombre, a.nombre, c.nombre, h.hora_inicio, h.hora_fin
        FROM matricula m
        JOIN estudiante e ON m.id_estudiante = e.id_estudiante
        JOIN horario h ON m.id_horario = h.id_horario
        JOIN curso c ON h.id_curso = c.id_curso
        JOIN aula a ON h.id_aula = a.id_aula
        WHERE e.carnet = %s
        AND h.dia = %s
        AND h.hora_inicio <= %s
        AND h.hora_fin > %s
        LIMIT 1
    """, (carnet, dia, hora_obj, hora_obj))
    actual = cursor.fetchone()

    # Todos los horarios
    cursor.execute("""
        SELECT a.nombre, c.nombre, h.dia, h.hora_inicio, h.hora_fin
        FROM matricula m
        JOIN estudiante e ON m.id_estudiante = e.id_estudiante
        JOIN horario h ON m.id_horario = h.id_horario
        JOIN curso c ON h.id_curso = c.id_curso
        JOIN aula a ON h.id_aula = a.id_aula
        WHERE e.carnet = %s
        ORDER BY h.dia, h.hora_inicio
    """, (carnet,))
    todos = cursor.fetchall()

    conn.close()
    return actual, todos


def obtener_aulas_disponibles_en_horario(dia, hora):
    """Retorna aulas disponibles en un horario específico"""
    conn = conectar_bd()
    if not conn:
        return []

    cursor = conn.cursor()
    hora_obj = time(hora[0], hora[1])

    cursor.execute("""
        SELECT a.id_aula, a.nombre, a.capacidad
        FROM aula a
        WHERE a.id_aula NOT IN (
            SELECT h.id_aula FROM horario h
            WHERE h.dia = %s
            AND h.hora_inicio <= %s
            AND h.hora_fin > %s
        )
        ORDER BY a.nombre
    """, (dia, hora_obj, hora_obj))
    resultado = cursor.fetchall()
    conn.close()
    return resultado


# ====== FUNCIONES DE MAPA ======
def resaltar_aula(nombre_aula):
    """Resalta una aula en el mapa y hace zoom"""
    for layer in QgsProject.instance().mapLayers().values():
        if "aula" in layer.name().lower():
            layer.removeSelection()

            for feature in layer.getFeatures():
                if feature['nombre'] == nombre_aula:
                    layer.select(feature.id())

            iface.mapCanvas().zoomToSelected(layer)
            iface.mapCanvas().refresh()
            break


def resaltar_multiples_aulas(aula_ids):
    """Resalta múltiples aulas"""
    for layer in QgsProject.instance().mapLayers().values():
        if "aula" in layer.name().lower():
            layer.removeSelection()

            for feature in layer.getFeatures():
                if feature['id_aula'] in aula_ids:
                    layer.select(feature.id())

            if layer.selectedFeatureCount() > 0:
                iface.mapCanvas().zoomToSelected(layer)
            iface.mapCanvas().refresh()
            break


# ====== DIÁLOGOS ======
class DialogoResultados(QDialog):
    def __init__(self, titulo, columnas, datos):
        super().__init__(iface.mainWindow())
        self.setWindowTitle(titulo)
        self.setGeometry(100, 100, 800, 400)

        layout = QVBoxLayout()

        self.tabla = QTableWidget()
        self.tabla.setColumnCount(len(columnas))
        self.tabla.setHorizontalHeaderLabels(columnas)
        self.tabla.setRowCount(len(datos))

        for row, fila in enumerate(datos):
            for col, valor in enumerate(fila):
                self.tabla.setItem(row, col, QTableWidgetItem(str(valor)))

        self.tabla.resizeColumnsToContents()
        layout.addWidget(self.tabla)

        btn_ok = QPushButton("Cerrar")
        btn_ok.clicked.connect(self.accept)
        layout.addWidget(btn_ok)

        self.setLayout(layout)


class DialogoSeleccionarHora(QDialog):
    """Diálogo para seleccionar día y hora"""
    def __init__(self):
        super().__init__(iface.mainWindow())
        self.setWindowTitle("Seleccionar Día y Hora")
        self.setGeometry(100, 100, 400, 200)
        self.dia = None
        self.hora = None

        layout = QVBoxLayout()

        # Seleccionar día
        layout.addWidget(QLabel("Día de la semana:"))
        self.combo_dia = QComboBox()
        dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']
        self.combo_dia.addItems(dias)
        layout.addWidget(self.combo_dia)

        # Seleccionar hora
        layout.addWidget(QLabel("Hora:"))
        hora_layout = QHBoxLayout()

        layout.addWidget(QLabel("Horas:"))
        self.spin_horas = QSpinBox()
        self.spin_horas.setRange(0, 23)
        self.spin_horas.setValue(7)
        hora_layout.addWidget(self.spin_horas)

        layout.addWidget(QLabel("Minutos:"))
        self.spin_minutos = QSpinBox()
        self.spin_minutos.setRange(0, 59)
        self.spin_minutos.setSingleStep(5)
        self.spin_minutos.setValue(55)
        hora_layout.addWidget(self.spin_minutos)

        layout.addLayout(hora_layout)

        # Botones
        btn_layout = QHBoxLayout()
        btn_ok = QPushButton("Aceptar")
        btn_cancel = QPushButton("Cancelar")
        btn_ok.clicked.connect(self.aceptar)
        btn_cancel.clicked.connect(self.reject)
        btn_layout.addWidget(btn_ok)
        btn_layout.addWidget(btn_cancel)

        layout.addLayout(btn_layout)
        self.setLayout(layout)

    def aceptar(self):
        self.dia = self.combo_dia.currentText()
        self.hora = (self.spin_horas.value(), self.spin_minutos.value())
        self.accept()

    def get_horario(self):
        return self.dia, self.hora


class DialogoProfesores(QDialog):
    def __init__(self):
        super().__init__(iface.mainWindow())
        self.setWindowTitle("Buscar Profesor")
        self.setGeometry(100, 100, 400, 150)
        self.profesor_id = None

        layout = QVBoxLayout()
        layout.addWidget(QLabel("Selecciona un profesor:"))

        self.combo = QComboBox()
        profesores = obtener_profesores()
        for prof_id, nombre in profesores:
            self.combo.addItem(nombre, prof_id)
        layout.addWidget(self.combo)

        btn_layout = QHBoxLayout()
        btn_ok = QPushButton("Buscar")
        btn_cancel = QPushButton("Cancelar")
        btn_ok.clicked.connect(self.aceptar)
        btn_cancel.clicked.connect(self.reject)
        btn_layout.addWidget(btn_ok)
        btn_layout.addWidget(btn_cancel)

        layout.addLayout(btn_layout)
        self.setLayout(layout)

    def aceptar(self):
        self.profesor_id = self.combo.currentData()
        self.accept()


class DialogoEstudiante(QDialog):
    def __init__(self):
        super().__init__(iface.mainWindow())
        self.setWindowTitle("Buscar Estudiante")
        self.setGeometry(100, 100, 400, 150)
        self.carnet = None

        layout = QVBoxLayout()
        layout.addWidget(QLabel("Selecciona un estudiante:"))

        self.combo = QComboBox()
        estudiantes = obtener_estudiantes()
        for carnet, nombre in estudiantes:
            self.combo.addItem(f"{nombre} ({carnet})", carnet)
        layout.addWidget(self.combo)

        btn_layout = QHBoxLayout()
        btn_ok = QPushButton("Buscar")
        btn_cancel = QPushButton("Cancelar")
        btn_ok.clicked.connect(self.aceptar)
        btn_cancel.clicked.connect(self.reject)
        btn_layout.addWidget(btn_ok)
        btn_layout.addWidget(btn_cancel)

        layout.addLayout(btn_layout)
        self.setLayout(layout)

    def aceptar(self):
        self.carnet = self.combo.currentData()
        self.accept()


# ====== ACCIONES DE BOTONES ======
def accion_buscar_profesor():
    dialogo_profesor = DialogoProfesores()
    if dialogo_profesor.exec() == QDialog.Accepted:
        profesor_id = dialogo_profesor.profesor_id

        dialogo_hora = DialogoSeleccionarHora()
        if dialogo_hora.exec() == QDialog.Accepted:
            dia, hora = dialogo_hora.get_horario()
            actual, todos = buscar_profesor_en_horario(profesor_id, dia, hora)

            if actual:
                nombre, aula, hora_inicio, hora_fin = actual
                resaltar_aula(aula)
                QMessageBox.information(
                    iface.mainWindow(),
                    "Profesor Localizado",
                    f"{nombre}\nAula: {aula}\nHora: {hora_inicio} - {hora_fin}"
                )
            else:
                QMessageBox.information(
                    iface.mainWindow(),
                    "Profesor",
                    f"No tiene clase a las {hora[0]:02d}:{hora[1]:02d}"
                )

            if todos:
                dialogo_res = DialogoResultados(
                    "Horarios del Profesor",
                    ["Aula", "Curso", "Día", "Inicio", "Fin"],
                    todos
                )
                dialogo_res.exec()


def accion_buscar_estudiante():
    dialogo_estudiante = DialogoEstudiante()
    if dialogo_estudiante.exec() == QDialog.Accepted:
        carnet = dialogo_estudiante.carnet

        dialogo_hora = DialogoSeleccionarHora()
        if dialogo_hora.exec() == QDialog.Accepted:
            dia, hora = dialogo_hora.get_horario()
            actual, todos = buscar_estudiante_en_horario(carnet, dia, hora)

            if actual:
                nombre, aula, curso, hora_inicio, hora_fin = actual
                resaltar_aula(aula)
                QMessageBox.information(
                    iface.mainWindow(),
                    "Estudiante Localizado",
                    f"{nombre}\nCurso: {curso}\nAula: {aula}\nHora: {hora_inicio} - {hora_fin}"
                )
            else:
                QMessageBox.information(
                    iface.mainWindow(),
                    "Estudiante",
                    f"No tiene clase a las {hora[0]:02d}:{hora[1]:02d}"
                )

            if todos:
                dialogo_res = DialogoResultados(
                    "Horarios del Estudiante",
                    ["Aula", "Curso", "Día", "Inicio", "Fin"],
                    todos
                )
                dialogo_res.exec()


def accion_aulas_disponibles():
    dialogo_hora = DialogoSeleccionarHora()
    if dialogo_hora.exec() == QDialog.Accepted:
        dia, hora = dialogo_hora.get_horario()
        aulas = obtener_aulas_disponibles_en_horario(dia, hora)

        if not aulas:
            QMessageBox.information(
                iface.mainWindow(),
                "Info",
                f"No hay aulas disponibles el {dia} a las {hora[0]:02d}:{hora[1]:02d}"
            )
            return

        dialogo = DialogoResultados(
            f"Aulas Disponibles - {dia} {hora[0]:02d}:{hora[1]:02d}",
            ["ID", "Nombre", "Capacidad"],
            aulas
        )
        dialogo.exec()

        resaltar_multiples_aulas([aula[0] for aula in aulas])


# ====== CREAR BOTONES EN LA BARRA DE HERRAMIENTAS ======
def crear_botones():
    # Botón: Buscar Profesor
    accion1 = QAction("🔍 Localizar Profesor", iface.mainWindow())
    accion1.triggered.connect(accion_buscar_profesor)
    iface.addToolBarIcon(accion1)

    # Botón: Buscar Estudiante
    accion2 = QAction("👤 Buscar Estudiante", iface.mainWindow())
    accion2.triggered.connect(accion_buscar_estudiante)
    iface.addToolBarIcon(accion2)

    # Botón: Aulas Disponibles
    accion3 = QAction("🏛️ Aulas Disponibles", iface.mainWindow())
    accion3.triggered.connect(accion_aulas_disponibles)
    iface.addToolBarIcon(accion3)

    print("✅ Botones creados - Ahora con selector de hora y día")


# ====== EJECUTAR ======
crear_botones()