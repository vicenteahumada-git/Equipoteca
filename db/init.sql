SET NAMES utf8mb4;
SET character_set_client = utf8mb4;

CREATE DATABASE IF NOT EXISTS equipoteca_db CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
USE equipoteca_db;

CREATE TABLE ADMINISTRADOR (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL
);

CREATE TABLE ESTUDIANTE (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    correo VARCHAR(100) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL
);

CREATE TABLE TIPO_RECURSO (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL
);

CREATE TABLE RECURSO (
    id_recurso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    id_tipo INT,
    biblioteca VARCHAR(100) NOT NULL,
    estado ENUM('Disponible', 'Mantenimiento', 'Baja') DEFAULT 'Disponible',
    FOREIGN KEY (id_tipo) REFERENCES TIPO_RECURSO(id_tipo)
);

CREATE TABLE SOLICITUD (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    rut_estudiante VARCHAR(12),
    id_recurso INT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado_solicitud ENUM('Pendiente', 'Aprobada', 'Rechazada', 'Finalizada', 'Caducada') DEFAULT 'Pendiente',
    FOREIGN KEY (rut_estudiante) REFERENCES ESTUDIANTE(rut),
    FOREIGN KEY (id_recurso) REFERENCES RECURSO(id_recurso)
);

-- NUEVA TABLA: SANCIONES
CREATE TABLE SANCION (
    id_sancion INT AUTO_INCREMENT PRIMARY KEY,
    rut_estudiante VARCHAR(12) NOT NULL,
    rut_admin VARCHAR(12) NOT NULL,
    motivo VARCHAR(255),
    fecha_inicio DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL, -- NULL significa permanente
    FOREIGN KEY (rut_estudiante) REFERENCES ESTUDIANTE(rut),
    FOREIGN KEY (rut_admin) REFERENCES ADMINISTRADOR(rut)
);

-- Datos de prueba
INSERT INTO ADMINISTRADOR (rut, nombre, apellido, correo, contrasena) VALUES 
('11111111-1', 'Admin', 'Principal', 'admin@usach.cl', '123');

INSERT INTO ESTUDIANTE (rut, nombre, apellido, correo, contrasena) VALUES 
('22222222-2', 'Juan', 'Pérez', 'juan@usach.cl', '123'),
('33333333-3', 'María', 'González', 'maria@usach.cl', '123');

INSERT INTO TIPO_RECURSO (nombre_tipo) VALUES ('Sala de Estudio'), ('Computador'), ('Notebook'), ('Tablet');

INSERT INTO RECURSO (nombre, id_tipo, biblioteca) VALUES 
('Sala 1', 1, 'Biblioteca Central'), ('Sala 2', 1, 'Biblioteca Central'),
('PC 01', 2, 'Biblioteca Central'), ('PC 02', 2, 'Biblioteca FAE'),
('Notebook ASUS', 3, 'Biblioteca Central'), ('Tablet Samsung', 4, 'Biblioteca EAO');
