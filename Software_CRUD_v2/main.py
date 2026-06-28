# Nucleo de todo, ejecuta todo el software
import sys
from PyQt5 import QtWidgets
from ui.usuarios_ui import Ui_Form
from controllers.usuario_controller import UsuarioController

class MiApp(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = Ui_Form()
        self.ui.setupUi(self)  # llamo al setupUi para inicializar el UI

        self.controller = UsuarioController()

        # El boton AGREGAR empieza deshabilitado, hasta que se busque una
        # cedula valida que aun no tenga usuario
        self.ui.bt_agregaruser.setEnabled(False)

        # ---------------- Conexion de botones a sus funciones ----------------
        # Pestaña BUSCAR PERSONAS
        self.ui.bt_buscar_todo_personas.clicked.connect(self.buscar_todas_personas)

        # Pestaña BUSCAR USUARIO
        self.ui.bt_buscaruser.clicked.connect(self.buscar_usuario_click)
        self.ui.bt_buscaruser_2.clicked.connect(self.buscar_todos_usuarios)

        # Pestaña AGREGAR USUARIOS
        self.ui.bt_buscar_persona.clicked.connect(self.buscar_persona_agregar)
        self.ui.bt_agregaruser.clicked.connect(self.agregar_usuario_click)

        # Pestaña ACTUALIZAR USUARIOS
        self.ui.bt_buscarInfuser.clicked.connect(self.buscar_info_actualizar)
        self.ui.bt_actualizaruser.clicked.connect(self.actualizar_usuario_click)

        # Pestaña BORRAR USUARIO
        self.ui.borrar_ok.clicked.connect(self.ver_info_borrar)
        self.ui.bt_borrar.clicked.connect(self.eliminar_usuario_click)

    # ---------------------------------------------------------------
    # Funcion auxiliar: llena cualquier tabla con una lista de filas
    # (se usa en tabla_personas, tabla_buscar y tabla_buscar_2, ya que
    # las 3 funcionan igual: una fila por registro, una columna por dato)
    # ---------------------------------------------------------------
    def llenar_tabla(self, tabla, datos):
        tabla.setRowCount(len(datos))
        for fila, registro in enumerate(datos):
            for columna, valor in enumerate(registro):
                tabla.setItem(fila, columna, QtWidgets.QTableWidgetItem(str(valor)))

    # ================= BUSCAR PERSONAS =================
    def buscar_todas_personas(self):
        personas = self.controller.listar_personas()
        self.llenar_tabla(self.ui.tabla_personas, personas)

    # ================= BUSCAR USUARIO =================
    def buscar_usuario_click(self):
        nombre_usuario = self.ui.usuario_buscar.text()
        existe, datos = self.controller.buscar_usuario(nombre_usuario)

        if existe:
            self.llenar_tabla(self.ui.tabla_buscar, [datos])
        else:
            self.ui.tabla_buscar.setRowCount(0)
            QtWidgets.QMessageBox.warning(self, "No encontrado", "Ese usuario no existe")

    def buscar_todos_usuarios(self):
        usuarios = self.controller.listar_usuarios()
        self.llenar_tabla(self.ui.tabla_buscar, usuarios)

    # ================= AGREGAR USUARIOS =================
    def buscar_persona_agregar(self):
        cedula = self.ui.txt_agg_cedula.text()
        exito, datos, mensaje = self.controller.buscar_persona_para_agregar(cedula)

        if exito:
            self.ui.txt_agg_nombres.setText(datos["nombres"])
            self.ui.txt_agg_apellidos.setText(datos["apellidos"])
            self.ui.txt_agg_rol.setText(datos["rol_texto"])
            self.ui.txt_agg_usuario.setText(datos["nombre_usuario"])
            self.ui.bt_agregaruser.setEnabled(True)
        else:
            self.ui.txt_agg_nombres.clear()
            self.ui.txt_agg_apellidos.clear()
            self.ui.txt_agg_rol.clear()
            self.ui.txt_agg_usuario.clear()
            self.ui.bt_agregaruser.setEnabled(False)
            QtWidgets.QMessageBox.warning(self, "Atención", mensaje)

    def agregar_usuario_click(self):
        cedula = self.ui.txt_agg_cedula.text()
        contrasenia = self.ui.txt_agg_contrasenia.text()
        estado = self.ui.cmb_agg_estado.currentText()

        exito, mensaje = self.controller.agregar_usuario(cedula, contrasenia, estado)

        if exito:
            QtWidgets.QMessageBox.information(self, "Éxito", mensaje)
            # Se limpia todo el formulario para el siguiente registro
            self.ui.txt_agg_cedula.clear()
            self.ui.txt_agg_nombres.clear()
            self.ui.txt_agg_apellidos.clear()
            self.ui.txt_agg_rol.clear()
            self.ui.txt_agg_usuario.clear()
            self.ui.txt_agg_contrasenia.clear()
            self.ui.bt_agregaruser.setEnabled(False)
        else:
            QtWidgets.QMessageBox.warning(self, "Error", mensaje)

    # ================= ACTUALIZAR USUARIOS =================
    def buscar_info_actualizar(self):
        nombre_usuario = self.ui.nombre_usuario.text()
        existe, datos = self.controller.buscar_usuario(nombre_usuario)

        if existe:
            nombres, apellidos, cedula, nombre_usuario_bd, estado, nombre_rol, fecha_creacion = datos
            self.ui.txt_act_usuario.setText(nombre_usuario_bd)
            self.ui.txt_act_nombres.setText(nombres)
            self.ui.txt_act_apellidos.setText(apellidos)
            self.ui.txt_act_rol.setText(nombre_rol)
            self.ui.txt_act_cedula.setText(cedula)
            self.ui.txt_act_contrasenia.clear()  # nunca se muestra la contrasenia real

            indice_estado = self.ui.cmb_act_estado.findText(estado)
            if indice_estado >= 0:
                self.ui.cmb_act_estado.setCurrentIndex(indice_estado)
        else:
            self.ui.txt_act_usuario.clear()
            self.ui.txt_act_nombres.clear()
            self.ui.txt_act_apellidos.clear()
            self.ui.txt_act_rol.clear()
            self.ui.txt_act_cedula.clear()
            QtWidgets.QMessageBox.warning(self, "No encontrado", "Ese usuario no existe")

    def actualizar_usuario_click(self):
        nombre_usuario = self.ui.txt_act_usuario.text()

        if nombre_usuario.strip() == "":
            QtWidgets.QMessageBox.warning(self, "Atención", "Primero busca un usuario con 'Buscar info'")
            return

        contrasenia = self.ui.txt_act_contrasenia.text()
        estado = self.ui.cmb_act_estado.currentText()

        exito, mensaje = self.controller.actualizar_usuario(nombre_usuario, contrasenia, estado)

        if exito:
            QtWidgets.QMessageBox.information(self, "Éxito", mensaje)
            self.ui.txt_act_contrasenia.clear()
        else:
            QtWidgets.QMessageBox.warning(self, "Error", mensaje)

    # ================= BORRAR USUARIO =================
    def ver_info_borrar(self):
        nombre_usuario = self.ui.codigo_usuarioaborrar.text()
        existe, datos = self.controller.buscar_usuario(nombre_usuario)

        if existe:
            self.llenar_tabla(self.ui.tabla_buscar_2, [datos])
        else:
            self.ui.tabla_buscar_2.setRowCount(0)
            QtWidgets.QMessageBox.warning(self, "No encontrado", "Ese usuario no existe")

    def eliminar_usuario_click(self):
        nombre_usuario = self.ui.codigo_usuarioaborrar.text()

        respuesta = QtWidgets.QMessageBox.question(
            self, "Confirmar",
            f"¿Seguro que desea eliminar al usuario '{nombre_usuario}'?",
            QtWidgets.QMessageBox.Yes | QtWidgets.QMessageBox.No
        )

        if respuesta == QtWidgets.QMessageBox.Yes:
            exito, mensaje = self.controller.eliminar_usuario(nombre_usuario)
            if exito:
                QtWidgets.QMessageBox.information(self, "Éxito", mensaje)
                self.ui.tabla_buscar_2.setRowCount(0)
                self.ui.codigo_usuarioaborrar.clear()
            else:
                QtWidgets.QMessageBox.warning(self, "Error", mensaje)


if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    mi_app = MiApp()
    mi_app.show()
    sys.exit(app.exec_())