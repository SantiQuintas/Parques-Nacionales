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

  Archivo:     02_SPEncriptacion.sql
  Descripcion: Script que contiene las definiciones de los procedimientos
               de cifrado/descifrado de datos sensibles en el sistema de
               gestion de Parques Nacionales. Solo encripta DNI en las tablas
               Guardaparque y Guia. La columna dni_cifrado almacena el DNI encriptado.                 
===============================================================================
*/
USE ParquesNacionales;
GO

-- Crear esquema de seguridad si no existe
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'seguridad')
    EXEC ('CREATE SCHEMA seguridad');
GO

/* ============================================================
   seguridad.Cifrar
   Encripta un valor usando EncryptByPassPhrase con la clave
   definida. Se utiliza para proteger datos sensibles (DNI)
   en las tablas Guardaparque y Guia.

   Parametros:
     @valor - Valor a encriptar (SQL_VARIANT)
   Retorna: VARBINARY(8000) con el dato encriptado.
   ============================================================ */
CREATE OR ALTER FUNCTION seguridad.Cifrar(@valor SQL_VARIANT)
RETURNS VARBINARY(8000)
AS
BEGIN
    DECLARE @ClaveUsuario NVARCHAR(128) = 'Prueba123';
    RETURN EncryptByPassPhrase(@ClaveUsuario,
        CAST(@valor AS NVARCHAR(MAX)), 1, CONVERT(VARBINARY(128), 0));
END
GO

-- Funciones de encriptación/desencriptación basadas en passphrase
/* ============================================================
   seguridad.Descifrar
   Desencripta un valor previamente encriptado con seguridad.Cifrar.
   Se utiliza para recuperar datos sensibles (DNI) cuando es
   necesario validar unicidad o mostrar información.

   Parametros:
     @valor_cifrado - VARBINARY(8000) encriptado
   Retorna: NVARCHAR(MAX) con el valor original en texto plano.
   ============================================================ */
CREATE OR ALTER FUNCTION seguridad.Descifrar(@valor_cifrado VARBINARY(8000))
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @ClaveUsuario NVARCHAR(128) = 'Prueba123';
    RETURN CAST(
        DecryptByPassPhrase(@ClaveUsuario,
            @valor_cifrado, 1, CONVERT(VARBINARY(128), 0))
        AS NVARCHAR(MAX));
END
GO

PRINT '============================================';
PRINT ' 02_SPEncriptacion.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
