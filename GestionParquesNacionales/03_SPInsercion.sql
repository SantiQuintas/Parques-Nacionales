/*
===============================================================================
  MATERIA:     Bases de Datos Aplicada - 3641
  COMISION:    02-5600
  UNIVERSIDAD: Universidad Nacional de la Matanza
  GRUPO:       10
  INTEGRANTES:
      - Amarilla, Facundo Nahuel   - 46201679
      - Ávila García, Eric Luis    - 43722795
      - Borgoño Villafañe, Gonzalo - 46645738
      - Quintas, Santiago Emanuel  - 46737706

  Archivo:      03_SPInsercion.sql
  Descripcion:  Stored Procedures de INSERT (alta) para todas las tablas del
                sistema de gestión de Parques Nacionales.
===============================================================================
*/

USE ParquesNacionales;
GO

-- ============================================================
-- ESQUEMA: parques
-- ============================================================

/* ============================================================
   sp_InsertarParque
   Inserta un nuevo parque en parques.Parque.

   Validaciones:
     1. nombre no puede ser nulo ni vacío.
     2. ubicacion no puede ser nula ni vacía.
     3. superficie debe ser mayor a 0.
     4. tipo debe pertenecer al dominio definido en el CHECK.
   Salida: id_parque generado mediante OUTPUT.
============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_InsertarParque
(
    @p_nombre     VARCHAR(100),
    @p_ubicacion  VARCHAR(200),
    @p_superficie DECIMAL(12,2),
    @p_tipo       VARCHAR(50),
    @p_latitud    DECIMAL(9,6),
    @p_longitud   DECIMAL(9,6)
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 1: nombre obligatorio
    IF @p_nombre IS NULL OR LTRIM(RTRIM(@p_nombre)) = ''
        SET @v_errores += N'- [nombre] El nombre del parque es obligatorio.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 2: ubicacion obligatoria
    IF @p_ubicacion IS NULL OR LTRIM(RTRIM(@p_ubicacion)) = ''
        SET @v_errores += N'- [ubicacion] La ubicación del parque es obligatoria.' + CHAR(10);

    -- Validacion 3: superficie positiva
    IF @p_superficie IS NULL OR @p_superficie <= 0
        SET @v_errores += N'- [superficie] La superficie debe ser mayor a 0.' + CHAR(10);

    -- Tipos válidos: Nacional, Reserva, Monumento, Reserva Estricta, Interjurisdiccional
    -- Solo se permiten valores del dominio definido
    -- Validacion 4: tipo en dominio valido
    IF @p_tipo NOT IN (
        'Parque Nacional',
        'Reserva Nacional',
        'Monumento Natural',
        'Reserva Natural Estricta',
        'Parque Interjurisdiccional'
    )
        SET @v_errores += N'- [tipo] El tipo debe ser uno de: Parque Nacional, Reserva Nacional, Monumento Natural, Reserva Natural Estricta, Parque Interjurisdiccional.' + CHAR(10);

    -- Coordenadas geográficas en grados decimales
    -- Validacion 5: latitud en rango valido
    -- Latitud: rango válido para el hemisferio sur
    IF @p_latitud IS NULL OR @p_latitud <= -90 OR @p_latitud >= 90
        SET @v_errores += N'- [latitud] La latitud debe ser mayor a -90 y menor a 90.' + CHAR(10);

    -- Validacion 6: longitud en rango valido
    -- Longitud: rango válido para territorio argentino
    IF @p_longitud IS NULL OR @p_longitud <= -180 OR @p_longitud >= 180
        SET @v_errores += N'- [longitud] La longitud debe ser mayor a -180 y menor a 180.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO parques.Parque (nombre, ubicacion, superficie, tipo, latitud, longitud)
    -- Retornar identificador del registro recién creado
    OUTPUT INSERTED.id_parque
    VALUES (
        LTRIM(RTRIM(@p_nombre)),
        -- Limpiar espacios antes de insertar
        LTRIM(RTRIM(@p_ubicacion)),
        -- Limpiar espacios antes de insertar
        @p_superficie,
        @p_tipo,
        @p_latitud,
        @p_longitud
    );
END
GO


/* ============================================================
   sp_InsertarTipoVisitante
   Inserta una categoria de visitante en parques.TipoVisitante.

   Validaciones:
     1. descripcion debe pertenecer al dominio definido en el CHECK.
     2. No puede existir ya esa descripcion (UNIQUE).
   Salida: id_tipo generado.
============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_InsertarTipoVisitante
(
    @p_descripcion VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- 5 categorías de visitantes definidas por el parque
    -- Solo se permiten valores del dominio definido
    -- Validacion 1: descripcion en dominio valido
    IF @p_descripcion NOT IN ('Residente', 'Extranjero', 'Estudiante', 'Jubilado', 'Menor')
        SET @v_errores += N'- [descripcion] Debe ser uno de: Residente, Extranjero, Estudiante, Jubilado, Menor.' + CHAR(10);

    -- Verificar que no exista un registro duplicado
    -- Validacion 2: no duplicado
    IF EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE descripcion = @p_descripcion)
        SET @v_errores += N'- [descripcion] Ya existe un tipo de visitante con esa descripción.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO parques.TipoVisitante (descripcion)
    -- Retornar identificador del registro recién creado
    OUTPUT INSERTED.id_tipo
    VALUES (@p_descripcion);
END
GO


/* ============================================================
   sp_InsertarPrecioEntrada
   Registra un nuevo precio para un parque y tipo de visitante.

   Validaciones:
     1. id_parque debe existir en parques.Parque.
     2. id_tipo debe existir en parques.TipoVisitante.
     3. precio debe ser >= 0.
     4. vigencia_desde no puede ser nula.
     5. No puede existir ya una combinacion (id_parque, id_tipo, vigencia_desde) idéntica (UNIQUE).
   Salida: id_precio generado.
============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_InsertarPrecioEntrada
(
    @p_id_parque      INT,
    @p_id_tipo        INT,
    @p_precio         DECIMAL(10,2),
    @p_vigencia_desde DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: parque existe
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 2: tipo de visitante existe
    IF NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE id_tipo = @p_id_tipo)
        SET @v_errores += N'- [id_tipo] No existe un tipo de visitante con ese ID.' + CHAR(10);

    -- Validacion 3: precio no negativo
    IF @p_precio IS NULL OR @p_precio < 0
        SET @v_errores += N'- [precio] El precio no puede ser negativo ni nulo.' + CHAR(10);

    -- Validacion 4: vigencia_desde obligatoria
    IF @p_vigencia_desde IS NULL
        SET @v_errores += N'- [vigencia_desde] La fecha de vigencia es obligatoria.' + CHAR(10);

    -- Un mismo parque/tipo solo puede tener un precio vigente desde cada fecha
    -- Verificar que no exista un registro duplicado
    -- Validacion 5: combinacion unica
    IF EXISTS (
        SELECT 1
        FROM parques.PrecioEntrada
        WHERE id_parque = @p_id_parque
          AND id_tipo   = @p_id_tipo
          AND vigencia_desde = @p_vigencia_desde
    )
        SET @v_errores += N'- [vigencia_desde] Ya existe un precio para ese parque, tipo de visitante y fecha de vigencia.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_id INT;

    -- Insertar el nuevo registro
    INSERT INTO parques.PrecioEntrada (id_parque, id_tipo, precio, vigencia_desde)
    VALUES (@p_id_parque, @p_id_tipo, @p_precio, @p_vigencia_desde);
    -- Capturar el ID generado por IDENTITY
    SET @v_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SELECT @v_id AS id_precio;
END
GO


-- ============================================================
-- ESQUEMA: ventas
-- ============================================================

/* ============================================================
   sp_InsertarMoneda
   Inserta una moneda extranjera en ventas.Moneda.

   Validaciones:
     1. codigo_iso debe tener exactamente 3 caracteres.
     2. nombre no puede ser nulo ni vacío.
     3. No puede existir ya ese codigo_iso (UNIQUE).
   Salida: id_moneda generado.
============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_InsertarMoneda
(
    @p_codigo_iso CHAR(3),
    @p_nombre     VARCHAR(50),
    @p_simbolo    VARCHAR(5) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 1: codigo ISO de 3 caracteres
    IF @p_codigo_iso IS NULL OR LEN(LTRIM(RTRIM(@p_codigo_iso))) <> 3
        SET @v_errores += N'- [codigo_iso] El código ISO debe tener exactamente 3 caracteres (ej: USD, EUR).' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 2: nombre obligatorio
    IF @p_nombre IS NULL OR LTRIM(RTRIM(@p_nombre)) = ''
        SET @v_errores += N'- [nombre] El nombre de la moneda es obligatorio.' + CHAR(10);

    -- Verificar que no exista un registro duplicado
    -- Validacion 3: codigo unico
    IF EXISTS (SELECT 1 FROM ventas.Moneda WHERE codigo_iso = UPPER(LTRIM(RTRIM(@p_codigo_iso))))
        SET @v_errores += N'- [codigo_iso] Ya existe una moneda con ese código ISO.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO ventas.Moneda (codigo_iso, nombre, simbolo)
    -- Retornar identificador del registro recién creado
    OUTPUT INSERTED.id_moneda
    VALUES (UPPER(LTRIM(RTRIM(@p_codigo_iso))), LTRIM(RTRIM(@p_nombre)), @p_simbolo);
    -- Limpiar espacios antes de insertar
END
GO


/* ============================================================
   sp_InsertarTasaCambio
   Registra una tasa de conversión a pesos para una moneda y fecha.

   Validaciones:
     1. id_moneda debe existir en ventas.Moneda.
     2. fecha_vigencia no puede ser nula.
     3. tasa_a_peso debe ser mayor a 0.
     4. No puede existir ya la combinacion (id_moneda, fecha_vigencia) (UNIQUE).
   Salida: id_tasa generado.
============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_InsertarTasaCambio
(
    @p_id_moneda      INT,
    @p_fecha_vigencia DATE,
    @p_tasa_a_peso    DECIMAL(12,4)
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: moneda existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Moneda WHERE id_moneda = @p_id_moneda)
        SET @v_errores += N'- [id_moneda] No existe una moneda con ese ID.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 2: fecha obligatoria
    IF @p_fecha_vigencia IS NULL
        SET @v_errores += N'- [fecha_vigencia] La fecha de vigencia es obligatoria.' + CHAR(10);

    -- Validacion 3: tasa positiva
    IF @p_tasa_a_peso IS NULL OR @p_tasa_a_peso <= 0
        SET @v_errores += N'- [tasa_a_peso] La tasa de cambio debe ser mayor a 0.' + CHAR(10);

    -- Verificar que no exista un registro duplicado
    -- Validacion 4: combinacion unica
    IF EXISTS (
        SELECT 1
        FROM ventas.TasaCambio
        WHERE id_moneda      = @p_id_moneda
          AND fecha_vigencia = @p_fecha_vigencia
    )
        SET @v_errores += N'- [fecha_vigencia] Ya existe una tasa para esa moneda y fecha.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO ventas.TasaCambio (id_moneda, fecha_vigencia, tasa_a_peso)
    -- Retornar identificador del registro recién creado
    OUTPUT INSERTED.id_tasa
    VALUES (@p_id_moneda, @p_fecha_vigencia, @p_tasa_a_peso);
END
GO


/* ============================================================
   sp_InsertarTicket
   Crea un comprobante de venta en ventas.Ticket.

   -- Reutiliza: Ninguno (SP raíz)
   Validaciones:
     1. id_parque debe existir en parques.Parque.
     2. fecha no puede ser nula.
     3. fecha_acceso no puede ser nula y debe ser >= fecha.
     4. punto_de_venta debe ser > 0.
     5. numero_comprobante debe ser > 0.
     6. La combinacion (punto_de_venta, numero_comprobante) debe ser única.
     7. forma_pago debe pertenecer al dominio definido en el CHECK.
     8. total_pagado debe ser >= 0.
   Salida: id_ticket generado.
============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_InsertarTicket
(
    @p_id_parque          INT,
    @p_fecha              DATE,
    @p_fecha_acceso       DATE,
    @p_punto_de_venta     INT,
    @p_numero_comprobante INT,
    @p_forma_pago         VARCHAR(30),
    @p_total_pagado       DECIMAL(10,2),
    @out_id               INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: parque existe
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 2: fecha obligatoria
    IF @p_fecha IS NULL
        SET @v_errores += N'- [fecha] La fecha de emisión es obligatoria.' + CHAR(10);

    -- Validacion 3: fecha_acceso >= fecha
    IF @p_fecha_acceso IS NULL
        SET @v_errores += N'- [fecha_acceso] La fecha de acceso es obligatoria.' + CHAR(10);
    ELSE IF @p_fecha IS NOT NULL AND @p_fecha_acceso < @p_fecha
        SET @v_errores += N'- [fecha_acceso] La fecha de acceso no puede ser anterior a la fecha de emisión.' + CHAR(10);

    -- Validacion 4: punto_de_venta positivo
    IF @p_punto_de_venta IS NULL OR @p_punto_de_venta <= 0
        SET @v_errores += N'- [punto_de_venta] El punto de venta debe ser mayor a 0.' + CHAR(10);

    -- Validacion 5: numero_comprobante positivo
    IF @p_numero_comprobante IS NULL OR @p_numero_comprobante <= 0
        SET @v_errores += N'- [numero_comprobante] El número de comprobante debe ser mayor a 0.' + CHAR(10);

    -- Comprobante único por punto de venta
    -- Verificar que no exista un registro duplicado
    -- Validacion 6: comprobante unico
    IF EXISTS (
        SELECT 1
        FROM ventas.Ticket
        WHERE punto_de_venta     = @p_punto_de_venta
          AND numero_comprobante = @p_numero_comprobante
    )
        SET @v_errores += N'- [numero_comprobante] Ya existe un comprobante con ese punto de venta y número.' + CHAR(10);

    -- Formas de pago aceptadas por el sistema
    -- Solo se permiten valores del dominio definido
    -- Validacion 7: forma_pago en dominio valido
    IF @p_forma_pago NOT IN (
        'Efectivo',
        'Tarjeta de Debito',
        'Tarjeta de Credito',
        'Transferencia',
        'Moneda Extranjera'
    )
        SET @v_errores += N'- [forma_pago] Debe ser uno de: Efectivo, Tarjeta de Debito, Tarjeta de Credito, Transferencia, Moneda Extranjera.' + CHAR(10);

    -- Validacion 8: total no negativo
    IF @p_total_pagado IS NULL OR @p_total_pagado < 0
        SET @v_errores += N'- [total_pagado] El total pagado no puede ser negativo ni nulo.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_local_id INT;

    -- Los campos fecha y fecha_acceso pueden diferir (compra anticipada)
    -- Insertar el nuevo registro
    INSERT INTO ventas.Ticket (
        id_parque, fecha, fecha_acceso,
        punto_de_venta, numero_comprobante, forma_pago, total_pagado
    )
    VALUES (
        @p_id_parque, @p_fecha, @p_fecha_acceso,
        @p_punto_de_venta, @p_numero_comprobante, @p_forma_pago, @p_total_pagado
    );
    -- SCOPE_IDENTITY retorna el último IDENTITY generado en el scope actual
    SET @v_local_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SET @out_id = @v_local_id;
    SELECT @v_local_id AS id_ticket;
END
GO

/* ============================================================
   sp_InsertarItemTicket
   Agrega un ítem (entrada o atraccion) a un ticket existente.

   -- Reutiliza: Ninguno (SP raíz)
   Validaciones:
     1. id_ticket debe existir en ventas.Ticket.
     2. Exactamente uno de (id_precio_entrada, id_atraccion) debe ser no nulo.
     3. Si se informa id_precio_entrada, debe existir en parques.PrecioEntrada.
     4. Si se informa id_atraccion, debe existir en actividades.Atraccion.
     5. precio_venta debe ser >= 0.
     6. cantidad debe ser > 0.
   Salida: id_item generado.
============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_InsertarItemTicket
(
    @p_id_ticket         INT,
    @p_id_precio_entrada INT           = NULL,
    @p_id_atraccion      INT           = NULL,
    @p_precio_venta      DECIMAL(10,2),
    @p_cantidad          INT,
    @out_id              INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: ticket existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Ticket WHERE id_ticket = @p_id_ticket)
        SET @v_errores += N'- [id_ticket] No existe un ticket con ese ID.' + CHAR(10);

    -- Debe informarse exactamente uno: entrada O atracción, no ambos ni ninguno
    -- Validación exclusiva: exactamente uno de los dos tipos de ítem
    -- Validacion 2: exactamente uno de los dos debe estar informado
    IF NOT (
        (@p_id_precio_entrada IS NOT NULL AND @p_id_atraccion IS NULL)
        OR
        (@p_id_precio_entrada IS NULL     AND @p_id_atraccion IS NOT NULL)
    )
        SET @v_errores += N'- [tipo_item] Debe informarse exactamente uno: id_precio_entrada o id_atraccion, no ambos ni ninguno.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 3: precio_entrada existe si se informó
    IF @p_id_precio_entrada IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM parques.PrecioEntrada WHERE id_precio = @p_id_precio_entrada)
        SET @v_errores += N'- [id_precio_entrada] No existe un precio de entrada con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 4: atraccion existe si se informó
    IF @p_id_atraccion IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion)
        SET @v_errores += N'- [id_atraccion] No existe una atracción con ese ID.' + CHAR(10);

    -- Validacion 5: precio no negativo
    IF @p_precio_venta IS NULL OR @p_precio_venta < 0
        SET @v_errores += N'- [precio_venta] El precio de venta no puede ser negativo ni nulo.' + CHAR(10);

    -- Validacion 6: cantidad positiva
    IF @p_cantidad IS NULL OR @p_cantidad <= 0
        SET @v_errores += N'- [cantidad] La cantidad debe ser mayor a 0.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_local_id INT;

    -- Insertar el nuevo registro
    INSERT INTO ventas.ItemTicket (
        id_ticket, id_precio_entrada, id_atraccion, precio_venta, cantidad
    )
    VALUES (
        @p_id_ticket, @p_id_precio_entrada, @p_id_atraccion, @p_precio_venta, @p_cantidad
    );
    -- Capturar ID del ítem insertado
    SET @v_local_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SET @out_id = @v_local_id;
    SELECT @v_local_id AS id_item;
END
GO


/* ============================================================
   sp_InsertarPagoMonedaExtranjera
   Registra el pago en moneda extranjera asociado a un ticket.

   -- Reutiliza: Ninguno (SP raíz)
   Validaciones:
     1. id_ticket debe existir en ventas.Ticket.
     2. id_tasa debe existir en ventas.TasaCambio.
     3. El ticket debe tener forma_pago = 'Moneda Extranjera'.
     4. monto_extranjero debe ser > 0.
     5. monto_pesos debe ser > 0.
   Salida: id_pago_ext generado.
============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_InsertarPagoMonedaExtranjera
(
    @p_id_ticket        INT,
    @p_id_tasa          INT,
    @p_monto_extranjero DECIMAL(12,2),
    @p_monto_pesos      DECIMAL(12,2),
    @out_id             INT = NULL OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: ticket existe
    IF NOT EXISTS (SELECT 1 FROM ventas.Ticket WHERE id_ticket = @p_id_ticket)
        SET @v_errores += N'- [id_ticket] No existe un ticket con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 2: tasa de cambio existe
    IF NOT EXISTS (SELECT 1 FROM ventas.TasaCambio WHERE id_tasa = @p_id_tasa)
        SET @v_errores += N'- [id_tasa] No existe una tasa de cambio con ese ID.' + CHAR(10);

    -- Solo aplica para tickets pagados en moneda extranjera
    -- Validacion 3: el ticket debe ser de forma_pago Moneda Extranjera
    IF NOT EXISTS (
        SELECT 1 FROM ventas.Ticket
        WHERE id_ticket  = @p_id_ticket
          AND forma_pago = 'Moneda Extranjera'
    )
        SET @v_errores += N'- [forma_pago] El ticket no tiene forma de pago "Moneda Extranjera"; no puede registrarse un pago en divisa.' + CHAR(10);

    -- Validacion 4: monto extranjero positivo
    IF @p_monto_extranjero IS NULL OR @p_monto_extranjero <= 0
        SET @v_errores += N'- [monto_extranjero] El monto en moneda extranjera debe ser mayor a 0.' + CHAR(10);

    -- Validacion 5: monto en pesos positivo
    IF @p_monto_pesos IS NULL OR @p_monto_pesos <= 0
        SET @v_errores += N'- [monto_pesos] El monto equivalente en pesos debe ser mayor a 0.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_local_id INT;

    -- Insertar el nuevo registro
    INSERT INTO ventas.PagoMonedaExtranjera (
        id_ticket, id_tasa, monto_extranjero, monto_pesos
    )
    VALUES (
        @p_id_ticket, @p_id_tasa, @p_monto_extranjero, @p_monto_pesos
    );
    -- Capturar ID del pago en divisa
    SET @v_local_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SET @out_id = @v_local_id;
    SELECT @v_local_id AS id_pago_ext;
END
GO


-- ============================================================
-- ESQUEMA: actividades
-- ============================================================

/* ============================================================
   sp_InsertarGuia
   Da de alta un guía autorizado en actividades.Guia.

   Validaciones:
     1. nombre no puede ser nulo ni vacío.
     2. apellido no puede ser nulo ni vacío.
     3. dni debe ser > 0 y <= 99999999.
     4. dni no puede estar ya registrado (UNIQUE).
     5. vigencia_autorizacion no puede ser nula.
   Salida: id_guia generado.
============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_InsertarGuia
(
    @p_nombre                VARCHAR(50),
    @p_apellido              VARCHAR(50),
    @p_dni                   INT,
    @p_especialidad          VARCHAR(100) = NULL,
    @p_titulo                VARCHAR(100) = NULL,
    @p_vigencia_autorizacion DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_nombre IS NULL OR LTRIM(RTRIM(@p_nombre)) = ''
        SET @v_errores += N'- [nombre] El nombre del guía es obligatorio.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_apellido IS NULL OR LTRIM(RTRIM(@p_apellido)) = ''
        SET @v_errores += N'- [apellido] El apellido del guía es obligatorio.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_dni IS NULL OR @p_dni <= 0 OR @p_dni > 99999999
        SET @v_errores += N'- [dni] El DNI debe ser un número entre 1 y 99999999.' + CHAR(10);

    -- El DNI se encripta para almacenamiento seguro (seguridad.Cifrar)
    -- Verificar que no exista un registro duplicado
    IF EXISTS (SELECT 1 FROM actividades.Guia
               WHERE CAST(seguridad.Descifrar(dni_cifrado) AS INT) = @p_dni)
        SET @v_errores += N'- [dni] Ya existe un guía registrado con ese DNI.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_vigencia_autorizacion IS NULL
        SET @v_errores += N'- [vigencia_autorizacion] La fecha de vigencia de la autorización es obligatoria.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_id INT;

    -- El DNI se encripta con seguridad.Cifrar antes de almacenar
    -- Insertar el nuevo registro
    INSERT INTO actividades.Guia (nombre, apellido, dni_cifrado, especialidad, titulo, vigencia_autorizacion)
    VALUES (
        LTRIM(RTRIM(@p_nombre)),
        -- Limpiar espacios antes de insertar
        LTRIM(RTRIM(@p_apellido)),
        -- Limpiar espacios antes de insertar
        seguridad.Cifrar(@p_dni),
        @p_especialidad,
        @p_titulo,
        @p_vigencia_autorizacion
    );
    -- Obtener ID del guía registrado
    SET @v_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SELECT @v_id AS id_guia;
END
GO


/* ============================================================
   sp_InsertarHabilitacionGuia
   Agrega una habilitación o certificación a un guía existente.

   Validaciones:
     1. id_guia debe existir en actividades.Guia.
     2. descripcion no puede ser nula ni vacía.
   Salida: id_habilitacion generado.
============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_InsertarHabilitacionGuia
(
    @p_id_guia           INT,
    @p_descripcion       VARCHAR(100),
    @p_fecha_vencimiento DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: guia existe
    IF NOT EXISTS (SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'- [id_guia] No existe un guía con ese ID.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 2: descripcion obligatoria
    IF @p_descripcion IS NULL OR LTRIM(RTRIM(@p_descripcion)) = ''
        SET @v_errores += N'- [descripcion] La descripción de la habilitación es obligatoria.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO actividades.HabilitacionGuia (id_guia, descripcion, fecha_vencimiento)
    -- Retorna ID de la habilitación creada
    OUTPUT INSERTED.id_habilitacion
    VALUES (@p_id_guia, LTRIM(RTRIM(@p_descripcion)), @p_fecha_vencimiento);
    -- Limpiar espacios antes de insertar
END
GO


/* ============================================================
   sp_InsertarAtraccion
   Registra una atracción o tour disponible en un parque.

   Validaciones:
     1. id_parque debe existir en parques.Parque.
      2. nombre no puede ser nulo ni vacío.
      3. tipo debe ser 'Gratuita', 'Paga' o 'Tour Guiado'.
      4. Si tipo = 'Gratuita', costo debe ser 0.
         Si tipo = 'Paga' o 'Tour Guiado', costo debe ser > 0.
      5. duracion debe ser > 0.
      6. horario_inicio no puede ser nulo.
      7. cupo_maximo debe ser > 0.
   Salida: id_atraccion generado.
============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_InsertarAtraccion
(
    @p_id_parque    INT,
    @p_nombre       VARCHAR(100),
    @p_tipo         VARCHAR(30),
    @p_costo        DECIMAL(10,2),
    @p_duracion     INT,
    @p_horario_inicio TIME,
    @p_cupo_maximo  INT
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: parque existe
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 2: nombre obligatorio
    IF @p_nombre IS NULL OR LTRIM(RTRIM(@p_nombre)) = ''
        SET @v_errores += N'- [nombre] El nombre de la atracción es obligatorio.' + CHAR(10);

    -- Solo se permiten valores del dominio definido
    -- Validacion 3: tipo valido
    IF @p_tipo NOT IN ('Gratuita', 'Paga', 'Tour Guiado')
        SET @v_errores += N'- [tipo] Debe ser uno de: Gratuita, Paga, Tour Guiado.' + CHAR(10);

    -- Regla: Gratuita=0, Paga/TourGuiado>0
    -- Validacion 4: regla costo segun tipo
    IF @p_tipo = 'Gratuita' AND @p_costo <> 0
        SET @v_errores += N'- [costo] Una atracción Gratuita debe tener costo = 0.' + CHAR(10);

    IF @p_tipo IN ('Paga', 'Tour Guiado') AND (@p_costo IS NULL OR @p_costo <= 0)
        SET @v_errores += N'- [costo] Una atracción Paga o Tour Guiado debe tener costo mayor a 0.' + CHAR(10);

    -- Duración en minutos, debe ser positiva
    -- Validacion 5: duracion positiva
    IF @p_duracion IS NULL OR @p_duracion <= 0
        SET @v_errores += N'- [duracion] La duración debe ser mayor a 0 minutos.' + CHAR(10);

    -- Validacion 6: horario_inicio obligatorio
    IF @p_horario_inicio IS NULL
        SET @v_errores += N'- [horario_inicio] El horario de inicio es obligatorio.' + CHAR(10);

    -- Validacion 7: cupo positivo
    IF @p_cupo_maximo IS NULL OR @p_cupo_maximo <= 0
        SET @v_errores += N'- [cupo_maximo] El cupo máximo debe ser mayor a 0.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO actividades.Atraccion (
        id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo_maximo
    )
    -- Retorna ID de la atracción registrada
    OUTPUT INSERTED.id_atraccion
    VALUES (
        @p_id_parque,
        LTRIM(RTRIM(@p_nombre)),
        -- Limpiar espacios antes de insertar
        @p_tipo,
        @p_costo,
        @p_duracion,
        @p_horario_inicio,
        @p_cupo_maximo
    );
END
GO


/* ============================================================
   sp_InsertarTourGuia
   Asocia un guía a una atracción en una fecha específica.

   Validaciones:
     1. id_guia debe existir en actividades.Guia.
     2. id_atraccion debe existir en actividades.Atraccion.
     3. La atraccion debe ser de tipo 'Tour Guiado'.
     4. La autorizacion del guia debe estar vigente para la fecha indicada.
     5. fecha no puede ser nula.
     6. La combinacion (id_guia, id_atraccion, fecha) debe ser unica (UNIQUE).
   Salida: id_tour_guia generado.
============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_InsertarTourGuia
(
    @p_id_guia      INT,
    @p_id_atraccion INT,
    @p_fecha        DATE
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: guia existe
    IF NOT EXISTS (SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'- [id_guia] No existe un guía con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 2: atraccion existe
    IF NOT EXISTS (SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion)
        SET @v_errores += N'- [id_atraccion] No existe una atracción con ese ID.' + CHAR(10);

    -- Solo se asignan guías a atracciones tipo Tour Guiado
    -- Validacion 3: la atraccion debe ser Tour Guiado
    IF EXISTS (SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion)
       AND NOT EXISTS (
           SELECT 1 FROM actividades.Atraccion
           WHERE id_atraccion = @p_id_atraccion AND tipo = 'Tour Guiado'
       )
        SET @v_errores += N'- [id_atraccion] Solo se pueden asignar guías a atracciones de tipo Tour Guiado.' + CHAR(10);

    -- La autorización del guía debe estar vigente para la fecha del tour
    -- Validacion 4: autorizacion vigente
    IF @p_fecha IS NOT NULL
       AND EXISTS (SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia)
       AND NOT EXISTS (
           SELECT 1 FROM actividades.Guia
           WHERE id_guia = @p_id_guia
             AND vigencia_autorizacion >= @p_fecha
       )
        SET @v_errores += N'- [vigencia_autorizacion] La autorización del guía no está vigente para la fecha indicada.' + CHAR(10);

    -- Validacion 5: fecha obligatoria
    IF @p_fecha IS NULL
        SET @v_errores += N'- [fecha] La fecha del tour es obligatoria.' + CHAR(10);

    -- Un guía no puede estar asignado dos veces al mismo tour en la misma fecha
    -- Verificar que no exista un registro duplicado
    -- Validacion 6: combinacion unica
    IF EXISTS (
        SELECT 1 FROM actividades.TourGuia
        WHERE id_guia      = @p_id_guia
          AND id_atraccion = @p_id_atraccion
          AND fecha        = @p_fecha
    )
        SET @v_errores += N'- [fecha] El guía ya está asignado a esa atracción en esa fecha.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO actividades.TourGuia (id_guia, id_atraccion, fecha)
    -- Retorna ID de la asignación guía-tour
    OUTPUT INSERTED.id_tour_guia
    VALUES (@p_id_guia, @p_id_atraccion, @p_fecha);
END
GO


-- ============================================================
-- ESQUEMA: concesiones
-- ============================================================

/* ============================================================
   sp_InsertarEmpresa
   Da de alta una empresa concesionaria en concesiones.Empresa.

   Validaciones:
     1. razon_social no puede ser nula ni vacía.
     2. cuit debe tener exactamente 11 dígitos numéricos.
     3. cuit no puede estar ya registrado (UNIQUE).
   Salida: id_empresa generado.
============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_InsertarEmpresa
(
    @p_razon_social VARCHAR(100),
    @p_cuit         CHAR(11),
    @p_contacto     VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 1: razon_social obligatoria
    IF @p_razon_social IS NULL OR LTRIM(RTRIM(@p_razon_social)) = ''
        SET @v_errores += N'- [razon_social] La razón social es obligatoria.' + CHAR(10);

    -- CUIT argentino: exactamente 11 dígitos sin guiones
    -- Validacion 2: CUIT de 11 digitos numericos
    IF @p_cuit IS NULL
       OR LEN(LTRIM(RTRIM(@p_cuit))) <> 11
       OR @p_cuit NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
        SET @v_errores += N'- [cuit] El CUIT debe contener exactamente 11 dígitos numéricos (sin guiones).' + CHAR(10);

    -- CUIT único a nivel nacional
    -- Verificar que no exista un registro duplicado
    -- Validacion 3: CUIT unico
    IF EXISTS (SELECT 1 FROM concesiones.Empresa WHERE cuit = @p_cuit)
        SET @v_errores += N'- [cuit] Ya existe una empresa registrada con ese CUIT.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_id INT;

    -- CUIT se almacena sin formato (11 dígitos puros)
    -- Insertar el nuevo registro
    INSERT INTO concesiones.Empresa (razon_social, cuit, contacto)
    VALUES (LTRIM(RTRIM(@p_razon_social)), @p_cuit, @p_contacto);
    -- Limpiar espacios antes de insertar
    -- Capturar ID de la empresa creada
    SET @v_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SELECT @v_id AS id_empresa;
END
GO


/* ============================================================
   sp_InsertarConcesion
   Registra un contrato de concesion en concesiones.Concesion.

   Validaciones:
     1. id_empresa debe existir en concesiones.Empresa.
     2. id_parque debe existir en parques.Parque.
     3. tipo_actividad no puede ser nulo ni vacío.
     4. fecha_inicio no puede ser nula.
     5. fecha_fin debe ser posterior a fecha_inicio.
     6. pago_mensual debe ser > 0.
   Salida: id_concesion generado.
============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_InsertarConcesion
(
    @p_id_empresa     INT,
    @p_id_parque      INT,
    @p_tipo_actividad VARCHAR(50),
    @p_fecha_inicio   DATE,
    @p_fecha_fin      DATE,
    @p_pago_mensual   DECIMAL(12,2)
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: empresa existe
    IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa)
        SET @v_errores += N'- [id_empresa] No existe una empresa con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 2: parque existe
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Tipo de actividad concedida (ej: gastronomía, alojamiento, etc.)
    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 3: tipo_actividad obligatorio
    IF @p_tipo_actividad IS NULL OR LTRIM(RTRIM(@p_tipo_actividad)) = ''
        SET @v_errores += N'- [tipo_actividad] El tipo de actividad es obligatorio.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 4: fecha_inicio obligatoria
    IF @p_fecha_inicio IS NULL
        SET @v_errores += N'- [fecha_inicio] La fecha de inicio del contrato es obligatoria.' + CHAR(10);

    -- La fecha de fin debe ser estrictamente posterior al inicio
    -- Validacion 5: fecha_fin posterior a fecha_inicio
    IF @p_fecha_fin IS NULL
        SET @v_errores += N'- [fecha_fin] La fecha de fin del contrato es obligatoria.' + CHAR(10);
    ELSE IF @p_fecha_inicio IS NOT NULL AND @p_fecha_fin <= @p_fecha_inicio
        SET @v_errores += N'- [fecha_fin] La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(10);

    -- Validacion 6: pago mensual positivo
    IF @p_pago_mensual IS NULL OR @p_pago_mensual <= 0
        SET @v_errores += N'- [pago_mensual] El pago mensual (canon) debe ser mayor a 0.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_id INT;

    -- Los textos se limpian de espacios extra con LTRIM/RTRIM
    -- Insertar el nuevo registro
    INSERT INTO concesiones.Concesion (
        id_empresa, id_parque, tipo_actividad, fecha_inicio, fecha_fin, pago_mensual
    )
    VALUES (
        @p_id_empresa,
        @p_id_parque,
        LTRIM(RTRIM(@p_tipo_actividad)),
        -- Limpiar espacios antes de insertar
        @p_fecha_inicio,
        @p_fecha_fin,
        @p_pago_mensual
    );
    -- Obtener ID del contrato de concesión
    SET @v_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SELECT @v_id AS id_concesion;
END
GO


/* ============================================================
   sp_InsertarPagoConcesion
   Registra un pago de canon en concesiones.PagoConcesion.

   Validaciones:
     1. id_empresa debe existir en concesiones.Empresa.
     2. id_concesion debe existir en concesiones.Concesion.
     3. La concesion debe pertenecer a la empresa indicada.
     4. fecha_pago no puede ser nula.
     5. monto debe ser > 0.
   Salida: id_pago generado.
============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_InsertarPagoConcesion
(
    @p_id_empresa   INT,
    @p_id_concesion INT,
    @p_fecha_pago   DATE,
    @p_monto        DECIMAL(12,2)
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: empresa existe
    IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa)
        SET @v_errores += N'- [id_empresa] No existe una empresa con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 2: concesion existe
    IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @p_id_concesion)
        SET @v_errores += N'- [id_concesion] No existe una concesión con ese ID.' + CHAR(10);

    -- La concesión debe pertenecer a la empresa que paga
    -- Validacion 3: la concesion debe pertenecer a la empresa
    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @p_id_concesion)
       AND NOT EXISTS (
           SELECT 1 FROM concesiones.Concesion
           WHERE id_concesion = @p_id_concesion
             AND id_empresa   = @p_id_empresa
       )
        SET @v_errores += N'- [id_empresa] La concesión indicada no pertenece a esa empresa.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 4: fecha_pago obligatoria
    IF @p_fecha_pago IS NULL
        SET @v_errores += N'- [fecha_pago] La fecha del pago es obligatoria.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_id INT;

    -- Insertar el nuevo registro
    INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
    VALUES (@p_id_empresa, @p_id_concesion, @p_fecha_pago, @p_monto);
    -- Capturar ID del pago registrado
    SET @v_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SELECT @v_id AS id_pago;
END
GO


-- ============================================================
-- ESQUEMA: personal
-- ============================================================

/* ============================================================
   sp_InsertarGuardaparque
   Da de alta un guardaparque en personal.Guardaparque.

   Validaciones:
     1. nombre no puede ser nulo ni vacío.
     2. apellido no puede ser nulo ni vacío.
     3. dni debe ser > 0 y <= 99999999.
     4. dni no puede estar ya registrado (UNIQUE).
   Salida: id_guardaparque generado.
============================================================ */
CREATE OR ALTER PROCEDURE personal.sp_InsertarGuardaparque
(
    @p_nombre   VARCHAR(50),
    @p_apellido VARCHAR(50),
    @p_dni      INT
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_nombre IS NULL OR LTRIM(RTRIM(@p_nombre)) = ''
        SET @v_errores += N'- [nombre] El nombre del guardaparque es obligatorio.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_apellido IS NULL OR LTRIM(RTRIM(@p_apellido)) = ''
        SET @v_errores += N'- [apellido] El apellido del guardaparque es obligatorio.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    IF @p_dni IS NULL OR @p_dni <= 0 OR @p_dni > 99999999
        SET @v_errores += N'- [dni] El DNI debe ser un número entre 1 y 99999999.' + CHAR(10);

    -- El DNI se descifra dinámicamente para validar unicidad
    IF EXISTS (SELECT 1 FROM personal.Guardaparque
               WHERE CAST(seguridad.Descifrar(dni_cifrado) AS INT) = @p_dni)
        SET @v_errores += N'- [dni] Ya existe un guardaparque registrado con ese DNI.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    DECLARE @v_id INT;

    -- El DNI se encripta al momento de la inserción
    -- Insertar el nuevo registro
    INSERT INTO personal.Guardaparque (nombre, apellido, dni_cifrado)
    VALUES (LTRIM(RTRIM(@p_nombre)), LTRIM(RTRIM(@p_apellido)), seguridad.Cifrar(@p_dni));
    -- Obtener ID del guardaparque creado
    SET @v_id = SCOPE_IDENTITY();

    -- Retornar identificador del registro recién creado
    SELECT @v_id AS id_guardaparque;
END
GO


/* ============================================================
   sp_InsertarAsignacionParque
   Registra la asignación (o reasignación) de un guardaparque a un parque.

   Validaciones:
     1. id_guardaparque debe existir en personal.Guardaparque.
     2. id_parque debe existir en parques.Parque.
     3. fecha_desde no puede ser nula.
     4. Si fecha_hasta no es nula, debe ser posterior a fecha_desde.
     5. No puede existir una asignacion activa (fecha_hasta IS NULL) para el mismo
        guardaparque en cualquier parque al momento de la nueva asignación
        (un guardaparque activo debe cerrarse antes de reasignarse).
   Salida: id_asignacion generado.
============================================================ */
CREATE OR ALTER PROCEDURE personal.sp_InsertarAsignacionParque
(
    @p_id_guardaparque INT,
    @p_id_parque       INT,
    @p_fecha_desde     DATE,
    @p_fecha_hasta     DATE         = NULL,
    @p_motivo_egreso   VARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';
    -- Acumular errores de validación para reportar todos a la vez

    -- Verificar existencia del registro referenciado
    -- Validacion 1: guardaparque existe
    IF NOT EXISTS (SELECT 1 FROM personal.Guardaparque WHERE id_guardaparque = @p_id_guardaparque)
        SET @v_errores += N'- [id_guardaparque] No existe un guardaparque con ese ID.' + CHAR(10);

    -- Verificar existencia del registro referenciado
    -- Validacion 2: parque existe
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Campo obligatorio: no puede ser nulo ni vacío
    -- Validacion 3: fecha_desde obligatoria
    IF @p_fecha_desde IS NULL
        SET @v_errores += N'- [fecha_desde] La fecha de inicio de asignación es obligatoria.' + CHAR(10);

    -- Validacion 4: fechas coherentes
    IF @p_fecha_hasta IS NOT NULL AND @p_fecha_desde IS NOT NULL AND @p_fecha_hasta <= @p_fecha_desde
        SET @v_errores += N'- [fecha_hasta] La fecha de egreso debe ser posterior a la fecha de inicio.' + CHAR(10);

    -- Un guardaparque con asignación activa no puede ser reasignado
    -- Validacion 5: no puede tener una asignacion activa abierta
    IF EXISTS (
        SELECT 1
        FROM personal.AsignacionParque
        WHERE id_guardaparque = @p_id_guardaparque
          AND fecha_hasta IS NULL
    )
        SET @v_errores += N'- [id_guardaparque] El guardaparque ya tiene una asignación activa sin fecha de egreso. Ciérrela antes de crear una nueva.' + CHAR(10);

    -- Si se acumularon errores, abortar con THROW
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Insertar el nuevo registro
    INSERT INTO personal.AsignacionParque (
        id_guardaparque, id_parque, fecha_desde, fecha_hasta, motivo_egreso
    )
    -- Retorna ID de la asignación creada
    OUTPUT INSERTED.id_asignacion
    VALUES (
        @p_id_guardaparque, @p_id_parque, @p_fecha_desde, @p_fecha_hasta, @p_motivo_egreso
    );
END
GO

PRINT '============================================';
PRINT ' 03_SPInsercion.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO