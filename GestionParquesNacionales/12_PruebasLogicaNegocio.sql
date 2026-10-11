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

  Archivo:     12_PruebasLogicaNegocio.sql
  Descripcion:  Script de pruebas para los Stored Procedures de lógica de negocio
                definidos en 06_SPLogicaNegocio.sql.
                Cubre casos exitosos y casos de validación fallida
                para cada SP. Cada bloque es autocontenido e inserta los datos
                necesarios para su prueba, y además comienza vaciando las
                tablas para evitar conflictos con datos anteriores y realizar
                pruebas de forma más simple
===============================================================================
*/

USE ParquesNacionales;
GO

EXEC dbo.sp_VaciarTablas;
GO

CREATE TABLE #Resultados (ok INT DEFAULT 0, fail INT DEFAULT 0);
INSERT INTO #Resultados DEFAULT VALUES;
GO

PRINT '================================================================';
PRINT ' INICIO DE TESTING - SPs de Lógica de Negocio';
PRINT ' Fecha: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '================================================================';
GO


/* ================================================================
   SETUP GENERAL: datos base compartidos entre varios tests
   ================================================================
   Se insertan: parques, tipos visitante, precios, guias,
   atracciones, moneda, empresa. Cada test luego usa estos datos.
   ================================================================ */

PRINT '';
PRINT '--- SETUP GENERAL: insertando datos base ---';
GO

-- 3 parques base: Nahuel Huapi, Iguazú, Talampaya
EXEC parques.sp_InsertarParque @p_nombre = 'Nahuel Huapi', @p_ubicacion = 'Neuquen / Rio Negro', @p_superficie = 717261.00, @p_tipo = 'Parque Nacional',  @p_latitud = -41.000000, @p_longitud = -71.500000;
EXEC parques.sp_InsertarParque @p_nombre = 'Iguazu',       @p_ubicacion = 'Misiones',            @p_superficie = 67720.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -25.600000, @p_longitud = -54.300000;
EXEC parques.sp_InsertarParque @p_nombre = 'Talampaya',    @p_ubicacion = 'La Rioja',            @p_superficie = 215000.00, @p_tipo = 'Parque Nacional',  @p_latitud = -29.800000, @p_longitud = -67.800000;
GO

-- 2 categorías: Residente y Extranjero
EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Residente';
EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Extranjero';
GO

-- Precios para parques 1 y 2, ambos tipos
EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = 1, @p_id_tipo = 1, @p_precio = 2500.00, @p_vigencia_desde = '2025-01-01';
EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = 1, @p_id_tipo = 2, @p_precio = 8000.00, @p_vigencia_desde = '2025-01-01';
EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = 2, @p_id_tipo = 1, @p_precio = 3000.00, @p_vigencia_desde = '2025-01-01';
EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = 2, @p_id_tipo = 2, @p_precio = 10000.00, @p_vigencia_desde = '2025-01-01';
GO

-- 2 guías: uno vigente, uno con autorización vencida
DECLARE @vig_futura DATE = DATEADD(YEAR, 2, CAST(GETDATE() AS DATE));
DECLARE @vig_pasada DATE = DATEADD(YEAR, -2, CAST(GETDATE() AS DATE));
EXEC actividades.sp_InsertarGuia @p_dni = 12345678, @p_nombre = 'Carlos',  @p_apellido = 'Perez', @p_vigencia_autorizacion = @vig_futura;
EXEC actividades.sp_InsertarGuia @p_dni = 23456789, @p_nombre = 'Maria',   @p_apellido = 'Lopez', @p_vigencia_autorizacion = @vig_pasada;
GO

DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @fecha_vencida DATE = DATEADD(YEAR, -2, @fecha_hoy);
DECLARE @fecha_vigente DATE = DATEADD(YEAR, 2, @fecha_hoy);

-- Guia 1 habilitado (vigente)
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 1, @p_descripcion = 'Habilitacion General', @p_fecha_vencimiento = @fecha_vigente;
-- Guia 2 habilitacion vencida
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 2, @p_descripcion = 'Habilitacion General', @p_fecha_vencimiento = @fecha_vencida;
GO

-- 1 atraccion Tour Guiado (para test de AsignarGuia)
EXEC actividades.sp_InsertarAtraccion @p_id_parque = 1, @p_nombre = 'Tour Isla Victoria', @p_tipo = 'Tour Guiado', @p_costo = 3500.00, @p_duracion = 240, @p_horario_inicio = '08:00', @p_cupo_maximo = 15;
GO

-- 1 atraccion Gratuita (para test de VentaEntradas con atraccion)
EXEC actividades.sp_InsertarAtraccion @p_id_parque = 1, @p_nombre = 'Sendero Arrayanes', @p_tipo = 'Gratuita', @p_costo = 0.00, @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 100;
GO

-- 1 empresa para tests de concesiones
EXEC concesiones.sp_InsertarEmpresa @p_cuit = '30123456781', @p_contacto = 'contacto@empresa.com', @p_razon_social = 'Empresa Turismo SA';
GO

-- 1 moneda (para test de moneda extranjera en VentaEntradas)
EXEC ventas.sp_InsertarMoneda @p_codigo_iso = 'USD', @p_nombre = 'Dolar Estadounidense', @p_simbolo = 'USD';
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 1, @p_fecha_vigencia = @fecha_hoy, @p_tasa_a_peso = 1200.00;
GO

PRINT '[OK] Setup general completado.';
GO

-- ================================================================
-- TEST: ventas.sp_VentaEntradas - Casos exitosos
-- ================================================================

/* ================================================================
   BLOQUE 1: ventas.sp_VentaEntradas
   ================================================================
   Reglas: valida parque, fecha acceso, precio vigente,
   atraccion pertenece al parque, comprobante unico,
   forma de pago, moneda extranjera con tasa vigente.
   ================================================================ */
PRINT '';
PRINT '--- BLOQUE 1: ventas.sp_VentaEntradas ---';
GO

DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);

-- TEST 1.1 [OK] Venta normal sin atraccion
-- Resultado esperado: se inserta ticket con 1 item.
CREATE TABLE #OutputTk (id INT);
BEGIN TRY
    INSERT INTO #OutputTk
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 1,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 1001,
        @p_forma_pago = 'Efectivo',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 2;
    DECLARE @v_tk_id INT = (SELECT TOP 1 id FROM #OutputTk);
    PRINT 'TEST 1.1 [OK] Venta normal. Ticket ID: ' + ISNULL(CAST(@v_tk_id AS VARCHAR), 'ERROR');
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.1 [ERROR] Venta normal fallo inesperadamente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
DELETE FROM #OutputTk;
GO

-- TEST 1.2 [OK] Venta con atraccion
-- Resultado esperado: ticket con 2 items (entrada + atraccion).
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @v_tk_id INT;
BEGIN TRY
    INSERT INTO #OutputTk
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 1,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 1002,
        @p_forma_pago = 'Tarjeta de Credito',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 1,
        @p_id_atraccion = 2;
    SET @v_tk_id = (SELECT TOP 1 id FROM #OutputTk);
    PRINT 'TEST 1.2 [OK] Venta con atraccion. Ticket ID: ' + ISNULL(CAST(@v_tk_id AS VARCHAR), 'ERROR');
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.2 [ERROR] Venta con atraccion fallo inesperadamente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
DELETE FROM #OutputTk;
GO

-- TEST 1.3 [OK] Venta en moneda extranjera
-- Resultado esperado: ticket + pago moneda extranjera.
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @v_tk_id INT;
BEGIN TRY
    INSERT INTO #OutputTk
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 1,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 2,
        @p_numero_comprobante = 2001,
        @p_forma_pago = 'Moneda Extranjera',
        @p_id_tipo_visitante = 2,
        @p_cantidad = 2,
        @p_id_moneda = 1,
        @p_monto_extranjero = 15.00;
    SET @v_tk_id = (SELECT TOP 1 id FROM #OutputTk);
    PRINT 'TEST 1.3 [OK] Venta moneda extranjera. Ticket ID: ' + ISNULL(CAST(@v_tk_id AS VARCHAR), 'ERROR');
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.3 [ERROR] Venta moneda extranjera fallo inesperadamente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
DROP TABLE #OutputTk;
GO

-- TEST 1.4 [ERROR] Parque inexistente
-- Resultado esperado: se rechaza porque el parque no existe.
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
BEGIN TRY
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 9999,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 9001,
        @p_forma_pago = 'Efectivo',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 1;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.4 [ERROR] (esperado) Parque inexistente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 1.5 [ERROR] Fecha acceso en pasado
-- Resultado esperado: se rechaza porque la fecha de acceso es en el pasado.
BEGIN TRY
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 1,
        @p_fecha_acceso = '2020-01-01',
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 9002,
        @p_forma_pago = 'Efectivo',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 1;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.5 [ERROR] (esperado) Fecha acceso en pasado: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 1.6 [ERROR] Tipo visitante sin precio vigente
-- Resultado esperado: se rechaza porque no hay precio vigente para el tipo.
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
BEGIN TRY
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 3,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 9003,
        @p_forma_pago = 'Efectivo',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 1;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.6 [ERROR] (esperado) Sin precio vigente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 1.7 [ERROR] Atraccion no pertenece al parque
-- Resultado esperado: se rechaza porque la atraccion no pertenece al parque.
-- Atraccion 1 (Tour Isla Victoria) esta en parque 1, no en parque 2
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
BEGIN TRY
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 2,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 9004,
        @p_forma_pago = 'Efectivo',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 1,
        @p_id_atraccion = 1;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.7 [ERROR] (esperado) Atraccion no pertenece al parque: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 1.8 [ERROR] Comprobante duplicado (mismo punto de venta + numero)
-- Resultado esperado: se rechaza por comprobante duplicado.
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
BEGIN TRY
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 1,
        @p_fecha_acceso = @fecha_hoy,
        @p_punto_de_venta = 1,
        @p_numero_comprobante = 1001,
        @p_forma_pago = 'Efectivo',
        @p_id_tipo_visitante = 1,
        @p_cantidad = 1;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 1.8 [ERROR] (esperado) Comprobante duplicado: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[OK] BLOQUE 1 - sp_VentaEntradas completado.';
GO


-- ================================================================
-- TEST: actividades.sp_RegistrarActividad - Casos exitosos
-- ================================================================

/* ================================================================
   BLOQUE 2: actividades.sp_RegistrarActividad
   ================================================================
   Reglas: valida nombre unico + rango horario no solapado
   en el mismo parque.
   ================================================================ */
PRINT '';
PRINT '--- BLOQUE 2: actividades.sp_RegistrarActividad ---';
GO

-- TEST 2.1 [OK] Registrar actividad normal
-- Resultado esperado: se registra la actividad correctamente.
BEGIN TRY
    EXEC actividades.sp_RegistrarActividad
        @p_id_parque = 1,
        @p_nombre = 'Navegacion Lago Nahuel',
        @p_tipo = 'Paga',
        @p_costo = 5500.00,
        @p_duracion = 120,
        @p_horario_inicio = '09:00',
        @p_cupo_maximo = 40;
    PRINT 'TEST 2.1 [OK] Actividad registrada correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 2.1 [ERROR] (inesperado) No se pudo registrar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 2.2 [OK] Actividad mismo nombre, parque DISTINTO (deberia funcionar)
-- Resultado esperado: se registra porque el parque es diferente.
BEGIN TRY
    EXEC actividades.sp_RegistrarActividad
        @p_id_parque = 2,
        @p_nombre = 'Navegacion Lago Nahuel',
        @p_tipo = 'Paga',
        @p_costo = 6000.00,
        @p_duracion = 90,
        @p_horario_inicio = '10:00',
        @p_cupo_maximo = 30;
    PRINT 'TEST 2.2 [OK] Mismo nombre en distinto parque - permitido.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 2.2 [ERROR] (inesperado) No se pudo registrar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 2.3 [OK] Actividad mismo nombre, mismo parque, horario NO solapado (deberia funcionar)
-- Resultado esperado: se registra la actividad sin conflictos.
BEGIN TRY
    EXEC actividades.sp_RegistrarActividad
        @p_id_parque = 1,
        @p_nombre = 'Navegacion Lago Nahuel',
        @p_tipo = 'Paga',
        @p_costo = 5500.00,
        @p_duracion = 120,
        @p_horario_inicio = '14:00',
        @p_cupo_maximo = 40;
    PRINT 'TEST 2.3 [OK] Mismo nombre, horario no solapado - permitido.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 2.3 [ERROR] (inesperado) No se pudo registrar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 2.4 [ERROR] Actividad mismo nombre, mismo parque, horario SOLAPADO
-- Resultado esperado: se rechaza por solapamiento de horario.
BEGIN TRY
    EXEC actividades.sp_RegistrarActividad
        @p_id_parque = 1,
        @p_nombre = 'Navegacion Lago Nahuel',
        @p_tipo = 'Paga',
        @p_costo = 5000.00,
        @p_duracion = 60,
        @p_horario_inicio = '09:30',
        @p_cupo_maximo = 30;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 2.4 [ERROR] (esperado) Actividad solapada: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 2.5 [ERROR] Tipo invalido (se delega a sp_InsertarAtraccion)
-- Resultado esperado: se rechaza por tipo de actividad invalido.
BEGIN TRY
    EXEC actividades.sp_RegistrarActividad
        @p_id_parque = 1,
        @p_nombre = 'Actividad Invalida',
        @p_tipo = 'Premium',
        @p_costo = 500.00,
        @p_duracion = 60,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo = 10;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 2.5 [ERROR] (esperado) Tipo invalido: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[OK] BLOQUE 2 - sp_RegistrarActividad completado.';
GO


-- ================================================================
-- TEST: actividades.sp_AsignarGuia - Casos exitosos
-- ================================================================

/* ================================================================
   BLOQUE 3: actividades.sp_AsignarGuia
   ================================================================
   Reglas: guia existe, habilitacion vigente, atraccion es
   Tour Guiado, fecha no pasada, sin solapamiento con otro tour.
   ================================================================ */
PRINT '';
PRINT '--- BLOQUE 3: actividades.sp_AsignarGuia ---';
GO

DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @id_guia3 INT, @id_atr_tour2 INT;
DECLARE @vig_futura DATE = DATEADD(YEAR, 2, @fecha_hoy);

-- Setup: nuevo guia y atraccion Tour Guiado para tests de conflicto
BEGIN TRY
    EXEC actividades.sp_InsertarGuia @p_dni = 34567890, @p_nombre = 'Lucia', @p_apellido = 'Garcia', @p_vigencia_autorizacion = @vig_futura;
    SET @id_guia3 = SCOPE_IDENTITY();
    EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = @id_guia3, @p_descripcion = 'Habilitacion Tours', @p_fecha_vencimiento = @vig_futura;
    EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Ascenso Cerro Campanario', @p_tipo = 'Tour Guiado', @p_costo = 3500.00, @p_duracion = 300, @p_horario_inicio = '07:00', @p_cupo_maximo = 15;
    SET @id_atr_tour2 = SCOPE_IDENTITY();
END TRY
BEGIN CATCH
    PRINT '[ERROR] Setup BLOQUE 3: ' + ERROR_MESSAGE();
END CATCH

-- TEST 3.1 [OK] Asignar guia a tour correctamente
-- Resultado esperado: se asigna el guia al tour sin errores.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = 1,
        @p_id_atraccion = 1,
        @p_fecha = @fecha_hoy;
    PRINT 'TEST 3.1 [OK] Guia asignado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.1 [ERROR] (inesperado) No se pudo asignar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH

-- TEST 3.2 [ERROR] Guia inexistente
-- Resultado esperado: se rechaza porque el guia no existe.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = 9999,
        @p_id_atraccion = 1,
        @p_fecha = @fecha_hoy;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.2 [ERROR] (esperado) Guia inexistente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH

-- TEST 3.3 [ERROR] Guia con habilitacion vencida
-- Resultado esperado: se rechaza porque la habilitacion esta vencida.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = 2,
        @p_id_atraccion = 1,
        @p_fecha = @fecha_hoy;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.3 [ERROR] (esperado) Habilitacion vencida: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH

-- TEST 3.4 [ERROR] Atraccion no es Tour Guiado
-- Resultado esperado: se rechaza porque la atraccion no es Tour Guiado.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = @id_guia3,
        @p_id_atraccion = 2,
        @p_fecha = @fecha_hoy;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.4 [ERROR] (esperado) No es Tour Guiado: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH

-- TEST 3.5 [ERROR] Guia ya tiene otro tour en la misma fecha
-- Resultado esperado: se rechaza por conflicto de agenda.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = 1,
        @p_id_atraccion = @id_atr_tour2,
        @p_fecha = @fecha_hoy;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.5 [ERROR] (esperado) Conflicto agenda: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH

-- TEST 3.6 [ERROR] Fecha en pasado
-- Resultado esperado: se rechaza la asignacion con fecha en el pasado.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = 1,
        @p_id_atraccion = 1,
        @p_fecha = '2020-01-01';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.6 [ERROR] (esperado) Fecha en pasado: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH

-- TEST 3.7 [ERROR] Guia ya asignado a ese mismo tour en esa fecha
-- Resultado esperado: se rechaza por conflicto de agenda duplicada.
BEGIN TRY
    EXEC actividades.sp_AsignarGuia
        @p_id_guia = 1,
        @p_id_atraccion = 1,
        @p_fecha = @fecha_hoy;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 3.7 [ERROR] (esperado) Guia ya asignado a ese tour: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH

PRINT '[OK] BLOQUE 3 - sp_AsignarGuia completado.';
GO


-- ================================================================
-- TEST: concesiones.sp_CrearConcesion - Casos exitosos
-- ================================================================

/* ================================================================
   BLOQUE 4: concesiones.sp_CrearConcesion
   ================================================================
   Reglas: empresa existe, fecha_fin > fecha_inicio,
   fecha_inicio no pasada, sin solapamiento.
   ================================================================ */
PRINT '';
PRINT '--- BLOQUE 4: concesiones.sp_CrearConcesion ---';
GO

DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @fecha_futura DATE = DATEADD(MONTH, 1, @fecha_hoy);
DECLARE @fecha_fin DATE = DATEADD(YEAR, 1, @fecha_futura);

-- TEST 4.1 [OK] Crear concesion normal
-- Resultado esperado: se crea la concesion correctamente.
BEGIN TRY
    EXEC concesiones.sp_CrearConcesion
        @p_id_empresa = 1,
        @p_id_parque = 1,
        @p_tipo_actividad = 'Restaurante',
        @p_pago_mensual = 15000.00,
        @p_fecha_inicio = @fecha_futura,
        @p_fecha_fin = @fecha_fin;
    PRINT 'TEST 4.1 [OK] Concesion creada correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 4.1 [ERROR] (inesperado) No se pudo crear: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 4.2 [OK] Crear concesion mismo parque distinto tipo (no solapa)
-- Resultado esperado: se crea la concesion correctamente.
DECLARE @fecha_futura2 DATE = DATEADD(MONTH, 1, CAST(GETDATE() AS DATE));
DECLARE @fecha_fin2 DATE = DATEADD(YEAR, 1, @fecha_futura2);
BEGIN TRY
    EXEC concesiones.sp_CrearConcesion
        @p_id_empresa = 1,
        @p_id_parque = 1,
        @p_tipo_actividad = 'Tienda',
        @p_pago_mensual = 8000.00,
        @p_fecha_inicio = @fecha_futura2,
        @p_fecha_fin = @fecha_fin2;
    PRINT 'TEST 4.2 [OK] Concesion distinto tipo - permitida.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 4.2 [ERROR] (inesperado) No se pudo crear: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 4.3 [ERROR] fecha_fin <= fecha_inicio
-- Resultado esperado: se rechaza la concesion por fechas invalidas.
DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);
BEGIN TRY
    EXEC concesiones.sp_CrearConcesion
        @p_id_empresa = 1,
        @p_id_parque = 1,
        @p_tipo_actividad = 'Restaurante',
        @p_pago_mensual = 10000.00,
        @p_fecha_inicio = @fecha_hoy,
        @p_fecha_fin = @fecha_hoy;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 4.3 [ERROR] (esperado) fecha_fin <= fecha_inicio: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 4.4 [ERROR] fecha_inicio en pasado
-- Resultado esperado: se rechaza la concesion con fecha de inicio en el pasado.
DECLARE @pasado DATE = '2020-01-01';
BEGIN TRY
    EXEC concesiones.sp_CrearConcesion
        @p_id_empresa = 1,
        @p_id_parque = 1,
        @p_tipo_actividad = 'Restaurante',
        @p_pago_mensual = 10000.00,
        @p_fecha_inicio = @pasado,
        @p_fecha_fin = '2025-01-01';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 4.4 [ERROR] (esperado) Fecha inicio en pasado: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 4.5 [ERROR] Concesion solapada (misma empresa+parque+tipo que TEST 4.1)
-- Resultado esperado: se rechaza la concesion por solapamiento.
DECLARE @fecha_futura5 DATE = DATEADD(MONTH, 1, CAST(GETDATE() AS DATE));
DECLARE @fecha_fin5 DATE = DATEADD(MONTH, 6, @fecha_futura5);
BEGIN TRY
    EXEC concesiones.sp_CrearConcesion
        @p_id_empresa = 1,
        @p_id_parque = 1,
        @p_tipo_actividad = 'Restaurante',
        @p_pago_mensual = 20000.00,
        @p_fecha_inicio = @fecha_futura5,
        @p_fecha_fin = @fecha_fin5;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 4.5 [ERROR] (esperado) Concesion solapada: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[OK] BLOQUE 4 - sp_CrearConcesion completado.';
GO


-- ================================================================
-- TEST: concesiones.sp_PagarConcesion - Casos exitosos
-- ================================================================

/* ================================================================
   BLOQUE 5: concesiones.sp_PagarConcesion
   ================================================================
   Reglas: concesion existe, fecha pago no futura,
   concesion no expirada >12 meses.
   ================================================================ */
PRINT '';
PRINT '--- BLOQUE 5: concesiones.sp_PagarConcesion ---';
GO

DECLARE @fecha_hoy DATE = CAST(GETDATE() AS DATE);

-- TEST 5.1 [OK] Pagar concesion normal
-- Resultado esperado: se registra el pago de la concesion.
BEGIN TRY
    EXEC concesiones.sp_PagarConcesion
        @p_id_concesion = 1,
        @p_fecha_pago = @fecha_hoy,
        @p_monto = 15000.00;
    PRINT 'TEST 5.1 [OK] Pago registrado correctamente.';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 5.1 [ERROR] (inesperado) No se pudo pagar: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 5.2 [ERROR] Concesion inexistente
-- Resultado esperado: se rechaza el pago por concesion inexistente.
DECLARE @hoy5 DATE = CAST(GETDATE() AS DATE);
BEGIN TRY
    EXEC concesiones.sp_PagarConcesion
        @p_id_concesion = 9999,
        @p_fecha_pago = @hoy5,
        @p_monto = 10000.00;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 5.2 [ERROR] (esperado) Concesion inexistente: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 5.3 [ERROR] Fecha de pago futura
-- Resultado esperado: se rechaza el pago con fecha futura.
DECLARE @futura DATE = DATEADD(YEAR, 1, CAST(GETDATE() AS DATE));
BEGIN TRY
    EXEC concesiones.sp_PagarConcesion
        @p_id_concesion = 1,
        @p_fecha_pago = @futura,
        @p_monto = 15000.00;
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
    PRINT 'TEST 5.3 [ERROR] (esperado) Fecha futura: ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[OK] BLOQUE 5 - sp_PagarConcesion completado.';
GO


/* ================================================================
   EVIDENCIA FINAL
   ================================================================ */
PRINT '';
PRINT '================================================================';
PRINT ' RESUMEN - Datos generados por los tests';
PRINT '================================================================';
SELECT 'parques.Parque'                  AS tabla, COUNT(*) AS registros FROM parques.Parque
UNION ALL SELECT 'parques.TipoVisitante',          COUNT(*) FROM parques.TipoVisitante
UNION ALL SELECT 'parques.PrecioEntrada',          COUNT(*) FROM parques.PrecioEntrada
UNION ALL SELECT 'actividades.Guia',               COUNT(*) FROM actividades.Guia
UNION ALL SELECT 'actividades.HabilitacionGuia',   COUNT(*) FROM actividades.HabilitacionGuia
UNION ALL SELECT 'actividades.Atraccion',          COUNT(*) FROM actividades.Atraccion
UNION ALL SELECT 'actividades.TourGuia',           COUNT(*) FROM actividades.TourGuia
UNION ALL SELECT 'concesiones.Empresa',            COUNT(*) FROM concesiones.Empresa
UNION ALL SELECT 'concesiones.Concesion',          COUNT(*) FROM concesiones.Concesion
UNION ALL SELECT 'concesiones.PagoConcesion',      COUNT(*) FROM concesiones.PagoConcesion
UNION ALL SELECT 'ventas.Moneda',                  COUNT(*) FROM ventas.Moneda
UNION ALL SELECT 'ventas.TasaCambio',              COUNT(*) FROM ventas.TasaCambio
UNION ALL SELECT 'ventas.Ticket',                  COUNT(*) FROM ventas.Ticket
UNION ALL SELECT 'ventas.ItemTicket',              COUNT(*) FROM ventas.ItemTicket
UNION ALL SELECT 'ventas.PagoMonedaExtranjera',    COUNT(*) FROM ventas.PagoMonedaExtranjera;
GO

PRINT '';
PRINT '================================================================';
PRINT ' CONTEO DE PRUEBAS';
PRINT '================================================================';
DECLARE @v_ok INT, @v_fail INT;
SELECT @v_ok = ok, @v_fail = fail FROM #Resultados;
PRINT '  Pruebas exitosas: ' + CAST(@v_ok AS VARCHAR(10));
PRINT '  Pruebas fallidas: ' + CAST(@v_fail AS VARCHAR(10));
PRINT '  Total: ' + CAST(@v_ok + @v_fail AS VARCHAR(10));
PRINT '================================================================';
PRINT '';
PRINT '================================================================';
PRINT ' FIN DE TESTING - SPs de Logica de Negocio';
PRINT ' Revisar cada mensaje [OK] / [ERROR] para verificar resultados.';
PRINT '================================================================';
DROP TABLE #Resultados;
GO

PRINT '============================================';
PRINT ' 12_PruebasLogicaNegocio.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
