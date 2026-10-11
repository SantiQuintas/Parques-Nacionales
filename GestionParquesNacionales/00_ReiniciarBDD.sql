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

  Archivo:      00_ReiniciarBDD.sql
  Descripcion:  Script maestro que reinicia la base de datos desde cero.
                Ejecutar en SQLCMD Mode (Query > SQLCMD Mode).
                Borra la BD existente, la recrea y ejecuta todos los scripts
                de creacion, SPs y seguridad en el orden correcto.

  Uso:          En SSMS habilitar SQLCMD Mode, abrir este script y ejecutar.
===============================================================================
*/

/*
-------------------------------------------------------------------------
  PASO 1: DROP de la base de datos existente
-------------------------------------------------------------------------
*/
USE master;
PRINT '';
PRINT '================================================================';
PRINT ' PASO 1: DROP de la base de datos existente';
PRINT '================================================================';
GO

IF DB_ID(N'ParquesNacionales') IS NOT NULL
BEGIN
    ALTER DATABASE ParquesNacionales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ParquesNacionales;
    PRINT 'Base de datos ParquesNacionales eliminada.';
END
ELSE
    PRINT 'La base de datos ParquesNacionales no existe. Se creara desde cero.';
GO

/*
-------------------------------------------------------------------------
  PASO 2: Creacion de la base de datos, esquemas y tablas
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 2: Creacion de DB, esquemas y tablas';
PRINT '================================================================';
GO
-- Ejecutar creación de DB, esquemas, tablas y restricciones
:r .\01_CreacionTablasEsquemasYBdd.sql

/*
-------------------------------------------------------------------------
  PASO 3: Seguridad - crear funciones de
          cifrado/descifrado. No ejecuta cifrado, solo deja todo listo.
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 3: Seguridad - columnas _cifrado, funciones y SPs';
PRINT '================================================================';
GO
-- Ejecutar funciones de cifrado/descifrado y columnas encriptadas
:r .\02_SPEncriptacion.sql

/*
-------------------------------------------------------------------------
  PASO 4: Stored Procedures de Insercion
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 4: SPs de Insercion';
PRINT '================================================================';
GO
-- Ejecutar stored procedures de inserción
:r .\03_SPInsercion.sql

/*
-------------------------------------------------------------------------
  PASO 5: Stored Procedures de Modificacion
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 5: SPs de Modificacion';
PRINT '================================================================';
GO
-- Ejecutar stored procedures de modificación
:r .\04_SPModificacion.sql

/*
-------------------------------------------------------------------------
  PASO 6: Stored Procedures de Borrado
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 6: SPs de Borrado';
PRINT '================================================================';
GO
-- Ejecutar stored procedures de borrado
:r .\05_SPBorrado.sql

/*
-------------------------------------------------------------------------
  PASO 7: Stored Procedures de Logica de Negocio
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 7: SPs de Logica de Negocio';
PRINT '================================================================';
GO
-- Ejecutar stored procedures de lógica de negocio
:r .\06_SPLogicaNegocio.sql

/*
-------------------------------------------------------------------------
  PASO 8: Stored Procedures de Importacion
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 8: SPs de Importacion';
PRINT '================================================================';
GO
-- Ejecutar stored procedures de importación
:r .\07_SPImportacion.sql

/*
-------------------------------------------------------------------------
  PASO 9: Stored Procedures de Reportes
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 9: SPs de Reportes';
PRINT '================================================================';
GO
-- Ejecutar stored procedures de reportes
:r .\08_SPReportes.sql

/*
-------------------------------------------------------------------------
  PASO 10: Creacion de roles y asignacion de permisos
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 10: Roles y permisos';
PRINT '================================================================';
GO
-- Ejecutar creación de roles y asignación de permisos
:r .\09_SPRoles.sql

/*
-------------------------------------------------------------------------
  PASO 11: Procedimiento de Vaciado de Tablas (sp_VaciarTablas)
-------------------------------------------------------------------------
*/
PRINT '';
PRINT '================================================================';
PRINT ' PASO 11: SP de Vaciado de Tablas';
PRINT '================================================================';
GO
-- Ejecutar script de vaciado de tablas y reset de IDENTITYs
:r .\10_SPVaciarTablas.sql

PRINT '';
PRINT '================================================================';
PRINT ' REINICIO COMPLETADO';
PRINT ' La base de datos ParquesNacionales esta lista para testing.';
PRINT '================================================================';
