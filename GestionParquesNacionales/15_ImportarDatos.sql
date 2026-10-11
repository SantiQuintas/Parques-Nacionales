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

   Archivo:     15_ImportarDatos.sql
   Descripcion: Script de ejecucion de los 3 procesos de importacion.

    REQUISITO:  Microsoft Access Database Engine 2016 (64-bit) instalado.
                Descargar accessdatabaseengine_X64.exe desde:
                https://www.microsoft.com/en-us/download/details.aspx?id=54920
                Si no esta instalado, la importacion de parques fallara
                con un mensaje de error.

   Flujo:
        1. Copia el Excel al DATA directory de SQL Server via xp_cmdshell
        2. Lee el Excel desde DATA directory via OPENROWSET
        3. Procesa cada fila e inserta/actualiza en parques.Parque
        4. Descarga tasas.json de dolarapi.com via xp_cmdshell
        5. Descarga feriados.json de date.nager.at via xp_cmdshell
        6. Ejecuta los SPs de importacion de tasas y feriados
===============================================================================
*/

-- ================================================================
-- BATCH 1: CONFIGURACION + PREPARACION DE ARCHIVOS
-- ================================================================
USE ParquesNacionales;
GO

PRINT '================================================================';
PRINT ' INICIO DE IMPORTACION DE DATOS';
PRINT ' Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '================================================================';
PRINT '';

-- ================================================================
-- CONFIGURACION: RUTAS DE ARCHIVOS
-- ================================================================

-- RUTA AL EXCEL DE PARQUES (SIB - Sistema de Informacion de Biodiversidad)
DECLARE @ruta_excel NVARCHAR(500)
    = N'C:\Users\lufys\OneDrive\Desktop\1er cuatri 2026\BDD2\TP 1\TP ParquesNacionales\ArchivosImportacion\Áreas protegidas de Argentina - Sistema de Información de Biodiversidad.xlsx';
PRINT 'Ruta Excel: ' + @ruta_excel;
PRINT '';

-- ================================================================
-- DETECTAR DIRECTORIO ACCESIBLE POR SQL SERVER
-- ================================================================
PRINT '--- Detectando DATA directory de SQL Server ---';

DECLARE @data_dir NVARCHAR(500);
SELECT @data_dir = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(500));

IF @data_dir IS NULL
    SET @data_dir = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\';

IF RIGHT(@data_dir, 1) <> '\'
    SET @data_dir = @data_dir + '\';

PRINT 'Directorio DESTINO: ' + @data_dir;
PRINT '';

-- ================================================================
-- TABLA DE CONFIGURACION (persiste entre batches via tempdb)
-- ================================================================
IF OBJECT_ID('tempdb..#ConfigImport') IS NOT NULL DROP TABLE #ConfigImport;
CREATE TABLE #ConfigImport (clave VARCHAR(50) PRIMARY KEY, valor NVARCHAR(500));

INSERT INTO #ConfigImport VALUES ('data_dir', @data_dir);
INSERT INTO #ConfigImport VALUES ('ruta_excel_parques',   @ruta_excel);
INSERT INTO #ConfigImport VALUES ('ruta_tasas_final',     @data_dir + N'tasas.json');
INSERT INTO #ConfigImport VALUES ('ruta_feriados_final',  @data_dir + N'feriados.json');

PRINT 'Configuracion guardada en #ConfigImport.';
PRINT '';

-- ================================================================
-- HABILITAR xp_cmdshell (necesario solo para descargar JSON)
-- ================================================================
PRINT '--- Habilitando xp_cmdshell ---';
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE;
PRINT 'xp_cmdshell habilitado.';
PRINT '';

-- ================================================================
-- 0a) Descargar tasas de cambio (dolarapi.com)
-- ================================================================
DECLARE @destino_tasas NVARCHAR(500) = @data_dir + N'tasas.json';
PRINT '--- Descargando tasas a: ' + @destino_tasas + ' ---';
DECLARE @cmd NVARCHAR(2000);
SET @cmd = 'powershell -Command "Invoke-WebRequest -Uri ''https://dolarapi.com/v1/cotizaciones'' -OutFile ''' + @destino_tasas + ''' -UseBasicParsing"';
EXEC xp_cmdshell @cmd;
SET @cmd = 'icacls "' + @destino_tasas + '" /grant Everyone:R /Q';
EXEC xp_cmdshell @cmd;
PRINT '';

-- ================================================================
-- 0b) Descargar feriados (Nager.Date)
-- ================================================================
DECLARE @destino_feriados NVARCHAR(500) = @data_dir + N'feriados.json';
PRINT '--- Descargando feriados a: ' + @destino_feriados + ' ---';
SET @cmd = 'powershell -Command "Invoke-WebRequest -Uri ''https://date.nager.at/api/v3/PublicHolidays/2026/AR'' -OutFile ''' + @destino_feriados + ''' -UseBasicParsing"';
EXEC xp_cmdshell @cmd;
SET @cmd = 'icacls "' + @destino_feriados + '" /grant Everyone:R /Q';
EXEC xp_cmdshell @cmd;
PRINT '';

-- ================================================================
-- 0c) Copiar Excel de parques al DATA directory
--     SQL Server no puede leer rutas de perfil de usuario (Desktop),
--     por lo que copiamos el archivo al DATA directory accesible.
-- ================================================================
PRINT '--- Copiando Excel de parques al DATA directory ---';
SET @cmd = 'copy "' + @ruta_excel + '" "' + @data_dir + N'parques.xlsx" /Y';
EXEC xp_cmdshell @cmd;
SET @cmd = 'icacls "' + @data_dir + N'parques.xlsx" /grant Everyone:R /Q';
EXEC xp_cmdshell @cmd;

-- Actualizar ruta en config para que apunte al archivo copiado
UPDATE #ConfigImport SET valor = @data_dir + N'parques.xlsx'
WHERE clave = 'ruta_excel_parques';

PRINT 'Excel copiado a: ' + @data_dir + 'parques.xlsx';

-- Verificar que el archivo existe
SET @cmd = 'if exist "' + @data_dir + N'parques.xlsx" (echo ARCHIVO OK) else (echo ERROR: NO EXISTE)';
EXEC xp_cmdshell @cmd;
PRINT '';

-- ================================================================
-- 0d) Limpiar datos de ejecuciones anteriores
-- ================================================================
PRINT '--- Limpiando datos anteriores ---';
DELETE FROM importacion.LogImportacion;
PRINT 'Log de importacion limpiado.';
PRINT '';

GO

PRINT 'Las monedas deben ser insertadas previamente por PoblarTablas.sql.';
GO

-- Importa parques desde el archivo Excel del SIB usando OPENROWSET.
-- Cada fila del Excel se procesa e inserta/actualiza en parques.Parque.
-- ================================================================
-- BATCH 2: IMPORTACION 1 - PARQUES DESDE EXCEL (via OPENROWSET)
-- ================================================================
PRINT '';
PRINT '--- IMPORTACION 1: Parques desde Excel ---';

DECLARE @ruta_excel_final NVARCHAR(500);
SELECT @ruta_excel_final = valor FROM #ConfigImport WHERE clave = 'ruta_excel_parques';

BEGIN TRY
    EXEC importacion.sp_ImportarParquesDesdeExcel @p_ruta_excel = @ruta_excel_final;
    PRINT 'RESULTADO: Importacion de parques finalizada.';
END TRY
BEGIN CATCH
    PRINT 'ERROR en importacion de parques: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Lee el archivo JSON descargado de dolarapi.com e inserta las tasas
-- de cambio vigentes en ventas.TasaCambio.
-- ================================================================
-- BATCH 3: IMPORTACION 2 - TASAS DE CAMBIO
-- ================================================================
PRINT '';
PRINT '--- IMPORTACION 2: Tasas de cambio ---';

DECLARE @ruta_tasas NVARCHAR(500);
SELECT @ruta_tasas = valor FROM #ConfigImport WHERE clave = 'ruta_tasas_final';
PRINT 'JSON path: ' + @ruta_tasas;

BEGIN TRY
    EXEC importacion.sp_ImportarTasaCambio @p_ruta_json = @ruta_tasas;
    PRINT 'RESULTADO: Tasas de cambio importadas.';
END TRY
BEGIN CATCH
    PRINT 'ERROR en importacion de tasas: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Lee el archivo JSON descargado de date.nager.at e inserta los
-- feriados argentinos del año corriente en importacion.Feriado.
-- ================================================================
-- BATCH 4: IMPORTACION 3 - FERIADOS
-- ================================================================
PRINT '';
PRINT '--- IMPORTACION 3: Feriados argentinos ---';

DECLARE @ruta_feriados NVARCHAR(500);
SELECT @ruta_feriados = valor FROM #ConfigImport WHERE clave = 'ruta_feriados_final';
PRINT 'JSON path: ' + @ruta_feriados;

BEGIN TRY
    EXEC importacion.sp_ImportarFeriados @p_ruta_json = @ruta_feriados;
    PRINT 'RESULTADO: Feriados importados.';
END TRY
BEGIN CATCH
    PRINT 'ERROR en importacion de feriados: ' + ERROR_MESSAGE();
END CATCH;
GO

-- ================================================================
-- BATCH 5: DESHABILITAR xp_cmdshell + MOSTRAR RESULTADOS
-- ================================================================
PRINT '';
PRINT '--- Deshabilitando xp_cmdshell ---';
EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 0; RECONFIGURE;
PRINT 'xp_cmdshell deshabilitado.';
PRINT '';

-- PARQUES
PRINT '--- PARQUES EN LA BASE ---';
SELECT id_parque, nombre, ubicacion, superficie, tipo, latitud, longitud
FROM parques.Parque
ORDER BY id_parque;
GO

-- TASAS DE CAMBIO
PRINT '';
PRINT '--- TASAS DE CAMBIO (solo la mas reciente por moneda) ---';
SELECT m.codigo_iso, m.nombre AS moneda, tc.fecha_vigencia, tc.tasa_a_peso
FROM ventas.Moneda m
INNER JOIN ventas.TasaCambio tc ON tc.id_moneda = m.id_moneda
WHERE tc.id_tasa = (
    SELECT TOP 1 tc2.id_tasa
    FROM ventas.TasaCambio tc2
    WHERE tc2.id_moneda = m.id_moneda
    ORDER BY tc2.fecha_vigencia DESC
)
ORDER BY m.codigo_iso;
GO

-- FERIADOS
PRINT '';
PRINT '--- FERIADOS ARGENTINOS 2026 ---';
SELECT id_feriado, fecha, nombre, tipo
FROM importacion.Feriado
ORDER BY fecha;
GO

-- LOG DE ERRORES
PRINT '';
PRINT '--- LOG DE ERRORES ---';
IF EXISTS (SELECT 1 FROM importacion.LogImportacion)
    SELECT id_log, proceso, fecha, fila_origen, mensaje_error
    FROM importacion.LogImportacion
    ORDER BY id_log;
ELSE
    PRINT 'No se registraron errores. Todas las importaciones fueron exitosas.';
GO

-- RESUMEN FINAL
PRINT '';
PRINT '================================================================';
PRINT ' RESUMEN FINAL';
PRINT '================================================================';
DECLARE @v_parques INT, @v_tasas INT, @v_feriados INT, @v_errores INT;
SELECT @v_parques  = COUNT(*) FROM parques.Parque;
SELECT @v_tasas    = COUNT(*) FROM ventas.TasaCambio;
SELECT @v_feriados = COUNT(*) FROM importacion.Feriado;
SELECT @v_errores  = COUNT(*) FROM importacion.LogImportacion;
PRINT '  Parques en base:       ' + CAST(@v_parques AS VARCHAR(10));
PRINT '  Tasas de cambio:       ' + CAST(@v_tasas AS VARCHAR(10));
PRINT '  Feriados importados:   ' + CAST(@v_feriados AS VARCHAR(10));
PRINT '  Errores registrados:   ' + CAST(@v_errores AS VARCHAR(10));
PRINT '';
PRINT 'Para ejecutar los reportes, corra ahora PruebasReportes.sql';
PRINT '================================================================';
GO

PRINT '============================================';
PRINT ' 15_ImportarDatos.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
