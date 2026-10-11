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

  Archivo: 04_SPModificacion.sql
  Descripcion: Script que contiene la definición de los Stored Procedures de UPDATE,
               para todas las tablas del sistema de gestión de Parques Nacionales.
               Validaciones acumuladas con mensaje único.
================================================================================
*/

USE ParquesNacionales;
GO

-- ============================================================
-- ESQUEMA: concesiones
-- ============================================================

-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE concesiones.sp_ModificarConcesion
(
    @p_id_concesion  INT,
    @p_id_empresa INT = NULL,
    @p_id_parque INT = NULL,
    @p_tipo_actividad VARCHAR(50) = NULL,
    @p_fecha_inicio DATE = NULL,
    @p_fecha_fin DATE = NULL,
    @p_pago_mensual DECIMAL(10,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM concesiones.Concesion
        WHERE id_concesion = @p_id_concesion
    )
        SET @v_errores += N'- [id_concesion] No existe una concesion con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_empresa IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa
    )
        SET @v_errores += N'- [id_empresa] No existe una empresa con ese ID.' + CHAR(10);

    IF @p_id_parque IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque
    )
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    -- Validación condicional: solo si se proporciona nuevo valor
    IF @p_tipo_actividad IS NOT NULL
    BEGIN
        SET @p_tipo_actividad = TRIM(@p_tipo_actividad);
        IF @p_tipo_actividad = '' OR LEN(@p_tipo_actividad) > 50
            SET @v_errores += N'- [tipo_actividad] El tipo de actividad no puede estar vacio y debe tener hasta 50 caracteres.' + CHAR(10);
    END

    -- Validar valor numérico positivo
    IF @p_pago_mensual IS NOT NULL AND @p_pago_mensual <= 0
        SET @v_errores += N'- [pago_mensual] El pago mensual debe ser mayor a 0.' + CHAR(10);

    -- Leer valores actuales de la base para comparar
    DECLARE @v_fecha_ini_actual DATE, @v_fecha_fin_actual DATE;
    SELECT @v_fecha_ini_actual = fecha_inicio, @v_fecha_fin_actual = fecha_fin
    FROM concesiones.Concesion
    WHERE id_concesion = @p_id_concesion;

    -- Las fechas efectivas se calculan para validar coherencia sin perder los valores actuales
    DECLARE @v_fecha_ini_efectiva DATE = COALESCE(@p_fecha_inicio, @v_fecha_ini_actual);
    DECLARE @v_fecha_fin_efectiva DATE = COALESCE(@p_fecha_fin,    @v_fecha_fin_actual);

    IF @v_fecha_ini_efectiva IS NOT NULL AND @v_fecha_fin_efectiva IS NOT NULL
        AND @v_fecha_fin_efectiva <= @v_fecha_ini_efectiva
        SET @v_errores += N'- [fechas] La fecha de fin debe ser posterior a la fecha de inicio.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE concesiones.Concesion
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_empresa = COALESCE(@p_id_empresa, id_empresa),
            id_parque = COALESCE(@p_id_parque, id_parque),
            tipo_actividad = COALESCE(@p_tipo_actividad, tipo_actividad),
            fecha_inicio = COALESCE(@p_fecha_inicio,  fecha_inicio),
            fecha_fin = COALESCE(@p_fecha_fin, fecha_fin),
            pago_mensual = COALESCE(@p_pago_mensual, pago_mensual)
        WHERE id_concesion = @p_id_concesion;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Concesion actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE concesiones.sp_ModificarEmpresa
(
    @p_id_empresa INT,
    @p_razon_social VARCHAR(100) = NULL,
    @p_cuit VARCHAR(11)  = NULL,
    @p_contacto VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa
    )
        SET @v_errores += N'- [id_empresa] No existe una empresa con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_razon_social IS NOT NULL
    BEGIN
        SET @p_razon_social = TRIM(@p_razon_social);
        IF @p_razon_social = '' OR LEN(@p_razon_social) > 100
            SET @v_errores += N'- [razon_social] La razon social no puede estar vacia y debe tener hasta 100 caracteres.' + CHAR(10);
    END

    -- Normalizar y validar cadena de texto
    -- Normalizar CUIT antes de validar formato y unicidad
    IF @p_cuit IS NOT NULL
    BEGIN
        SET @p_cuit = TRIM(@p_cuit);
        IF @p_cuit LIKE '%[^0-9]%' OR LEN(@p_cuit) <> 11
            SET @v_errores += N'- [cuit] El CUIT debe contener exactamente 11 digitos.' + CHAR(10);

        -- El CUIT debe ser exclusivo por empresa (constraint de negocio)
        IF EXISTS
        (
            SELECT 1 FROM concesiones.Empresa
            WHERE cuit = @p_cuit AND id_empresa <> @p_id_empresa
        )
            SET @v_errores += N'- [cuit] El CUIT ya esta registrado en otra empresa.' + CHAR(10);
    END

    -- Normalizar y validar cadena de texto
    IF @p_contacto IS NOT NULL
    BEGIN
        SET @p_contacto = TRIM(@p_contacto);
        IF @p_contacto = '' OR LEN(@p_contacto) > 100
            SET @v_errores += N'- [contacto] El contacto no puede estar vacio y debe tener hasta 100 caracteres.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE concesiones.Empresa
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            razon_social = COALESCE(@p_razon_social, razon_social),
            cuit = COALESCE(@p_cuit, cuit),
            contacto = COALESCE(@p_contacto, contacto)
        WHERE id_empresa = @p_id_empresa;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Empresa actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE concesiones.sp_ModificarPagoConcesion
(
    @p_id_pago INT,
    @p_id_empresa INT = NULL,
    @p_id_concesion INT = NULL,
    @p_fecha_pago DATE = NULL,
    @p_monto DECIMAL(12,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM concesiones.PagoConcesion WHERE id_pago = @p_id_pago
    )
        SET @v_errores += N'- [id_pago] No existe un pago de concesion con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_empresa IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa
    )
        SET @v_errores += N'- [id_empresa] No existe una empresa con ese ID.' + CHAR(10);

    IF @p_id_concesion IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @p_id_concesion
    )
        SET @v_errores += N'- [id_concesion] No existe una concesion con ese ID.' + CHAR(10);

    -- Validar valor numérico positivo
    -- El monto puede diferir del pago_mensual original
    IF @p_monto IS NOT NULL AND @p_monto <= 0
        SET @v_errores += N'- [monto] El monto debe ser mayor a 0.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- El monto puede diferir del pago_mensual para reflejar ajustes
        UPDATE concesiones.PagoConcesion
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_empresa = COALESCE(@p_id_empresa, id_empresa),
            id_concesion = COALESCE(@p_id_concesion, id_concesion),
            fecha_pago = COALESCE(@p_fecha_pago, fecha_pago),
            monto = COALESCE(@p_monto, monto)
        WHERE id_pago = @p_id_pago;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Pago actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0 
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- ESQUEMA: parques
-- ============================================================

-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE parques.sp_ModificarParque
(
    @p_id_parque INT,
    @p_nombre VARCHAR(100) = NULL,
    @p_ubicacion VARCHAR(200) = NULL,
    @p_superficie DECIMAL(12,2) = NULL,
    @p_tipo VARCHAR(50) = NULL,
    @p_latitud DECIMAL(9,6) = NULL,
    @p_longitud DECIMAL(9,6) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Solo validar y actualizar campos proporcionados (no nulos)
    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque
    )
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_nombre IS NOT NULL
    BEGIN
        SET @p_nombre = TRIM(@p_nombre);
        IF @p_nombre = '' SET @v_errores += N'- [nombre] El nombre del parque no puede estar vacio.' + CHAR(10);
    END

    -- Normalizar y validar cadena de texto
    IF @p_ubicacion IS NOT NULL
    BEGIN
        SET @p_ubicacion = TRIM(@p_ubicacion);
        IF @p_ubicacion = '' SET @v_errores += N'- [ubicacion] La ubicacion no puede estar vacia.' + CHAR(10);
    END

    -- Validar valor numérico positivo
    IF @p_superficie IS NOT NULL AND @p_superficie <= 0
        SET @v_errores += N'- [superficie] La superficie debe ser mayor a 0.' + CHAR(10);

    -- Validar tipo de parque dentro del dominio
    IF @p_tipo IS NOT NULL
    BEGIN
        SET @p_tipo = TRIM(@p_tipo);
        IF @p_tipo = '' SET @v_errores += N'- [tipo] El tipo de parque no puede estar vacio.' + CHAR(10);
    END

    -- Coordenadas válidas para territorio argentino
    IF @p_latitud IS NOT NULL AND (@p_latitud <= -90 OR @p_latitud >= 90)
        SET @v_errores += N'- [latitud] La latitud debe ser mayor a -90 y menor a 90.' + CHAR(10);

    IF @p_longitud IS NOT NULL AND (@p_longitud <= -180 OR @p_longitud >= 180)
        SET @v_errores += N'- [longitud] La longitud debe ser mayor a -180 y menor a 180.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE parques.Parque
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            nombre = COALESCE(@p_nombre, nombre),
            ubicacion  = COALESCE(@p_ubicacion, ubicacion),
            superficie = COALESCE(@p_superficie, superficie),
            tipo = COALESCE(@p_tipo, tipo),
            latitud = COALESCE(@p_latitud, latitud),
            longitud = COALESCE(@p_longitud, longitud)
        WHERE id_parque = @p_id_parque;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Parque actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0 
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE parques.sp_ModificarTipoVisitante
(
    @p_id_tipo INT,
    @p_descripcion VARCHAR(50) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM parques.TipoVisitante WHERE id_tipo = @p_id_tipo
    )
        SET @v_errores += N'- [id_tipo] No existe un tipo de visitante con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_descripcion IS NOT NULL
    BEGIN
        -- Solo ejecutar si se proporcionó un nuevo valor de descripción
        SET @p_descripcion = TRIM(@p_descripcion);

        -- Solo se permiten las 5 categorías definidas en la tabla
        IF @p_descripcion NOT IN ('Residente','Extranjero','Estudiante','Jubilado','Menor')
            SET @v_errores += N'- [descripcion] Debe ser uno de: Residente, Extranjero, Estudiante, Jubilado, Menor.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos

    -- Solo ejecutar UPDATE si se proporcionó un nuevo valor
    IF @p_descripcion IS NOT NULL
    BEGIN
        -- Abrir transacción para garantizar atomicidad
        BEGIN TRANSACTION;
        BEGIN TRY

            UPDATE parques.TipoVisitante
            SET descripcion = @p_descripcion
            WHERE id_tipo = @p_id_tipo;

            -- Confirmar la transacción
            COMMIT;
        END TRY
        BEGIN CATCH
            -- Revertir transacción pendiente en caso de error
            IF @@TRANCOUNT > 0
            ROLLBACK;
            THROW;
        END CATCH
    END

    -- Confirmar éxito al cliente
    PRINT 'Tipo de visitante actualizado correctamente.';
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE parques.sp_ModificarPrecioEntrada
(
    @p_id_precio INT,
    @p_id_parque INT = NULL,
    @p_id_tipo INT = NULL,
    @p_precio DECIMAL(10,2) = NULL,
    @p_vigencia_desde DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM parques.PrecioEntrada WHERE id_precio = @p_id_precio
    )
        SET @v_errores += N'- [id_precio] No existe un precio de entrada con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_parque IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque
    )
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    IF @p_id_tipo IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.TipoVisitante WHERE id_tipo = @p_id_tipo
    )
        SET @v_errores += N'- [id_tipo] No existe un tipo de visitante con ese ID.' + CHAR(10);

    -- Validar valor numérico positivo
    IF @p_precio IS NOT NULL AND @p_precio < 0
        SET @v_errores += N'- [precio] El precio no puede ser negativo.' + CHAR(10);

    -- Un mismo parque/tipo no puede tener dos precios vigentes desde la misma fecha
    -- ISNULL usa el valor actual cuando no se proporciona nuevo parque/tipo
    IF @p_vigencia_desde IS NOT NULL
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM parques.PrecioEntrada
            WHERE id_parque = ISNULL(@p_id_parque, id_parque)
              AND id_tipo = ISNULL(@p_id_tipo,   id_tipo)
              AND vigencia_desde = @p_vigencia_desde
              AND id_precio <> @p_id_precio
        )
            SET @v_errores += N'- [vigencia_desde] Ya existe un precio para ese parque, tipo y fecha.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE parques.PrecioEntrada
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_parque = COALESCE(@p_id_parque, id_parque),
            id_tipo = COALESCE(@p_id_tipo, id_tipo),
            precio = COALESCE(@p_precio, precio),
            vigencia_desde = COALESCE(@p_vigencia_desde, vigencia_desde)
        WHERE id_precio = @p_id_precio;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Precio de entrada actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- ESQUEMA: personal
-- ============================================================

-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE personal.sp_ModificarAsignacionParque
(
    @p_id_asignacion INT,
    @p_id_guardaparque INT = NULL,
    @p_id_parque INT = NULL,
    @p_fecha_desde DATE = NULL,
    @p_fecha_hasta DATE = NULL,
    @p_motivo_egreso VARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM personal.AsignacionParque WHERE id_asignacion = @p_id_asignacion
    )
        SET @v_errores += N'- [id_asignacion] No existe una asignacion con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_guardaparque IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM personal.Guardaparque WHERE id_guardaparque = @p_id_guardaparque
    )
        SET @v_errores += N'- [id_guardaparque] No existe un guardaparque con ese ID.' + CHAR(10);

    IF @p_id_parque IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque
    )
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

   
    -- Obtener fechas actuales para cálculo de efectivas
    -- Se leen los valores actuales para calcular fechas efectivas
    DECLARE @v_fd_actual DATE, @v_fh_actual DATE;
    SELECT @v_fd_actual = fecha_desde, @v_fh_actual = fecha_hasta
    FROM personal.AsignacionParque
    WHERE id_asignacion = @p_id_asignacion;

    DECLARE @v_fd_efectiva DATE = COALESCE(@p_fecha_desde, @v_fd_actual);
    DECLARE @v_fh_efectiva DATE = COALESCE(@p_fecha_hasta, @v_fh_actual);

    IF @v_fd_efectiva IS NOT NULL AND @v_fh_efectiva IS NOT NULL
        AND @v_fh_efectiva <= @v_fd_efectiva
        SET @v_errores += N'- [fechas] La fecha de egreso debe ser posterior a la fecha de inicio.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- motivo_egreso: NULLIF+TRIM evita guardar cadenas vacías como valor válido
        UPDATE personal.AsignacionParque
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_guardaparque = COALESCE(@p_id_guardaparque, id_guardaparque),
            id_parque       = COALESCE(@p_id_parque,       id_parque),
            fecha_desde     = COALESCE(@p_fecha_desde,     fecha_desde),
            fecha_hasta     = COALESCE(@p_fecha_hasta,     fecha_hasta),
            motivo_egreso   = COALESCE(NULLIF(TRIM(ISNULL(@p_motivo_egreso,'')),'' ), motivo_egreso)
        WHERE id_asignacion = @p_id_asignacion;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Asignacion actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO


-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE personal.sp_ModificarGuardaparque
(
    @p_id_guardaparque INT,
    @p_nombre          VARCHAR(50) = NULL,
    @p_apellido        VARCHAR(50) = NULL,
    @p_dni             INT         = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS (SELECT 1 FROM personal.Guardaparque WHERE id_guardaparque = @p_id_guardaparque)
        SET @v_errores += N'- [id_guardaparque] No existe un guardaparque con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_nombre IS NOT NULL
    BEGIN
        SET @p_nombre = TRIM(@p_nombre);
        IF @p_nombre = '' SET @v_errores += N'- [nombre] El nombre no puede estar vacio.' + CHAR(10);
    END

    IF @p_apellido IS NOT NULL
    BEGIN
        SET @p_apellido = TRIM(@p_apellido);
        IF @p_apellido = '' SET @v_errores += N'- [apellido] El apellido no puede estar vacio.' + CHAR(10);
    END

    -- El DNI se descifra dinámicamente porque está encriptado (seguridad.Cifrar)
    IF @p_dni IS NOT NULL
    BEGIN
        IF @p_dni <= 0 OR @p_dni > 99999999
            SET @v_errores += N'- [dni] El DNI debe ser un numero entre 1 y 99999999.' + CHAR(10);

        IF EXISTS (SELECT 1 FROM personal.Guardaparque
                   WHERE CAST(seguridad.Descifrar(dni_cifrado) AS INT) = @p_dni
                     AND id_guardaparque <> @p_id_guardaparque)
            SET @v_errores += N'- [dni] Ya existe otro guardaparque con ese DNI.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Encriptar DNI nuevo si se proporciona (caso contrario conservar el actual)
        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE personal.Guardaparque
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            nombre = COALESCE(@p_nombre, nombre),
            apellido = COALESCE(@p_apellido, apellido),
            dni_cifrado = CASE WHEN @p_dni IS NOT NULL THEN seguridad.Cifrar(@p_dni) ELSE dni_cifrado END
        WHERE id_guardaparque = @p_id_guardaparque;

        -- Confirmar la transacción
        COMMIT;
        -- Confirmar éxito al cliente
        PRINT 'Guardaparque actualizado correctamente.';
    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- ESQUEMA: actividades
-- ============================================================

-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE actividades.sp_ModificarAtraccion
(
    @p_id_atraccion INT,
    @p_id_parque INT = NULL,
    @p_nombre VARCHAR(100)  = NULL,
    @p_tipo VARCHAR(30)   = NULL,
    @p_costo DECIMAL(10,2) = NULL,
    @p_duracion INT = NULL,
    @p_horario_inicio TIME = NULL,
    @p_cupo_maximo INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion
    )
        SET @v_errores += N'- [id_atraccion] No existe una atraccion con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_parque IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque
    )
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_nombre IS NOT NULL
    BEGIN
        SET @p_nombre = TRIM(@p_nombre);
        IF @p_nombre = '' SET @v_errores += N'- [nombre] El nombre de la atraccion no puede estar vacio.' + CHAR(10);
    END

    -- Validar valor dentro del dominio permitido
    IF @p_tipo IS NOT NULL AND @p_tipo NOT IN ('Gratuita','Paga','Tour Guiado')
        SET @v_errores += N'- [tipo] Debe ser uno de: Gratuita, Paga, Tour Guiado.' + CHAR(10);

    -- Validar valor numérico positivo
    IF @p_costo IS NOT NULL AND @p_costo < 0
        SET @v_errores += N'- [costo] El costo no puede ser negativo.' + CHAR(10);

    -- Regla de negocio: Gratuita → costo=0; Paga/Tour Guiado → costo>0
    -- Validación cruzada tipo-costos: coherencia de negocio
    IF @p_tipo = 'Gratuita' AND @p_costo <> 0
        SET @v_errores += N'- [costo] Una atraccion Gratuita debe tener costo = 0.' + CHAR(10);

    -- Regla: actividades de pago deben tener costo positivo
    IF @p_tipo IN ('Paga', 'Tour Guiado') AND @p_costo <= 0
        SET @v_errores += N'- [costo] Una atraccion Paga o Tour Guiado debe tener costo mayor a 0.' + CHAR(10);

    IF @p_duracion IS NOT NULL AND @p_duracion <= 0
        SET @v_errores += N'- [duracion] La duracion debe ser mayor a 0 minutos.' + CHAR(10);

    IF @p_cupo_maximo IS NOT NULL AND @p_cupo_maximo <= 0
        SET @v_errores += N'- [cupo_maximo] El cupo maximo debe ser mayor a 0.' + CHAR(10);

    IF @p_horario_inicio IS NOT NULL AND @p_horario_inicio < '00:00:00'
        SET @v_errores += N'- [horario_inicio] El horario de inicio no es valido.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE actividades.Atraccion
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_parque = COALESCE(@p_id_parque, id_parque),
            nombre = COALESCE(@p_nombre, nombre),
            tipo = COALESCE(@p_tipo, tipo),
            costo = COALESCE(@p_costo, costo),
            duracion = COALESCE(@p_duracion, duracion),
            horario_inicio = COALESCE(@p_horario_inicio, horario_inicio),
            cupo_maximo = COALESCE(@p_cupo_maximo, cupo_maximo)
        WHERE id_atraccion = @p_id_atraccion;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Atraccion actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE actividades.sp_ModificarGuia
(
    @p_id_guia INT,
    @p_nombre VARCHAR(50) = NULL,
    @p_apellido VARCHAR(50) = NULL,
    @p_dni INT = NULL,
    @p_especialidad VARCHAR(100) = NULL,
    @p_titulo VARCHAR(100) = NULL,
    @p_vigencia_autorizacion DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS (SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'- [id_guia] No existe un guia con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_nombre IS NOT NULL
    BEGIN
        SET @p_nombre = TRIM(@p_nombre);
        IF @p_nombre = '' SET @v_errores += N'- [nombre] El nombre del guia no puede estar vacio.' + CHAR(10);
    END

    IF @p_apellido IS NOT NULL
    BEGIN
        SET @p_apellido = TRIM(@p_apellido);
        IF @p_apellido = '' SET @v_errores += N'- [apellido] El apellido del guia no puede estar vacio.' + CHAR(10);
    END

    -- El DNI se valida contra la tabla encriptada usando seguridad.Descifrar
    IF @p_dni IS NOT NULL
    BEGIN
        IF @p_dni <= 0 OR @p_dni > 99999999
            SET @v_errores += N'- [dni] El DNI debe ser un numero entre 1 y 99999999.' + CHAR(10);

        IF EXISTS (SELECT 1 FROM actividades.Guia
                   WHERE CAST(seguridad.Descifrar(dni_cifrado) AS INT) = @p_dni
                     AND id_guia <> @p_id_guia)
            SET @v_errores += N'- [dni] Ya existe otro guia registrado con ese DNI.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Encriptar DNI, limpiar especialidad/título con NULLIF+TRIM
        -- especialidad y título: NULLIF+TRIM permite diferenciar "vacío" de NULL
        UPDATE actividades.Guia
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            nombre = COALESCE(@p_nombre, nombre),
            apellido = COALESCE(@p_apellido, apellido),
            dni_cifrado = CASE WHEN @p_dni IS NOT NULL THEN seguridad.Cifrar(@p_dni) ELSE dni_cifrado END,
            especialidad = COALESCE(NULLIF(TRIM(ISNULL(@p_especialidad,'')),'' ), especialidad),
            titulo = COALESCE(NULLIF(TRIM(ISNULL(@p_titulo,'')),'' ), titulo),
            vigencia_autorizacion = COALESCE(@p_vigencia_autorizacion, vigencia_autorizacion)
        WHERE id_guia = @p_id_guia;

        -- Confirmar la transacción
        COMMIT;
        -- Confirmar éxito al cliente
        PRINT 'Guia actualizado correctamente.';
    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE actividades.sp_ModificarHabilitacionGuia
(
    @p_id_habilitacion INT,
    @p_id_guia INT = NULL,
    @p_descripcion VARCHAR(100) = NULL,
    @p_fecha_vencimiento DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM actividades.HabilitacionGuia WHERE id_habilitacion = @p_id_habilitacion
    )
        SET @v_errores += N'- [id_habilitacion] No existe una habilitacion con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_guia IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia
    )
        SET @v_errores += N'- [id_guia] No existe un guia con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    IF @p_descripcion IS NOT NULL
    BEGIN
        SET @p_descripcion = TRIM(@p_descripcion);
        IF @p_descripcion = '' SET @v_errores += N'- [descripcion] La descripcion no puede estar vacia.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- La habilitación se asocia a un guía existente
        UPDATE actividades.HabilitacionGuia
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_guia = COALESCE(@p_id_guia, id_guia),
            descripcion = COALESCE(@p_descripcion, descripcion),
            fecha_vencimiento = COALESCE(@p_fecha_vencimiento, fecha_vencimiento)
        WHERE id_habilitacion = @p_id_habilitacion;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Habilitacion actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- ESQUEMA: actividades (cont.)
-- ============================================================

/* ============================================================
   sp_ModificarTourGuia
   Modifica la asignación de un guía a un tour.
   ============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_ModificarTourGuia
(
    @p_id_tour_guia INT,
    @p_id_guia INT = NULL,
    @p_id_atraccion INT = NULL,
    @p_fecha DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS (SELECT 1 FROM actividades.TourGuia WHERE id_tour_guia = @p_id_tour_guia)
        SET @v_errores += N'- [id_tour_guia] No existe un tour-guía con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_guia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'- [id_guia] No existe un guía con ese ID.' + CHAR(10);

    IF @p_id_atraccion IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion)
        SET @v_errores += N'- [id_atraccion] No existe una atracción con ese ID.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Solo se modifican guía, atracción o fecha de la asignación
        UPDATE actividades.TourGuia
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_guia = COALESCE(@p_id_guia, id_guia),
            id_atraccion = COALESCE(@p_id_atraccion, id_atraccion),
            fecha = COALESCE(@p_fecha, fecha)
        WHERE id_tour_guia = @p_id_tour_guia;

        -- Confirmar la transacción
        COMMIT;
        -- Confirmar éxito al cliente
        PRINT 'Asignación de tour-guía actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO

-- ============================================================
-- ESQUEMA: ventas
-- ============================================================

-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE ventas.sp_ModificarTicket
(
    @p_id_ticket INT,
    @p_id_parque INT = NULL,
    @p_fecha DATE = NULL,   -- Fecha de emisión
    @p_fecha_acceso DATE = NULL,
    @p_punto_de_venta INT = NULL,
    @p_numero_comprobante INT = NULL,
    @p_forma_pago VARCHAR(30) = NULL,
    @p_total_pagado DECIMAL(10,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM ventas.Ticket WHERE id_ticket = @p_id_ticket
    )
        SET @v_errores += N'- [id_ticket] No existe un ticket con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_parque IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque
    )
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Validar valor dentro del dominio permitido
    IF @p_forma_pago IS NOT NULL
        AND @p_forma_pago NOT IN ('Efectivo','Tarjeta de Debito','Tarjeta de Credito','Transferencia','Moneda Extranjera')
        SET @v_errores += N'- [forma_pago] Debe ser uno de: Efectivo, Tarjeta de Debito, Tarjeta de Credito, Transferencia, Moneda Extranjera.' + CHAR(10);

    -- Validar valor numérico positivo
    IF @p_total_pagado IS NOT NULL AND @p_total_pagado < 0
        SET @v_errores += N'- [total_pagado] El total pagado no puede ser negativo.' + CHAR(10);

    -- Obtener fechas actuales para comparar coherencia
    DECLARE @v_fecha_actual DATE, @v_fecha_acceso_actual DATE;
    SELECT @v_fecha_actual = fecha, @v_fecha_acceso_actual = fecha_acceso
    FROM ventas.Ticket WHERE id_ticket = @p_id_ticket;

    DECLARE @v_fecha_efectiva DATE = COALESCE(@p_fecha, @v_fecha_actual);
    DECLARE @v_fecha_acceso_efectiva DATE = COALESCE(@p_fecha_acceso, @v_fecha_acceso_actual);

    -- La fecha de acceso debe ser igual o posterior a la de emisión
    IF @v_fecha_acceso_efectiva < @v_fecha_efectiva
        SET @v_errores += N'- [fecha_acceso] La fecha de acceso no puede ser anterior a la fecha de emision.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Actualización parcial: solo se modifican campos con valor no nulo (COALESCE)
        UPDATE ventas.Ticket
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_parque = COALESCE(@p_id_parque, id_parque),
            fecha = COALESCE(@p_fecha, fecha),
            fecha_acceso = COALESCE(@p_fecha_acceso, fecha_acceso),
            punto_de_venta = COALESCE(@p_punto_de_venta, punto_de_venta),
            numero_comprobante = COALESCE(@p_numero_comprobante, numero_comprobante),
            forma_pago = COALESCE(@p_forma_pago, forma_pago),
            total_pagado = COALESCE(@p_total_pagado, total_pagado)
        WHERE id_ticket = @p_id_ticket;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Ticket actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE ventas.sp_ModificarItemTicket
(
    @p_id_item INT,
    @p_id_ticket INT = NULL,
    @p_id_precio_entrada INT = NULL,
    @p_id_atraccion INT = NULL,
    @p_precio_venta DECIMAL(10,2) = NULL,
    @p_cantidad INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM ventas.ItemTicket WHERE id_item = @p_id_item
    )
        SET @v_errores += N'- [id_item] No existe un item de ticket con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    -- Validar que el registro referenciado exista en la tabla correspondiente
    IF @p_id_ticket IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM ventas.Ticket WHERE id_ticket = @p_id_ticket
    )
        SET @v_errores += N'- [id_ticket] No existe un ticket con ese ID.' + CHAR(10);

    -- Validar que el registro referenciado exista en la tabla correspondiente
    IF @p_id_precio_entrada IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM parques.PrecioEntrada WHERE id_precio = @p_id_precio_entrada
    )
        SET @v_errores += N'- [id_precio_entrada] No existe un precio de entrada con ese ID.' + CHAR(10);

    -- Validar que el registro referenciado exista en la tabla correspondiente
    IF @p_id_atraccion IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion
    )
        SET @v_errores += N'- [id_atraccion] No existe una atraccion con ese ID.' + CHAR(10);

    -- Validar valor numérico positivo
    IF @p_precio_venta IS NOT NULL AND @p_precio_venta < 0
        SET @v_errores += N'- [precio_venta] El precio de venta no puede ser negativo.' + CHAR(10);

    IF @p_cantidad IS NOT NULL AND @p_cantidad <= 0
        SET @v_errores += N'- [cantidad] La cantidad debe ser mayor a 0.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Los items de ticket son las líneas individuales (entradas o atracciones)
        UPDATE ventas.ItemTicket
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_ticket = COALESCE(@p_id_ticket, id_ticket),
            id_precio_entrada = COALESCE(@p_id_precio_entrada, id_precio_entrada),
            id_atraccion = COALESCE(@p_id_atraccion, id_atraccion),
            precio_venta = COALESCE(@p_precio_venta, precio_venta),
            cantidad = COALESCE(@p_cantidad, cantidad)
        WHERE id_item = @p_id_item;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Item actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE ventas.sp_ModificarTasaCambio
(
    @p_id_tasa INT,
    @p_id_moneda INT = NULL,
    @p_fecha_vigencia DATE = NULL,
    @p_tasa_a_peso DECIMAL(12,4) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM ventas.TasaCambio WHERE id_tasa = @p_id_tasa
    )
        SET @v_errores += N'- [id_tasa] No existe una tasa de cambio con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_moneda IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM ventas.Moneda WHERE id_moneda = @p_id_moneda
    )
        SET @v_errores += N'- [id_moneda] No existe una moneda con ese ID.' + CHAR(10);

    -- Validar valor numérico positivo
    -- La tasa debe ser positiva para poder convertir
    IF @p_tasa_a_peso IS NOT NULL AND @p_tasa_a_peso <= 0
        SET @v_errores += N'- [tasa_a_peso] La tasa debe ser mayor a 0.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Las tasas de cambio se aplican a pagos en moneda extranjera
        UPDATE ventas.TasaCambio
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_moneda = COALESCE(@p_id_moneda, id_moneda),
            fecha_vigencia = COALESCE(@p_fecha_vigencia, fecha_vigencia),
            tasa_a_peso = COALESCE(@p_tasa_a_peso, tasa_a_peso)
        WHERE id_tasa = @p_id_tasa;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Tasa de cambio actualizada correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE ventas.sp_ModificarMoneda
(
    @p_id_moneda INT,
    @p_codigo_iso CHAR(3) = NULL,
    @p_nombre VARCHAR(50) = NULL,
    @p_simbolo VARCHAR(5) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM ventas.Moneda WHERE id_moneda = @p_id_moneda
    )
        SET @v_errores += N'- [id_moneda] No existe una moneda con ese ID.' + CHAR(10);

    -- Normalizar y validar cadena de texto
    -- Normalizar y validar código ISO 4217 de 3 letras
    IF @p_codigo_iso IS NOT NULL
    BEGIN
        SET @p_codigo_iso = TRIM(@p_codigo_iso);
        IF LEN(@p_codigo_iso) <> 3
            SET @v_errores += N'- [codigo_iso] El código ISO debe tener exactamente 3 caracteres.' + CHAR(10);
        ELSE IF EXISTS
        (
            SELECT 1 FROM ventas.Moneda
            WHERE codigo_iso = @p_codigo_iso AND id_moneda <> @p_id_moneda
        )
            SET @v_errores += N'- [codigo_iso] El código ISO ingresado ya se encuentra registrado en otra moneda.' + CHAR(10);
    END

    -- Normalizar y validar cadena de texto
    -- Limpiar espacios y verificar que no esté vacío
    IF @p_nombre IS NOT NULL
    BEGIN
        SET @p_nombre = TRIM(@p_nombre);
        IF @p_nombre = ''
            SET @v_errores += N'- [nombre] El nombre de la moneda no puede estar vacio.' + CHAR(10);
    END

    -- Limpiar espacios del símbolo monetario
    IF @p_simbolo IS NOT NULL
    BEGIN
        SET @p_simbolo = TRIM(@p_simbolo);
        IF @p_simbolo = ''
            SET @v_errores += N'- [simbolo] El simbolo de la moneda no puede estar vacio.' + CHAR(10);
    END

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Las monedas se utilizan para registrar pagos en divisa
        UPDATE ventas.Moneda
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            codigo_iso = COALESCE(@p_codigo_iso, codigo_iso),
            nombre = COALESCE(@p_nombre, nombre),
            simbolo = COALESCE(@p_simbolo, simbolo)
        WHERE id_moneda = @p_id_moneda;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Moneda actualizada correctamente.';
    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO



-- Reutiliza: patrón de actualización parcial con COALESCE

CREATE OR ALTER PROCEDURE ventas.sp_ModificarPagoMonedaExtranjera
(
    @p_id_pago_ext INT,
    @p_id_ticket INT = NULL,
    @p_id_tasa INT = NULL,
    @p_monto_extranjero DECIMAL(12,2) = NULL,
    @p_monto_pesos DECIMAL(12,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N''; -- Acumular todos los errores de validación en un solo mensaje

    -- Validar que el registro exista
    IF NOT EXISTS
    (
        SELECT 1 FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = @p_id_pago_ext
    )
        SET @v_errores += N'- [id_pago_ext] No existe un pago en moneda extranjera con ese ID.' + CHAR(10);

    -- Validar que la empresa/parque/guía/etc. referenciado exista
    IF @p_id_ticket IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM ventas.Ticket WHERE id_ticket = @p_id_ticket
    )
        SET @v_errores += N'- [id_ticket] No existe un ticket con ese ID.' + CHAR(10);

    IF @p_id_tasa IS NOT NULL AND NOT EXISTS
    (
        SELECT 1 FROM ventas.TasaCambio WHERE id_tasa = @p_id_tasa
    )
        SET @v_errores += N'- [id_tasa] No existe una tasa de cambio con ese ID.' + CHAR(10);

    -- Validar valor numérico positivo
    -- Monto en divisa original
    IF @p_monto_extranjero IS NOT NULL AND @p_monto_extranjero <= 0
        SET @v_errores += N'- [monto_extranjero] El monto en moneda extranjera debe ser mayor a 0.' + CHAR(10);

    -- Monto equivalente en pesos argentinos
    IF @p_monto_pesos IS NOT NULL AND @p_monto_pesos <= 0
        SET @v_errores += N'- [monto_pesos] El monto en pesos debe ser mayor a 0.' + CHAR(10);

    -- Si hubo errores, abortar la ejecución
    IF @v_errores <> N''
        THROW 50000, @v_errores, 1;

    -- --------------------------------------------------
    -- A partir de aquí comienza la operación sobre datos
    -- Abrir transacción para garantizar atomicidad
    BEGIN TRANSACTION;
    BEGIN TRY

        -- Registra la conversión de divisa a pesos al momento de la venta
        UPDATE ventas.PagoMonedaExtranjera
        SET
            -- COALESCE preserva el valor actual cuando el parámetro es NULL
            id_ticket = COALESCE(@p_id_ticket, id_ticket),
            id_tasa = COALESCE(@p_id_tasa, id_tasa),
            monto_extranjero = COALESCE(@p_monto_extranjero, monto_extranjero),
            monto_pesos = COALESCE(@p_monto_pesos, monto_pesos)
        WHERE id_pago_ext = @p_id_pago_ext;

        -- Confirmar la transacción
        COMMIT;

        -- Confirmar éxito al cliente
        PRINT 'Pago en moneda extranjera actualizado correctamente.';

    END TRY
    BEGIN CATCH
        -- Revertir transacción pendiente en caso de error
        IF @@TRANCOUNT > 0
        ROLLBACK;
        THROW;
    END CATCH
END
GO