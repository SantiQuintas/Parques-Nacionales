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

   Archivo:     13_PruebasSeguridad.sql
   Descripcion: Script de prueba del cifrado/descifrado y muestreo de roles.
                Comienza con sp_VaciarTablas para partir de un estado limpio.
===============================================================================
*/
USE ParquesNacionales;
GO
EXEC dbo.sp_VaciarTablas;
GO

PRINT '==========================================================';
PRINT ' PRUEBA DE CIFRADO/DESCIFRADO + ROLES';
PRINT '==========================================================';
PRINT '';
GO

CREATE TABLE #Resultados (ok INT DEFAULT 0, fail INT DEFAULT 0);
INSERT INTO #Resultados DEFAULT VALUES;
GO

-- ================================================================
-- TEST: Encriptación de datos sensibles (DNI)
-- ================================================================
-- ============================================================
-- 1) INSERTAR Y VERIFICAR CIFRADO AUTOMATICO
-- ============================================================
PRINT '--- [PASO 1] Insertar y verificar cifrado automatico ---';
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Juan', @p_apellido = 'Perez', @p_dni = 11111111;
EXEC actividades.sp_InsertarGuia @p_nombre = 'Maria', @p_apellido = 'Lopez', @p_dni = 22222222, @p_vigencia_autorizacion = '2026-12-31';

DECLARE @dni_gp INT = (SELECT CAST(seguridad.Descifrar(dni_cifrado) AS INT) FROM personal.Guardaparque WHERE nombre = 'Juan');
DECLARE @dni_guia INT = (SELECT CAST(seguridad.Descifrar(dni_cifrado) AS INT) FROM actividades.Guia WHERE nombre = 'Maria');

IF @dni_gp = 11111111 AND @dni_guia = 22222222
    PRINT '  [OK] Cifrado/descifrado funciona correctamente.';
ELSE
BEGIN
    PRINT '  [FALLA] Descifrado no devolvio el valor esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END
GO

-- ============================================================
-- 2) VERIFICAR UNIQUE POR SCAN
-- ============================================================
PRINT '';
PRINT '--- [PASO 2] Verificar rechazo de DNI duplicado ---';
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Otro', @p_apellido = 'Test', @p_dni = 11111111;
    PRINT '  [FALLA] Se esperaba error por DNI duplicado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT '  [OK] Error capturado: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- ================================================================
-- TEST: Control de acceso por roles
-- ================================================================
-- ============================================================
-- 3) MUESTREO DE ROLES
-- ============================================================
PRINT '';
PRINT '--- [PASO 3] Muestreo de roles ---';

IF DATABASE_PRINCIPAL_ID('usr_Admin') IS NULL CREATE USER usr_Admin WITHOUT LOGIN;
ALTER ROLE Admin ADD MEMBER usr_Admin;

IF DATABASE_PRINCIPAL_ID('usr_AdminPersonal') IS NULL CREATE USER usr_AdminPersonal WITHOUT LOGIN;
ALTER ROLE AdminPersonal ADD MEMBER usr_AdminPersonal;

IF DATABASE_PRINCIPAL_ID('usr_AdminParques') IS NULL CREATE USER usr_AdminParques WITHOUT LOGIN;
ALTER ROLE AdminParques ADD MEMBER usr_AdminParques;

IF DATABASE_PRINCIPAL_ID('usr_Consultas') IS NULL CREATE USER usr_Consultas WITHOUT LOGIN;
ALTER ROLE Consultas ADD MEMBER usr_Consultas;
GO

-- 3a) Admin puede modificar cualquier esquema
PRINT '  3a) Admin ejecuta sp_InsertarGuardaparque...';
EXECUTE AS USER = 'usr_Admin';
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque @p_nombre = 'AdminTest', @p_apellido = 'OK', @p_dni = 33333333;
    PRINT '    [OK] Admin inserto guardaparque correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '    [FALLA] Admin deberia poder insertar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
REVERT;
GO

-- 3b) AdminPersonal puede insertar guardaparque
PRINT '  3b) AdminPersonal ejecuta sp_InsertarGuardaparque...';
EXECUTE AS USER = 'usr_AdminPersonal';
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque @p_nombre = 'PersTest', @p_apellido = 'OK', @p_dni = 44444444;
    PRINT '    [OK] AdminPersonal inserto guardaparque correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '    [FALLA] AdminPersonal deberia poder insertar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
REVERT;
GO

-- 3c) AdminParques NO puede insertar guardaparque
PRINT '  3c) AdminParques intenta insertar guardaparque...';
EXECUTE AS USER = 'usr_AdminParques';
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque @p_nombre = 'ParqTest', @p_apellido = 'DENIED', @p_dni = 55555555;
    PRINT '    [FALLA] AdminParques NO deberia poder insertar guardaparque.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT '    [OK] Acceso denegado a AdminParques: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
REVERT;
GO

-- 3d) Consultas puede hacer SELECT
PRINT '  3d) Consultas ejecuta SELECT sobre personal.Guardaparque...';
EXECUTE AS USER = 'usr_Consultas';
BEGIN TRY
    DECLARE @count INT;
    SELECT @count = COUNT(*) FROM personal.Guardaparque;
    PRINT '    [OK] Consultas leyo ' + CAST(@count AS VARCHAR) + ' registros.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT '    [FALLA] Consultas deberia poder leer: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
REVERT;
GO

-- 3e) Consultas NO puede hacer INSERT
PRINT '  3e) Consultas intenta INSERT directo...';
EXECUTE AS USER = 'usr_Consultas';
BEGIN TRY
    INSERT INTO personal.Guardaparque (nombre, apellido, dni_cifrado) VALUES ('X', 'Y', NULL);
    PRINT '    [FALLA] Consultas NO deberia poder insertar.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT '    [OK] Acceso denegado a Consultas (INSERT): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
REVERT;
GO

-- ============================================================
-- 4) LIMPIAR USUARIOS DE PRUEBA
-- ============================================================
PRINT '';
PRINT '--- [PASO 4] Limpiar usuarios de prueba ---';
DROP USER IF EXISTS usr_Admin;
DROP USER IF EXISTS usr_AdminPersonal;
DROP USER IF EXISTS usr_AdminParques;
DROP USER IF EXISTS usr_Consultas;
PRINT '  [OK] Usuarios de prueba eliminados.';
GO

-- ============================================================
-- 5) RESUMEN FINAL
-- ============================================================
PRINT '';

PRINT '==========================================================';
PRINT ' RESUMEN DE PRUEBAS';
PRINT '==========================================================';

DECLARE @v_ok_final INT, @v_fail_final INT;
SELECT @v_ok_final = ok, @v_fail_final = fail FROM #Resultados;
PRINT '  Pruebas exitosas: ' + CAST(@v_ok_final AS VARCHAR(10));
PRINT '  Pruebas fallidas: ' + CAST(@v_fail_final AS VARCHAR(10));
PRINT '';
PRINT '  Cifrado/Descifrado:';
PRINT '    - ABM SPs:           cifran automaticamente el DNI al insertar';
PRINT '    - Descifrar():       funcion que permite leer el DNI original';
PRINT '    - UNIQUE:            validado por scan de Descifrar() en SPs';
PRINT '';
PRINT '  Roles (muestreo):';
PRINT '    - Admin:             CONTROL total sobre todos los esquemas';
PRINT '    - AdminPersonal:     SELECT+EXECUTE sobre personal';
PRINT '    - AdminParques:      solo parques (sin acceso a personal)';
PRINT '    - Consultas:         solo SELECT (INSERT denegado)';
PRINT '==========================================================';

DROP TABLE #Resultados;
GO

PRINT '============================================';
PRINT ' 13_PruebasSeguridad.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
