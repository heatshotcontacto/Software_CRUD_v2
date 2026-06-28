'''
usuario_validator.py

Implementa las validaciones solicitadas en el proyecto:

    ✅ Contraseña segura
    ✅ Usuario único
    ✅ Campos obligatorios
    ✅ Formatos válidos
    ✅ Validaciones en tiempo real

Evita que información incorrecta llegue a la base de datos.
'''

import re # La libreria re sirve para la manipulación y valdiación de texto mediaten patrones
import unicodedata # La libreria unicodedata sirve para el procesamiento y normalización de caracteres (acentos, simbolos u otros caracteres especiales)

def validar_campos_vacios(nombres, apellidos, cedula, contrasenia):
    if ( nombres.strip() == "") or (apellidos.strip() == "") or (cedula.strip() == "") or (contrasenia.strip() == ""):
        return False
    return True

def validar_solo_letras(nombres, apellidos):
    return (re.fullmatch(r"[A-Za-zÁÉÍÓÚáéíóúÑñ ]+", nombres) and re.fullmatch(r"[A-Za-zÁÉÍÓÚáéíóúÑñ ]+", apellidos))

def validar_cedula(cedula):
    cedula = cedula.strip()
    return len(cedula) == 10 and cedula.isdigit()

def validar_codigo_rol(codigo_rol):
    try:
        return int(codigo_rol) in (1, 2, 3)
    except (ValueError, TypeError):
        return False

def validar_contrasenia(contrasenia):
    if len(contrasenia) < 8:
        return False

    if not re.search(r"[A-Z]", contrasenia):
        return False

    if not re.search(r"[a-z]", contrasenia):
        return False

    if not re.search(r"[0-9]", contrasenia):
        return False

    return True

def validar_estado(estado):
    # El estado solo puede ser uno de los dos valores que acepta el ENUM en la BD
    return estado.strip().lower() in ("activo", "inactivo")

def validar_usuario_unico(dao, nombre_usuario):
    # Verifica contra la BD si el nombre_usuario ya existe, antes de insertar
    resultado = dao.buscar_usuario(nombre_usuario)
    return len(resultado) == 0

def normalizar_texto(texto):
    # Quita tildes y la ñ (ej. 'Bajaña' -> 'Bajana') para que el nombre_usuario
    # quede en ASCII puro. nombres/apellidos guardan el nombre real sin tocar;
    # esta normalizacion es SOLO para construir el nombre_usuario.
    texto = unicodedata.normalize('NFKD', texto)
    texto = texto.encode('ascii', 'ignore').decode('ascii')
    return texto

def generar_nombre_usuario(dao, nombres, apellidos):
    # Genera primernombre.primerapellido (normalizado y en minusculas).
    # Si ya existe, agrega un numero al final (bajana, bajana2, bajana3...)
    # hasta encontrar uno disponible, para soportar personas con el mismo
    # primer nombre y primer apellido.
    primer_nombre = normalizar_texto(nombres.strip().split(" ")[0]).lower()
    primer_apellido = normalizar_texto(apellidos.strip().split(" ")[0]).lower()
    base = f"{primer_nombre}.{primer_apellido}"

    nombre_usuario = base
    contador = 1
    while not validar_usuario_unico(dao, nombre_usuario):
        nombre_usuario = f"{base}{contador}"
        contador = contador + 1

    return nombre_usuario