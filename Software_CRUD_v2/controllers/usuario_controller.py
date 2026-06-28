'''
usuario_controller.py

Es el intermediario entre la interfaz y la base de datos.

Cuando el usuario presiona un botón:

    Recibe la acción.
    Valida los datos.
    Llama al DAO.
    Muestra el resultado.

Coordina todo el flujo del sistema.
'''

from datetime import date
from models.usuario import Usuario
from dao.usuario_dao import UsuarioDAO
from validators.usuario_validator import *
# validar_cedula, validar_contrasenia, validar_estado, validar_codigo_rol
# generar_nombre_usuario,  validar_campos_vacios, validar_solo_letras


class UsuarioController:

    def __init__(self):
        self.dao = UsuarioDAO()

    def agregar_usuario(self, cedula, contrasenia, estado):
        '''
        El usuario se crea a partir de una persona que YA EXISTE en personas.
        nombres, apellidos y codigo_rol NO se piden: se obtienen automaticamente.
        '''

        # 1. La cedula debe tener formato valido
        if not validar_cedula(cedula):
            return False, "Error: la cedula debe tener 10 digitos numericos"

        # 2. La cedula debe existir en personas
        persona = self.dao.buscar_persona_por_cedula(cedula)
        if persona is None:
            return False, "Error: esa cedula no esta registrada en personas"

        _, nombres, apellidos = persona

        # 3. Esa persona no puede tener ya un usuario
        if self.dao.cedula_tiene_usuario(cedula):
            return False, "Error: esa persona ya tiene un usuario registrado"

        # 4. El rol se determina solo, segun en que tabla de especializacion este
        codigo_rol = self.dao.obtener_codigo_rol_por_cedula(cedula)
        if codigo_rol is None or not validar_codigo_rol(codigo_rol):
            return False, "Error: esa persona no esta registrada como estudiante, docente o administrativo"

        # 5. Contrasenia segura
        if not validar_contrasenia(contrasenia):
            return False, "Error: la contraseña debe tener minimo 8 caracteres, una mayuscula, una minuscula y un numero"

        # 6. Estado valido
        if not validar_estado(estado):
            return False, 'Error: el estado debe ser "activo" o "inactivo"'

        # Todo bien: se genera el nombre_usuario y la fecha
        nombre_usuario = generar_nombre_usuario(self.dao, nombres, apellidos)
        fecha_creacion = date.today().isoformat()

        nuevo_usuario = Usuario(
            nombre_usuario=nombre_usuario,
            contrasenia=contrasenia,
            fecha_creacion=fecha_creacion,
            estado=estado,
            cedula=cedula,
            codigo_rol=codigo_rol
        )

        self.dao.insertar_usuario(nuevo_usuario)

        return True, f"Usuario creado correctamente: {nombre_usuario}"

    def listar_usuarios(self):
        return self.dao.listar_usuarios()

    def buscar_usuario(self, nombre_usuario):
        if nombre_usuario.strip() == "":
            return False, None

        resultado = self.dao.buscar_usuario(nombre_usuario)

        if len(resultado) == 0:
            return False, None

        return True, resultado[0]

    def actualizar_usuario(self, nombre_usuario, contrasenia, estado):
        '''
        Solo contrasenia y estado se pueden modificar.
        '''
        existe, _ = self.buscar_usuario(nombre_usuario)
        if not existe:
            return False, "Error: ese usuario no existe"

        if contrasenia != "":
            if not validar_contrasenia(contrasenia):
                return False, "Error: la contraseña debe tener minimo 8 caracteres, una mayuscula, una minuscula y un numero"

        if estado != "":
            if not validar_estado(estado):
                return False, 'Error: el estado debe ser "activo" o "inactivo"'

        usuario_obj = Usuario(
            nombre_usuario=nombre_usuario,
            contrasenia=contrasenia,
            fecha_creacion="",
            estado=estado,
            cedula="",
            codigo_rol=0
        )

        filas_afectadas = self.dao.actualizar_usuario(usuario_obj)

        if filas_afectadas > 0:
            return True, "Usuario actualizado correctamente"
        else:
            return False, "No se pudo actualizar el usuario"

    def eliminar_usuario(self, nombre_usuario):
        existe, _ = self.buscar_usuario(nombre_usuario)
        if not existe:
            return False, "Error: ese usuario no existe"

        filas_afectadas = self.dao.eliminar_usuario(nombre_usuario)

        if filas_afectadas > 0:
            return True, "Usuario eliminado correctamente"
        else:
            return False, "No se pudo eliminar el usuario"
    
    def listar_personas(self):
        return self.dao.listar_personas()

    def buscar_persona_para_agregar(self, cedula):
        '''
        Busca la persona por cedula y prepara los datos para mostrarlos en el
        formulario de Agregar Usuario (Nombres, Apellidos, Rol, Usuario), sin
        insertar nada todavia en la base de datos.
        '''
        if not validar_cedula(cedula):
            return False, None, "Error: la cedula debe tener 10 digitos numericos"

        persona = self.dao.buscar_persona_por_cedula(cedula)
        if persona is None:
            return False, None, "Error: esa cedula no esta registrada en personas"

        _, nombres, apellidos = persona

        if self.dao.cedula_tiene_usuario(cedula):
            return False, None, "Error: esa persona ya tiene un usuario registrado"

        codigo_rol = self.dao.obtener_codigo_rol_por_cedula(cedula)
        if codigo_rol is None:
            return False, None, "Error: esa persona no esta registrada como estudiante, docente o administrativo"

        # Traduce el codigo_rol a un texto legible para mostrarlo en el formulario
        nombres_roles = {1: "Estudiante", 2: "Docente", 3: "Administrativo"}
        rol_texto = nombres_roles.get(codigo_rol, "Desconocido")

        nombre_usuario = generar_nombre_usuario(self.dao, nombres, apellidos)

        datos = {
            "nombres": nombres,
            "apellidos": apellidos,
            "rol_texto": rol_texto,
            "nombre_usuario": nombre_usuario
        }

        return True, datos, "Persona encontrada"