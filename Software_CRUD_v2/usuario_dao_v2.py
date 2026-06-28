# De la carpeta database/conexion.py importa la definición connectionDB 
from database.conexion import connectionDB 
# Se crea una clase para almacenar todas las definiciones del CRUD; CREATE, READ, UPDATE y DELETE
class UsuarioDAO: # Segun normativas se debe usar al principio una MAYUSUCLA
    def insertar_usuario(self, obj_usuario): # self representa el propio objeto de la clase UsuarioDAO y obj_usuario representa ese objeto por ejemplo nombre_usuario
        self.conexion = connectionDB() # Crea la conexión con la base de datos
        cursor = self.conexion.cursor() # Crea un cursor, es decir un puente entre Python y MySQL
        try: # Parametro por si todo sale bien
            print("Antes del insert")
            # Aqui entra la logica de sql al hacer un insert y poner los datos a agregar
            sql = '''INSERT INTO usuarios 
            (nombre_usuario, nombres, apellidos, cedula, contrasenia, fecha_creacion, estado, codigo_rol) 
            VALUES ('{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}')'''.format(
                obj_usuario.nombre_usuario,
                obj_usuario.nombres,
                obj_usuario.apellidos,
                obj_usuario.cedula,
                obj_usuario.contrasenia,
                obj_usuario.fecha_creacion,
                obj_usuario.estado,
                obj_usuario.codigo_rol
            )
            # Ejecuta la consulta SQL
            cursor.execute(sql)
            print("Ejecutó el insert")
            print(sql)
            print("Antes del commit")
            self.conexion.commit() # Guarda los cambios en la base de datos.

        except Exception as e: # Parametro por si algo falla
            print(f"Error al insertar usuario: {e}")

        finally: # Se ejecuta siempre haya error o no 
            cursor.close() # cierra el canal con MySQL
            self.conexion.close() # cierra la conexion con MySQL
            # Se añadieron estos parametros para evitar que el programa consuma recursos, 
            # se vuelva lento en inestable, limite conexiones u bloque accesos

    def listar_usuarios(self): # self represente el propio objeto de la clase UsuarioDAO
        self.conexion = connectionDB() # Realiza la conexion con MySQL
        cursor = self.conexion.cursor() # Crea un cursor, es decir un puente entre Python y MySQL
        try:
            print('Consultando usuarios...')
            sql = 'SELECT * FROM usuarios'
            cursor.execute(sql)
            resultados = cursor.fetchall()
            print('Consulta realizada')
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
            print('Buscando usuario...')
            sql = "SELECT * FROM usuarios WHERE nombre_usuario = '{}'".format(nombre_usuario)
            cursor.execute(sql)
            resultado = cursor.fetchall()
            print("Consulta realizada")
            return resultado

        except Exception as e:
            print(f'Error al buscar usuario: {e}')
            return []
        
        finally:
            cursor.close()
            self.conexion.close()

    def actualizar_usuario(self, obj_usuario):
        self.conexion = connectionDB()
        cursor = self.conexion.cursor()
        try:
            print('Entró al update')
            sql = '''UPDATE usuarios SET 
            nombres = '{}',
            apellidos = '{}',
            cedula = '{}',
            contrasenia = '{}',
            fecha_creacion = '{}',
            estado = '{}',
            codigo_rol = '{}'
            WHERE nombre_usuario = '{}' '''.format(
                obj_usuario.nombres,
                obj_usuario.apellidos,
                obj_usuario.cedula,
                obj_usuario.contrasenia,
                obj_usuario.fecha_creacion,
                obj_usuario.estado,
                obj_usuario.codigo_rol,
                obj_usuario.nombre_usuario
            )

            cursor.execute(sql)
            print("Ejecutó el update")
            print(sql)
            filas_afectadas = cursor.rowcount # Devuelve cuántas filas fueron afectadas.
            print("Se hizo el commit")
            self.conexion.commit()
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
            filas_afectadas = cursor.rowcount # Devuelve cuántas filas fueron afectadas.
            print("Se hizo el commit")
            self.conexion.commit()
            return filas_afectadas

        except Exception as e:
            print(f"Error al eliminar usuario: {e}")
            return 0

        finally:
            cursor.close()
            self.conexion.close()