'''
from models.usuario import Usuario
from dao.usuario_dao import UsuarioDAO

dao = UsuarioDAO()

print('Agregar usuario')
print('nombre_usuario, nombres, apellidos, cedula, contrasenia, fecha_creacion, estado, codigo_rol')
usuario= Usuario(nombre_usuario='cristian.marin',nombres='Cristian Teodoro',apellidos='Marin Guachichullca',cedula='0102698351',contrasenia='1234cinco',fecha_creacion='2026-06-22',estado='activo',codigo_rol=1)
dao.insertar_usuario(usuario)

print('listar todos usuarios')
usuarios = dao.listar_usuarios
for i in usuarios:
    print(i)

print('buscar usuario especifico')
usuario_especifico = dao.buscar_usuario('cristian.marin')

print('actualizar usuario')
# Solo se puede modificar: nombres, apellidos, contrasenia, estado y codigo_rol
usuario.nombres = 'Teodoro Cristian'
usuario.apellidos = 'Guiachicullca Cabrera'
usuario.contrasenia = 'Teo12345'
usuario.estado = 'desactivo'
usuario.rol = 2

print('eliminar usuario')
dao.eliminar_usuario('cristian.marin')

print('listado final')
usuarios = dao.listar_usuarios()
for u in usuarios:
    print(u)
'''

from datetime import date
from models.usuario import Usuario
from dao.usuario_dao import UsuarioDAO
from validators.usuario_validator import *
# validar_estado, generar_nombre_usuario, validar_campos_vacios, validar_solo_letras
# validar_cedula, validar_contrasenia

dao = UsuarioDAO()
programa = True

while programa:
    try:
        menu = int(input('Ingrese lo que desea hacer: '
            '\n 1. Agregar Usuario '
            '\n 2. Ver todos los usuarios '
            '\n 3. Buscar un usuario especifico '
            '\n 4. Actualizar datos del usuario '
            '\n 5. Borrar Usuario '
            '\n 6. Salir'
            '\n Opcion: '))
        if menu == 1:
            print('------------------- Agregar Usuario -------------------')
            name = input('Ingrese los nombres: ')
            last_name = input('Ingrese los apellidos: ')
            cedulis = input('Ingrese la cedula: ')
            passwd = input('Ingrese su contraseña: ')
            state = input('Ingrese el estado (activo/inactivo): ')
            roles = int(input('Ingrese el codigo del rol \n 1. Estudiante \n 2. Docente \n 3. Administrador: '))

            if not validar_campos_vacios(name, last_name, cedulis, passwd):
                print('Error: ningún campo puede estar vacío')
            elif not validar_solo_letras(name, last_name):
                print('Error: nombres y apellidos solo deben contener letras')
            elif not validar_cedula(cedulis):
                print('Error: la cedula debe tener 10 digitos numericos')
            elif not validar_contrasenia(passwd):
                print('Error: la contraseña debe tener minimo 8 caracteres, una mayuscula, una minuscula y un numero')
            elif not validar_estado(state):
                print('Error: el estado debe ser "activo" o "inactivo"')
            else:
                # El nombre_usuario se genera automaticamente: primernombre.primerapellido
                # (sin tildes/ñ, y si ya existe agrega un numero al final)
                nickname = generar_nombre_usuario(dao, name, last_name)
                # La fecha_creacion la genera el sistema, no la escribe el usuario
                date_creation = date.today().isoformat()

                usuario = Usuario(
                    nombre_usuario=nickname,
                    nombres=name,
                    apellidos=last_name,
                    cedula=cedulis,
                    contrasenia=passwd,
                    fecha_creacion=date_creation,
                    estado=state,
                    codigo_rol=roles
                )
                dao.insertar_usuario(usuario)
        elif menu == 2:
            print('------------------- Ver todos los usuarios -------------------')
            usuarios = dao.listar_usuarios()
            for i in usuarios:
                print(i)
        elif menu == 3:
            print('------------------- Buscar un usuario especifico -------------------')
            val = input('Ingrese el usuario que esta buscando: ')
            usuario_especifico = dao.buscar_usuario(val)
            print(usuario_especifico)
        elif menu == 4:
            print('------------------- Actualizar datos del usuario -------------------')
            usuario_nombre = input('Ingrese el usuario que desea modificar: ')
            vall = int(input(' Ingrese lo que desee hacer:' \
                '\n 1. nombres ' \
                '\n 2. apellidos ' \
                '\n 3. contrasenia ' \
                '\n 4. estado ' \
                '\n 5. Rol ' \
                '\n 6. Salir ' \
                '\n Opcion: '))
            if vall == 1:
                print('------------------- Actualizar Nombres -------------------')
                namee = input(f'Ingrese los nuevos nombres de {usuario_nombre}: ')
                usuario_obj = Usuario(usuario_nombre, namee, "", "", "", "", "", 0)
                dao.actualizar_usuario(usuario_obj)
            elif vall == 2:
                print('------------------- Actualizar Apellidos -------------------')
                last_namee = input(f'Ingrese los nuevos apellidos de {usuario_nombre}: ')
                usuario_obj = Usuario(usuario_nombre, "", last_namee, "", "", "", "", 0)
                dao.actualizar_usuario(usuario_obj)
            elif vall == 3:
                print('------------------- Actualizar Contrasenia -------------------')
                passwdd = input(f'Ingrese la nueva contraseña de {usuario_nombre}: ')
                if not validar_contrasenia(passwdd):
                    print('Error: la contraseña debe tener minimo 8 caracteres, una mayuscula, una minuscula y un numero')
                else:
                    usuario_obj = Usuario(usuario_nombre, "", "", "", passwdd, "", "", 0)
                    dao.actualizar_usuario(usuario_obj)
            elif vall == 4:
                print('------------------- Actualizar Estado -------------------')
                statee = input(f'Ingrese el nuevo estado de {usuario_nombre}: ')
                if not validar_estado(statee):
                    print('Error: el estado debe ser "activo" o "inactivo"')
                else:
                    usuario_obj = Usuario(usuario_nombre, "", "", "", "", "", statee, 0)
                    dao.actualizar_usuario(usuario_obj)
            elif vall == 5:
                print('------------------- Actualizar Rol -------------------')
                rouless = int(input('Ingrese el nuevo rol (1,2,3): '))
                usuario_obj = Usuario(usuario_nombre, "", "", "", "", "", "", rouless)
                dao.actualizar_usuario(usuario_obj)
            elif vall == 6:
                print('Salir de actualizar')
            else:
                print('Ingrese parametros validos')
        elif menu == 5:
            print('------------------- Borrar Usuario -------------------')
            sure = int(input('¿Desea borrar usuario? \n 1. Si \n 2. No \n Opcion: '))
            if sure == 1:
                nicknamee = input('Ingrese el usuario a borrar: ')
                dao.eliminar_usuario(nicknamee)
            elif sure == 2:
                print('Cancelado')
        elif menu == 6:
            print('------------------- Salir -------------------')
            programa = False
        else:
            print('Ingrese parametros validos')
    except ValueError:
        print('Ingrese solo números')