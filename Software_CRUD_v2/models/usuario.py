class Usuario: # se esta creando la clase, como molde o plantilla
    # Se define cuando se crea un usuario nuevo
    def __init__(self, nombre_usuario, contrasenia, fecha_creacion, estado, cedula, codigo_rol):
        self.nombre_usuario = nombre_usuario
        self.contrasenia = contrasenia
        self.fecha_creacion = fecha_creacion
        self.estado = estado
        self.cedula = cedula
        self.codigo_rol = codigo_rol
        # en este caso se usa self para guardar dentro del objeto en este caso 
        # los objetos dentro de la tabla usuarios