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

  Archivo:     05_SPBorrado.sql
  Descripcion: Stored Procedures de DELETE (baja) para todas las tablas del
               sistema de gestión de Parques Nacionales.
               Cada SP verifica dependencias antes de eliminar y reporta
               mensajes claros con todos los impedimentos encontrados.
================================================================================
*/

USE ParquesNacionales;
GO

-- ============================================================
-- ESQUEMA: parques
-- ============================================================

/* ============================================================
   sp_BorrarParque
   Elimina un parque si no tiene registros dependientes.
   Dependencias: Ticket, PrecioEntrada, Atraccion,
                 AsignacionParque, Concesion
   Parametros:   @p_id_parque  ID del parque a eliminar
   ============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_BorrarParque
    @p_id_parque INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM parques.Parque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- [id_parque] No existe un parque con ese ID.' + CHAR(10);

    -- Dependencia: ventas.Ticket
    -- Verificar que no existan registros dependientes en otras tablas
    IF EXISTS (SELECT 1 FROM ventas.Ticket WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- El parque tiene tickets emitidos. Elimine los tickets primero.' + CHAR(10);

    -- Dependencia: parques.PrecioEntrada
    IF EXISTS (SELECT 1 FROM parques.PrecioEntrada WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- El parque tiene precios de entrada registrados.' + CHAR(10);

    -- Dependencia: actividades.Atraccion
    IF EXISTS (SELECT 1 FROM actividades.Atraccion WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- El parque tiene atracciones registradas.' + CHAR(10);

    -- Dependencia: personal.AsignacionParque
    IF EXISTS (SELECT 1 FROM personal.AsignacionParque WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- El parque tiene guardaparques asignados.' + CHAR(10);

    -- Dependencia: concesiones.Concesion
    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_parque = @p_id_parque)
        SET @v_errores += N'- El parque tiene concesiones registradas.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar el parque. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM parques.Parque WHERE id_parque = @p_id_parque;
        PRINT 'Parque eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarTipoVisitante
   Elimina un tipo de visitante si no tiene precios asociados.
   Dependencias: PrecioEntrada
   ============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_BorrarTipoVisitante
    @p_id_tipo INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM parques.TipoVisitante WHERE id_tipo = @p_id_tipo)
        SET @v_errores += N'- [id_tipo] No existe un tipo de visitante con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM parques.PrecioEntrada WHERE id_tipo = @p_id_tipo)
        SET @v_errores += N'- El tipo de visitante tiene precios de entrada registrados.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar el tipo de visitante. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM parques.TipoVisitante WHERE id_tipo = @p_id_tipo;
        PRINT 'Tipo de visitante eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarPrecioEntrada
   Elimina un precio de entrada si no tiene items de ticket asociados.
   Dependencias: ItemTicket
   ============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_BorrarPrecioEntrada
    @p_id_precio INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM parques.PrecioEntrada WHERE id_precio = @p_id_precio)
        SET @v_errores += N'- [id_precio] No existe un precio de entrada con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM ventas.ItemTicket WHERE id_precio_entrada = @p_id_precio)
        SET @v_errores += N'- El precio de entrada tiene tickets emitidos asociados.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar el precio de entrada. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM parques.PrecioEntrada WHERE id_precio = @p_id_precio;
        PRINT 'Precio de entrada eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


-- ============================================================
-- ESQUEMA: ventas
-- ============================================================

/* ============================================================
   sp_BorrarMoneda
   Elimina una moneda si no tiene tasas de cambio asociadas.
   Dependencias: TasaCambio
   ============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_BorrarMoneda
    @p_id_moneda INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Moneda WHERE id_moneda = @p_id_moneda)
        SET @v_errores += N'- [id_moneda] No existe una moneda con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM ventas.TasaCambio WHERE id_moneda = @p_id_moneda)
        SET @v_errores += N'- La moneda tiene tasas de cambio registradas.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar la moneda. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM ventas.Moneda WHERE id_moneda = @p_id_moneda;
        PRINT 'Moneda eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarTasaCambio
   Elimina una tasa de cambio si no tiene pagos en moneda extranjera asociados.
   Dependencias: PagoMonedaExtranjera
   ============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_BorrarTasaCambio
    @p_id_tasa INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM ventas.TasaCambio WHERE id_tasa = @p_id_tasa)
        SET @v_errores += N'- [id_tasa] No existe una tasa de cambio con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM ventas.PagoMonedaExtranjera WHERE id_tasa = @p_id_tasa)
        SET @v_errores += N'- La tasa de cambio tiene pagos en moneda extranjera asociados.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar la tasa de cambio. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM ventas.TasaCambio WHERE id_tasa = @p_id_tasa;
        PRINT 'Tasa de cambio eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarTicket
   Elimina un ticket y todos sus items y pagos asociados.
   Dependencias: ItemTicket, PagoMonedaExtranjera (se eliminan en cascada)
   ============================================================ */
-- Elimina en cascada: PagoMonedaExtranjera, ItemTicket
CREATE OR ALTER PROCEDURE ventas.sp_BorrarTicket
    @p_id_ticket INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM ventas.Ticket WHERE id_ticket = @p_id_ticket)
        THROW 50000, N'[id_ticket] No existe un ticket con ese ID.', 1;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- Primero eliminar hijos en orden inverso de FK
        -- Eliminar registros dependientes en orden inverso de FK
        DELETE FROM ventas.PagoMonedaExtranjera WHERE id_ticket = @p_id_ticket;
        DELETE FROM ventas.ItemTicket WHERE id_ticket = @p_id_ticket;
        -- Finalmente eliminar la cabecera del ticket
        DELETE FROM ventas.Ticket WHERE id_ticket = @p_id_ticket;

        COMMIT TRANSACTION;

        PRINT 'Ticket y sus registros asociados eliminados correctamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarItemTicket
   Elimina un item de ticket.
   Sin dependencias (tabla hija).
   ============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_BorrarItemTicket
    @p_id_item INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM ventas.ItemTicket WHERE id_item = @p_id_item)
        THROW 50000, N'[id_item] No existe un item de ticket con ese ID.', 1;

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM ventas.ItemTicket WHERE id_item = @p_id_item;
        PRINT 'Item de ticket eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarPagoMonedaExtranjera
   Elimina un registro de pago en moneda extranjera.
   Sin dependencias (tabla hija).
   ============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_BorrarPagoMonedaExtranjera
    @p_id_pago_ext INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = @p_id_pago_ext)
        THROW 50000, N'[id_pago_ext] No existe un pago en moneda extranjera con ese ID.', 1;

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = @p_id_pago_ext;
        PRINT 'Pago en moneda extranjera eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


-- ============================================================
-- ESQUEMA: actividades
-- ============================================================

/* ============================================================
   sp_BorrarGuia
   Elimina un guía si no tiene habilitaciones o tours asignados.
   Dependencias: HabilitacionGuia, TourGuia
   ============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_BorrarGuia
    @p_id_guia INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM actividades.Guia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'[id_guia] No existe un guía con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM actividades.HabilitacionGuia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'- El guía tiene habilitaciones registradas.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM actividades.TourGuia WHERE id_guia = @p_id_guia)
        SET @v_errores += N'- El guía tiene tours asignados.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar el guía. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM actividades.Guia WHERE id_guia = @p_id_guia;
        PRINT 'Guía eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarHabilitacionGuia
   Elimina una habilitación de guía.
   Sin dependencias (tabla hija).
   ============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_BorrarHabilitacionGuia
    @p_id_habilitacion INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM actividades.HabilitacionGuia WHERE id_habilitacion = @p_id_habilitacion)
        THROW 50000, N'[id_habilitacion] No existe una habilitación con ese ID.', 1;

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM actividades.HabilitacionGuia WHERE id_habilitacion = @p_id_habilitacion;
        PRINT 'Habilitación eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarAtraccion
   Elimina una atracción. Borra sus items de ticket referenciados
   y sus asignaciones de guías antes de eliminar la atracción.
   ============================================================ */
-- Elimina en cascada: ItemTicket (si existen)
CREATE OR ALTER PROCEDURE actividades.sp_BorrarAtraccion
    @p_id_atraccion INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion)
        THROW 50000, N'[id_atraccion] No existe una atracción con ese ID.', 1;

    BEGIN TRANSACTION;
    BEGIN TRY

        -- Nota: los ítems de ticket son registros financieros históricos
        -- Nota: se eliminan items de ticket asociados (registros financieros)
        DELETE FROM ventas.ItemTicket WHERE id_atraccion = @p_id_atraccion;
        DELETE FROM actividades.TourGuia WHERE id_atraccion = @p_id_atraccion;
        -- Eliminar el registro (sin dependencias)
        DELETE FROM actividades.Atraccion WHERE id_atraccion = @p_id_atraccion;

        COMMIT;

        PRINT 'Atracción eliminada correctamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarTourGuia
   Elimina una asignación de guía a tour.
   Sin dependencias (tabla hija).
   ============================================================ */
CREATE OR ALTER PROCEDURE actividades.sp_BorrarTourGuia
    @p_id_tour_guia INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM actividades.TourGuia WHERE id_tour_guia = @p_id_tour_guia)
        THROW 50000, N'[id_tour_guia] No existe una asignación tour-guía con ese ID.', 1;

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM actividades.TourGuia WHERE id_tour_guia = @p_id_tour_guia;
        PRINT 'Asignación tour-guía eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


-- ============================================================
-- ESQUEMA: concesiones
-- ============================================================

/* ============================================================
   sp_BorrarEmpresa
   Elimina una empresa si no tiene concesiones o pagos asociados.
   Dependencias: Concesion, PagoConcesion
   ============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_BorrarEmpresa
    @p_id_empresa INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa)
        SET @v_errores += N'[id_empresa] No existe una empresa con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_empresa = @p_id_empresa)
        SET @v_errores += N'- La empresa tiene concesiones registradas.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM concesiones.PagoConcesion WHERE id_empresa = @p_id_empresa)
        SET @v_errores += N'- La empresa tiene pagos de concesión registrados.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar la empresa. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM concesiones.Empresa WHERE id_empresa = @p_id_empresa;
        PRINT 'Empresa eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarConcesion
   Elimina una concesión si no tiene pagos asociados.
   Dependencias: PagoConcesion
   ============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_BorrarConcesion
    @p_id_concesion INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @p_id_concesion)
        SET @v_errores += N'[id_concesion] No existe una concesión con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM concesiones.PagoConcesion WHERE id_concesion = @p_id_concesion)
        SET @v_errores += N'- La concesión tiene pagos registrados.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar la concesión. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM concesiones.Concesion WHERE id_concesion = @p_id_concesion;
        PRINT 'Concesión eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

/* ============================================================
   sp_BorrarPagoConcesion
   Elimina un pago de concesión.
   Sin dependencias adicionales (tabla hija).
   ============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_BorrarPagoConcesion
    @p_id_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM concesiones.PagoConcesion WHERE id_pago = @p_id_pago)
        THROW 50000, N'[id_pago] No existe un pago de concesión con ese ID.', 1;

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM concesiones.PagoConcesion WHERE id_pago = @p_id_pago;
        PRINT 'Pago de concesión eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


-- ============================================================
-- ESQUEMA: personal
-- ============================================================

/* ============================================================
   sp_BorrarGuardaparque
   Elimina un guardaparque si no tiene asignaciones a parques.
   Dependencias: AsignacionParque
   ============================================================ */
CREATE OR ALTER PROCEDURE personal.sp_BorrarGuardaparque
    @p_id_guardaparque INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    DECLARE @v_errores NVARCHAR(2000) = N'';

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM personal.Guardaparque WHERE id_guardaparque = @p_id_guardaparque)
        SET @v_errores += N'[id_guardaparque] No existe un guardaparque con ese ID.' + CHAR(10);

    -- Verificar que no existan registros dependientes
    IF EXISTS (SELECT 1 FROM personal.AsignacionParque WHERE id_guardaparque = @p_id_guardaparque)
        SET @v_errores += N'- El guardaparque tiene asignaciones a parques.' + CHAR(10);

    IF @v_errores <> N''
    BEGIN
        -- Construir mensaje de error con todos los impedimentos encontrados
        SET @v_errores = N'No se puede eliminar el guardaparque. Motivos:' + CHAR(10) + @v_errores;
        THROW 50000, @v_errores, 1;
    END

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM personal.Guardaparque WHERE id_guardaparque = @p_id_guardaparque;
        PRINT 'Guardaparque eliminado correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


/* ============================================================
   sp_BorrarAsignacionParque
   Elimina una asignación de guardaparque a parque.
   Sin dependencias (tabla hija).
   ============================================================ */
CREATE OR ALTER PROCEDURE personal.sp_BorrarAsignacionParque
    @p_id_asignacion INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Evitar que SQL Server retorne conteo de filas afectadas al cliente

    -- Verificar que el registro a eliminar exista
    IF NOT EXISTS (SELECT 1 FROM personal.AsignacionParque WHERE id_asignacion = @p_id_asignacion)
        THROW 50000, N'[id_asignacion] No existe una asignación con ese ID.', 1;

    BEGIN TRY
        -- Eliminar el registro (sin dependencias)
        DELETE FROM personal.AsignacionParque WHERE id_asignacion = @p_id_asignacion;
        PRINT 'Asignación eliminada correctamente.';
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO


PRINT '============================================';
PRINT ' 05_SPBorrado.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
