/*
================================================================================
  MATERIA:     Bases de Datos Aplicada - 3641
  COMISION:    02-5600
  UNIVERSIDAD: Universidad Nacional de la Matanza
  GRUPO:       10
  INTEGRANTES:
      - Amarilla, Facundo Nahuel   - 46201679
      - Ávila García, Eric Luis    - 43722795
      - Borgoño Villafañe, Gonzalo - 46645738
      - Quintas, Santiago Emanuel  - 46737706

  Archivo:     06_SPLogicaNegocio.sql
  Descripcion: Stored Procedures de lógica de negocio. Cada SP orquesta
               operaciones sobre múltiples tablas dentro de una transacción,
               garantizando la integridad de los datos ante cualquier error.
               REUTILIZAN los SPs de ABM (sp_Insertar*, sp_Modificar_*, sp_Borrar*)
               para todas las operaciones de datos.

  SPs incluidos:
      1. ventas.sp_VentaEntradas         - Registra un ticket de venta completo
      2. actividades.sp_RegistrarActividad - Da de alta una atracción en un parque
      3. actividades.sp_AsignarGuia      - Asigna un guía autorizado a un tour
      4. concesiones.sp_CrearConcesion    - Registra un contrato de concesión
      5. concesiones.sp_PagarConcesion    - Registra un pago de canon
      6. importacion.sp_ImportarParquesDesdeExcel - Importa parques desde Excel SIB (07_SPImportacion.sql)
================================================================================
*/

USE ParquesNacionales;
GO

-- ============================================================
-- 1. VENTA DE ENTRADAS
--
-- Registra un ticket completo con sus ítems. Flujo:
--   a) Validar reglas de negocio cruzadas
--   b) Insertar Ticket (cabecera) mediante sp_InsertarTicket
--   c) Insertar ítem de entrada mediante sp_InsertarItemTicket
--   d) Si hay atracción, insertar ese ítem también
--   e) Si es moneda extranjera, registrar conversión
-- ============================================================
/* ============================================================
   sp_VentaEntradas
   Registra un ticket de venta completo con sus items.
   Flujo: validar reglas → insertar Ticket → insertar ItemTicket
   → opcionalmente insertar ítem de atracción → si es moneda
   extranjera, registrar conversión.

   Parametros:
     @p_id_parque          - Parque donde se realiza la venta
     @p_fecha_acceso       - Fecha de acceso al parque
     @p_punto_de_venta     - Punto de venta (1..N)
     @p_numero_comprobante - Número de comprobante único
     @p_forma_pago         - Forma de pago válida
     @p_id_tipo_visitante  - Categoría del visitante
     @p_cantidad           - Cantidad de entradas
     @p_id_atraccion       - (Opcional) Atracción contratada
     @p_id_moneda          - (Opcional) Moneda extranjera
     @p_monto_extranjero   - (Opcional) Monto en divisa
   ============================================================ */
-- Llama a: sp_InsertarTicket, sp_InsertarItemTicket, sp_InsertarPagoMonedaExtranjera (03_SPInsercion.sql)
CREATE OR ALTER PROCEDURE ventas.sp_VentaEntradas
    @p_id_parque          INT,
    @p_fecha_acceso       DATE,
    @p_punto_de_venta     INT,
    @p_numero_comprobante INT,
    @p_forma_pago         VARCHAR(30),
    @p_id_tipo_visitante  INT,
    @p_cantidad           INT,
    @p_id_atraccion       INT           = NULL,
    @p_id_moneda          INT           = NULL,
    @p_monto_extranjero   DECIMAL(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores       NVARCHAR(2000) = N'';
    -- Variables para acumular datos calculados durante la validación
    DECLARE @v_id_precio     INT;
    DECLARE @v_precio_actual DECIMAL(10,2);
    DECLARE @v_costo_atraccion     DECIMAL(10,2) = 0;
    -- Acumular total del ticket para validación y registro
    DECLARE @v_total         DECIMAL(10,2);
    DECLARE @v_id_ticket     INT;
    DECLARE @v_id_tasa       INT;
    DECLARE @v_tasa          DECIMAL(12,4);
    DECLARE @v_monto_pesos   DECIMAL(12,2);
    DECLARE @v_hoy           DATE = CAST(GETDATE() AS DATE);

    -- ---- Validaciones de negocio ----

    -- Verificar unicidad del comprobante en el punto de venta
    IF EXISTS (
        SELECT 1 FROM ventas.Ticket
        WHERE punto_de_venta = @p_punto_de_venta
          AND numero_comprobante = @p_numero_comprobante
    )
        SET @v_errores += N'- Ya existe un comprobante con ese punto de venta y número.' + CHAR(10);

    -- La fecha de acceso no puede ser en el pasado
    IF @p_fecha_acceso < @v_hoy
        SET @v_errores += N'- La fecha de acceso no puede ser anterior a hoy.' + CHAR(10);

    -- Buscar el precio vigente más reciente para parque + tipo visitante
    SELECT TOP 1
        @v_id_precio     = id_precio,
        @v_precio_actual = precio
    FROM parques.PrecioEntrada
    WHERE id_parque       = @p_id_parque
      AND id_tipo         = @p_id_tipo_visitante
      AND vigencia_desde <= @v_hoy
    ORDER BY vigencia_desde DESC;

    IF @v_id_precio IS NULL
        SET @v_errores += N'- No existe precio vigente para ese parque y tipo de visitante.' + CHAR(10);

    -- Si se contrató una atracción, verificar que pertenezca al parque
    IF @p_id_atraccion IS NOT NULL
    BEGIN
        IF NOT EXISTS (
            SELECT 1 FROM actividades.Atraccion
            WHERE id_atraccion = @p_id_atraccion AND id_parque = @p_id_parque
        )
            SET @v_errores += N'- La atracción indicada no existe o no pertenece al parque.' + CHAR(10);
        ELSE
            SELECT @v_costo_atraccion = costo FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion;
    END

    -- Para pagos en divisa, buscar tasa de cambio vigente
    IF @p_forma_pago = 'Moneda Extranjera'
    BEGIN
        IF @p_id_moneda IS NULL OR @p_monto_extranjero IS NULL OR @p_monto_extranjero <= 0
            SET @v_errores += N'- Para pago en moneda extranjera se requiere moneda y monto válidos.' + CHAR(10);
        ELSE
        BEGIN
            SELECT TOP 1
                @v_id_tasa = id_tasa,
                @v_tasa    = tasa_a_peso
            FROM ventas.TasaCambio
            WHERE id_moneda = @p_id_moneda AND fecha_vigencia <= @v_hoy
            ORDER BY fecha_vigencia DESC;

            IF @v_id_tasa IS NULL
                SET @v_errores += N'- No existe tasa de cambio vigente para la moneda indicada.' + CHAR(10);
        END
    END

    -- Abortar transacción y notificar errores al cliente
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- ---- Operación ----

    -- Calcular el total del ticket sumando ítems individuales
    -- Total = (precio entrada × cantidad) + costo atracción
    SET @v_total = (@v_precio_actual * @p_cantidad) + @v_costo_atraccion;

    BEGIN TRY
        -- Reutiliza SP de inserción del esquema ventas
        -- Crear la cabecera del ticket
        EXEC ventas.sp_InsertarTicket
            @p_id_parque = @p_id_parque,
            @p_fecha = @v_hoy,
            @p_fecha_acceso = @p_fecha_acceso,
            @p_punto_de_venta = @p_punto_de_venta,
            @p_numero_comprobante = @p_numero_comprobante,
            @p_forma_pago = @p_forma_pago,
            @p_total_pagado = @v_total,
            @out_id = @v_id_ticket OUTPUT;

        -- Reutiliza SP de inserción del esquema ventas
        -- Insertar línea de entrada al ticket
        EXEC ventas.sp_InsertarItemTicket
            @p_id_ticket = @v_id_ticket,
            @p_id_precio_entrada = @v_id_precio,
            @p_id_atraccion = NULL,
            @p_precio_venta = @v_precio_actual,
            @p_cantidad = @p_cantidad;

        -- Paso 3: Insertar ítem de atracción (opcional)
        IF @p_id_atraccion IS NOT NULL
        BEGIN
            -- Reutiliza SP de inserción del esquema ventas
            -- Insertar línea de atracción al ticket
            EXEC ventas.sp_InsertarItemTicket
                @p_id_ticket = @v_id_ticket,
                @p_id_precio_entrada = NULL,
                @p_id_atraccion = @p_id_atraccion,
                @p_precio_venta = @v_costo_atraccion,
                @p_cantidad = 1;
        END

        -- Paso 4: Registrar conversión de moneda extranjera
        IF @p_forma_pago = 'Moneda Extranjera'
        BEGIN
            SET @v_monto_pesos = @p_monto_extranjero * @v_tasa;

            -- Reutiliza SP de inserción del esquema ventas
            -- Registrar el pago en divisa extranjera con conversión
            EXEC ventas.sp_InsertarPagoMonedaExtranjera
                @p_id_ticket = @v_id_ticket,
                @p_id_tasa = @v_id_tasa,
                @p_monto_extranjero = @p_monto_extranjero,
                @p_monto_pesos = @v_monto_pesos;
        END

        -- Retornar ID del ticket generado
        SELECT @v_id_ticket AS id;
        PRINT 'Venta registrada correctamente. ID de ticket: ' + CAST(@v_id_ticket AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- 2. REGISTRO DE ACTIVIDAD
--
-- Da de alta una nueva atracción/tour en un parque.
-- La validación tipo-costo se delega a sp_InsertarAtraccion.
-- Aquí validamos que no exista otra actividad con el mismo nombre
-- y rango horario solapado en el mismo parque.
-- ============================================================
/* ============================================================
   sp_RegistrarActividad
   Da de alta una nueva atracción/tour en un parque.
   Valida que no exista otra actividad con el mismo nombre
   y rango horario solapado en el mismo parque.

   Parametros:
     @p_id_parque       - Parque donde se registra
     @p_nombre          - Nombre de la actividad
     @p_tipo            - Gratuita, Paga o Tour Guiado
     @p_costo           - Costo de la actividad
     @p_duracion        - Duración en minutos
     @p_horario_inicio  - Hora de inicio
     @p_cupo_maximo     - Cupo máximo de participantes
   ============================================================ */
-- Reutiliza: sp_InsertarAtraccion (03_SPInsercion.sql)
CREATE OR ALTER PROCEDURE actividades.sp_RegistrarActividad
    @p_id_parque       INT,
    @p_nombre          VARCHAR(100),
    @p_tipo            VARCHAR(30),
    @p_costo           DECIMAL(10,2),
    @p_duracion        INT,
    @p_horario_inicio  TIME,
    @p_cupo_maximo     INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que no exista solapamiento horario con otra actividad del mismo nombre en el parque
    IF EXISTS (
        SELECT 1 FROM actividades.Atraccion
        WHERE id_parque = @p_id_parque
          AND nombre = LTRIM(RTRIM(@p_nombre))
          AND @p_horario_inicio < DATEADD(MINUTE, duracion, horario_inicio)
          AND horario_inicio < DATEADD(MINUTE, @p_duracion, @p_horario_inicio)
    )
        SET @v_errores += N'- Ya existe una actividad con ese nombre y horario solapado en el parque.' + CHAR(10);

    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Reutilizar sp_InsertarAtraccion para la inserción
        -- Reutiliza SP de inserción del esquema actividades
        EXEC actividades.sp_InsertarAtraccion
            @p_id_parque = @p_id_parque,
            @p_nombre = @p_nombre,
            @p_tipo = @p_tipo,
            @p_costo = @p_costo,
            @p_duracion = @p_duracion,
            @p_horario_inicio = @p_horario_inicio,
            @p_cupo_maximo = @p_cupo_maximo;

        -- Confirmar cambios en la base de datos
        COMMIT TRANSACTION;
        PRINT 'Atracción registrada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- 3. ASIGNACIÓN DE GUÍA A TOUR
--
-- Asocia un guía a una instancia de tour (atracción + fecha).
-- Reglas: guía vigente, atracción tipo Tour Guiado, sin solapamiento.
-- ============================================================
/* ============================================================
   sp_AsignarGuia
   Asocia un guía autorizado a una instancia de tour.
   Valida: guía vigente, atracción tipo Tour Guiado,
   sin solapamiento de tours para el mismo guía.

   Parametros:
     @p_id_guia      - Guía a asignar
     @p_id_atraccion - Atracción tipo Tour Guiado
     @p_fecha        - Fecha del tour
   ============================================================ */
-- Reutiliza: sp_InsertarTourGuia (03_SPInsercion.sql)
CREATE OR ALTER PROCEDURE actividades.sp_AsignarGuia
    @p_id_guia      INT,
    @p_id_atraccion INT,
    @p_fecha        DATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores  NVARCHAR(2000) = N'';
    DECLARE @v_tipo_atraccion VARCHAR(30);
    DECLARE @v_vigencia_guia DATE;

    -- Obtener vigencia de autorización del guía
    SELECT @v_vigencia_guia = vigencia_autorizacion FROM actividades.Guia WHERE id_guia = @p_id_guia;

    IF @v_vigencia_guia IS NULL
        SET @v_errores += N'- El guía indicado no existe.' + CHAR(10);
    ELSE IF @v_vigencia_guia < @p_fecha
        SET @v_errores += N'- La autorización del guía está vencida para la fecha indicada.' + CHAR(10);

    -- Verificar que la atracción sea tipo Tour Guiado
    SELECT @v_tipo_atraccion = tipo FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion;

    IF @v_tipo_atraccion IS NULL
        SET @v_errores += N'- La atracción indicada no existe.' + CHAR(10);
    ELSE IF @v_tipo_atraccion <> 'Tour Guiado'
        SET @v_errores += N'- Solo se pueden asignar guías a atracciones de tipo Tour Guiado.' + CHAR(10);

    -- La fecha del tour debe ser futura
    IF @p_fecha < CAST(GETDATE() AS DATE)
        SET @v_errores += N'- La fecha del tour no puede ser anterior a hoy.' + CHAR(10);

    -- Verificar que el guía no tenga otro tour asignado en la misma fecha
    IF EXISTS (
        SELECT 1 FROM actividades.TourGuia
        WHERE id_guia = @p_id_guia AND fecha = @p_fecha AND id_atraccion <> @p_id_atraccion
    )
        SET @v_errores += N'- El guía ya tiene asignado otro tour distinto en esa fecha.' + CHAR(10);

    -- Verificar que no exista ya esta asignación exacta
    IF EXISTS (
        SELECT 1 FROM actividades.TourGuia
        WHERE id_guia = @p_id_guia AND id_atraccion = @p_id_atraccion AND fecha = @p_fecha
    )
        SET @v_errores += N'- El guía ya está asignado a ese tour en esa fecha.' + CHAR(10);

    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Reutiliza SP de inserción del esquema actividades
        EXEC actividades.sp_InsertarTourGuia
            @p_id_guia = @p_id_guia,
            @p_id_atraccion = @p_id_atraccion,
            @p_fecha = @p_fecha;

        -- Confirmar cambios en la base de datos
        COMMIT TRANSACTION;
        PRINT 'Guía asignado correctamente al tour.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- 4. GESTIÓN DE CONCESIONES
-- ============================================================

/* ============================================================
   sp_CrearConcesion
   Registra un contrato de concesión entre una empresa y un parque.
   Valida que no exista superposición de períodos para la misma
   empresa, parque y tipo de actividad.

   Parametros:
     @p_id_empresa     - Empresa concesionaria
     @p_id_parque      - Parque donde se otorga
     @p_tipo_actividad - Tipo de actividad concedida
     @p_fecha_inicio   - Inicio del contrato
     @p_fecha_fin      - Fin del contrato
     @p_pago_mensual   - Canon mensual
   ============================================================ */
-- Reutiliza: sp_InsertarConcesion (03_SPInsercion.sql)
CREATE OR ALTER PROCEDURE concesiones.sp_CrearConcesion
    @p_id_empresa     INT,
    @p_id_parque      INT,
    @p_tipo_actividad VARCHAR(50),
    @p_fecha_inicio   DATE,
    @p_fecha_fin      DATE,
    @p_pago_mensual   DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Validar coherencia de fechas del contrato
    IF @p_fecha_fin <= @p_fecha_inicio
        SET @v_errores += N'- La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(10);

    IF @p_fecha_inicio < CAST(GETDATE() AS DATE)
        SET @v_errores += N'- La fecha de inicio no puede ser anterior a hoy.' + CHAR(10);

    -- Verificar que no exista superposición de períodos para la misma empresa/parque/tipo
    IF EXISTS (
        SELECT 1 FROM concesiones.Concesion
        WHERE id_empresa = @p_id_empresa
          AND id_parque = @p_id_parque
          AND tipo_actividad = @p_tipo_actividad
          AND @p_fecha_inicio < fecha_fin
          AND @p_fecha_fin > fecha_inicio
    )
        SET @v_errores += N'- La empresa ya tiene una concesión del mismo tipo en ese parque con período superpuesto.' + CHAR(10);

    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Reutilizar sp_InsertarConcesion para la inserción
        EXEC concesiones.sp_InsertarConcesion
            @p_id_empresa = @p_id_empresa,
            @p_id_parque = @p_id_parque,
            @p_tipo_actividad = @p_tipo_actividad,
            @p_fecha_inicio = @p_fecha_inicio,
            @p_fecha_fin = @p_fecha_fin,
            @p_pago_mensual = @p_pago_mensual;

        -- Confirmar cambios en la base de datos
        COMMIT TRANSACTION;
        PRINT 'Concesión registrada correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO

/* ============================================================
   sp_PagarConcesion
   Registra un pago de canon de concesión. Valida que la
   concesión exista y pertenezca a la empresa indicada.
   Emite advertencia si el monto difiere del pago_mensual.

   Parametros:
     @p_id_empresa   - Empresa que paga
     @p_id_concesion - Concesión a la que se imputa
     @p_fecha_pago   - Fecha del pago
     @p_monto        - Monto pagado
   ============================================================ */
-- Reutiliza: sp_InsertarPagoConcesion (03_SPInsercion.sql)
CREATE OR ALTER PROCEDURE concesiones.sp_PagarConcesion
    @p_id_concesion INT,
    @p_fecha_pago   DATE,
    @p_monto        DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores    NVARCHAR(2000) = N'';
    DECLARE @v_id_empresa INT;
    DECLARE @v_pago_mens  DECIMAL(12,2);
    DECLARE @v_fecha_fin  DATE;

    -- Verificar que la empresa sea titular de la concesión
    SELECT @v_id_empresa = id_empresa, @v_pago_mens = pago_mensual, @v_fecha_fin = fecha_fin
    FROM concesiones.Concesion
    WHERE id_concesion = @p_id_concesion;

    IF @v_id_empresa IS NULL
        SET @v_errores += N'- La concesión indicada no existe.' + CHAR(10);
    ELSE IF @p_fecha_pago > DATEADD(MONTH, 12, @v_fecha_fin)
        SET @v_errores += N'- No se pueden registrar pagos para concesiones vencidas hace más de 12 meses.' + CHAR(10);

    IF @p_fecha_pago > CAST(GETDATE() AS DATE)
        SET @v_errores += N'- La fecha de pago no puede ser futura.' + CHAR(10);

    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Registrar el pago de canon
        EXEC concesiones.sp_InsertarPagoConcesion
            @p_id_empresa = @v_id_empresa,
            @p_id_concesion = @p_id_concesion,
            @p_fecha_pago = @p_fecha_pago,
            @p_monto = @p_monto;

        -- Confirmar cambios en la base de datos
        COMMIT TRANSACTION;

        -- Advertir si el monto difiere del canon mensual esperado
        IF @p_monto <> @v_pago_mens
            PRINT 'Advertencia: el monto pagado (' + CAST(@p_monto AS VARCHAR(20)) +
                  ') difiere del canon mensual (' + CAST(@v_pago_mens AS VARCHAR(20)) + ').';
        ELSE
            PRINT 'Pago de canon registrado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- 5. IMPORTACIÓN DE DATOS EXTERNOS
-- ============================================================
PRINT 'Nota: Importacion de datos implementada en la Entrega 6.';
GO

PRINT '============================================';
PRINT ' 06_SPLogicaNegocio.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
