SET NAMES utf8mb4;
CREATE DATABASE IF NOT EXISTS equipoteca_db CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
USE equipoteca_db;

CREATE TABLE ADMINISTRADOR (
    rut VARCHAR(12) PRIMARY KEY, nombre VARCHAR(60), apellido VARCHAR(60), correo VARCHAR(60) UNIQUE, contrasena VARCHAR(60)
) CHARACTER SET utf8mb4;

CREATE TABLE ESTUDIANTE (
    rut VARCHAR(12) PRIMARY KEY, nombre VARCHAR(60), apellido VARCHAR(60), correo VARCHAR(60) UNIQUE, contrasena VARCHAR(60)
) CHARACTER SET utf8mb4;

CREATE TABLE TIPO_RECURSO (
    id_tipo INT PRIMARY KEY, nombre_tipo VARCHAR(50)
) CHARACTER SET utf8mb4;

CREATE TABLE RECURSO (
    id_recurso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_tipo INT,
    biblioteca VARCHAR(100) DEFAULT 'Biblioteca Central',
    estado VARCHAR(20) DEFAULT 'Disponible',
    FOREIGN KEY (id_tipo) REFERENCES TIPO_RECURSO(id_tipo)
) CHARACTER SET utf8mb4;

CREATE TABLE SOLICITUD (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    rut_estudiante VARCHAR(12),
    id_recurso INT,
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_inicio DATE,
    fecha_fin DATE,
    hora_inicio TIME,
    hora_fin TIME,
    estado_solicitud VARCHAR(20) DEFAULT 'Pendiente',
    FOREIGN KEY (rut_estudiante) REFERENCES ESTUDIANTE(rut),
    FOREIGN KEY (id_recurso) REFERENCES RECURSO(id_recurso)
) CHARACTER SET utf8mb4;

-- USUARIOS
INSERT INTO ESTUDIANTE VALUES ('33333333-3', 'Íñigo', 'Peña', 'inigo@usach.cl', '1234');
INSERT INTO ESTUDIANTE VALUES ('22222222-2', 'María', 'López', 'maria@usach.cl', '1234');
INSERT INTO ADMINISTRADOR VALUES ('11111111-1', 'Sebastián', 'Muñoz', 'admin@usach.cl', '1234');

-- TIPOS
INSERT INTO TIPO_RECURSO VALUES (1, 'Sala de Estudio'), (2, 'PC Desktop'), (3, 'Notebook'), (4, 'Tablet');

-- RECURSOS
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('Sala Central 01', 1, 'Biblioteca Central', 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('Sala Central 02', 1, 'Biblioteca Central', 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('PC Lab Central 01', 2, 'Biblioteca Central', 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('iPad Air Pro', 4, 'Biblioteca Central', 'Disponible');

INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('Sala FAE Especializada', 1, 'Biblioteca FAE', 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('PC FAE 01', 2, 'Biblioteca FAE', 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('Notebook Dell Latitude', 3, 'Biblioteca FAE', 'Disponible');

INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('Sala Estudio 1 DMCC', 1, 'Biblioteca DMCC', 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, biblioteca, estado) VALUES ('PC DMCC 01', 2, 'Biblioteca DMCC', 'Mantenimiento');
