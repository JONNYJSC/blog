-- =============================================
-- SCRIPT COMPLETO - BASE DE DATOS DISTRIBUIDA
-- FORO N01 - CREACIÓN DE OBJETOS EN SQL SERVER
-- =============================================

-- =============================================
-- CREACIÓN DE LA BASE DE DATOS
-- =============================================
CREATE DATABASE EcommerceDistribuido;
GO

USE EcommerceDistribuido;
GO

-- =============================================
-- CREACIÓN DE ESQUEMAS
-- =============================================
CREATE SCHEMA SQM_GENERAL;
GO

CREATE SCHEMA SQM_CATALOGS;
GO

CREATE SCHEMA SQM_SECURITY;
GO

-- =============================================
-- CREACIÓN DE TABLAS
-- =============================================

-- Tablas de SQM_CATALOGS
CREATE TABLE SQM_CATALOGS.Tbl_ProductIdentificators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CategoryId INT NOT NULL,
    SubCategoryId INT NOT NULL,
    SegmentId INT NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE SQM_CATALOGS.Tbl_AttributeProducts (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    AttributeId INT NOT NULL,
    AttributeValue VARCHAR(255),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- Tablas de SQM_GENERAL
CREATE TABLE SQM_GENERAL.Tbl_Products (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(255) NOT NULL,
    Description TEXT,
    BasePrice DECIMAL(18,2) NOT NULL,
    Currency VARCHAR(3) DEFAULT 'USD',
    IdentificatorId INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (IdentificatorId) REFERENCES SQM_CATALOGS.Tbl_ProductIdentificators(Id)
);
GO

CREATE TABLE SQM_GENERAL.Tbl_ProductVariables (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    VariableName VARCHAR(255) NOT NULL,
    Price DECIMAL(18,2) NOT NULL,
    Stock INT DEFAULT 0,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductId) REFERENCES SQM_GENERAL.Tbl_Products(Id)
);
GO

CREATE TABLE SQM_GENERAL.Tbl_Stocks (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductVariableId INT NOT NULL,
    Quantity INT NOT NULL,
    LastUpdated DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductVariableId) REFERENCES SQM_GENERAL.Tbl_ProductVariables(Id)
);
GO

CREATE TABLE SQM_GENERAL.Tbl_StockMovements (
    MovementId INT IDENTITY(1,1) PRIMARY KEY,
    MovementType VARCHAR(50) NOT NULL CHECK (MovementType IN ('INGRESO INVENTARIO', 'EGRESO INVENTARIO')),
    MovementDate DATETIME DEFAULT GETDATE(),
    Description TEXT,
    CreatedBy VARCHAR(100)
);
GO

CREATE TABLE SQM_GENERAL.Tbl_StockMovementDetails (
    DetailId INT IDENTITY(1,1) PRIMARY KEY,
    MovementId INT NOT NULL,
    ProductVariableId INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2),
    FOREIGN KEY (MovementId) REFERENCES SQM_GENERAL.Tbl_StockMovements(MovementId),
    FOREIGN KEY (ProductVariableId) REFERENCES SQM_GENERAL.Tbl_ProductVariables(Id)
);
GO

CREATE TABLE SQM_GENERAL.Tbl_AttributeProductVariables (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    ProductVariableId INT NOT NULL,
    AttributeId INT NOT NULL,
    AttributeValue VARCHAR(255),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (ProductVariableId) REFERENCES SQM_GENERAL.Tbl_ProductVariables(Id)
);
GO

CREATE TABLE SQM_GENERAL.Tbl_Carts (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CartDate DATETIME DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

CREATE TABLE SQM_GENERAL.Tbl_CartDetails (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CartId INT NOT NULL,
    ProductVariableId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price DECIMAL(18,2) NOT NULL,
    Discount DECIMAL(18,2) DEFAULT 0,
    Currency VARCHAR(3) DEFAULT 'USD',
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CartId) REFERENCES SQM_GENERAL.Tbl_Carts(Id),
    FOREIGN KEY (ProductVariableId) REFERENCES SQM_GENERAL.Tbl_ProductVariables(Id)
);
GO

-- Tablas de SQM_SECURITY
CREATE TABLE SQM_SECURITY.Tbl_Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Username VARCHAR(100) UNIQUE NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME DEFAULT GETDATE()
);
GO

-- =============================================
-- 1. INSERCIÓN DE DATOS
-- =============================================

-- Insertar identificadores de productos
INSERT INTO SQM_CATALOGS.Tbl_ProductIdentificators (CategoryId, SubCategoryId, SegmentId, IsActive) VALUES
(1, 1, 1, 1),  -- Electrónica / Computadoras / Gamer
(1, 1, 2, 1),  -- Electrónica / Computadoras / Oficina
(1, 2, 1, 1),  -- Electrónica / Smartphones / Alta Gama
(2, 1, 1, 1),  -- Ropa / Hombre / Casual
(2, 2, 1, 1),  -- Ropa / Mujer / Formal
(3, 1, 1, 1),  -- Hogar / Cocina / Electrodomésticos
(3, 2, 1, 1),  -- Hogar / Muebles / Sala
(4, 1, 1, 1),  -- Deportes / Fitness / Equipos
(4, 2, 1, 1),  -- Deportes / Camping / Accesorios
(5, 1, 1, 1);  -- Libros / Ficción / Novelas
GO

-- Insertar 20 productos
INSERT INTO SQM_GENERAL.Tbl_Products (ProductName, Description, BasePrice, Currency, IdentificatorId, IsActive) VALUES
('Laptop Gamer ASUS', 'Laptop de alta gama con RTX 4080, 32GB RAM, 1TB SSD', 2500.00, 'USD', 1, 1),
('Laptop Office HP', 'Laptop para oficina con i5, 16GB RAM, 512GB SSD', 800.00, 'USD', 2, 1),
('iPhone 15 Pro', 'Smartphone Apple último modelo con cámara de 48MP', 1200.00, 'USD', 3, 1),
('Camisa Casual Hombre', 'Camisa de algodón manga larga, varios colores', 45.00, 'USD', 4, 1),
('Vestido Formal Mujer', 'Vestido de gala talla M, seda natural', 120.00, 'USD', 5, 1),
('Refrigeradora Samsung', 'Refrigeradora inteligente con pantalla LCD', 950.00, 'USD', 6, 1),
('Sofá de Sala', 'Sofá de 3 plazas color gris, tela impermeable', 650.00, 'USD', 7, 1),
('Caminadora Eléctrica', 'Caminadora plegable para hogar, 12 programas', 700.00, 'USD', 8, 1),
('Carpa para Camping', 'Carpa para 4 personas impermeable, fácil armado', 180.00, 'USD', 9, 1),
('Libro Cien Años de Soledad', 'Novela de Gabriel García Márquez, edición especial', 25.00, 'USD', 10, 1),
('Monitor Samsung 27"', 'Monitor curvo 144Hz, 4K UHD', 350.00, 'USD', 1, 1),
('Teclado Mecánico', 'Teclado RGB switch red, iluminación personalizable', 80.00, 'USD', 1, 1),
('Mouse Gamer', 'Mouse inalámbrico 16000 DPI, 8 botones', 50.00, 'USD', 1, 1),
('Audífonos Sony', 'Audífonos con cancelación de ruido, Bluetooth 5.0', 200.00, 'USD', 1, 1),
('Tablet iPad Air', 'Tablet Apple con M1, 10.9 pulgadas', 700.00, 'USD', 3, 1),
('Smartwatch Samsung', 'Reloj inteligente con GPS, monitor cardiaco', 250.00, 'USD', 3, 1),
('Cafetera Nespresso', 'Cafetera de cápsulas, 19 bares de presión', 150.00, 'USD', 6, 1),
('Licuadora Oster', 'Licuadora de alta potencia, 1000W', 80.00, 'USD', 6, 1),
('Set de Sartenes', 'Sartenes antiadherentes 3 piezas, titanio', 90.00, 'USD', 6, 1),
('Mesa de Centro', 'Mesa de madera para sala, diseño moderno', 200.00, 'USD', 7, 1);
GO

-- Insertar variantes para cada producto (mínimo 3 por producto)
INSERT INTO SQM_GENERAL.Tbl_ProductVariables (ProductId, VariableName, Price, Stock, IsActive) VALUES
-- Producto 1: Laptop Gamer ASUS
(1, '16GB RAM + 512GB SSD + RTX 4060', 2500.00, 15, 1),
(1, '32GB RAM + 1TB SSD + RTX 4080', 3000.00, 10, 1),
(1, '64GB RAM + 2TB SSD + RTX 4090', 3500.00, 5, 1),
-- Producto 2: Laptop Office HP
(2, '8GB RAM + 256GB SSD', 800.00, 25, 1),
(2, '16GB RAM + 512GB SSD', 950.00, 20, 1),
(2, '32GB RAM + 1TB SSD', 1100.00, 10, 1),
-- Producto 3: iPhone 15 Pro
(3, '256GB Negro', 1200.00, 30, 1),
(3, '512GB Plata', 1350.00, 25, 1),
(3, '1TB Azul', 1500.00, 15, 1),
-- Producto 4: Camisa Casual
(4, 'Talla S Blanco', 45.00, 50, 1),
(4, 'Talla M Azul', 45.00, 45, 1),
(4, 'Talla L Negro', 45.00, 40, 1),
-- Producto 5: Vestido Formal
(5, 'Talla S Rojo', 120.00, 20, 1),
(5, 'Talla M Negro', 120.00, 25, 1),
(5, 'Talla L Azul', 120.00, 15, 1),
-- Producto 6: Refrigeradora Samsung
(6, '300L Inoxidable', 950.00, 8, 1),
(6, '400L Inoxidable', 1100.00, 6, 1),
(6, '500L Inoxidable', 1300.00, 4, 1),
-- Producto 7: Sofá
(7, '3 plazas Gris', 650.00, 12, 1),
(7, '3 plazas Beige', 650.00, 10, 1),
(7, '3 plazas Azul', 650.00, 8, 1),
-- Producto 8: Caminadora
(8, 'Básica Plegable', 700.00, 15, 1),
(8, 'Profesional Motorizada', 900.00, 10, 1),
(8, 'Deportiva con Inclinación', 1100.00, 5, 1),
-- Producto 9: Carpa
(9, '2 personas', 120.00, 20, 1),
(9, '4 personas', 180.00, 15, 1),
(9, '6 personas', 250.00, 10, 1),
-- Producto 10: Libro
(10, 'Tapa blanda', 25.00, 100, 1),
(10, 'Tapa dura', 35.00, 50, 1),
(10, 'Edición de lujo', 50.00, 25, 1),
-- Producto 11: Monitor
(11, 'Full HD', 350.00, 30, 1),
(11, '4K UHD', 450.00, 20, 1),
(11, 'Curvo 4K', 550.00, 15, 1),
-- Producto 12: Teclado
(12, 'Switch Red', 80.00, 40, 1),
(12, 'Switch Blue', 80.00, 35, 1),
(12, 'Switch Brown', 80.00, 30, 1),
-- Producto 13: Mouse
(13, 'Negro', 50.00, 60, 1),
(13, 'Blanco', 50.00, 55, 1),
(13, 'Gris', 50.00, 50, 1),
-- Producto 14: Audífonos
(14, 'Negros', 200.00, 25, 1),
(14, 'Blancos', 200.00, 20, 1),
(14, 'Grises', 200.00, 15, 1),
-- Producto 15: iPad Air
(15, '64GB WiFi', 700.00, 20, 1),
(15, '256GB WiFi', 850.00, 15, 1),
(15, '256GB Cellular', 1000.00, 10, 1),
-- Producto 16: Smartwatch
(16, 'Negro', 250.00, 30, 1),
(16, 'Plata', 250.00, 25, 1),
(16, 'Dorado', 250.00, 20, 1),
-- Producto 17: Cafetera
(17, 'Blanca', 150.00, 25, 1),
(17, 'Negra', 150.00, 20, 1),
(17, 'Roja', 150.00, 15, 1),
-- Producto 18: Licuadora
(18, 'Blanca', 80.00, 30, 1),
(18, 'Negra', 80.00, 25, 1),
(18, 'Roja', 80.00, 20, 1),
-- Producto 19: Sartenes
(19, 'Negro', 90.00, 25, 1),
(19, 'Gris', 90.00, 20, 1),
(19, 'Rojo', 90.00, 15, 1),
-- Producto 20: Mesa
(20, 'Madera Roble', 200.00, 10, 1),
(20, 'Madera Nogal', 200.00, 8, 1),
(20, 'Madera Pino', 200.00, 12, 1);
GO

-- Registrar inventario para todas las variantes
INSERT INTO SQM_GENERAL.Tbl_Stocks (ProductVariableId, Quantity, LastUpdated)
SELECT Id, Stock, GETDATE()
FROM SQM_GENERAL.Tbl_ProductVariables
WHERE IsActive = 1;
GO

-- Crear usuarios
INSERT INTO SQM_SECURITY.Tbl_Users (Username, Email, FirstName, LastName, IsActive) VALUES
('juan_perez', 'juan.perez@email.com', 'Juan', 'Pérez', 1),
('maria_garcia', 'maria.garcia@email.com', 'María', 'García', 1),
('carlos_lopez', 'carlos.lopez@email.com', 'Carlos', 'López', 1),
('ana_martinez', 'ana.martinez@email.com', 'Ana', 'Martínez', 1),
('pedro_ramirez', 'pedro.ramirez@email.com', 'Pedro', 'Ramírez', 1),
('laura_sanchez', 'laura.sanchez@email.com', 'Laura', 'Sánchez', 1),
('david_torres', 'david.torres@email.com', 'David', 'Torres', 1),
('patricia_ruiz', 'patricia.ruiz@email.com', 'Patricia', 'Ruiz', 1);
GO

-- Crear carritos de compras
INSERT INTO SQM_GENERAL.Tbl_Carts (UserId, CartDate, IsActive) VALUES
(1, GETDATE(), 1),
(2, GETDATE(), 1),
(3, GETDATE(), 1),
(4, GETDATE(), 1),
(5, GETDATE(), 1),
(6, GETDATE(), 1),
(7, GETDATE(), 1),
(8, GETDATE(), 1);
GO

-- Insertar detalles de carrito (mínimo 5 productos por carrito)
-- Carrito 1
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(1, 1, 1, 2500.00, 100.00, 1),
(1, 7, 2, 1200.00, 50.00, 1),
(1, 10, 3, 45.00, 5.00, 1),
(1, 13, 1, 45.00, 0.00, 1),
(1, 16, 1, 950.00, 50.00, 1),
(1, 19, 2, 650.00, 30.00, 1),
(1, 22, 1, 700.00, 25.00, 1);
GO

-- Carrito 2
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(2, 2, 1, 3000.00, 150.00, 1),
(2, 8, 1, 1350.00, 50.00, 1),
(2, 11, 2, 45.00, 0.00, 1),
(2, 14, 1, 120.00, 10.00, 1),
(2, 17, 1, 1100.00, 75.00, 1),
(2, 20, 1, 650.00, 20.00, 1),
(2, 23, 2, 900.00, 50.00, 1);
GO

-- Carrito 3
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(3, 3, 1, 3500.00, 200.00, 1),
(3, 9, 1, 1500.00, 75.00, 1),
(3, 12, 3, 45.00, 10.00, 1),
(3, 15, 1, 120.00, 5.00, 1),
(3, 18, 2, 1300.00, 100.00, 1),
(3, 21, 1, 650.00, 15.00, 1),
(3, 24, 1, 1100.00, 50.00, 1);
GO

-- Carrito 4
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(4, 4, 2, 800.00, 50.00, 1),
(4, 7, 1, 1200.00, 25.00, 1),
(4, 10, 2, 45.00, 0.00, 1),
(4, 13, 1, 45.00, 5.00, 1),
(4, 16, 1, 950.00, 30.00, 1),
(4, 22, 1, 700.00, 20.00, 1),
(4, 25, 2, 180.00, 15.00, 1);
GO

-- Carrito 5
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(5, 5, 1, 950.00, 25.00, 1),
(5, 8, 2, 1350.00, 100.00, 1),
(5, 11, 1, 45.00, 0.00, 1),
(5, 14, 1, 120.00, 5.00, 1),
(5, 17, 1, 1100.00, 40.00, 1),
(5, 23, 1, 900.00, 30.00, 1),
(5, 26, 3, 25.00, 5.00, 1);
GO

-- Carrito 6
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(6, 6, 1, 1100.00, 75.00, 1),
(6, 9, 1, 1500.00, 50.00, 1),
(6, 12, 2, 45.00, 0.00, 1),
(6, 15, 1, 120.00, 8.00, 1),
(6, 18, 1, 1300.00, 60.00, 1),
(6, 21, 1, 650.00, 12.00, 1),
(6, 27, 2, 35.00, 5.00, 1);
GO

-- Carrito 7
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(7, 1, 2, 2500.00, 200.00, 1),
(7, 8, 1, 1350.00, 45.00, 1),
(7, 11, 3, 45.00, 8.00, 1),
(7, 14, 2, 120.00, 12.00, 1),
(7, 19, 1, 650.00, 18.00, 1),
(7, 22, 1, 700.00, 22.00, 1),
(7, 28, 1, 50.00, 5.00, 1);
GO

-- Carrito 8
INSERT INTO SQM_GENERAL.Tbl_CartDetails (CartId, ProductVariableId, Quantity, Price, Discount, IsActive) VALUES
(8, 3, 1, 3500.00, 180.00, 1),
(8, 7, 2, 1200.00, 60.00, 1),
(8, 10, 2, 45.00, 4.00, 1),
(8, 13, 3, 45.00, 6.00, 1),
(8, 16, 1, 950.00, 35.00, 1),
(8, 20, 1, 650.00, 15.00, 1),
(8, 29, 1, 80.00, 5.00, 1);
GO

-- Insertar movimientos de stock
INSERT INTO SQM_GENERAL.Tbl_StockMovements (MovementType, Description, CreatedBy) VALUES
('INGRESO INVENTARIO', 'Compra a proveedor inicial - Electronics SA', 'Admin'),
('INGRESO INVENTARIO', 'Reabastecimiento mensual - Tech Distributors', 'Admin'),
('EGRESO INVENTARIO', 'Venta a cliente - Orden #1001', 'Sistema'),
('EGRESO INVENTARIO', 'Venta online - Orden #1002', 'Sistema'),
('INGRESO INVENTARIO', 'Devolución de cliente - Orden #1001', 'Admin'),
('EGRESO INVENTARIO', 'Venta a cliente - Orden #1003', 'Sistema'),
('INGRESO INVENTARIO', 'Nuevo inventario - Temporada', 'Admin'),
('EGRESO INVENTARIO', 'Venta a cliente - Orden #1004', 'Sistema');
GO

INSERT INTO SQM_GENERAL.Tbl_StockMovementDetails (MovementId, ProductVariableId, Quantity, UnitPrice) VALUES
(1, 1, 20, 2000.00),
(1, 2, 15, 2500.00),
(1, 3, 10, 3000.00),
(2, 4, 30, 600.00),
(2, 5, 25, 750.00),
(2, 6, 20, 900.00),
(3, 1, 2, 2500.00),
(3, 2, 1, 3000.00),
(3, 7, 3, 1200.00),
(4, 8, 2, 1350.00),
(4, 9, 1, 1500.00),
(5, 1, 1, 2500.00),
(6, 10, 5, 45.00),
(6, 11, 3, 45.00),
(7, 16, 10, 950.00),
(7, 17, 8, 1100.00),
(8, 19, 2, 650.00),
(8, 20, 1, 650.00);
GO

-- =============================================
-- 2. CREACIÓN DE TRIGGERS
-- =============================================

-- Trigger para INGRESO DE INVENTARIO
CREATE TRIGGER SQM_GENERAL.Trg_StockInput
ON SQM_GENERAL.Tbl_StockMovementDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Actualizar stock existente
        UPDATE s
        SET 
            s.Quantity = s.Quantity + i.Quantity,
            s.LastUpdated = GETDATE()
        FROM SQM_GENERAL.Tbl_Stocks s
        INNER JOIN inserted i ON s.ProductVariableId = i.ProductVariableId
        INNER JOIN SQM_GENERAL.Tbl_StockMovements m ON i.MovementId = m.MovementId
        WHERE m.MovementType = 'INGRESO INVENTARIO';
        
        -- Insertar nuevos registros si no existen
        INSERT INTO SQM_GENERAL.Tbl_Stocks (ProductVariableId, Quantity, LastUpdated)
        SELECT 
            i.ProductVariableId,
            i.Quantity,
            GETDATE()
        FROM inserted i
        INNER JOIN SQM_GENERAL.Tbl_StockMovements m ON i.MovementId = m.MovementId
        WHERE m.MovementType = 'INGRESO INVENTARIO'
            AND NOT EXISTS (SELECT 1 FROM SQM_GENERAL.Tbl_Stocks s WHERE s.ProductVariableId = i.ProductVariableId);
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Trigger para EGRESO DE INVENTARIO
CREATE TRIGGER SQM_GENERAL.Trg_StockOutput
ON SQM_GENERAL.Tbl_StockMovementDetails
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar stock suficiente antes de actualizar
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN SQM_GENERAL.Tbl_StockMovements m ON i.MovementId = m.MovementId
            INNER JOIN SQM_GENERAL.Tbl_Stocks s ON s.ProductVariableId = i.ProductVariableId
            WHERE m.MovementType = 'EGRESO INVENTARIO'
                AND s.Quantity < i.Quantity
        )
        BEGIN
            RAISERROR('Error: Stock insuficiente para realizar el egreso', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Actualizar stock
        UPDATE s
        SET 
            s.Quantity = s.Quantity - i.Quantity,
            s.LastUpdated = GETDATE()
        FROM SQM_GENERAL.Tbl_Stocks s
        INNER JOIN inserted i ON s.ProductVariableId = i.ProductVariableId
        INNER JOIN SQM_GENERAL.Tbl_StockMovements m ON i.MovementId = m.MovementId
        WHERE m.MovementType = 'EGRESO INVENTARIO';
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- =============================================
-- 3. CREACIÓN DE FUNCIONES ESCALARES
-- =============================================

-- Función para calcular descuento
CREATE FUNCTION SQM_GENERAL.Fn_CalculateDiscount
(
    @DiscountPercentage INT,
    @Price DECIMAL(18,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Result DECIMAL(18,2);
    
    -- Validar parámetros
    IF @DiscountPercentage IS NULL OR @Price IS NULL
        RETURN NULL;
    
    -- Validar rango de descuento
    IF @DiscountPercentage < 0 
        SET @DiscountPercentage = 0;
    
    IF @DiscountPercentage > 100
        SET @DiscountPercentage = 100;
    
    -- Calcular descuento
    SET @Result = @Price * (@DiscountPercentage / 100.0);
    
    RETURN @Result;
END;
GO

-- Función para calcular subtotal
CREATE FUNCTION SQM_GENERAL.Fn_CalculateSubtotal
(
    @Price DECIMAL(18,2),
    @Quantity INT,
    @Discount DECIMAL(18,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Result DECIMAL(18,2);
    
    -- Validar parámetros
    IF @Price IS NULL OR @Quantity IS NULL OR @Discount IS NULL
        RETURN NULL;
    
    -- Validar valores negativos
    IF @Price < 0
        SET @Price = 0;
    
    IF @Quantity < 0
        SET @Quantity = 0;
    
    IF @Discount < 0
        SET @Discount = 0;
    
    -- Calcular subtotal
    SET @Result = (@Price * @Quantity) - @Discount;
    
    -- Asegurar que no sea negativo
    IF @Result < 0
        SET @Result = 0;
    
    RETURN @Result;
END;
GO

-- Función para calcular impuesto (15% fijo)
CREATE FUNCTION SQM_GENERAL.Fn_CalculateTAX
(
    @Subtotal DECIMAL(18,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Result DECIMAL(18,2);
    
    -- Validar parámetro
    IF @Subtotal IS NULL
        RETURN NULL;
    
    -- Validar subtotal negativo
    IF @Subtotal < 0
        SET @Subtotal = 0;
    
    -- Impuesto fijo del 15%
    SET @Result = @Subtotal * 0.15;
    
    RETURN @Result;
END;
GO

-- Función para calcular total
CREATE FUNCTION SQM_GENERAL.Fn_CalculateTotal
(
    @Subtotal DECIMAL(18,2),
    @Tax DECIMAL(18,2),
    @ShippingCost DECIMAL(18,2) = 0  -- Opcional
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @Result DECIMAL(18,2);
    
    -- Validar parámetros obligatorios
    IF @Subtotal IS NULL OR @Tax IS NULL
        RETURN NULL;
    
    -- Validar valores negativos
    IF @Subtotal < 0
        SET @Subtotal = 0;
    
    IF @Tax < 0
        SET @Tax = 0;
    
    IF @ShippingCost IS NULL OR @ShippingCost < 0
        SET @ShippingCost = 0;
    
    -- Calcular total
    SET @Result = @Subtotal + @Tax + @ShippingCost;
    
    RETURN @Result;
END;
GO

-- =============================================
-- 4. CREACIÓN DE VISTAS
-- =============================================

-- Vista de identificadores de productos activos
CREATE VIEW SQM_GENERAL.Vw_ProductByIdentificators
AS
SELECT 
    pi.Id AS IdentificatorId,
    pi.CategoryId,
    pi.SubCategoryId,
    pi.SegmentId,
    CASE 
        WHEN pi.CategoryId = 1 THEN 'Electrónica'
        WHEN pi.CategoryId = 2 THEN 'Ropa'
        WHEN pi.CategoryId = 3 THEN 'Hogar'
        WHEN pi.CategoryId = 4 THEN 'Deportes'
        WHEN pi.CategoryId = 5 THEN 'Libros'
        ELSE 'Otros'
    END AS CategoryName,
    CASE 
        WHEN pi.SubCategoryId = 1 AND pi.CategoryId = 1 THEN 'Computadoras'
        WHEN pi.SubCategoryId = 2 AND pi.CategoryId = 1 THEN 'Smartphones'
        WHEN pi.SubCategoryId = 1 AND pi.CategoryId = 2 THEN 'Hombre'
        WHEN pi.SubCategoryId = 2 AND pi.CategoryId = 2 THEN 'Mujer'
        WHEN pi.SubCategoryId = 1 AND pi.CategoryId = 3 THEN 'Cocina'
        WHEN pi.SubCategoryId = 2 AND pi.CategoryId = 3 THEN 'Muebles'
        WHEN pi.SubCategoryId = 1 AND pi.CategoryId = 4 THEN 'Fitness'
        WHEN pi.SubCategoryId = 2 AND pi.CategoryId = 4 THEN 'Camping'
        WHEN pi.SubCategoryId = 1 AND pi.CategoryId = 5 THEN 'Ficción'
        ELSE 'General'
    END AS SubCategoryName,
    pi.IsActive,
    pi.CreatedDate
FROM SQM_CATALOGS.Tbl_ProductIdentificators pi
WHERE pi.IsActive = 1;
GO

-- Vista de productos con atributos activos
CREATE VIEW SQM_GENERAL.Vw_ProductWithAttributes
AS
SELECT 
    ap.Id AS AttributeProductId,
    ap.ProductId,
    p.ProductName,
    p.BasePrice,
    p.Currency,
    ap.AttributeId,
    CASE 
        WHEN ap.AttributeId = 1 THEN 'Color'
        WHEN ap.AttributeId = 2 THEN 'Tamaño'
        WHEN ap.AttributeId = 3 THEN 'Material'
        WHEN ap.AttributeId = 4 THEN 'Peso'
        WHEN ap.AttributeId = 5 THEN 'Marca'
        ELSE 'Otro'
    END AS AttributeName,
    ap.AttributeValue,
    ap.IsActive,
    ap.CreatedDate
FROM SQM_CATALOGS.Tbl_AttributeProducts ap
INNER JOIN SQM_GENERAL.Tbl_Products p ON ap.ProductId = p.Id
WHERE ap.IsActive = 1;
GO

-- Vista de variantes de productos activas
CREATE VIEW SQM_GENERAL.Vw_ProductByVariables
AS
SELECT 
    pv.Id AS VariableId,
    pv.ProductId,
    p.ProductName,
    p.Description,
    pv.VariableName,
    pv.Price,
    pv.Stock,
    p.Currency,
    pv.IsActive,
    pv.CreatedDate
FROM SQM_GENERAL.Tbl_ProductVariables pv
INNER JOIN SQM_GENERAL.Tbl_Products p ON pv.ProductId = p.Id
WHERE pv.IsActive = 1;
GO

-- Vista de atributos de variantes activos
CREATE VIEW SQM_GENERAL.Vw_ProductWithVariableAttributes
AS
SELECT 
    apv.Id AS AttributeVariableId,
    apv.ProductVariableId,
    pv.VariableName,
    p.ProductName,
    pv.Price,
    apv.AttributeId,
    CASE 
        WHEN apv.AttributeId = 1 THEN 'Color'
        WHEN apv.AttributeId = 2 THEN 'Tamaño'
        WHEN apv.AttributeId = 3 THEN 'Material'
        WHEN apv.AttributeId = 4 THEN 'Peso'
        ELSE 'Otro'
    END AS AttributeName,
    apv.AttributeValue,
    apv.IsActive,
    apv.CreatedDate
FROM SQM_GENERAL.Tbl_AttributeProductVariables apv
INNER JOIN SQM_GENERAL.Tbl_ProductVariables pv ON apv.ProductVariableId = pv.Id
INNER JOIN SQM_GENERAL.Tbl_Products p ON pv.ProductId = p.Id
WHERE apv.IsActive = 1;
GO

-- Vista de carrito por usuario con cálculos
CREATE VIEW SQM_GENERAL.Vw_CartByUser
AS
SELECT 
    u.Id AS UserId,
    u.Username,
    u.Email,
    u.FirstName,
    u.LastName,
    c.Id AS CartId,
    c.CartDate,
    cd.Id AS CartDetailId,
    cd.ProductVariableId,
    pv.VariableName AS ProductVariant,
    p.ProductName,
    p.Description,
    cd.Quantity,
    cd.Price AS UnitPrice,
    cd.Discount AS DiscountAmount,
    cd.Currency,
    -- Calcular subtotal usando la función
    SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount) AS Subtotal,
    -- Calcular impuesto usando la función
    SQM_GENERAL.Fn_CalculateTAX(SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount)) AS Tax,
    -- Calcular total con envío de $10 como ejemplo
    SQM_GENERAL.Fn_CalculateTotal(
        SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount),
        SQM_GENERAL.Fn_CalculateTAX(SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount)),
        10.00  -- Costo de envío estándar
    ) AS TotalWithShipping,
    c.IsActive AS CartActive,
    cd.IsActive AS DetailActive
FROM SQM_SECURITY.Tbl_Users u
INNER JOIN SQM_GENERAL.Tbl_Carts c ON u.Id = c.UserId
INNER JOIN SQM_GENERAL.Tbl_CartDetails cd ON c.Id = cd.CartId
INNER JOIN SQM_GENERAL.Tbl_ProductVariables pv ON cd.ProductVariableId = pv.Id
INNER JOIN SQM_GENERAL.Tbl_Products p ON pv.ProductId = p.Id
WHERE c.IsActive = 1;
GO

-- Vista de detalles de carrito por usuario (activos)
CREATE VIEW SQM_GENERAL.Vw_CartDetailsByUser
AS
SELECT 
    u.Id AS UserId,
    u.Username,
    u.Email,
    u.FirstName,
    u.LastName,
    c.Id AS CartId,
    c.CartDate,
    cd.Id AS CartDetailId,
    cd.ProductVariableId,
    pv.VariableName AS ProductVariant,
    p.ProductName,
    cd.Quantity,
    cd.Price AS UnitPrice,
    cd.Discount AS DiscountAmount,
    cd.Currency,
    -- Calcular subtotal usando la función
    SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount) AS Subtotal,
    cd.IsActive AS DetailActive,
    cd.CreatedDate
FROM SQM_SECURITY.Tbl_Users u
INNER JOIN SQM_GENERAL.Tbl_Carts c ON u.Id = c.UserId AND c.IsActive = 1
INNER JOIN SQM_GENERAL.Tbl_CartDetails cd ON c.Id = cd.CartId
INNER JOIN SQM_GENERAL.Tbl_ProductVariables pv ON cd.ProductVariableId = pv.Id
INNER JOIN SQM_GENERAL.Tbl_Products p ON pv.ProductId = p.Id
WHERE cd.Quantity > 0 
    AND cd.IsActive = 1
    -- Verificar que el usuario solo tenga este carrito activo
    AND NOT EXISTS (
        SELECT 1 
        FROM SQM_GENERAL.Tbl_Carts c2 
        WHERE c2.UserId = u.Id 
            AND c2.IsActive = 1
            AND c2.Id > c.Id
    );
GO

-- =============================================
-- VISTAS ADICIONALES PARA CONSULTAS ÚTILES
-- =============================================

-- Vista de inventario actual
CREATE VIEW SQM_GENERAL.Vw_CurrentInventory
AS
SELECT 
    s.Id AS StockId,
    s.ProductVariableId,
    pv.VariableName,
    p.ProductName,
    p.BasePrice,
    s.Quantity,
    s.LastUpdated,
    CASE 
        WHEN s.Quantity <= 5 THEN 'CRÍTICO - Reordenar urgentemente'
        WHEN s.Quantity <= 10 THEN 'BAJO - Reordenar pronto'
        WHEN s.Quantity <= 20 THEN 'MEDIO - Stock suficiente'
        ELSE 'ALTO - Stock abundante'
    END AS StockStatus,
    CASE 
        WHEN s.Quantity <= 5 THEN '#FF0000' -- Rojo
        WHEN s.Quantity <= 10 THEN '#FFA500' -- Naranja
        WHEN s.Quantity <= 20 THEN '#FFFF00' -- Amarillo
        ELSE '#00FF00' -- Verde
    END AS StockColor
FROM SQM_GENERAL.Tbl_Stocks s
INNER JOIN SQM_GENERAL.Tbl_ProductVariables pv ON s.ProductVariableId = pv.Id
INNER JOIN SQM_GENERAL.Tbl_Products p ON pv.ProductId = p.Id;
GO

-- Vista de resumen de carritos
CREATE VIEW SQM_GENERAL.Vw_CartSummary
AS
SELECT 
    c.Id AS CartId,
    u.Username,
    u.Email,
    COUNT(DISTINCT cd.Id) AS TotalUniqueItems,
    SUM(cd.Quantity) AS TotalProducts,
    SUM(cd.Price * cd.Quantity) AS GrossAmount,
    SUM(cd.Discount) AS TotalDiscount,
    SUM(SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount)) AS CartSubtotal,
    SUM(SQM_GENERAL.Fn_CalculateTAX(SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount))) AS TotalTax,
    SUM(SQM_GENERAL.Fn_CalculateTotal(
        SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount),
        SQM_GENERAL.Fn_CalculateTAX(SQM_GENERAL.Fn_CalculateSubtotal(cd.Price, cd.Quantity, cd.Discount)),
        10.00
    )) AS CartTotal,
    c.CartDate,
    c.IsActive
FROM SQM_GENERAL.Tbl_Carts c
INNER JOIN SQM_SECURITY.Tbl_Users u ON c.UserId = u.Id
LEFT JOIN SQM_GENERAL.Tbl_CartDetails cd ON c.Id = cd.CartId AND cd.IsActive = 1
GROUP BY c.Id, u.Username, u.Email, c.CartDate, c.IsActive;
GO

-- Vista de productos más vendidos
CREATE VIEW SQM_GENERAL.Vw_TopSellingProducts
AS
SELECT 
    p.Id AS ProductId,
    p.ProductName,
    pv.Id AS VariableId,
    pv.VariableName,
    SUM(cd.Quantity) AS TotalSold,
    COUNT(DISTINCT cd.CartId) AS TimesInCarts,
    AVG(cd.Price) AS AveragePrice,
    SUM(cd.Quantity * cd.Price) AS TotalRevenue
FROM SQM_GENERAL.Tbl_Products p
INNER JOIN SQM_GENERAL.Tbl_ProductVariables pv ON p.Id = pv.ProductId
INNER JOIN SQM_GENERAL.Tbl_CartDetails cd ON pv.Id = cd.ProductVariableId
WHERE cd.IsActive = 1
GROUP BY p.Id, p.ProductName, pv.Id, pv.VariableName;
GO

-- =============================================
-- CONSULTAS DE VERIFICACIÓN (CORREGIDAS)
-- =============================================

PRINT '=============================================';
PRINT 'VERIFICACIÓN DE CREACIÓN DE BASE DE DATOS';
PRINT '=============================================';
PRINT '';

PRINT '=== TABLAS CREADAS ===';
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

PRINT '=== VISTAS CREADAS ===';
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.VIEWS 
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO

PRINT '=== FUNCIONES CREADAS ===';
SELECT SPECIFIC_SCHEMA, SPECIFIC_NAME 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'FUNCTION'
ORDER BY SPECIFIC_SCHEMA, SPECIFIC_NAME;
GO

PRINT '=== TRIGGERS CREADOS ===';
SELECT name, type_desc 
FROM sys.triggers 
WHERE type = 'TR';
GO

PRINT '=== VERIFICACIÓN DE DATOS INSERTADOS ===';
PRINT '';

-- Usar variables para almacenar los conteos
DECLARE @TotalProductos INT, @TotalVariantes INT, @TotalUsuarios INT, 
        @TotalCarritos INT, @TotalDetalles INT, @TotalMovimientos INT, @TotalDetallesMov INT;

SELECT @TotalProductos = COUNT(*) FROM SQM_GENERAL.Tbl_Products;
SELECT @TotalVariantes = COUNT(*) FROM SQM_GENERAL.Tbl_ProductVariables;
SELECT @TotalUsuarios = COUNT(*) FROM SQM_SECURITY.Tbl_Users;
SELECT @TotalCarritos = COUNT(*) FROM SQM_GENERAL.Tbl_Carts;
SELECT @TotalDetalles = COUNT(*) FROM SQM_GENERAL.Tbl_CartDetails;
SELECT @TotalMovimientos = COUNT(*) FROM SQM_GENERAL.Tbl_StockMovements;
SELECT @TotalDetallesMov = COUNT(*) FROM SQM_GENERAL.Tbl_StockMovementDetails;

PRINT 'Total de productos: ' + CAST(@TotalProductos AS VARCHAR);
PRINT 'Total de variantes: ' + CAST(@TotalVariantes AS VARCHAR);
PRINT 'Total de usuarios: ' + CAST(@TotalUsuarios AS VARCHAR);
PRINT 'Total de carritos: ' + CAST(@TotalCarritos AS VARCHAR);
PRINT 'Total de detalles de carrito: ' + CAST(@TotalDetalles AS VARCHAR);
PRINT 'Total de movimientos de stock: ' + CAST(@TotalMovimientos AS VARCHAR);
PRINT 'Total de detalles de movimiento: ' + CAST(@TotalDetallesMov AS VARCHAR);
PRINT '';

PRINT '=== VERIFICACIÓN DE FUNCIONES ===';

DECLARE @DiscountResult DECIMAL(18,2), @SubtotalResult DECIMAL(18,2), 
        @TaxResult DECIMAL(18,2), @TotalResult DECIMAL(18,2);

SELECT @DiscountResult = SQM_GENERAL.Fn_CalculateDiscount(20, 100.00);
SELECT @SubtotalResult = SQM_GENERAL.Fn_CalculateSubtotal(100.00, 2, 10.00);
SELECT @TaxResult = SQM_GENERAL.Fn_CalculateTAX(190.00);
SELECT @TotalResult = SQM_GENERAL.Fn_CalculateTotal(190.00, 28.50, 10.00);

PRINT 'Fn_CalculateDiscount (20%, $100): $' + CAST(@DiscountResult AS VARCHAR);
PRINT 'Fn_CalculateSubtotal ($100, 2, $10): $' + CAST(@SubtotalResult AS VARCHAR);
PRINT 'Fn_CalculateTAX ($190): $' + CAST(@TaxResult AS VARCHAR);
PRINT 'Fn_CalculateTotal ($190, $28.5, $10): $' + CAST(@TotalResult AS VARCHAR);
PRINT '';

PRINT '=== EJEMPLO DE CONSULTA - Vw_CartSummary ===';
SELECT TOP 3 * FROM SQM_GENERAL.Vw_CartSummary;
PRINT '';

PRINT '=== EJEMPLO DE CONSULTA - Vw_CurrentInventory ===';
SELECT TOP 5 * FROM SQM_GENERAL.Vw_CurrentInventory WHERE StockStatus LIKE '%CRÍTICO%';
PRINT '';

PRINT '=============================================';
PRINT 'SCRIPT COMPLETADO EXITOSAMENTE';
PRINT 'BASE DE DATOS: EcommerceDistribuido';
PRINT '=============================================';
GO