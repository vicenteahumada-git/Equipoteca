CREATE DATABASE IF NOT EXISTS equipoteca_db;
USE equipoteca_db;

CREATE TABLE ADMINISTRADOR (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(60),
    apellido VARCHAR(60),
    correo VARCHAR(60) UNIQUE,
    contrasena VARCHAR(60)
);

CREATE TABLE ESTUDIANTE (
    rut VARCHAR(12) PRIMARY KEY,
    nombre VARCHAR(60),
    apellido VARCHAR(60),
    correo VARCHAR(60) UNIQUE,
    contrasena VARCHAR(60)
);

-- Insertamos un par de usuarios de prueba (Mocks)
INSERT INTO ADMINISTRADOR (rut, nombre, apellido, correo, contrasena) 
VALUES
	('11111111-1', 'Admin', 'Root', 'admin@usach.cl', '1234'),
	('11111112-1', 'Admin2', 'Root', 'admin2@usach.cl', '1234')
	;

INSERT INTO ESTUDIANTE (rut, nombre, apellido, correo, contrasena) 
VALUES
	('22222222-2', 'Ñuñez', 'Juan', 'estudiante@usach.cl', '1234'),
	('22222223-2', 'Vicente', 'Ahumada', 'vicente.ahumada@usach.cl', '1234')
	;
