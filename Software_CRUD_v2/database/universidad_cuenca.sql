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

USE universidad_cuenca;

-- GENERO

INSERT INTO genero (nombre_genero) VALUES
('Masculino'),
('Femenino'),
('No binario'),
('Transgenero masculino'),
('Transgenero femenino'),
('Genero fluido'),
('Agenero'),
('Bigenero'),
('Pangenero'),
('Demigenero'),
('Intersexual'),
('Androgino'),
('Genderqueer'),
('Otro'),
('Prefiere no decir'),
('Cuestionando'),
('Poligenero'),
('Neutrois'),
('Dos espiritus'),
('No declarado');


-- PAIS

INSERT INTO pais (nombre_pais) VALUES
('Ecuador'),
('Colombia'),
('Peru'),
('Venezuela'),
('Argentina'),
('Chile'),
('Brasil'),
('Mexico'),
('Espana'),
('Estados Unidos'),
('Canada'),
('Bolivia'),
('Paraguay'),
('Uruguay'),
('Panama'),
('Costa Rica'),
('Cuba'),
('Republica Dominicana'),
('Guatemala'),
('Honduras');


-- PROVINCIA

INSERT INTO provincia (nombre_provincia, codigo_pais) VALUES
('Azuay', 1),
('Pichincha', 1),
('Guayas', 1),
('Manabi', 1),
('Loja', 1),
('El Oro', 1),
('Tungurahua', 1),
('Chimborazo', 1),
('Imbabura', 1),
('Canar', 1),
('Carchi', 1),
('Cotopaxi', 1),
('Bolivar', 1),
('Los Rios', 1),
('Esmeraldas', 1),
('Santa Elena', 1),
('Sucumbios', 1),
('Napo', 1),
('Pastaza', 1),
('Zamora Chinchipe', 1);


-- CANTON

INSERT INTO canton (nombre_canton, codigo_provincia) VALUES
('Cuenca', 1),
('Gualaceo', 1),
('Paute', 1),
('Sigsig', 1),
('Santa Isabel', 1),
('Giron', 1),
('San Fernando', 1),
('Nabon', 1),
('Ona', 1),
('Chordeleg', 1),
('Quito', 2),
('Ruminahui', 2),
('Mejia', 2),
('Guayaquil', 3),
('Duran', 3),
('Samborondon', 3),
('Loja', 5),
('Catamayo', 5),
('Portoviejo', 4),
('Manta', 4);


-- PARROQUIA (se agrega Tarqui para Guayaquil, canton 14)

INSERT INTO parroquia (nombre_parroquia, codigo_canton) VALUES
('Bellavista', 1),
('El Batan', 1),
('El Sagrario', 1),
('El Vecino', 1),
('Gil Ramirez Davalos', 1),
('Huayna Capac', 1),
('Machangara', 1),
('Monay', 1),
('San Blas', 1),
('San Sebastian', 1),
('Sucre', 1),
('Totoracocha', 1),
('Yanuncay', 1),
('Hermano Miguel', 1),
('Cananribamba', 1),
('Banos', 1),
('Ricaurte', 1),
('Sinincay', 1),
('Sayausi', 1),
('Turi', 1),
('Tarqui', 14);


-- AREA

INSERT INTO area (nombre_area) VALUES
('Recursos Humanos'),
('Financiero'),
('Tecnologias de la Informacion'),
('Bienestar Universitario'),
('Secretaria General'),
('Biblioteca'),
('Comunicacion'),
('Vinculacion con la Sociedad'),
('Investigacion'),
('Posgrados'),
('Relaciones Internacionales'),
('Planificacion'),
('Auditoria Interna'),
('Compras Publicas'),
('Mantenimiento'),
('Servicios Generales'),
('Talento Humano Docente'),
('Admisiones'),
('Bienestar Estudiantil'),
('Gestion de Calidad');


-- CARRERAS

INSERT INTO carreras (nombre_carrera, descripcion_carrera, anios_duracion) VALUES
('Medicina', 'Formacion de medicos generales', 6),
('Derecho', 'Formacion en ciencias juridicas', 5),
('Ingenieria Civil', 'Diseno y construccion de obras civiles', 5),
('Ingenieria de Sistemas', 'Desarrollo de software y sistemas informaticos', 5),
('Arquitectura', 'Diseno y planificacion de espacios', 5),
('Odontologia', 'Formacion en salud bucal', 5),
('Psicologia', 'Formacion en ciencias del comportamiento humano', 5),
('Administracion de Empresas', 'Gestion y direccion empresarial', 4),
('Contabilidad y Auditoria', 'Formacion contable y financiera', 4),
('Enfermeria', 'Formacion en cuidado de la salud', 4),
('Ingenieria Electrica', 'Sistemas de potencia y electricidad', 5),
('Ingenieria Quimica', 'Procesos industriales quimicos', 5),
('Biologia', 'Formacion en ciencias biologicas', 4),
('Economia', 'Analisis economico y financiero', 4),
('Comunicacion Social', 'Formacion en medios y periodismo', 4),
('Artes', 'Formacion en artes plasticas y escenicas', 4),
('Educacion', 'Formacion de docentes', 5),
('Ingenieria Agronomica', 'Produccion agricola y manejo de suelos', 5),
('Medicina Veterinaria', 'Salud y produccion animal', 5),
('Estadistica', 'Analisis de datos y modelos estadisticos', 4);


-- ROLES (ajustado al CHECK: solo estudiante, docente, administrativo)

INSERT INTO roles (nombre_rol, descripcion_rol) VALUES
('estudiante', 'Rol asignado a estudiantes regulares'),
('docente', 'Rol asignado al personal docente'),
('administrativo', 'Rol asignado al personal administrativo');


-- TIPO_SERVICIO

INSERT INTO tipo_servicio (nombre) VALUES
('Correo electronico institucional'),
('Almacenamiento en la nube'),
('Reserva de laboratorios'),
('Acceso VPN'),
('Wifi institucional'),
('Plataforma virtual de aprendizaje'),
('Biblioteca digital'),
('Impresion y fotocopiado'),
('Soporte tecnico'),
('Videoconferencia'),
('Reserva de auditorios'),
('Software licenciado'),
('Portal academico'),
('Sistema de matricula'),
('Correo masivo institucional'),
('Reserva de equipos audiovisuales'),
('Laboratorio de computo'),
('Tutorias virtuales'),
('Gestion documental'),
('Reserva de salas de estudio');


-- SERVICIOS_TECNOLOGICOS

INSERT INTO servicios_tecnologicos (nombre, descripcion, codigo_tipo) VALUES
('Correo Institucional Gmail', 'Servicio de correo electronico para la comunidad universitaria', 1),
('Google Drive Universidad', 'Almacenamiento en la nube institucional', 2),
('Laboratorio de Computo 1', 'Laboratorio para practicas de computacion', 3),
('VPN Institucional', 'Acceso remoto seguro a la red universitaria', 4),
('WiFi Campus Central', 'Red inalambrica del campus central', 5),
('EVA - Entorno Virtual de Aprendizaje', 'Plataforma de gestion de cursos en linea', 6),
('Biblioteca Digital UC', 'Acceso a recursos bibliograficos digitales', 7),
('Impresora Facultad de Ingenieria', 'Servicio de impresion para estudiantes', 8),
('Mesa de Ayuda TI', 'Soporte tecnico a usuarios de la plataforma', 9),
('Zoom Institucional', 'Servicio de videoconferencias', 10),
('Auditorio Fray Vicente Solano', 'Reserva de auditorio para eventos', 11),
('Licencia Office 365', 'Suite ofimatica institucional', 12),
('Portal Academico SGA', 'Sistema de gestion academica', 13),
('Sistema de Matricula en Linea', 'Plataforma para matriculacion de estudiantes', 14),
('Correo Masivo Comunicaciones', 'Envio de comunicados institucionales', 15),
('Proyector Portatil A', 'Equipo audiovisual para reservas', 16),
('Laboratorio de Redes', 'Laboratorio especializado en redes', 17),
('Tutorias Virtuales Matematicas', 'Espacio de tutoria en linea', 18),
('Sistema de Gestion Documental', 'Plataforma de gestion de documentos', 19),
('Sala de Estudio Biblioteca Central', 'Espacio de estudio reservable', 20);


-- PERSONAS (20 filas: 10 estudiantes, 5 docentes, 5 administrativos)

INSERT INTO personas (cedula, nombres, apellidos, fecha_nacimiento, edad, correo_electronico,
telefono_convencional, telefono_personal, calle_principal, calle_secundaria, numero_casa, referencia,
discapacidad, codigo_genero, codigo_parroquia) VALUES
('0100000001', 'Michael Jose', 'Bajaña Espinoza', '1981-10-21', 44, 'michael.bajana1@gmail.com', '04234053', '0918728463', 'Av. Francisco de Orellana', 'Av. Carlos Julio Arosemena', '12-34', 'Cerca del Malecon 2000', 0, 1, 21),
('0100000002', 'Cristian Teodoro', 'Marín Guachichullca', '1997-03-13', 29, 'cristian.marin2@gmail.com', '07229258', '0931227216', 'Av. Doce de Abril', 'Av. Ordonez Lasso', '45-12', 'Cerca de la Universidad de Cuenca', 0, 1, 1),
('0100000003', 'Alexander Francisco', 'Guamán Congo', '2007-12-12', 18, 'alexander.guaman3@gmail.com', '07291704', '0900872248', 'Av. Huayna Capac', 'Calle Larga', '22-08', 'Frente al Parque Calderon', 0, 1, 2),
('0100000004', 'Samuel Felipe', 'Vallejo Morales', '2006-11-14', 19, 'samuel.vallejo4@gmail.com', '07107175', '0912448136', 'Av. Solano', 'Av. Unidad Nacional', '33-21', 'Cerca del Estadio Alejandro Serrano', 0, 1, 3),
('0100000005', 'Valentina Domenica', 'Suárez Pacheco', '2005-05-20', 21, 'valentina.suarez5@gmail.com', '07130889', '0950806024', 'Av. Las Americas', 'Av. Espana', '18-55', 'Junto al Centro Comercial Millenium', 0, 2, 4),
('0100000006', 'Michael Andres', 'Bajaña Ramírez', '2003-07-15', 22, 'michael.bajana6@gmail.com', '07048050', '0988753260', 'Calle Simon Bolivar', 'Av. Loja', '9-40', 'Cerca del Mercado 10 de Agosto', 0, 1, 5),
('0100000007', 'Cristian Eduardo', 'Marín Solano', '2004-02-22', 22, 'cristian.marin7@gmail.com', '07874628', '0948966946', 'Av. Don Bosco', 'Av. Fray Vicente Solano', '27-13', 'A dos cuadras del Coliseo Mayor', 0, 1, 6),
('0100000008', 'Alexander Joel', 'Guamán Pintado', '2006-09-09', 19, 'alexander.guaman8@gmail.com', '07171339', '0962043515', 'Av. Huayna Capac', 'Av. Loja', '14-66', 'Frente al Colegio Benigno Malo', 0, 1, 7),
('0100000009', 'Samuel Andres', 'Vallejo Cabrera', '2007-01-30', 19, 'samuel.vallejo9@gmail.com', '07240174', '0904308421', 'Calle Simon Bolivar', 'Av. Espana', '51-09', 'Cerca de la Plaza San Francisco', 0, 1, 8),
('0100000010', 'Valentina Nicole', 'Suárez Andrade', '2006-04-18', 20, 'valentina.suarez10@gmail.com', '07222955', '0987971488', 'Calle Hermano Miguel', 'Av. Huayna Capac', '63-17', 'Junto a la Iglesia de San Blas', 0, 2, 9),
('0100000011', 'Patricia Fernanda', 'Calderón Espinoza', '1975-06-12', 51, 'patricia.calderon11@gmail.com', '07565158', '0935264581', 'Av. Doce de Abril', 'Av. Fray Vicente Solano', '70-05', 'Cerca del Hospital Vicente Corral', 0, 2, 10),
('0100000012', 'Roberto Andres', 'Peña Guzmán', '1980-09-25', 45, 'roberto.pena12@gmail.com', '07095325', '0906323852', 'Av. Unidad Nacional', 'Av. Ordonez Lasso', '16-88', 'Frente a la Facultad de Ingenieria', 0, 1, 11),
('0100000013', 'Patricia Lucia', 'Calderón Vintimilla', '1978-03-08', 48, 'patricia.calderon13@gmail.com', '07490785', '0971016525', 'Av. Loja', 'Av. Las Americas', '5-23', 'Cerca del Parque de la Madre', 0, 2, 12),
('0100000014', 'Roberto Carlos', 'Peña Salazar', '1982-11-19', 43, 'roberto.pena14@gmail.com', '07116970', '0939392920', 'Av. Huayna Capac', 'Av. Don Bosco', '38-77', 'Junto al Banco Central', 0, 1, 13),
('0100000015', 'Patricia Gabriela', 'Calderón Ruiz', '1976-12-01', 49, 'patricia.calderon15@gmail.com', '07912804', '0983926371', 'Av. Loja', 'Av. Unidad Nacional', '44-19', 'Cerca de la Notaria Tercera', 0, 2, 14),
('0100000016', 'Monica Alexandra', 'Torres Bermeo', '1978-04-14', 48, 'monica.torres16@gmail.com', '07565579', '0971182864', 'Av. Solano', 'Av. Fray Vicente Solano', '60-31', 'Frente al Edificio del Rectorado', 0, 2, 15),
('0100000017', 'Diego Armando', 'Cordero Salinas', '1982-08-21', 43, 'diego.cordero17@gmail.com', '07251083', '0907774584', 'Calle Larga', 'Av. Fray Vicente Solano', '25-60', 'Cerca del Mercado 9 de Octubre', 0, 1, 16),
('0100000018', 'Monica Belen', 'Torres Quintero', '1980-01-09', 46, 'monica.torres18@gmail.com', '07691798', '0963791320', 'Av. Las Americas', 'Av. Don Bosco', '81-44', 'Junto al Coliseo Jefferson Perez', 0, 2, 17),
('0100000019', 'Diego Sebastian', 'Cordero Farfán', '1985-05-27', 41, 'diego.cordero19@gmail.com', '07210922', '0995690391', 'Av. Loja', 'Av. Huayna Capac', '29-52', 'Cerca de la Plaza Rotary', 0, 1, 18),
('0100000020', 'Monica Isabel', 'Torres Andrade', '1979-10-03', 46, 'monica.torres20@gmail.com', '07235612', '0908593410', 'Av. Espana', 'Av. Solano', '17-08', 'Frente al Parque de la Madre', 0, 2, 19);


-- ESTUDIANTES

INSERT INTO estudiantes (anio_fin_bachillerato, cedula, codigo_carrera) VALUES
(2003, '0100000001', 4),
(2015, '0100000002', 4),
(2025, '0100000003', 4),
(2024, '0100000004', 4),
(2023, '0100000005', 7),
(2021, '0100000006', 2),
(2022, '0100000007', 9),
(2024, '0100000008', 11),
(2025, '0100000009', 13),
(2024, '0100000010', 15);


-- DOCENTES

INSERT INTO docentes (titulo_academico, tipo_docente, fecha_ingreso, cedula) VALUES
('Magister en Educacion', 'tiempo completo', '2010-03-01', '0100000011'),
('PhD en Ingenieria', 'tiempo completo', '2008-08-15', '0100000012'),
('Magister en Psicologia', 'medio tiempo', '2015-01-20', '0100000013'),
('Doctor en Ciencias', 'medio tiempo', '2012-09-10', '0100000014'),
('Magister en Derecho', 'tiempo completo', '2018-05-05', '0100000015');


-- ADMINISTRATIVOS

INSERT INTO administrativos (cargo, fecha_ingreso, cedula, codigo_area) VALUES
('Coordinadora', '2011-02-14', '0100000016', 1),
('Analista', '2014-07-22', '0100000017', 3),
('Secretaria', '2016-11-30', '0100000018', 5),
('Tecnico', '2019-04-18', '0100000019', 8),
('Director', '2013-06-09', '0100000020', 10);


-- USUARIOS (20 filas; codigo_rol: 1=estudiante, 2=docente, 3=administrativo)

/*
INSERT INTO usuarios (nombre_usuario, contrasenia, fecha_creacion, estado, cedula, codigo_rol) VALUES
('michael.bajana', '12345678', '2025-01-10', 'activo', '0100000001', 1),
('cristian.marin', 'password', '2025-02-11', 'activo', '0100000002', 1),
('alexander.guaman', 'clave123', '2025-03-12', 'inactivo', '0100000003', 1),
('samuel.vallejo', 'qwerty123', '2025-04-13', 'activo', '0100000004', 1),
('valentina.suarez', 'abc12345', '2025-05-14', 'activo', '0100000005', 1),
('michael.bajana1', 'ucuenca123', '2025-06-15', 'inactivo', '0100000006', 1),
('cristian.marin1', 'contrasena123', '2025-07-16', 'activo', '0100000007', 1),
('alexander.guaman1', '12345678', '2025-08-17', 'activo', '0100000008', 1),
('samuel.vallejo1', 'unicamente1', '2025-09-18', 'inactivo', '0100000009', 1),
('valentina.suarez1', 'password', '2025-10-19', 'activo', '0100000010', 1),
('patricia.calderon', 'clave123', '2023-02-20', 'activo', '0100000011', 2),
('roberto.pena', 'qwerty123', '2023-03-21', 'activo', '0100000012', 2),
('patricia.calderon1', 'abc12345', '2023-04-22', 'inactivo', '0100000013', 2),
('roberto.pena1', 'ucuenca123', '2023-05-23', 'activo', '0100000014', 2),
('patricia.calderon2', 'contrasena123', '2023-06-24', 'activo', '0100000015', 2),
('monica.torres', '12345678', '2024-01-05', 'activo', '0100000016', 3),
('diego.cordero', 'password', '2024-02-06', 'activo', '0100000017', 3),
('monica.torres1', 'clave123', '2024-03-07', 'inactivo', '0100000018', 3),
('diego.cordero1', 'qwerty123', '2024-04-08', 'activo', '0100000019', 3),
('monica.torres2', 'abc12345', '2024-05-09', 'activo', '0100000020', 3);
*/

-- ACCESOS

INSERT INTO accesos (fecha_inicio, fecha_fin, hora_inicio, hora_fin, duracion, calificacion,
observacion, nombre_usuario, codigo_servicios) VALUES
('2025-08-07', '2025-08-07', '15:16:00', '15:59:00', 43, 3, 'Sin novedad', 'michael.bajana', 1),
('2025-09-08', '2025-09-08', '12:18:00', '13:08:00', 50, 4, NULL, 'cristian.marin', 2),
('2026-12-22', '2026-12-22', '11:39:00', '14:36:00', 177, 5, 'Buen servicio', 'alexander.guaman', 3),
('2026-11-15', '2026-11-15', '15:19:00', '18:18:00', 179, 1, 'Funciono correctamente', 'samuel.vallejo', 4),
('2025-09-28', '2025-09-28', '08:56:00', '09:33:00', 37, 5, 'Funciono correctamente', 'valentina.suarez', 5),
('2025-10-06', '2025-10-06', '11:38:00', '12:41:00', 63, 3, 'Tuvo demoras', 'michael.bajana1', 6),
('2026-12-05', '2026-12-05', '17:54:00', '19:11:00', 77, 5, 'Hubo una falla momentanea', 'cristian.marin1', 7),
('2025-09-15', '2025-09-15', '07:05:00', '09:57:00', 172, 4, 'Excelente atencion', 'alexander.guaman1', 8),
('2025-02-15', '2025-02-15', '07:21:00', '08:04:00', 43, 3, 'Funciono correctamente', 'samuel.vallejo1', 9),
('2026-03-29', '2026-03-29', '15:45:00', '17:44:00', 119, 5, 'Buen servicio', 'valentina.suarez1', 10),
('2025-04-25', '2025-04-25', '08:56:00', '09:44:00', 48, 5, 'Buen servicio', 'patricia.calderon', 11),
('2026-01-14', '2026-01-14', '16:35:00', '17:22:00', 47, 4, 'Funciono correctamente', 'roberto.pena', 12),
('2025-02-12', '2025-02-12', '11:23:00', '11:43:00', 20, 3, 'Tuvo demoras', 'patricia.calderon1', 13),
('2026-11-30', '2026-11-30', '10:42:00', '11:18:00', 36, 3, NULL, 'roberto.pena1', 14),
('2026-02-21', '2026-02-21', '16:47:00', '17:36:00', 49, 2, 'Funciono correctamente', 'patricia.calderon2', 15),
('2025-07-01', '2025-07-01', '13:01:00', '13:56:00', 55, 3, 'Todo en orden', 'monica.torres', 16),
('2026-11-17', '2026-11-17', '18:51:00', '20:04:00', 73, 3, 'Funciono correctamente', 'diego.cordero', 17),
('2026-12-20', '2026-12-20', '08:24:00', '08:43:00', 19, 4, 'Tuvo demoras', 'monica.torres1', 18),
('2025-07-24', '2025-07-24', '14:22:00', '15:50:00', 88, 2, 'Tuvo demoras', 'diego.cordero1', 19),
('2025-01-25', '2025-01-25', '17:12:00', '19:04:00', 112, 3, 'Excelente atencion', 'monica.torres2', 20);


-- RESERVAS

INSERT INTO reservas (fecha_reserva, hora_reserva, tiempo_estimado, estado, nombre_usuario, codigo_servicios) VALUES
('2025-03-13', '11:22:00', 120, 'pendiente', 'samuel.vallejo', 6),
('2026-06-06', '13:43:00', 90, 'confirmada', 'valentina.suarez', 7),
('2025-12-06', '07:07:00', 45, 'cancelada', 'michael.bajana1', 8),
('2025-07-02', '16:16:00', 15, 'pendiente', 'cristian.marin1', 9),
('2025-04-22', '16:27:00', 45, 'confirmada', 'alexander.guaman1', 10),
('2025-11-18', '13:38:00', 90, 'cancelada', 'samuel.vallejo1', 11),
('2025-04-29', '13:57:00', 90, 'pendiente', 'valentina.suarez1', 12),
('2025-07-14', '11:02:00', 120, 'confirmada', 'patricia.calderon', 13),
('2026-03-23', '07:33:00', 90, 'cancelada', 'roberto.pena', 14),
('2026-12-05', '18:47:00', 120, 'pendiente', 'patricia.calderon1', 15),
('2026-11-18', '10:23:00', 60, 'confirmada', 'roberto.pena1', 16),
('2025-03-13', '17:58:00', 45, 'cancelada', 'patricia.calderon2', 17),
('2026-10-01', '12:42:00', 15, 'pendiente', 'monica.torres', 18),
('2025-11-04', '15:19:00', 120, 'confirmada', 'diego.cordero', 19),
('2026-02-23', '12:25:00', 120, 'cancelada', 'monica.torres1', 20),
('2025-10-30', '15:08:00', 30, 'pendiente', 'diego.cordero1', 1),
('2026-03-07', '17:24:00', 120, 'confirmada', 'monica.torres2', 2),
('2025-06-28', '16:36:00', 45, 'cancelada', 'michael.bajana', 3),
('2026-02-20', '15:53:00', 15, 'pendiente', 'cristian.marin', 4),
('2025-11-08', '11:13:00', 60, 'confirmada', 'alexander.guaman', 5);

-- ver las tablas
use universidad_cuenca;
select * from genero;
select * from pais;
select * from provincia;
select * from canton;
select * from parroquia;
select * from personas;
select * from area;
select * from administrativos;
select * from carreras;
select * from estudiantes;
select * from docentes;
select * from roles;
select * from usuarios;
select * from tipo_servicio;
select * from servicios_tecnologicos;
select * from accesos;
select * from reservas;

SELECT p.cedula, p.nombres, p.apellidos, p.correo_electronico,
CASE WHEN u.cedula IS NULL THEN 'No' ELSE 'Si' END AS tiene_usuario
FROM personas p
LEFT JOIN usuarios u ON p.cedula = u.cedula
