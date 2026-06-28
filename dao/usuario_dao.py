from database.conexion import connectionDB
class UsuarioDAO:
    def insertar_usuario(self, obj_usuario):
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Antes del insert")
            sql = '''INSERT INTO usuarios
            (nombre_usuario, contrasenia, fecha_creacion, estado, cedula, codigo_rol)
            VALUES ('{}', '{}', '{}', '{}', '{}', '{}')'''.format(
                obj_usuario.nombre_usuario,
                obj_usuario.contrasenia,
                obj_usuario.fecha_creacion,
                obj_usuario.estado,
                obj_usuario.cedula,
                obj_usuario.codigo_rol
            )
            cursor.execute(sql)
            print("Ejecutó el insert")
            print(sql)
            print("Antes del commit")
            self.conexion.commit()
        except Exception as e:
            print(f"Error al insertar usuario: {e}")
        finally:
            cursor.close()
            self.conexion.close()

    def listar_usuarios(self):
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Consultando usuarios...")
            # Orden de columnas igual al de la tabla en la interfaz:
            # Nombres, Apellidos, Cedula, Nombre de Usuario, Estado, Rol, Fecha Creación
            sql = '''SELECT p.nombres, p.apellidos, u.cedula, u.nombre_usuario, u.estado,
            r.nombre_rol, u.fecha_creacion
            FROM usuarios u
            INNER JOIN personas p ON u.cedula = p.cedula
            INNER JOIN roles r ON u.codigo_rol = r.codigo_rol'''
            cursor.execute(sql)
            resultados = cursor.fetchall()
            print("Consulta realizada")
            return resultados
        except Exception as e:
            print(f"Error al listar usuarios: {e}")
            return []
        finally:
            cursor.close()
            self.conexion.close()

    def buscar_usuario(self, nombre_usuario):
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Buscando usuario...")
            # Mismo orden que en listar_usuarios, para que coincida con la tabla de la interfaz
            sql = '''SELECT p.nombres, p.apellidos, u.cedula, u.nombre_usuario, u.estado,
            r.nombre_rol, u.fecha_creacion
            FROM usuarios u
            INNER JOIN personas p ON u.cedula = p.cedula
            INNER JOIN roles r ON u.codigo_rol = r.codigo_rol
            WHERE u.nombre_usuario = '{}' '''.format(nombre_usuario)
            cursor.execute(sql)
            resultado = cursor.fetchall()
            print("Consulta realizada")
            return resultado
        except Exception as e:
            print(f"Error al buscar usuario: {e}")
            return []
        finally:
            cursor.close()
            self.conexion.close()

    def actualizar_usuario(self, obj_usuario):
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Entró al update")
            # Solo contrasenia y estado se pueden modificar
            # (nombres/apellidos viven en personas, codigo_rol depende de la cedula)
            campos = []

            if obj_usuario.contrasenia != "":
                campos.append("contrasenia = '{}'".format(obj_usuario.contrasenia))
            if obj_usuario.estado != "":
                campos.append("estado = '{}'".format(obj_usuario.estado))

            if not campos:
                print("No se proporcionó ningún campo para actualizar")
                return 0

            sql = "UPDATE usuarios SET " + ", ".join(campos) + " WHERE nombre_usuario = '{}'".format(obj_usuario.nombre_usuario)

            cursor.execute(sql)
            print("Ejecutó el update")
            print(sql)
            filas_afectadas = cursor.rowcount
            self.conexion.commit()
            print("Se hizo el commit")
            return filas_afectadas
        except Exception as e:
            print(f"Error al actualizar usuario: {e}")
            return 0
        finally:
            cursor.close()
            self.conexion.close()

    def eliminar_usuario(self, nombre_usuario):
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Entró al delete")
            sql = '''DELETE FROM usuarios
            WHERE nombre_usuario = '{}' '''.format(nombre_usuario)
            cursor.execute(sql)
            print("Ejecutó el delete")
            print(sql)
            filas_afectadas = cursor.rowcount
            print("Se hizo el commit")
            self.conexion.commit()
            return filas_afectadas
        except Exception as e:
            print(f"Error al eliminar usuario: {e}")
            return 0
        finally:
            cursor.close()
            self.conexion.close()

    # ---------- METODOS NUEVOS, necesarios porque usuario se crea desde personas ----------

    def buscar_persona_por_cedula(self, cedula):
        # Busca la persona en la tabla personas, para autocompletar nombres/apellidos
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Buscando persona por cedula...")
            sql = "SELECT cedula, nombres, apellidos FROM personas WHERE cedula = '{}'".format(cedula)
            cursor.execute(sql)
            resultado = cursor.fetchone()
            return resultado  # None si no existe
        except Exception as e:
            print(f"Error al buscar persona: {e}")
            return None
        finally:
            cursor.close()
            self.conexion.close()

    def cedula_tiene_usuario(self, cedula):
        # Revisa si esa cedula ya tiene un usuario creado (cedula es UNIQUE en usuarios)
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            sql = "SELECT COUNT(*) FROM usuarios WHERE cedula = '{}'".format(cedula)
            cursor.execute(sql)
            resultado = cursor.fetchone()
            return resultado[0] > 0
        except Exception as e:
            print(f"Error al verificar cedula: {e}")
            return False
        finally:
            cursor.close()
            self.conexion.close()

    def obtener_codigo_rol_por_cedula(self, cedula):
        # Revisa en que tabla de especializacion esta la cedula, y devuelve el
        # codigo_rol correspondiente desde la tabla roles
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            cursor.execute("SELECT 1 FROM estudiantes WHERE cedula = '{}'".format(cedula))
            if cursor.fetchone():
                nombre_rol = "estudiante"
            else:
                cursor.execute("SELECT 1 FROM docentes WHERE cedula = '{}'".format(cedula))
                if cursor.fetchone():
                    nombre_rol = "docente"
                else:
                    cursor.execute("SELECT 1 FROM administrativos WHERE cedula = '{}'".format(cedula))
                    if cursor.fetchone():
                        nombre_rol = "administrativo"
                    else:
                        return None  # no esta en ninguna tabla de especializacion

            cursor.execute("SELECT codigo_rol FROM roles WHERE nombre_rol = '{}'".format(nombre_rol))
            resultado = cursor.fetchone()
            return resultado[0] if resultado else None
        except Exception as e:
            print(f"Error al determinar el rol: {e}")
            return None
        finally:
            cursor.close()
            self.conexion.close()

    def listar_personas(self):
        # Lista todas las personas, indicando si ya tienen un usuario creado o no
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print("Consultando personas...")
            sql = '''SELECT p.cedula, p.nombres, p.apellidos, p.correo_electronico,
            CASE WHEN u.cedula IS NULL THEN 'No' ELSE 'Si' END AS tiene_usuario
            FROM personas p
            LEFT JOIN usuarios u ON p.cedula = u.cedula'''
            cursor.execute(sql)
            resultados = cursor.fetchall()
            print("Consulta realizada")
            return resultados
        except Exception as e:
            print(f"Error al listar personas: {e}")
            return []
        finally:
            cursor.close()
            self.conexion.close()