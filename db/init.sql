SET NAMES utf8mb4;

SET character_set_client = utf8mb4;

CREATE DATABASE IF NOT EXISTS equipoteca_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_spanish_ci;

USE equipoteca_db;

CREATE TABLE ADMINISTRADOR (
    rut         VARCHAR(12) PRIMARY KEY,
    nombre      VARCHAR(60),
    apellido    VARCHAR(60),
    correo      VARCHAR(60) UNIQUE,
    contrasena  VARCHAR(60)
) CHARACTER SET utf8mb4;

CREATE TABLE ESTUDIANTE (
    rut         VARCHAR(12) PRIMARY KEY,
    nombre      VARCHAR(60),
    apellido    VARCHAR(60),
    correo      VARCHAR(60) UNIQUE,
    contrasena  VARCHAR(60)
) CHARACTER SET utf8mb4;

CREATE TABLE TIPO_RECURSO (
    id_tipo     INT PRIMARY KEY,
    nombre_tipo VARCHAR(50)
) CHARACTER SET utf8mb4;

CREATE TABLE ESTADO_RECURSO (
    id_estado     INT PRIMARY KEY,
    nombre_estado VARCHAR(50)
) CHARACTER SET utf8mb4;

CREATE TABLE ESTADO_SOLICITUD (
    id_estado_solicitud INT PRIMARY KEY,
    nombre_estado       VARCHAR(50)
) CHARACTER SET utf8mb4;

CREATE TABLE RECURSO (
    id_recurso  INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    id_tipo     INT,
    biblioteca  VARCHAR(100) DEFAULT 'Biblioteca Central',
    id_estado   INT DEFAULT 1,
    FOREIGN KEY (id_tipo)   REFERENCES TIPO_RECURSO(id_tipo),
    FOREIGN KEY (id_estado) REFERENCES ESTADO_RECURSO(id_estado)
) CHARACTER SET utf8mb4;

CREATE TABLE SOLICITUD (
    id_solicitud        INT AUTO_INCREMENT PRIMARY KEY,
    rut_estudiante      VARCHAR(12),
    id_recurso          INT,
    fecha_solicitud     DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_inicio        DATE,
    fecha_fin           DATE,
    hora_inicio         TIME,
    hora_fin            TIME,
    id_estado_solicitud INT DEFAULT 1,
    FOREIGN KEY (rut_estudiante)      REFERENCES ESTUDIANTE(rut),
    FOREIGN KEY (id_recurso)          REFERENCES RECURSO(id_recurso),
    FOREIGN KEY (id_estado_solicitud) REFERENCES ESTADO_SOLICITUD(id_estado_solicitud)
) CHARACTER SET utf8mb4;


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


INSERT INTO ESTADO_RECURSO VALUES
    (1,'Disponible'),
    (2,'Ocupado'),
    (3,'No Disponible');

INSERT INTO ESTADO_SOLICITUD VALUES
    (1,'Pendiente'),
    (2,'Aprobada'),
    (3,'Rechazada'),
    (4,'Caducada'),
    (5,'Finalizada');

INSERT INTO TIPO_RECURSO VALUES
    (1,'Sala de Estudio'),
    (2,'PC Desktop'),
    (3,'Notebook'),
    (4,'Tablet');

-- ===============================
-- ESTUDIANTES (30)
-- ===============================

INSERT INTO ESTUDIANTE VALUES
('20000001-1','Camila','Rojas','camila.rojas.g@usach.cl','1234'),
('20000002-2','Diego','Fuentes','diego.fuentes.m@usach.cl','1234'),
('20000003-3','Valentina','Castro','valentina.castro.r@usach.cl','1234'),
('20000004-4','Matias','Silva','matias.silva.p@usach.cl','1234'),
('20000005-5','Jose','Morales','jose.morales.t@usach.cl','1234'),
('20000006-6','Daniela','Torres','daniela.torres.a@usach.cl','1234'),
('20000007-7','Felipe','Contreras','felipe.contreras.s@usach.cl','1234'),
('20000008-8','Fernanda','Pizarro','fernanda.pizarro.l@usach.cl','1234'),
('20000009-9','Ignacio','Araya','ignacio.araya.d@usach.cl','1234'),
('20000010-0','Javiera','Molina','javiera.molina.c@usach.cl','1234'),

('20000011-1','Sebastian','Vargas','sebastian.vargas.f@usach.cl','1234'),
('20000012-2','Antonia','Herrera','antonia.herrera.v@usach.cl','1234'),
('20000013-3','Cristobal','Navarro','cristobal.navarro.g@usach.cl','1234'),
('20000014-4','Catalina','Sepulveda','catalina.sepulveda.r@usach.cl','1234'),
('20000015-5','Nicolas','Soto','nicolas.soto.p@usach.cl','1234'),
('20000016-6','Francisca','Alvarez','francisca.alvarez.m@usach.cl','1234'),
('20000017-7','Benjamin','Campos','benjamin.campos.t@usach.cl','1234'),
('20000018-8','Macarena','Mendez','macarena.mendez.l@usach.cl','1234'),
('20000019-9','Vicente','Cortes','vicente.cortes.s@usach.cl','1234'),
('20000020-0','Amanda','Reyes','amanda.reyes.f@usach.cl','1234'),

('20000021-1','Pablo','Salazar','pablo.salazar.a@usach.cl','1234'),
('20000022-2','Florencia','Carrasco','florencia.carrasco.p@usach.cl','1234'),
('20000023-3','Rodrigo','Ortega','rodrigo.ortega.c@usach.cl','1234'),
('20000024-4','Isidora','Tapia','isidora.tapia.r@usach.cl','1234'),
('20000025-5','Gabriel','Peña','gabriel.pena.g@usach.cl','1234'),
('20000026-6','Constanza','Figueroa','constanza.figueroa.m@usach.cl','1234'),
('20000027-7','Alonso','Bravo','alonso.bravo.l@usach.cl','1234'),
('20000028-8','Daniel','Escobar','daniel.escobar.t@usach.cl','1234'),
('20000029-9','Paula','Gallardo','paula.gallardo.f@usach.cl','1234'),
('20000030-0','Lucas','Parra','lucas.parra.c@usach.cl','1234');

-- ===============================
-- ADMINISTRADORES (5)
-- ===============================

INSERT INTO ADMINISTRADOR VALUES
('30000001-1','Andres','Valenzuela','andres.valenzuela.p@usach.cl','admin123'),
('30000002-2','Carolina','Bustos','carolina.bustos.m@usach.cl','admin123'),
('30000003-3','Ricardo','Sandoval','ricardo.sandoval.t@usach.cl','admin123'),
('30000004-4','Patricia','Zuniga','patricia.zuniga.r@usach.cl','admin123'),
('30000005-5','Mauricio','Godoy','mauricio.godoy.c@usach.cl','admin123');

-- ===============================
-- RECURSOS POR BIBLIOTECA
-- ===============================

-- Biblioteca Central
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Central 05',1,'Biblioteca Central'),
('Sala Central 06',1,'Biblioteca Central'),
('PC Central 02',2,'Biblioteca Central'),
('PC Central 03',2,'Biblioteca Central'),
('PC Central 04',2,'Biblioteca Central'),
('Notebook Central 02',3,'Biblioteca Central'),
('Notebook Central 03',3,'Biblioteca Central'),
('Tablet Central 02',4,'Biblioteca Central');

-- FAE
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala FAE 03',1,'Facultad de Administración y Economía (FAE)'),
('Sala FAE 04',1,'Facultad de Administración y Economía (FAE)'),
('PC FAE 02',2,'Facultad de Administración y Economía (FAE)'),
('PC FAE 03',2,'Facultad de Administración y Economía (FAE)'),
('Notebook FAE 02',3,'Facultad de Administración y Economía (FAE)');

-- FARAC
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala FARAC 02',1,'Facultad de Arquitectura y Ambiente Construido (FARAC)'),
('Sala FARAC 03',1,'Facultad de Arquitectura y Ambiente Construido (FARAC)'),
('PC FARAC 01',2,'Facultad de Arquitectura y Ambiente Construido (FARAC)'),
('Notebook FARAC 01',3,'Facultad de Arquitectura y Ambiente Construido (FARAC)'),
('Tablet FARAC 02',4,'Facultad de Arquitectura y Ambiente Construido (FARAC)');

-- Física
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Física 03',1,'Departamento de Física (FCIENCIA)'),
('Sala Física 04',1,'Departamento de Física (FCIENCIA)'),
('PC Física 01',2,'Departamento de Física (FCIENCIA)'),
('PC Física 02',2,'Departamento de Física (FCIENCIA)'),
('Notebook Física 01',3,'Departamento de Física (FCIENCIA)');

-- DMCC
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala DMCC 04',1,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)'),
('Sala DMCC 05',1,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)'),
('PC DMCC 02',2,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)'),
('PC DMCC 03',2,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)'),
('PC DMCC 04',2,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)'),
('Notebook DMCC 02',3,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)'),
('Tablet DMCC 01',4,'Departamento de Matemática y Ciencia de la Computación (FCIENCIA)');

-- FACIMED
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala FACIMED 02',1,'Facultad de Ciencias Médicas (FACIMED)'),
('Sala FACIMED 03',1,'Facultad de Ciencias Médicas (FACIMED)'),
('PC FACIMED 01',2,'Facultad de Ciencias Médicas (FACIMED)'),
('Notebook FACIMED 01',3,'Facultad de Ciencias Médicas (FACIMED)');

-- FQyB
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala FQyB 03',1,'Facultad de Química y Biología (FQyB)'),
('Sala FQyB 04',1,'Facultad de Química y Biología (FQyB)'),
('PC FQyB 01',2,'Facultad de Química y Biología (FQyB)'),
('PC FQyB 02',2,'Facultad de Química y Biología (FQyB)'),
('Notebook FQyB 01',3,'Facultad de Química y Biología (FQyB)'),
('Tablet FQyB 01',4,'Facultad de Química y Biología (FQyB)');

-- Derecho
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Derecho 02',1,'Facultad de Derecho (FDE)'),
('Sala Derecho 03',1,'Facultad de Derecho (FDE)'),
('PC Derecho 01',2,'Facultad de Derecho (FDE)'),
('Notebook Derecho 01',3,'Facultad de Derecho (FDE)');

-- Humanidades
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Humanidades 02',1,'Facultad de Humanidades (FAHU)'),
('Sala Humanidades 03',1,'Facultad de Humanidades (FAHU)'),
('PC Humanidades 01',2,'Facultad de Humanidades (FAHU)'),
('Notebook Humanidades 01',3,'Facultad de Humanidades (FAHU)');

-- Psicología
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Psicologia 02',1,'Escuela de Psicología (FAHU)'),
('Sala Psicologia 03',1,'Escuela de Psicología (FAHU)'),
('PC Psicologia 01',2,'Escuela de Psicología (FAHU)'),
('Notebook Psicologia 01',3,'Escuela de Psicología (FAHU)');

-- Ingeniería Eléctrica
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Electrica 02',1,'Departamento de Ingeniería Eléctrica (FING)'),
('Sala Electrica 03',1,'Departamento de Ingeniería Eléctrica (FING)'),
('PC Electrica 02',2,'Departamento de Ingeniería Eléctrica (FING)'),
('PC Electrica 03',2,'Departamento de Ingeniería Eléctrica (FING)'),
('Notebook Electrica 01',3,'Departamento de Ingeniería Eléctrica (FING)');

-- Ingeniería Industrial
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Industrial 02',1,'Departamento de Ingeniería Industrial (FING)'),
('Sala Industrial 03',1,'Departamento de Ingeniería Industrial (FING)'),
('PC Industrial 02',2,'Departamento de Ingeniería Industrial (FING)'),
('PC Industrial 03',2,'Departamento de Ingeniería Industrial (FING)'),
('Notebook Industrial 01',3,'Departamento de Ingeniería Industrial (FING)');

-- Ingeniería Informática
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Informatica 02',1,'Departamento de Ingeniería Informática (FING)'),
('Sala Informatica 03',1,'Departamento de Ingeniería Informática (FING)'),
('PC Informatica 03',2,'Departamento de Ingeniería Informática (FING)'),
('PC Informatica 04',2,'Departamento de Ingeniería Informática (FING)'),
('PC Informatica 05',2,'Departamento de Ingeniería Informática (FING)'),
('Notebook Informatica 02',3,'Departamento de Ingeniería Informática (FING)'),
('Notebook Informatica 03',3,'Departamento de Ingeniería Informática (FING)'),
('Tablet Informatica 01',4,'Departamento de Ingeniería Informática (FING)');

-- Ingeniería Mecánica
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Mecanica 02',1,'Departamento de Ingeniería Mecánica (FING)'),
('Sala Mecanica 03',1,'Departamento de Ingeniería Mecánica (FING)'),
('PC Mecanica 01',2,'Departamento de Ingeniería Mecánica (FING)'),
('Notebook Mecanica 01',3,'Departamento de Ingeniería Mecánica (FING)');

-- Ingeniería Metalúrgica
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Metalurgia 02',1,'Departamento de Ingeniería Metalúrgica (FING)'),
('Sala Metalurgia 03',1,'Departamento de Ingeniería Metalúrgica (FING)'),
('PC Metalurgia 01',2,'Departamento de Ingeniería Metalúrgica (FING)'),
('Notebook Metalurgia 01',3,'Departamento de Ingeniería Metalúrgica (FING)');

-- Ingeniería Minas
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Minas 02',1,'Departamento de Ingeniería en Minas (FING)'),
('Sala Minas 03',1,'Departamento de Ingeniería en Minas (FING)'),
('PC Minas 01',2,'Departamento de Ingeniería en Minas (FING)'),
('Notebook Minas 01',3,'Departamento de Ingeniería en Minas (FING)');

-- Ingeniería Química
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala Quimica Ing 02',1,'Departamento de Ingeniería Química y Bioprocesos (FING)'),
('Sala Quimica Ing 03',1,'Departamento de Ingeniería Química y Bioprocesos (FING)'),
('PC Quimica Ing 01',2,'Departamento de Ingeniería Química y Bioprocesos (FING)'),
('Notebook Quimica Ing 01',3,'Departamento de Ingeniería Química y Bioprocesos (FING)');

-- FACTEC
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala FACTEC 02',1,'Facultad Tecnológica (FACTEC)'),
('Sala FACTEC 03',1,'Facultad Tecnológica (FACTEC)'),
('PC FACTEC 01',2,'Facultad Tecnológica (FACTEC)'),
('Notebook FACTEC 02',3,'Facultad Tecnológica (FACTEC)');

-- IDEA
INSERT INTO RECURSO (nombre,id_tipo,biblioteca) VALUES
('Sala IDEA 02',1,'Instituto de Estudios Avanzados (IDEA)'),
('Sala IDEA 03',1,'Instituto de Estudios Avanzados (IDEA)'),
('PC IDEA 01',2,'Instituto de Estudios Avanzados (IDEA)'),
('Notebook IDEA 01',3,'Instituto de Estudios Avanzados (IDEA)'),
('Tablet IDEA 01',4,'Instituto de Estudios Avanzados (IDEA)');

USE equipoteca_db;
