CREATE DATABASE contactCenter
CREATE DATABASE gestionClientes
CREATE DATABASE respaldoSistemaContable


USE gestionClientes

CREATE TABLE clientes(

	id int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	cedula varchar(13) NOT NULL UNIQUE,
	nombre varchar(100),
	apellido varchar(100),
	contacto varchar(15),
	direccion text
)

INSERT INTO clientes (cedula, nombre, apellido, contacto, direccion)
VALUES 
('1723893439', 'Juan', 'Pérez', '809-555-0001', 'Calle 8, No. 20, Santo Domingo'),
('1753823233', 'María', 'López', '809-555-0002', 'Avenida Las Palmas, No. 47, Santiago'),
('1724897482', 'Carlos', 'Díaz', '809-555-0003', 'Calle Los Robles, No. 12, La Vega'),
('1723893549', 'Ana', 'Martinez', '809-555-0004', 'Calle El Sol, No. 33, San Cristóbal'),
('1723123439', 'Luis', 'Alvarado', '809-555-0005', 'Avenida Libertad, No. 5, Puerto Plata'),
('1754643439', 'Carmen', 'Rodríguez', '809-555-0006', 'Callejón San Juan, No. 89, Barahona'),
('1745678430', 'Fernando', 'Jiménez', '809-555-0007', 'Avenida Duarte, No. 13, Punta Cana'),
('1725453539', 'Dolores', 'Fernandez', '809-555-0008', 'Calle Principal, No. 45, Samaná'),
('1723843543', 'Pedro', 'Castillo', '809-555-0009', 'Calle San Martín, No. 22, Bayaguana'),
('1723895645', 'Susana', 'Torres', '809-555-0010', 'Calle La Marina, No. 56, Monte Cristi');

INSERT INTO clientes (cedula, nombre, apellido, contacto, direccion)
VALUES 
('1729345655', 'Kevin', 'Pérez', '809-555-0001', 'Calle 8, No. 20, Santo Domingo')

USE contactCenter



CREATE TABLE datos_contacto(

	id int IDENTITY (1,1) PRIMARY KEY NOT NULL,
	cedula varchar(13) NOT NULL UNIQUE,
	nombre varchar(100),
	apellido varchar(100),
	contacto varchar(15),
	direccion text
)

INSERT INTO datos_contacto (cedula, nombre, apellido, contacto, direccion)
VALUES 
('1753823233', 'María', 'López', '809-555-0002', 'Avenida Las Palmas, No. 47, Santiago'),
('1724897482', 'Carlos', 'Díaz', '809-555-0003', 'Calle Los Robles, No. 12, La Vega'),
('1723893549', 'Ana', 'Martinez', '809-555-0004', 'Calle El Sol, No. 33, San Cristóbal'),
('1723123439', 'Luis', 'Alvarado', '809-555-0005', 'Avenida Libertad, No. 5, Puerto Plata'),
('1754643439', 'Carmen', 'Rodríguez', '809-555-0006', 'Callejón San Juan, No. 89, Barahona'),
('1745678430', 'Fernando', 'Jiménez', '809-555-0007', 'Avenida Duarte, No. 13, Punta Cana'),
('1725453539', 'Dolores', 'Fernandez', '809-555-0008', 'Calle Principal, No. 45, Samaná'),
('1723843543', 'Pedro', 'Castillo', '809-555-0009', 'Calle San Martín, No. 22, Bayaguana'),
('1723895645', 'Susana', 'Torres', '809-555-0010', 'Calle La Marina, No. 56, Monte Cristi');

DROP table datos_contacto

USE respaldoSistemaContable

CREATE TABLE respaldo(

	id INT IDENTITY(1,1) PRIMARY KEY,
	cedula varchar(13),
	nombre varchar(100),
	apellido varchar(100),
	contacto varchar(15),
	dinero float,
	fecha varchar(100)
)


drop table respaldo

Go;

CREATE TRIGGER trg_HandleInserts ON respaldoSistemaContable.dbo.respaldo
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Sumar el dinero si la cédula y la fecha son iguales
    UPDATE r
    SET r.dinero = r.dinero + i.dinero
    FROM respaldoSistemaContable.dbo.respaldo AS r
    INNER JOIN inserted AS i ON r.cedula = i.cedula AND r.fecha = i.fecha
    WHERE r.id <> i.id;

    -- Eliminar el registro recién insertado si es un duplicado exacto en términos de cédula y fecha
    DELETE FROM r
    FROM respaldoSistemaContable.dbo.respaldo AS r
    WHERE EXISTS (
        SELECT 1
        FROM inserted AS i
        WHERE i.cedula = r.cedula AND i.fecha = r.fecha AND i.id <> r.id
    );
END;
GO

GO


USE gestionClientes;
GO

CREATE TRIGGER trg_SyncClientesToContacto
ON clientes
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar datos en la tabla datos_contacto en la base de datos contactCenter
    INSERT INTO contactCenter.dbo.datos_contacto (cedula, nombre, apellido, contacto, direccion)
    SELECT i.cedula, i.nombre, i.apellido, i.contacto, i.direccion
    FROM inserted AS i
    WHERE NOT EXISTS (
        -- Asegurarse de que no se inserten duplicados en datos_contacto
        SELECT 1 FROM contactCenter.dbo.datos_contacto AS dc
        WHERE dc.cedula = i.cedula
    );
END;

GO


GO

USE gestionClientes;
GO

ALTER TABLE clientes
ALTER COLUMN direccion VARCHAR(MAX);

USE contactCenter;
GO

ALTER TABLE datos_contacto
ALTER COLUMN direccion VARCHAR(MAX);
