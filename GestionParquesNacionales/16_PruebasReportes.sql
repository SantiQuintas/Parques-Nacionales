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

   Archivo:     16_PruebasReportes.sql
   Descripcion: Script de pruebas para los stored procedures de reportes
                definidos en 08_SPReportes.sql.
                Ejecuta los SPs de reportes contra los datos cargados por
                PoblarTablas.sql y/o ImportarDatos.sql.
===============================================================================
*/

USE ParquesNacionales;
GO

CREATE TABLE #Resultados (ok INT DEFAULT 0, fail INT DEFAULT 0);
INSERT INTO #Resultados DEFAULT VALUES;
GO

PRINT '================================================================';
PRINT ' INICIO DE TESTING - SPs de Reportes (Entrega 7)';
PRINT ' Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '================================================================';
GO
-- ================================================
-- EJECUCION DE REPORTES
-- ================================================
PRINT '';
PRINT '================================================================';
PRINT ' EJECUTANDO REPORTES (Entrega 7)';
PRINT '================================================================';
GO

-- ================================================================
-- TEST: parques.sp_ReporteVisitasPorPeriodo (XML)
-- ================================================================
-- ================================================
-- REPORTE 1: Visitas por periodo (XML)
-- ================================================
PRINT '';
PRINT '--- REPORTE 1: parques.sp_ReporteVisitasPorPeriodo (XML) ---';
BEGIN TRY
    EXEC parques.sp_ReporteVisitasPorPeriodo;
    PRINT '  [OK] Reporte 1 ejecutado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '  [ERROR] Reporte 1: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- ================================================================
-- TEST: ventas.sp_ReporteIngresosPorPeriodo
-- ================================================================
-- ================================================
-- REPORTE 2: Ingresos por periodo
-- ================================================
PRINT '';
PRINT '--- REPORTE 2: ventas.sp_ReporteIngresosPorPeriodo ---';
BEGIN TRY
    EXEC ventas.sp_ReporteIngresosPorPeriodo;
    PRINT '  [OK] Reporte 2 ejecutado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '  [ERROR] Reporte 2: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- ================================================================
-- TEST: concesiones.sp_ReporteDeudores
-- ================================================================
-- ================================================
-- REPORTE 3: Deudores de concesiones
-- ================================================
PRINT '';
PRINT '--- REPORTE 3: concesiones.sp_ReporteDeudores ---';
PRINT '>> Debe mostrar: Tienda Nahuel Huapi y Turismo Aventura Nahuel Huapi con meses adeudados';
BEGIN TRY
    EXEC concesiones.sp_ReporteDeudores;
    PRINT '  [OK] Reporte 3 ejecutado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '  [ERROR] Reporte 3: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- ================================================================
-- TEST: ventas.sp_ReporteMatrizVisitas (XML)
-- ================================================================
-- ================================================
-- REPORTE 4: Matriz Pivot de visitas (XML)
-- ================================================
PRINT '';
PRINT '--- REPORTE 4: ventas.sp_ReporteMatrizVisitas (XML) ---';
PRINT '>> Matriz: filas = parques, columnas = meses (Ene-Dic)';
BEGIN TRY
    EXEC ventas.sp_ReporteMatrizVisitas;
    PRINT '  [OK] Reporte 4 ejecutado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '  [ERROR] Reporte 4: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- ================================================================
-- TEST: parques.sp_ReporteParquesConcesiones (XML)
-- ================================================================
-- ================================================
-- REPORTE 5: Parques y concesiones (XML anidado)
-- ================================================
PRINT '';
PRINT '--- REPORTE 5: parques.sp_ReporteParquesConcesiones (XML) ---';
PRINT '>> XML anidado con parques y sus concesiones';
BEGIN TRY
    EXEC parques.sp_ReporteParquesConcesiones;
    PRINT '  [OK] Reporte 5 ejecutado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '  [ERROR] Reporte 5: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- ================================================================
-- TEST: importacion.sp_ReporteVisitasFeriados
-- ================================================================
-- ================================================
-- REPORTE 6 (extra): Visitas en feriados
-- ================================================
PRINT '';
PRINT '--- REPORTE 6: importacion.sp_ReporteVisitasFeriados ---';
PRINT '>> Tabla con feriados, visitantes e ingresos + resumen';
BEGIN TRY
    EXEC importacion.sp_ReporteVisitasFeriados;
    PRINT '  [OK] Reporte 6 ejecutado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '  [ERROR] Reporte 6: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- ================================================
-- FIN DEL TESTING
-- ================================================
PRINT '';
PRINT '================================================================';
PRINT ' RESUMEN DE PRUEBAS - Reportes';
PRINT '================================================================';
DECLARE @v_ok INT, @v_fail INT;
SELECT @v_ok = ok, @v_fail = fail FROM #Resultados;
PRINT '  Reportes exitosos: ' + CAST(@v_ok AS VARCHAR(10));
PRINT '  Reportes fallidos: ' + CAST(@v_fail AS VARCHAR(10));
PRINT '  Total: ' + CAST(@v_ok + @v_fail AS VARCHAR(10));
PRINT '================================================================';
PRINT ' Verificar que cada reporte devuelva datos coherentes.';
PRINT ' Reportes 1, 4 y 5 deben retornar XML.';
PRINT ' Reportes 2 y 3 deben retornar tablas.';
PRINT ' Reporte 6 (extra): tabla + resumen de visitas en feriados.';
PRINT '================================================================';
DROP TABLE #Resultados;
GO

PRINT '============================================';
PRINT ' 16_PruebasReportes.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
