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

  Archivo:     09_SPRoles.sql
   Descripcion: Script de creacion de roles y asignacion de permisos para el
                sistema de gestion de Parques Nacionales. Debe ejecutarse al
                FINAL del proceso, despues de que todos los SPs existan, para
                evitar errores de GRANT sobre objetos aun no creados.
--                Ejecutar al FINAL del proceso, después de todos los SPs.
===============================================================================
*/
USE ParquesNacionales;
GO

-- ============================================================
-- Creacion de roles (8 roles)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Admin' AND type = 'R')
    CREATE ROLE Admin;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'ImportadorDatos' AND type = 'R')
    CREATE ROLE ImportadorDatos;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Consultas' AND type = 'R')
    CREATE ROLE Consultas;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminParques' AND type = 'R')
    CREATE ROLE AdminParques;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminPersonal' AND type = 'R')
    CREATE ROLE AdminPersonal;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminConcesiones' AND type = 'R')
    CREATE ROLE AdminConcesiones;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminActividades' AND type = 'R')
    CREATE ROLE AdminActividades;
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'AdminVentas' AND type = 'R')
    CREATE ROLE AdminVentas;
GO

-- ============================================================
-- Admin: acceso total a todos los esquemas. Puede crear, modificar y eliminar cualquier objeto.
-- ============================================================
-- Control total: crea, modifica y elimina objetos y datos
GRANT CONTROL ON SCHEMA::parques TO Admin;
GRANT CONTROL ON SCHEMA::personal TO Admin;
GRANT CONTROL ON SCHEMA::concesiones TO Admin;
GRANT CONTROL ON SCHEMA::actividades TO Admin;
GRANT CONTROL ON SCHEMA::ventas TO Admin;
GRANT CONTROL ON SCHEMA::importacion TO Admin;
GRANT CONTROL ON SCHEMA::seguridad TO Admin;
GO

-- ============================================================
-- Consultas: solo lectura en esquemas operativos. No puede modificar datos ni ejecutar SPs.
-- ============================================================
-- Solo lectura: puede consultar pero no modificar
GRANT SELECT ON SCHEMA::parques TO Consultas;
GRANT SELECT ON SCHEMA::personal TO Consultas;
GRANT SELECT ON SCHEMA::concesiones TO Consultas;
GRANT SELECT ON SCHEMA::actividades TO Consultas;
GRANT SELECT ON SCHEMA::ventas TO Consultas;
GRANT SELECT ON SCHEMA::importacion TO Consultas;
GO

-- ============================================================
-- ImportadorDatos: puede insertar datos e importar desde fuentes externas. No puede modificar ni eliminar.
-- ============================================================
-- Puede insertar parques nuevos desde fuentes externas
GRANT EXECUTE ON parques.sp_InsertarParque TO ImportadorDatos;
GRANT EXECUTE ON parques.sp_InsertarTipoVisitante TO ImportadorDatos;
GRANT EXECUTE ON parques.sp_InsertarPrecioEntrada TO ImportadorDatos;
GRANT EXECUTE ON ventas.sp_InsertarMoneda TO ImportadorDatos;
GRANT EXECUTE ON ventas.sp_InsertarTasaCambio TO ImportadorDatos;
GRANT EXECUTE ON ventas.sp_InsertarTicket TO ImportadorDatos;
GRANT EXECUTE ON ventas.sp_InsertarItemTicket TO ImportadorDatos;
GRANT EXECUTE ON ventas.sp_InsertarPagoMonedaExtranjera TO ImportadorDatos;
GRANT EXECUTE ON actividades.sp_InsertarGuia TO ImportadorDatos;
GRANT EXECUTE ON actividades.sp_InsertarHabilitacionGuia TO ImportadorDatos;
GRANT EXECUTE ON actividades.sp_InsertarAtraccion TO ImportadorDatos;
GRANT EXECUTE ON actividades.sp_InsertarTourGuia TO ImportadorDatos;
GRANT EXECUTE ON concesiones.sp_InsertarEmpresa TO ImportadorDatos;
GRANT EXECUTE ON concesiones.sp_InsertarConcesion TO ImportadorDatos;
GRANT EXECUTE ON concesiones.sp_InsertarPagoConcesion TO ImportadorDatos;
GRANT EXECUTE ON personal.sp_InsertarGuardaparque TO ImportadorDatos;
GRANT EXECUTE ON personal.sp_InsertarAsignacionParque TO ImportadorDatos;
-- Lectura de tablas de importación (log, feriados)
GRANT SELECT ON SCHEMA::importacion TO ImportadorDatos;
-- Ejecutar SPs de importación (Excel, API)
GRANT EXECUTE ON SCHEMA::importacion TO ImportadorDatos;
GO

-- ============================================================
-- AdminParques: lectura y ejecucion en esquema parques. CRUD de parques, tipos de visitante y precios de entrada.
-- ============================================================
-- Lectura para gestión de parques
GRANT SELECT ON SCHEMA::parques TO AdminParques;
-- Ejecutar ABM de parques, tipos visitante, precios
GRANT EXECUTE ON SCHEMA::parques TO AdminParques;
GO

-- ============================================================
-- AdminPersonal: lectura y ejecucion en esquema personal. CRUD de guardaparques y asignaciones a parques.
-- ============================================================
-- Lectura para gestión de personal
GRANT SELECT ON SCHEMA::personal TO AdminPersonal;
-- Ejecutar ABM de guardaparques y asignaciones
GRANT EXECUTE ON SCHEMA::personal TO AdminPersonal;
GO

-- ============================================================
-- AdminConcesiones: lectura y ejecucion en esquema concesiones. CRUD de empresas, contratos de concesion y pagos de canon.
-- ============================================================
-- Lectura para gestión de concesiones
GRANT SELECT ON SCHEMA::concesiones TO AdminConcesiones;
-- Ejecutar ABM de empresas, concesiones y pagos
GRANT EXECUTE ON SCHEMA::concesiones TO AdminConcesiones;
GO

-- ============================================================
-- AdminActividades: lectura y ejecucion en esquema actividades. CRUD de guias, habilitaciones, atracciones y tours.
-- ============================================================
-- Lectura para gestión de actividades
GRANT SELECT ON SCHEMA::actividades TO AdminActividades;
-- Ejecutar ABM de guías, atracciones y tours
GRANT EXECUTE ON SCHEMA::actividades TO AdminActividades;
GO

-- ============================================================
-- AdminVentas: lectura y ejecucion en esquema ventas. CRUD de tickets, items de ticket, monedas, tasas de cambio y pagos.
-- ============================================================
-- Lectura para gestión de ventas
GRANT SELECT ON SCHEMA::ventas TO AdminVentas;
-- Ejecutar ABM de tickets, items y pagos
GRANT EXECUTE ON SCHEMA::ventas TO AdminVentas;
GO

PRINT '============================================';
PRINT ' 09_SPRoles.sql CARGADO CORRECTAMENTE';
PRINT ' Roles creados: Admin, ImportadorDatos,';
PRINT ' Consultas, AdminParques, AdminPersonal,';
PRINT ' AdminConcesiones, AdminActividades,';
PRINT ' AdminVentas';
PRINT '============================================';
GO
