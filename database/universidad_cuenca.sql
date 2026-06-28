/*
Es el archivo donde estará definida toda la base de datos.
Contendrá:
    Creación de la base de datos.
    Creación de tablas.
    Llaves primarias.
    Llaves foráneas.
    Restricciones.
    Inserciones masivas.
Su objetivo es permitir reconstruir la base de datos completa desde cero.
*/

-- DROP DATABASE IF EXISTS universidad_cuenca; -- borrar la base de datos si existe
CREATE DATABASE IF NOT EXISTS universidad_cuenca; -- crear la base de datos si no existe 
USE universidad_cuenca; -- Seleccionar la base de datos en la que se va a trabajar
CREATE TABLE genero -- Se crea la tabla genero
(
  codigo_genero INT NOT NULL AUTO_INCREMENT, 
  nombre_genero VARCHAR(30) NOT NULL,
  PRIMARY KEY (codigo_genero)
);

CREATE TABLE pais -- Se crea la tabla pais
(
  codigo_pais INT NOT NULL AUTO_INCREMENT,
  nombre_pais VARCHAR(100) NOT NULL,
  PRIMARY KEY (codigo_pais)
);

CREATE TABLE provincia -- Se crea la tabla provincia
( 
  codigo_provincia INT NOT NULL AUTO_INCREMENT,
  nombre_provincia VARCHAR(100) NOT NULL,
  codigo_pais INT NOT NULL,
  PRIMARY KEY (codigo_provincia),
  FOREIGN KEY (codigo_pais) REFERENCES pais(codigo_pais)
);

CREATE TABLE canton -- Se crea la tabla canton
(
  codigo_canton INT NOT NULL AUTO_INCREMENT,
  nombre_canton VARCHAR(100) NOT NULL,
  codigo_provincia INT NOT NULL,
  PRIMARY KEY (codigo_canton),
  FOREIGN KEY (codigo_provincia) REFERENCES provincia(codigo_provincia)
);

CREATE TABLE parroquia -- Se crea la tabla parroquia
(
  codigo_parroquia INT NOT NULL AUTO_INCREMENT,
  nombre_parroquia VARCHAR(100) NOT NULL,
  codigo_canton INT NOT NULL,
  PRIMARY KEY (codigo_parroquia),
  FOREIGN KEY (codigo_canton) REFERENCES canton(codigo_canton)
);

CREATE TABLE personas -- Se crea la tabla personas
(
  cedula VARCHAR(10) NOT NULL,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  fecha_nacimiento DATE NOT NULL,
  edad INT NOT NULL,
  correo_electronico VARCHAR(100) NOT NULL UNIQUE,
  telefono_convencional VARCHAR(10) NOT NULL,
  telefono_personal VARCHAR(10) NOT NULL,
  calle_principal VARCHAR(200) NOT NULL,
  calle_secundaria VARCHAR(100) NOT NULL,
  numero_casa VARCHAR(10) NOT NULL,
  referencia VARCHAR(200) NOT NULL,
  discapacidad BOOLEAN NOT NULL,
  codigo_genero INT NOT NULL,
  codigo_parroquia INT NOT NULL,
  PRIMARY KEY (cedula),
  FOREIGN KEY (codigo_genero) REFERENCES genero(codigo_genero),
  FOREIGN KEY (codigo_parroquia) REFERENCES parroquia(codigo_parroquia)
);

CREATE TABLE area -- Se crea la tabla area
(
  codigo_area INT NOT NULL AUTO_INCREMENT,
  nombre_area VARCHAR(100) NOT NULL,
  PRIMARY KEY (codigo_area)
);

CREATE TABLE administrativos -- Se crea la tabla adminsitrativos
(
  cargo VARCHAR(100) NOT NULL,
  fecha_ingreso DATE NOT NULL,
  cedula VARCHAR(10) NOT NULL,
  codigo_area INT NOT NULL,
  PRIMARY KEY (cedula),
  FOREIGN KEY (cedula) REFERENCES personas(cedula),
  FOREIGN KEY (codigo_area) REFERENCES area(codigo_area)
);

CREATE TABLE carreras -- Se crea la tabla carreras
(
  codigo_carrera INT NOT NULL AUTO_INCREMENT,
  nombre_carrera VARCHAR(200) NOT NULL,
  descripcion_carrera VARCHAR(500) NOT NULL,
  anios_duracion INT NOT NULL,
  PRIMARY KEY (codigo_carrera)
);

CREATE TABLE estudiantes -- Se crea la tabla estudiantes
(
  codigo_estudiante INT NOT NULL AUTO_INCREMENT,
  anio_fin_bachillerato YEAR NOT NULL,
  cedula VARCHAR(10) NOT NULL UNIQUE,
  codigo_carrera INT NOT NULL,
  PRIMARY KEY (codigo_estudiante),
  FOREIGN KEY (cedula) REFERENCES personas(cedula),
  FOREIGN KEY (codigo_carrera) REFERENCES carreras(codigo_carrera)
);

CREATE TABLE docentes -- Se crea la tabla docentes
(
  titulo_academico VARCHAR(100) NOT NULL,
  tipo_docente ENUM('tiempo completo','medio tiempo') NOT NULL,
  fecha_ingreso DATE NOT NULL,
  cedula VARCHAR(10) NOT NULL,
  PRIMARY KEY (cedula),
  FOREIGN KEY (cedula) REFERENCES personas(cedula)
);

/*
CREATE TABLE roles -- Se crea la tabla roles
(
  codigo_rol INT NOT NULL AUTO_INCREMENT,
  nombre_rol VARCHAR(100) NOT NULL,
  descripcion_rol VARCHAR(300) NOT NULL,
  PRIMARY KEY (codigo_rol)
);
*/

CREATE TABLE roles
(
  codigo_rol INT NOT NULL AUTO_INCREMENT,
  nombre_rol VARCHAR(100) NOT NULL UNIQUE,
  descripcion_rol VARCHAR(300) NOT NULL,
  PRIMARY KEY (codigo_rol),
  -- Validación que solo permita los campos, estudiante, docente y administrativo
  CHECK(nombre_rol IN ('estudiante','docente','administrativo'))
);

CREATE TABLE usuarios -- Se crea la tabla usuarios
(
  nombre_usuario VARCHAR(100) NOT NULL,
  contrasenia VARCHAR(255) NOT NULL,
  fecha_creacion DATE NOT NULL,
  estado ENUM('activo','inactivo') NOT NULL,
  cedula VARCHAR(10) NOT NULL UNIQUE,
  codigo_rol INT NOT NULL,
  PRIMARY KEY (nombre_usuario),
  FOREIGN KEY (cedula) REFERENCES personas(cedula),
  FOREIGN KEY (codigo_rol) REFERENCES roles(codigo_rol)
);

CREATE TABLE tipo_servicio -- Se crea la tabla tipo_servicio
(
  codigo_tipo INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  PRIMARY KEY (codigo_tipo)
);

CREATE TABLE servicios_tecnologicos -- Se crea la tabla servicios_tecnologicos
(
  codigo_servicios INT NOT NULL AUTO_INCREMENT,
  nombre VARCHAR(100) NOT NULL,
  descripcion VARCHAR(200) NOT NULL,
  codigo_tipo INT NOT NULL,
  PRIMARY KEY (codigo_servicios),
  FOREIGN KEY (codigo_tipo) REFERENCES tipo_servicio(codigo_tipo)
);

CREATE TABLE accesos -- Se crea la tabla acdesos
(
  codigo_acceso INT NOT NULL AUTO_INCREMENT,
  fecha_inicio DATE NOT NULL,
  fecha_fin DATE NOT NULL,
  hora_inicio TIME NOT NULL,
  hora_fin TIME NOT NULL,
  duracion INT NOT NULL,
  -- calificacion INT NOT NULL,
  calificacion INT NOT NULL CHECK(calificacion BETWEEN 1 AND 5), 
  -- Validación para que califique del 1 al 5  
  observacion VARCHAR(200),
  nombre_usuario VARCHAR(100) NOT NULL,
  codigo_servicios INT NOT NULL,
  PRIMARY KEY (codigo_acceso),
  FOREIGN KEY (nombre_usuario) REFERENCES usuarios(nombre_usuario),
  FOREIGN KEY (codigo_servicios) REFERENCES servicios_tecnologicos(codigo_servicios)
);

CREATE TABLE reservas -- Se crea la tabla reservas
(
  codigo_reserva INT NOT NULL AUTO_INCREMENT,
  fecha_reserva DATE NOT NULL,
  hora_reserva TIME NOT NULL,
  tiempo_estimado INT NOT NULL,
  estado ENUM('pendiente','confirmada','cancelada') NOT NULL,
  nombre_usuario VARCHAR(100) NOT NULL,
  codigo_servicios INT NOT NULL,
  PRIMARY KEY (codigo_reserva),
  FOREIGN KEY (nombre_usuario) REFERENCES usuarios(nombre_usuario),
  FOREIGN KEY (codigo_servicios) REFERENCES servicios_tecnologicos(codigo_servicios)
);

