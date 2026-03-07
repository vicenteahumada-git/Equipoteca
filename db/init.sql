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

-- DATOS MOCK
INSERT INTO ESTUDIANTE VALUES ('33333333-3', 'Íñigo', 'Peña', 'inigo@usach.cl', '1234');
INSERT INTO ADMINISTRADOR VALUES ('11111111-1', 'Sebastián', 'Muñoz', 'admin@usach.cl', '1234');
INSERT INTO TIPO_RECURSO VALUES (1, 'Sala de Estudio'), (2, 'PC Biblioteca'), (3, 'Equipo Portátil');
INSERT INTO RECURSO (nombre, id_tipo, estado) VALUES ('Sala de Estudio A', 1, 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, estado) VALUES ('Sala de Estudio B', 1, 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, estado) VALUES ('PC Lab 1 - 01', 2, 'Disponible');
INSERT INTO RECURSO (nombre, id_tipo, estado) VALUES ('Notebook HP 01', 3, 'Disponible');
