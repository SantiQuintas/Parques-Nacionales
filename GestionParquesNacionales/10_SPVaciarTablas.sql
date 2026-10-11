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

  Archivo:      10_SPVaciarTablas.sql
  Descripcion:  Procedimiento almacenado que elimina todos los registros
                de todas las tablas en orden inverso de dependencias (FK-safe)
                y resetea los IDENTITY a 0. Permite re-ejecutar scripts de
                testing o de importación sobre una base limpia sin tener
                que recrear la DB.
===============================================================================
*/
USE ParquesNacionales;
GO

/* ============================================================
   dbo.sp_VaciarTablas
   Elimina todos los registros de todas las tablas en orden
   inverso de dependencias FK y resetea los IDENTITY a 0.
   Permite re-ejecutar scripts de testing o importación sobre
   una base limpia sin recrear la DB.

   Sin parametros de entrada.
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.sp_VaciarTablas
AS
BEGIN
    SET NOCOUNT ON;

    -- Eliminar datos en orden inverso de dependencias FK (hijos primero)

    -- 1. Feriados (sin dependencias salientes)
    DELETE FROM importacion.Feriado;
    -- 2. Log de importaciones (sin dependencias salientes)
    DELETE FROM importacion.LogImportacion;

    -- 3. Pagos en divisa (depende de Ticket, TasaCambio)
    DELETE FROM ventas.PagoMonedaExtranjera;

    -- 4. Ítems de ticket (depende de Ticket, PrecioEntrada, Atraccion)
    DELETE FROM ventas.ItemTicket;

    -- 5. Asignaciones guía-tour (depende de Guia, Atraccion)
    DELETE FROM actividades.TourGuia;

    -- 6. Habilitaciones de guías (depende de Guia)
    DELETE FROM actividades.HabilitacionGuia;

    -- 7. Asignaciones de guardaparques (depende de Guardaparque, Parque)
    DELETE FROM personal.AsignacionParque;

    -- 8. Pagos de concesión (depende de Empresa, Concesion)
    DELETE FROM concesiones.PagoConcesion;

    -- 9. Tickets (depende de Parque)
    DELETE FROM ventas.Ticket;

    -- 10. Concesiones (depende de Empresa, Parque)
    DELETE FROM concesiones.Concesion;

    -- 11. Atracciones (depende de Parque)
    DELETE FROM actividades.Atraccion;

    -- 12. Tasas de cambio (depende de Moneda)
    DELETE FROM ventas.TasaCambio;

    -- 13. Precios de entrada (depende de Parque, TipoVisitante)
    DELETE FROM parques.PrecioEntrada;

    -- 14. Guardaparques
    DELETE FROM personal.Guardaparque;

    -- 15. Guías
    DELETE FROM actividades.Guia;

    -- 16. Empresas
    DELETE FROM concesiones.Empresa;

    -- 17. Monedas
    DELETE FROM ventas.Moneda;

    -- 18. Tipos de visitante
    DELETE FROM parques.TipoVisitante;

    -- 19. Parques (tabla raíz, sin dependencias entrantes activas)
    DELETE FROM parques.Parque;

    -- Resetear contadores IDENTITY a 0 para poder re-insertar desde ID=1
    -- Reseteo de IDENTITY a 0 solo si la tabla ya tuvo datos
    -- (usa sys.identity_columns.last_value en vez de IDENT_CURRENT
    --  porque IDENT_CURRENT puede no retornar NULL en tablas recien creadas)
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('parques.Parque')) IS NOT NULL
        DBCC CHECKIDENT ('parques.Parque', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('parques.TipoVisitante')) IS NOT NULL
        DBCC CHECKIDENT ('parques.TipoVisitante', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('parques.PrecioEntrada')) IS NOT NULL
        DBCC CHECKIDENT ('parques.PrecioEntrada', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('ventas.Moneda')) IS NOT NULL
        DBCC CHECKIDENT ('ventas.Moneda', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('ventas.TasaCambio')) IS NOT NULL
        DBCC CHECKIDENT ('ventas.TasaCambio', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('ventas.Ticket')) IS NOT NULL
        DBCC CHECKIDENT ('ventas.Ticket', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('ventas.ItemTicket')) IS NOT NULL
        DBCC CHECKIDENT ('ventas.ItemTicket', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('ventas.PagoMonedaExtranjera')) IS NOT NULL
        DBCC CHECKIDENT ('ventas.PagoMonedaExtranjera', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('actividades.Guia')) IS NOT NULL
        DBCC CHECKIDENT ('actividades.Guia', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('actividades.HabilitacionGuia')) IS NOT NULL
        DBCC CHECKIDENT ('actividades.HabilitacionGuia', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('actividades.Atraccion')) IS NOT NULL
        DBCC CHECKIDENT ('actividades.Atraccion', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('actividades.TourGuia')) IS NOT NULL
        DBCC CHECKIDENT ('actividades.TourGuia', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('concesiones.Empresa')) IS NOT NULL
        DBCC CHECKIDENT ('concesiones.Empresa', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('concesiones.Concesion')) IS NOT NULL
        DBCC CHECKIDENT ('concesiones.Concesion', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('concesiones.PagoConcesion')) IS NOT NULL
        DBCC CHECKIDENT ('concesiones.PagoConcesion', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('personal.Guardaparque')) IS NOT NULL
        DBCC CHECKIDENT ('personal.Guardaparque', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('personal.AsignacionParque')) IS NOT NULL
        DBCC CHECKIDENT ('personal.AsignacionParque', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('importacion.LogImportacion')) IS NOT NULL
        DBCC CHECKIDENT ('importacion.LogImportacion', RESEED, 0);
    IF (SELECT last_value FROM sys.identity_columns WHERE object_id = OBJECT_ID('importacion.Feriado')) IS NOT NULL
        DBCC CHECKIDENT ('importacion.Feriado', RESEED, 0);

    PRINT 'Tablas vaciadas e IDENTITYs reseteados correctamente.';
END
GO
