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

  Archivo:      11_PruebasABM.sql
  Descripcion:  Script unificado de pruebas ABM (Insercion + Modificacion + Borrado).
                Reutiliza: sp_VaciarTablas (10_SPVaciarTablas.sql)
                Combina los tres scripts de testing en un solo archivo.
                Comienza con EXEC dbo.sp_VaciarTablas para partir
                de un estado limpio, y realizar pruebas sin conflictos.
===============================================================================
*/
USE ParquesNacionales;
GO
EXEC dbo.sp_VaciarTablas;
GO

CREATE TABLE #Resultados (ok INT DEFAULT 0, fail INT DEFAULT 0);
INSERT INTO #Resultados DEFAULT VALUES;
GO

/*
===============================================================
            INICIO - PRUEBAS DE INSERCION
===============================================================
*/

-- ================================================================
-- BLOQUE 1: parques.sp_InsertarParque
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 1: parques.sp_InsertarParque ---';
GO

-- TEST 1.1 [OK] Insertar parque válido - Parque Nacional Nahuel Huapi
-- Resultado esperado: se inserta correctamente y retorna id_parque = 1 (o el siguiente disponible).
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarParque
        @p_nombre     = 'Nahuel Huapi',
        @p_ubicacion  = 'Neuquén / Río Negro',
        @p_superficie = 717261.00,
        @p_tipo       = 'Parque Nacional',
        @p_latitud    = -41.000000,
        @p_longitud   = -71.500000;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 1.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 1.2 [OK] Insertar otro parque válido - Reserva Nacional
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarParque
        @p_nombre     = 'Los Alerces',
        @p_ubicacion  = 'Chubut',
        @p_superficie = 263000.00,
        @p_tipo       = 'Reserva Nacional',
        @p_latitud    = -42.800000,
        @p_longitud   = -71.900000;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 1.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 1.3 [OK] Insertar parque tipo Monumento Natural
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarParque
        @p_nombre     = 'Bosques Petrificados de Jaramillo',
        @p_ubicacion  = 'Santa Cruz',
        @p_superficie = 150000.00,
        @p_tipo       = 'Monumento Natural',
        @p_latitud    = -47.650000,
        @p_longitud   = -68.100000;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 1.3 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 1.4 [ERROR] nombre vacío
-- Resultado esperado: error "[nombre] El nombre del parque es obligatorio."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarParque
        @p_nombre     = '',
        @p_ubicacion  = 'Córdoba',
        @p_superficie = 50000.00,
        @p_tipo       = 'Parque Nacional',
        @p_latitud    = -31.600000,
        @p_longitud   = -64.700000;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 1.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 1.5 [ERROR] superficie negativa
-- Resultado esperado: error "[superficie] La superficie debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarParque
        @p_nombre     = 'Parque Inválido',
        @p_ubicacion  = 'Buenos Aires',
        @p_superficie = -100.00,
        @p_tipo       = 'Parque Nacional',
        @p_latitud    = -34.600000,
        @p_longitud   = -58.400000;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 1.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 1.6 [ERROR] tipo fuera del dominio
-- Resultado esperado: error "[tipo] El tipo debe ser uno de: ..."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarParque
        @p_nombre     = 'Parque Tipo Raro',
        @p_ubicacion  = 'Mendoza',
        @p_superficie = 10000.00,
        @p_tipo       = 'Eco-Reserva',
        @p_latitud    = -32.900000,
        @p_longitud   = -68.800000;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 1.6 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 1: verificar los parques insertados correctamente
PRINT 'Evidencia BLOQUE 1 - Parques insertados:';
SELECT id_parque, nombre, ubicacion, superficie, tipo, latitud, longitud
FROM parques.Parque;
GO


-- ================================================================
-- BLOQUE 2: parques.sp_InsertarTipoVisitante
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 2: parques.sp_InsertarTipoVisitante ---';
GO

-- TEST 2.1 [OK] Insertar todos los tipos válidos del dominio
-- Resultado esperado: 5 filas insertadas, una por cada tipo.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Residente';
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Extranjero';
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Estudiante';
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Jubilado';
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Menor';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 2.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 2.2 [ERROR] tipo fuera del dominio
-- Resultado esperado: error "[descripcion] Debe ser uno de: ..."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'VIP';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 2.2 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 2.3 [ERROR] duplicado
-- Resultado esperado: error "[descripcion] Ya existe un tipo de visitante con esa descripción."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Residente';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 2.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 2
PRINT 'Evidencia BLOQUE 2 - Tipos de visitante insertados:';
SELECT id_tipo, descripcion FROM parques.TipoVisitante;
GO


-- ================================================================
-- BLOQUE 3: parques.sp_InsertarPrecioEntrada
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 3: parques.sp_InsertarPrecioEntrada ---';
GO

-- TEST 3.1 [OK] Precio para Nahuel Huapi (id_parque=1), Residente (id_tipo=1)
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 1,
        @p_id_tipo        = 1,
        @p_precio         = 2500.00,
        @p_vigencia_desde = '2025-01-01';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 3.2 [OK] Precio para Nahuel Huapi, Extranjero
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 1,
        @p_id_tipo        = 2,
        @p_precio         = 8000.00,
        @p_vigencia_desde = '2025-01-01';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 3.3 [OK] Precio gratuito para Menores
-- Resultado esperado: se inserta correctamente con precio = 0.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 1,
        @p_id_tipo        = 5,
        @p_precio         = 0.00,
        @p_vigencia_desde = '2025-01-01';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.3 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 3.4 [OK] Actualización de precio (nueva vigencia)
-- Resultado esperado: se inserta un segundo registro con nueva fecha, sin pisar el anterior.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 1,
        @p_id_tipo        = 1,
        @p_precio         = 3200.00,
        @p_vigencia_desde = '2026-01-01';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.4 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 3.5 [ERROR] parque inexistente
-- Resultado esperado: error "[id_parque] No existe un parque con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 9999,
        @p_id_tipo        = 1,
        @p_precio         = 1000.00,
        @p_vigencia_desde = '2025-01-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 3.6 [ERROR] precio negativo
-- Resultado esperado: error "[precio] El precio no puede ser negativo ni nulo."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 1,
        @p_id_tipo        = 1,
        @p_precio         = -500.00,
        @p_vigencia_desde = '2025-06-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.6 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 3.7 [ERROR] combinación duplicada (mismo parque, tipo y vigencia)
-- Resultado esperado: error "[vigencia_desde] Ya existe un precio para ese parque, tipo y fecha."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_InsertarPrecioEntrada
        @p_id_parque      = 1,
        @p_id_tipo        = 1,
        @p_precio         = 999.00,
        @p_vigencia_desde = '2025-01-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 3.7 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 3
PRINT 'Evidencia BLOQUE 3 - Precios de entrada insertados:';
SELECT pe.id_precio, p.nombre AS parque, tv.descripcion AS tipo_visitante,
       pe.precio, pe.vigencia_desde
FROM parques.PrecioEntrada pe
JOIN parques.Parque        p  ON p.id_parque = pe.id_parque
JOIN parques.TipoVisitante tv ON tv.id_tipo  = pe.id_tipo
ORDER BY pe.id_parque, pe.id_tipo, pe.vigencia_desde;
GO


-- ================================================================
-- BLOQUE 4: ventas.sp_InsertarMoneda
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 4: ventas.sp_InsertarMoneda ---';
GO

-- TEST 4.1 [OK] Dólar estadounidense
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarMoneda
        @p_codigo_iso = 'USD',
        @p_nombre     = 'Dólar Estadounidense',
        @p_simbolo    = '$';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 4.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 4.2 [OK] Euro sin símbolo (opcional)
-- Resultado esperado: se inserta correctamente con simbolo NULL.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarMoneda
        @p_codigo_iso = 'EUR',
        @p_nombre     = 'Euro';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 4.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 4.3 [OK] Real brasileño
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarMoneda
        @p_codigo_iso = 'BRL',
        @p_nombre     = 'Real Brasileño',
        @p_simbolo    = 'R$';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 4.3 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 4.4 [ERROR] código ISO con longitud incorrecta
-- Resultado esperado: error "[codigo_iso] El código ISO debe tener exactamente 3 caracteres."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarMoneda
        @p_codigo_iso = 'US',
        @p_nombre     = 'Dólar Corto';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 4.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 4.5 [ERROR] codigo_iso duplicado
-- Resultado esperado: error "[codigo_iso] Ya existe una moneda con ese código ISO."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarMoneda
        @p_codigo_iso = 'USD',
        @p_nombre     = 'Otro Dólar';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 4.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 4
PRINT 'Evidencia BLOQUE 4 - Monedas insertadas:';
SELECT id_moneda, codigo_iso, nombre, simbolo FROM ventas.Moneda;
GO


-- ================================================================
-- BLOQUE 5: ventas.sp_InsertarTasaCambio
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 5: ventas.sp_InsertarTasaCambio ---';
GO

-- TEST 5.1 [OK] Tasa USD del dia
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTasaCambio
        @p_id_moneda      = 1,
        @p_fecha_vigencia = '2026-06-11',
        @p_tasa_a_peso    = 1050.5000;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 5.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 5.2 [OK] Tasa EUR
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTasaCambio
        @p_id_moneda      = 2,
        @p_fecha_vigencia = '2026-06-11',
        @p_tasa_a_peso    = 1150.7500;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 5.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 5.3 [ERROR] moneda inexistente
-- Resultado esperado: error "[id_moneda] No existe una moneda con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTasaCambio
        @p_id_moneda      = 9999,
        @p_fecha_vigencia = '2026-06-11',
        @p_tasa_a_peso    = 500.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 5.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 5.4 [ERROR] tasa <= 0
-- Resultado esperado: error "[tasa_a_peso] La tasa de cambio debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTasaCambio
        @p_id_moneda      = 1,
        @p_fecha_vigencia = '2026-06-12',
        @p_tasa_a_peso    = 0.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 5.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 5.5 [ERROR] combinación (moneda, fecha) duplicada
-- Resultado esperado: error "[fecha_vigencia] Ya existe una tasa para esa moneda y fecha."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTasaCambio
        @p_id_moneda      = 1,
        @p_fecha_vigencia = '2026-06-11',
        @p_tasa_a_peso    = 1100.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 5.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 5
PRINT 'Evidencia BLOQUE 5 - Tasas de cambio insertadas:';
SELECT tc.id_tasa, m.codigo_iso, tc.fecha_vigencia, tc.tasa_a_peso
FROM ventas.TasaCambio tc
JOIN ventas.Moneda m ON m.id_moneda = tc.id_moneda;
GO


-- ================================================================
-- BLOQUE 6: ventas.sp_InsertarTicket
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 6: ventas.sp_InsertarTicket ---';
GO

-- TEST 6.1 [OK] Ticket de venta en efectivo
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 1,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-11',
        @p_punto_de_venta     = 1,
        @p_numero_comprobante = 1001,
        @p_forma_pago         = 'Efectivo',
        @p_total_pagado       = 2500.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 6.2 [OK] Ticket en moneda extranjera
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 1,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-13',
        @p_punto_de_venta     = 1,
        @p_numero_comprobante = 1002,
        @p_forma_pago         = 'Moneda Extranjera',
        @p_total_pagado       = 8000.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 6.3 [OK] Ticket en otro parque
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 2,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-11',
        @p_punto_de_venta     = 2,
        @p_numero_comprobante = 2001,
        @p_forma_pago         = 'Tarjeta de Debito',
        @p_total_pagado       = 3200.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.3 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 6.4 [ERROR] parque inexistente
-- Resultado esperado: error "[id_parque] No existe un parque con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 9999,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-11',
        @p_punto_de_venta     = 1,
        @p_numero_comprobante = 9001,
        @p_forma_pago         = 'Efectivo',
        @p_total_pagado       = 1000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 6.5 [ERROR] fecha_acceso anterior a fecha de emisión
-- Resultado esperado: error "[fecha_acceso] La fecha de acceso no puede ser anterior a la fecha de emisión."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 1,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-10',
        @p_punto_de_venta     = 1,
        @p_numero_comprobante = 9002,
        @p_forma_pago         = 'Efectivo',
        @p_total_pagado       = 1000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 6.6 [ERROR] comprobante duplicado (mismo punto_de_venta y número)
-- Resultado esperado: error "[numero_comprobante] Ya existe un comprobante con ese punto de venta y número."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 1,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-11',
        @p_punto_de_venta     = 1,
        @p_numero_comprobante = 1001,
        @p_forma_pago         = 'Efectivo',
        @p_total_pagado       = 1000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.6 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 6.7 [ERROR] forma de pago inválida
-- Resultado esperado: error "[forma_pago] Debe ser uno de: ..."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarTicket
        @p_id_parque          = 1,
        @p_fecha              = '2026-06-11',
        @p_fecha_acceso       = '2026-06-11',
        @p_punto_de_venta     = 1,
        @p_numero_comprobante = 9003,
        @p_forma_pago         = 'Criptomoneda',
        @p_total_pagado       = 500.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 6.7 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 6
PRINT 'Evidencia BLOQUE 6 - Tickets insertados:';
SELECT t.id_ticket, p.nombre AS parque, t.fecha, t.fecha_acceso,
       t.punto_de_venta, t.numero_comprobante, t.forma_pago, t.total_pagado
FROM ventas.Ticket t
JOIN parques.Parque p ON p.id_parque = t.id_parque;
GO


-- ================================================================
-- BLOQUE 7: ventas.sp_InsertarItemTicket
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 7: ventas.sp_InsertarItemTicket ---';
GO

-- TEST 7.1 [OK] Ítem de entrada en ticket 1 (Residente, precio vigente)
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarItemTicket
        @p_id_ticket         = 1,
        @p_id_precio_entrada = 1,
        @p_id_atraccion      = NULL,
        @p_precio_venta      = 2500.00,
        @p_cantidad          = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 7.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 7.2 [OK] Ítem de entrada Extranjero en ticket 2
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarItemTicket
        @p_id_ticket         = 2,
        @p_id_precio_entrada = 2,
        @p_id_atraccion      = NULL,
        @p_precio_venta      = 8000.00,
        @p_cantidad          = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 7.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 7.3 [ERROR] ambos campos nulos (ni precio ni atracción)
-- Resultado esperado: error "[tipo_item] Debe informarse exactamente uno: ..."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarItemTicket
        @p_id_ticket         = 1,
        @p_id_precio_entrada = NULL,
        @p_id_atraccion      = NULL,
        @p_precio_venta      = 500.00,
        @p_cantidad          = 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 7.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 7.4 [ERROR] ambos campos informados simultáneamente
-- Resultado esperado: error "[tipo_item] Debe informarse exactamente uno: ..."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarItemTicket
        @p_id_ticket         = 1,
        @p_id_precio_entrada = 1,
        @p_id_atraccion      = 1,
        @p_precio_venta      = 500.00,
        @p_cantidad          = 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 7.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 7.5 [ERROR] ticket inexistente
-- Resultado esperado: error "[id_ticket] No existe un ticket con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarItemTicket
        @p_id_ticket         = 9999,
        @p_id_precio_entrada = 1,
        @p_id_atraccion      = NULL,
        @p_precio_venta      = 500.00,
        @p_cantidad          = 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 7.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 7.6 [ERROR] cantidad = 0
-- Resultado esperado: error "[cantidad] La cantidad debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarItemTicket
        @p_id_ticket         = 1,
        @p_id_precio_entrada = 1,
        @p_id_atraccion      = NULL,
        @p_precio_venta      = 500.00,
        @p_cantidad          = 0;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 7.6 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 7
PRINT 'Evidencia BLOQUE 7 - Ítems de ticket insertados:';
SELECT it.id_item, it.id_ticket, it.id_precio_entrada, it.id_atraccion,
       it.precio_venta, it.cantidad
FROM ventas.ItemTicket it;
GO


-- ================================================================
-- BLOQUE 8: ventas.sp_InsertarPagoMonedaExtranjera
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 8: ventas.sp_InsertarPagoMonedaExtranjera ---';
GO

-- TEST 8.1 [OK] Pago en USD para ticket 2 (que tiene forma_pago = 'Moneda Extranjera')
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarPagoMonedaExtranjera
        @p_id_ticket        = 2,
        @p_id_tasa          = 1,
        @p_monto_extranjero = 7.62,
        @p_monto_pesos      = 8000.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 8.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 8.2 [ERROR] ticket con forma_pago distinta a 'Moneda Extranjera'
-- Resultado esperado: error "[forma_pago] El ticket no tiene forma de pago Moneda Extranjera."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarPagoMonedaExtranjera
        @p_id_ticket        = 1,
        @p_id_tasa          = 1,
        @p_monto_extranjero = 5.00,
        @p_monto_pesos      = 5250.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 8.2 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 8.3 [ERROR] tasa inexistente
-- Resultado esperado: error "[id_tasa] No existe una tasa de cambio con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarPagoMonedaExtranjera
        @p_id_ticket        = 2,
        @p_id_tasa          = 9999,
        @p_monto_extranjero = 5.00,
        @p_monto_pesos      = 5250.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 8.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 8.4 [ERROR] monto_extranjero = 0
-- Resultado esperado: error "[monto_extranjero] El monto en moneda extranjera debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_InsertarPagoMonedaExtranjera
        @p_id_ticket        = 2,
        @p_id_tasa          = 1,
        @p_monto_extranjero = 0.00,
        @p_monto_pesos      = 0.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 8.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 8
PRINT 'Evidencia BLOQUE 8 - Pagos en moneda extranjera:';
SELECT pme.id_pago_ext, pme.id_ticket, m.codigo_iso,
       tc.tasa_a_peso, pme.monto_extranjero, pme.monto_pesos
FROM ventas.PagoMonedaExtranjera pme
JOIN ventas.TasaCambio tc ON tc.id_tasa   = pme.id_tasa
JOIN ventas.Moneda     m  ON m.id_moneda  = tc.id_moneda;
GO


-- ================================================================
-- BLOQUE 9: actividades.sp_InsertarGuia
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 9: actividades.sp_InsertarGuia ---';
GO

-- TEST 9.1 [OK] Guía válido con especialidad y título
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarGuia
        @p_nombre                = 'Martina',
        @p_apellido              = 'Suárez',
        @p_dni                   = 32156789,
        @p_especialidad          = 'Fauna Patagónica',
        @p_titulo                = 'Licenciada en Biología',
        @p_vigencia_autorizacion = '2027-12-31';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 9.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 9.2 [OK] Guía válido sin especialidad ni título (campos opcionales)
-- Resultado esperado: se inserta correctamente con especialidad y titulo NULL.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarGuia
        @p_nombre                = 'Carlos',
        @p_apellido              = 'Mendez',
        @p_dni                   = 28765432,
        @p_vigencia_autorizacion = '2026-12-31';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 9.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 9.3 [ERROR] DNI duplicado
-- Resultado esperado: error "[dni] Ya existe un guía registrado con ese DNI."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarGuia
        @p_nombre                = 'Otro',
        @p_apellido              = 'Guia',
        @p_dni                   = 32156789,
        @p_vigencia_autorizacion = '2027-01-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 9.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 9.4 [ERROR] DNI fuera de rango (mayor a 99999999)
-- Resultado esperado: error "[dni] El DNI debe ser un número entre 1 y 99999999."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarGuia
        @p_nombre                = 'Juan',
        @p_apellido              = 'Lopez',
        @p_dni                   = 123456789,
        @p_vigencia_autorizacion = '2027-01-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 9.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 9.5 [ERROR] nombre vacío
-- Resultado esperado: error "[nombre] El nombre del guía es obligatorio."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarGuia
        @p_nombre                = '   ',
        @p_apellido              = 'Lopez',
        @p_dni                   = 11223344,
        @p_vigencia_autorizacion = '2027-01-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 9.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 9
PRINT 'Evidencia BLOQUE 9 - Guías insertados:';
SELECT id_guia, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni, especialidad, titulo, vigencia_autorizacion
FROM actividades.Guia;
GO


-- ================================================================
-- BLOQUE 10: actividades.sp_InsertarHabilitacionGuia
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 10: actividades.sp_InsertarHabilitacionGuia ---';
GO

-- TEST 10.1 [OK] Habilitación con vencimiento
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarHabilitacionGuia
        @p_id_guia           = 1,
        @p_descripcion       = 'Guía de Alta Montaña',
        @p_fecha_vencimiento = '2027-06-30';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 10.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 10.2 [OK] Habilitación sin vencimiento (permanente)
-- Resultado esperado: se inserta correctamente con fecha_vencimiento NULL.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarHabilitacionGuia
        @p_id_guia     = 1,
        @p_descripcion = 'Primeros Auxilios en Naturaleza';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 10.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 10.3 [ERROR] guía inexistente
-- Resultado esperado: error "[id_guia] No existe un guía con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarHabilitacionGuia
        @p_id_guia     = 9999,
        @p_descripcion = 'Habilitación Falsa';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 10.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 10.4 [ERROR] descripción vacía
-- Resultado esperado: error "[descripcion] La descripción de la habilitación es obligatoria."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarHabilitacionGuia
        @p_id_guia     = 1,
        @p_descripcion = '';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 10.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 10
PRINT 'Evidencia BLOQUE 10 - Habilitaciones de guías:';
SELECT hg.id_habilitacion, g.nombre + ' ' + g.apellido AS guia,
       hg.descripcion, hg.fecha_vencimiento
FROM actividades.HabilitacionGuia hg
JOIN actividades.Guia g ON g.id_guia = hg.id_guia;
GO


-- ================================================================
-- BLOQUE 11: actividades.sp_InsertarAtraccion
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 11: actividades.sp_InsertarAtraccion ---';
GO

-- TEST 11.1 [OK] Atracción gratuita
-- Resultado esperado: se inserta correctamente con costo = 0.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Sendero Lago Moreno',
        @p_tipo         = 'Gratuita',
        @p_costo        = 0.00,
        @p_duracion     = 120,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo  = 50;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 11.2 [OK] Atracción paga
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Navegación Lago Nahuel Huapi',
        @p_tipo         = 'Paga',
        @p_costo        = 1500.00,
        @p_duracion     = 90,
        @p_horario_inicio = '09:00',
        @p_cupo_maximo  = 20;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 11.3 [OK] Tour Guiado
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Tour Isla Victoria',
        @p_tipo         = 'Tour Guiado',
        @p_costo        = 3500.00,
        @p_duracion     = 240,
        @p_horario_inicio = '08:30',
        @p_cupo_maximo  = 15;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.3 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 11.4 [ERROR] atracción Gratuita con costo > 0
-- Resultado esperado: error "[costo] Una atracción Gratuita debe tener costo = 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Sendero Inválido',
        @p_tipo         = 'Gratuita',
        @p_costo        = 100.00,
        @p_duracion     = 60,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo  = 10;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 11.5 [ERROR] Tour Guiado con costo = 0
-- Resultado esperado: error "[costo] Una atracción Paga o Tour Guiado debe tener costo mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Tour Gratis',
        @p_tipo         = 'Tour Guiado',
        @p_costo        = 0.00,
        @p_duracion     = 180,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo  = 10;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 11.6 [ERROR] tipo fuera del dominio
-- Resultado esperado: error "[tipo] Debe ser uno de: Gratuita, Paga, Tour Guiado."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Actividad Rara',
        @p_tipo         = 'Exclusiva',
        @p_costo        = 500.00,
        @p_duracion     = 60,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo  = 5;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.6 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 11.7 [ERROR] cupo = 0
-- Resultado esperado: error "[cupo_maximo] El cupo máximo debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Sendero Sin Cupo',
        @p_tipo         = 'Gratuita',
        @p_costo        = 0.00,
        @p_duracion     = 60,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo  = 0;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.7 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 11.8 [ERROR] parque inexistente
-- Resultado esperado: error "[id_parque] No existe un parque con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 9999,
        @p_nombre       = 'Atracción Sin Parque',
        @p_tipo         = 'Gratuita',
        @p_costo        = 0.00,
        @p_duracion     = 30,
        @p_horario_inicio = '08:00',
        @p_cupo_maximo  = 10;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.8 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 11.9 [ERROR] horario_inicio NULL
-- Resultado esperado: error "[horario_inicio] El horario de inicio es obligatorio."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarAtraccion
        @p_id_parque    = 1,
        @p_nombre       = 'Actividad Sin Horario',
        @p_tipo         = 'Gratuita',
        @p_costo        = 0.00,
        @p_duracion     = 60,
        @p_horario_inicio = NULL,
        @p_cupo_maximo  = 10;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 11.9 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 11 - Ítem de atracción en ticket (ahora que existen atracciones)
-- Primero insertamos un ítem de atracción en el ticket 1 para evidenciar sp_InsertarItemTicket
EXEC ventas.sp_InsertarItemTicket
    @p_id_ticket         = 1,
    @p_id_precio_entrada = NULL,
    @p_id_atraccion      = 2,
    @p_precio_venta      = 1500.00,
    @p_cantidad          = 2;
GO

PRINT 'Evidencia BLOQUE 11 - Atracciones insertadas:';
SELECT a.id_atraccion, p.nombre AS parque, a.nombre, a.tipo,
       a.costo, a.duracion, a.cupo_maximo
FROM actividades.Atraccion a
JOIN parques.Parque p ON p.id_parque = a.id_parque;
GO

PRINT 'Evidencia BLOQUE 11 - Ítems de ticket (incluyendo atracción):';
SELECT it.id_item, it.id_ticket, it.id_precio_entrada, it.id_atraccion,
       it.precio_venta, it.cantidad
FROM ventas.ItemTicket it;
GO


-- ================================================================
-- BLOQUE 12: actividades.sp_InsertarTourGuia
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 12: actividades.sp_InsertarTourGuia ---';
GO

-- TEST 12.1 [OK] Asignación válida de guía a Tour Guiado
-- Guía 1 (Martina Suárez, vigente hasta 2027-12-31) al Tour Isla Victoria (id=3)
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarTourGuia
        @p_id_guia      = 1,
        @p_id_atraccion = 3,
        @p_fecha        = '2026-07-15';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 12.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 12.2 [OK] Mismo guía, mismo tour, fecha distinta
-- Resultado esperado: se inserta correctamente (la unicidad es por las tres columnas juntas).
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarTourGuia
        @p_id_guia      = 1,
        @p_id_atraccion = 3,
        @p_fecha        = '2026-08-01';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 12.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 12.3 [ERROR] asignar guía a una atracción que NO es Tour Guiado
-- Resultado esperado: error "[id_atraccion] Solo se pueden asignar guías a atracciones de tipo Tour Guiado."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarTourGuia
        @p_id_guia      = 1,
        @p_id_atraccion = 1,    -- id=1 es 'Gratuita'
        @p_fecha        = '2026-07-15';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 12.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 12.4 [ERROR] guía con autorización vencida para la fecha indicada
-- Guía 2 (Carlos Mendez, vigente hasta 2026-12-31): fecha 2027-01-10 ya vencida
-- Resultado esperado: error "[vigencia_autorizacion] La autorización del guía no está vigente..."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarTourGuia
        @p_id_guia      = 2,
        @p_id_atraccion = 3,
        @p_fecha        = '2027-01-10';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 12.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 12.5 [ERROR] combinación duplicada (mismo guía, atracción y fecha)
-- Resultado esperado: error "[fecha] El guía ya está asignado a esa atracción en esa fecha."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_InsertarTourGuia
        @p_id_guia      = 1,
        @p_id_atraccion = 3,
        @p_fecha        = '2026-07-15';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 12.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 12
PRINT 'Evidencia BLOQUE 12 - Asignaciones Tour-Guía:';
SELECT tg.id_tour_guia,
       g.nombre + ' ' + g.apellido AS guia,
       a.nombre AS atraccion,
       tg.fecha
FROM actividades.TourGuia tg
JOIN actividades.Guia     g ON g.id_guia      = tg.id_guia
JOIN actividades.Atraccion a ON a.id_atraccion = tg.id_atraccion;
GO


-- ================================================================
-- BLOQUE 13: concesiones.sp_InsertarEmpresa
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 13: concesiones.sp_InsertarEmpresa ---';
GO

-- TEST 13.1 [OK] Empresa válida con contacto
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarEmpresa
        @p_razon_social = 'Patagonia Turismo S.A.',
        @p_cuit         = '30712345670',
        @p_contacto     = 'contacto@patagoniaturismo.com.ar';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 13.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 13.2 [OK] Empresa válida sin contacto
-- Resultado esperado: se inserta correctamente con contacto NULL.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarEmpresa
        @p_razon_social = 'Bosque Verde S.R.L.',
        @p_cuit         = '30698765432';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 13.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 13.3 [ERROR] CUIT con longitud incorrecta (menos de 11 dígitos)
-- Resultado esperado: error "[cuit] El CUIT debe contener exactamente 11 dígitos numéricos."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarEmpresa
        @p_razon_social = 'Empresa Corta',
        @p_cuit         = '3071234567';  -- solo 10 digitos
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 13.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 13.4 [ERROR] CUIT con caracteres no numéricos
-- Resultado esperado: error "[cuit] El CUIT debe contener exactamente 11 dígitos numéricos."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarEmpresa
        @p_razon_social = 'Empresa Letras',
        @p_cuit         = '3071234567A';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 13.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 13.5 [ERROR] CUIT duplicado
-- Resultado esperado: error "[cuit] Ya existe una empresa registrada con ese CUIT."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarEmpresa
        @p_razon_social = 'Copia Patagonia',
        @p_cuit         = '30712345670';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 13.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 13
PRINT 'Evidencia BLOQUE 13 - Empresas insertadas:';
SELECT id_empresa, razon_social, cuit, contacto FROM concesiones.Empresa;
GO


-- ================================================================
-- BLOQUE 14: concesiones.sp_InsertarConcesion
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 14: concesiones.sp_InsertarConcesion ---';
GO

-- TEST 14.1 [OK] Concesión vigente
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarConcesion
        @p_id_empresa     = 1,
        @p_id_parque      = 1,
        @p_tipo_actividad = 'Restaurante',
        @p_fecha_inicio   = '2025-01-01',
        @p_fecha_fin      = '2027-12-31',
        @p_pago_mensual   = 450000.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 14.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 14.2 [OK] Concesión ya vencida (para cumplir criterio de aceptación)
-- Resultado esperado: se inserta correctamente; el sistema registra también contratos históricos.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarConcesion
        @p_id_empresa     = 2,
        @p_id_parque      = 2,
        @p_tipo_actividad = 'Tienda de Souvenirs',
        @p_fecha_inicio   = '2022-01-01',
        @p_fecha_fin      = '2024-12-31',
        @p_pago_mensual   = 120000.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 14.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 14.3 [ERROR] fecha_fin anterior a fecha_inicio
-- Resultado esperado: error "[fecha_fin] La fecha de fin debe ser posterior a la fecha de inicio."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarConcesion
        @p_id_empresa     = 1,
        @p_id_parque      = 1,
        @p_tipo_actividad = 'Kiosco',
        @p_fecha_inicio   = '2026-06-01',
        @p_fecha_fin      = '2026-01-01',
        @p_pago_mensual   = 50000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 14.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 14.4 [ERROR] pago mensual = 0
-- Resultado esperado: error "[pago_mensual] El pago mensual (canon) debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarConcesion
        @p_id_empresa     = 1,
        @p_id_parque      = 1,
        @p_tipo_actividad = 'Kiosco Gratuito',
        @p_fecha_inicio   = '2026-01-01',
        @p_fecha_fin      = '2026-12-31',
        @p_pago_mensual   = 0.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 14.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 14.5 [ERROR] empresa inexistente
-- Resultado esperado: error "[id_empresa] No existe una empresa con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarConcesion
        @p_id_empresa     = 9999,
        @p_id_parque      = 1,
        @p_tipo_actividad = 'Bar',
        @p_fecha_inicio   = '2026-01-01',
        @p_fecha_fin      = '2026-12-31',
        @p_pago_mensual   = 100000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 14.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 14
PRINT 'Evidencia BLOQUE 14 - Concesiones insertadas:';
SELECT c.id_concesion, e.razon_social, p.nombre AS parque,
       c.tipo_actividad, c.fecha_inicio, c.fecha_fin, c.pago_mensual,
       CASE WHEN c.fecha_fin >= CAST(GETDATE() AS DATE) THEN 'Vigente' ELSE 'Vencida' END AS estado
FROM concesiones.Concesion c
JOIN concesiones.Empresa e ON e.id_empresa = c.id_empresa
JOIN parques.Parque      p ON p.id_parque  = c.id_parque;
GO


-- ================================================================
-- BLOQUE 15: concesiones.sp_InsertarPagoConcesion
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 15: concesiones.sp_InsertarPagoConcesion ---';
GO

-- TEST 15.1 [OK] Pago de canon válido
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarPagoConcesion
        @p_id_empresa   = 1,
        @p_id_concesion = 1,
        @p_fecha_pago   = '2026-01-05',
        @p_monto        = 450000.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 15.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 15.2 [OK] Segundo pago del mismo contrato
-- Resultado esperado: se inserta correctamente (el historial admite múltiples pagos).
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarPagoConcesion
        @p_id_empresa   = 1,
        @p_id_concesion = 1,
        @p_fecha_pago   = '2026-02-05',
        @p_monto        = 450000.00;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 15.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 15.3 [ERROR] la concesión no pertenece a la empresa indicada
-- Resultado esperado: error "[id_empresa] La concesión indicada no pertenece a esa empresa."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarPagoConcesion
        @p_id_empresa   = 2,      -- empresa incorrecta para concesion 1
        @p_id_concesion = 1,
        @p_fecha_pago   = '2026-03-05',
        @p_monto        = 450000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 15.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 15.4 [ERROR] monto negativo
-- Resultado esperado: error "[monto] El monto del pago debe ser mayor a 0."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarPagoConcesion
        @p_id_empresa   = 1,
        @p_id_concesion = 1,
        @p_fecha_pago   = '2026-04-05',
        @p_monto        = -1000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 15.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 15.5 [ERROR] concesión inexistente
-- Resultado esperado: error "[id_concesion] No existe una concesión con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_InsertarPagoConcesion
        @p_id_empresa   = 1,
        @p_id_concesion = 9999,
        @p_fecha_pago   = '2026-04-05',
        @p_monto        = 100000.00;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 15.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 15
PRINT 'Evidencia BLOQUE 15 - Pagos de concesión registrados:';
SELECT pc.id_pago, e.razon_social, c.tipo_actividad,
       pc.fecha_pago, pc.monto
FROM concesiones.PagoConcesion pc
JOIN concesiones.Empresa   e ON e.id_empresa   = pc.id_empresa
JOIN concesiones.Concesion c ON c.id_concesion = pc.id_concesion;
GO


-- ================================================================
-- BLOQUE 16: personal.sp_InsertarGuardaparque
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 16: personal.sp_InsertarGuardaparque ---';
GO

-- TEST 16.1 [OK] Guardaparque válido
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque
        @p_nombre   = 'Roberto',
        @p_apellido = 'Vargas',
        @p_dni      = 25478963;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 16.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 16.2 [OK] Otro guardaparque válido
-- Resultado esperado: se inserta correctamente.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque
        @p_nombre   = 'Elena',
        @p_apellido = 'Peralta',
        @p_dni      = 33987654;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 16.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 16.3 [ERROR] DNI duplicado
-- Resultado esperado: error "[dni] Ya existe un guardaparque registrado con ese DNI."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque
        @p_nombre   = 'Roberto',
        @p_apellido = 'Duplicado',
        @p_dni      = 25478963;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 16.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 16.4 [ERROR] apellido vacío
-- Resultado esperado: error "[apellido] El apellido del guardaparque es obligatorio."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarGuardaparque
        @p_nombre   = 'Sin Apellido',
        @p_apellido = '',
        @p_dni      = 11111111;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 16.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 16
PRINT 'Evidencia BLOQUE 16 - Guardaparques insertados:';
SELECT id_guardaparque, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni FROM personal.Guardaparque;
GO


-- ================================================================
-- BLOQUE 17: personal.sp_InsertarAsignacionParque
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 17: personal.sp_InsertarAsignacionParque ---';
GO

-- TEST 17.1 [OK] Asignación activa (sin fecha de egreso) para guardaparque 1
-- Resultado esperado: se inserta correctamente con fecha_hasta NULL.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarAsignacionParque
        @p_id_guardaparque = 1,
        @p_id_parque       = 1,
        @p_fecha_desde     = '2024-03-01';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 17.1 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 17.2 [OK] Asignación histórica cerrada para guardaparque 2
-- Resultado esperado: se inserta correctamente con fecha_hasta informada.
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarAsignacionParque
        @p_id_guardaparque = 2,
        @p_id_parque       = 2,
        @p_fecha_desde     = '2022-06-01',
        @p_fecha_hasta     = '2024-05-31',
        @p_motivo_egreso   = 'Reasignación por necesidad del servicio';
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 17.2 [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

-- TEST 17.3 [ERROR] guardaparque ya tiene una asignación activa abierta
-- El guardaparque 1 ya tiene una asignacion sin fecha_hasta; no puede crear otra
-- Resultado esperado: error "El guardaparque ya tiene una asignación activa sin fecha de egreso."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarAsignacionParque
        @p_id_guardaparque = 1,
        @p_id_parque       = 2,
        @p_fecha_desde     = '2026-06-11';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 17.3 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 17.4 [ERROR] fecha_hasta anterior a fecha_desde
-- Resultado esperado: error "[fecha_hasta] La fecha de egreso debe ser posterior a la fecha de inicio."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarAsignacionParque
        @p_id_guardaparque = 2,
        @p_id_parque       = 1,
        @p_fecha_desde     = '2026-06-01',
        @p_fecha_hasta     = '2026-05-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 17.4 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- TEST 17.5 [ERROR] parque inexistente
-- Resultado esperado: error "[id_parque] No existe un parque con ese ID."
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_InsertarAsignacionParque
        @p_id_guardaparque = 2,
        @p_id_parque       = 9999,
        @p_fecha_desde     = '2026-06-01';
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT 'TEST 17.5 - Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- EVIDENCIA 17
PRINT 'Evidencia BLOQUE 17 - Asignaciones de guardaparques:';
SELECT ap.id_asignacion,
       g.nombre + ' ' + g.apellido AS guardaparque,
       p.nombre AS parque,
       ap.fecha_desde, ap.fecha_hasta, ap.motivo_egreso,
       CASE WHEN ap.fecha_hasta IS NULL THEN 'Activo' ELSE 'Inactivo' END AS estado
FROM personal.AsignacionParque ap
JOIN personal.Guardaparque g ON g.id_guardaparque = ap.id_guardaparque
JOIN parques.Parque        p ON p.id_parque        = ap.id_parque;
GO


-- ================================================================
-- RESUMEN FINAL DE DATOS INSERTADOS
-- ================================================================
PRINT '';
PRINT '================================================================';
PRINT ' RESUMEN FINAL - Conteo de registros por tabla';
PRINT '================================================================';

SELECT 'parques.Parque'                  AS tabla, COUNT(*) AS registros FROM parques.Parque
UNION ALL
SELECT 'parques.TipoVisitante',           COUNT(*) FROM parques.TipoVisitante
UNION ALL
SELECT 'parques.PrecioEntrada',           COUNT(*) FROM parques.PrecioEntrada
UNION ALL
SELECT 'ventas.Moneda',                   COUNT(*) FROM ventas.Moneda
UNION ALL
SELECT 'ventas.TasaCambio',               COUNT(*) FROM ventas.TasaCambio
UNION ALL
SELECT 'ventas.Ticket',                   COUNT(*) FROM ventas.Ticket
UNION ALL
SELECT 'ventas.ItemTicket',               COUNT(*) FROM ventas.ItemTicket
UNION ALL
SELECT 'ventas.PagoMonedaExtranjera',     COUNT(*) FROM ventas.PagoMonedaExtranjera
UNION ALL
SELECT 'actividades.Guia',                COUNT(*) FROM actividades.Guia
UNION ALL
SELECT 'actividades.HabilitacionGuia',    COUNT(*) FROM actividades.HabilitacionGuia
UNION ALL
SELECT 'actividades.Atraccion',           COUNT(*) FROM actividades.Atraccion
UNION ALL
SELECT 'actividades.TourGuia',            COUNT(*) FROM actividades.TourGuia
UNION ALL
SELECT 'concesiones.Empresa',             COUNT(*) FROM concesiones.Empresa
UNION ALL
SELECT 'concesiones.Concesion',           COUNT(*) FROM concesiones.Concesion
UNION ALL
SELECT 'concesiones.PagoConcesion',       COUNT(*) FROM concesiones.PagoConcesion
UNION ALL
SELECT 'personal.Guardaparque',           COUNT(*) FROM personal.Guardaparque
UNION ALL
SELECT 'personal.AsignacionParque',       COUNT(*) FROM personal.AsignacionParque;
GO

PRINT '';
PRINT '================================================================';
PRINT ' FIN DE TESTING - SPs de Insercion';
PRINT ' Registros validos insertados: todos los marcados [OK].';
PRINT ' Errores capturados: todos los marcados [ERROR].';
PRINT ' Ningun registro invalido debe figurar en las tablas.';
PRINT '================================================================';
GO

/*
===============================================================
            INICIO - PRUEBAS DE MODIFICACION
===============================================================
*/

-- =====================================================================
-- Pruebas de modificacion de concesiones
-- =====================================================================

/*
==============================================================
SP: concesiones.sp_ModificarConcesion
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: concesiones.sp_ModificarConcesion';
PRINT '================================================';
PRINT 'TEST: concesiones.sp_ModificarConcesion';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar tipo_actividad y pago_mensual';
-- Resultado esperado: se actualizan tipo_actividad y pago_mensual de la concesion 1.
-- Requiere: concesion insertada en TEST 14.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_concesion, id_empresa, id_parque, tipo_actividad, fecha_inicio, fecha_fin, pago_mensual
    FROM concesiones.Concesion WHERE id_concesion = 1;

    EXEC concesiones.sp_ModificarConcesion
        @p_id_concesion  = 1,
        @p_tipo_actividad = 'Gastronomia',
        @p_pago_mensual  = 8000.00;

    -- Verificar resultado de la operacion
    SELECT id_concesion, id_empresa, id_parque, tipo_actividad, fecha_inicio, fecha_fin, pago_mensual
    FROM concesiones.Concesion WHERE id_concesion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
------------------------------------------------------
*/
PRINT '[FALLA] ID de concesion inexistente';
-- Resultado esperado: error por ID de concesion inexistente
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion @p_id_concesion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Empresa inexistente';
-- Resultado esperado: error por empresa inexistente
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion @p_id_concesion = 1, @p_id_empresa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente';
-- Resultado esperado: error por parque inexistente
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion @p_id_concesion = 1, @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Tipo de actividad vacio';
-- Resultado esperado: error por tipo de actividad vacio
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion @p_id_concesion = 1, @p_tipo_actividad = '   ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Pago mensual negativo';
-- Resultado esperado: error por pago mensual negativo
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion @p_id_concesion = 1, @p_pago_mensual = -500;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Fecha fin anterior a fecha inicio';
-- Resultado esperado: error porque fecha_fin debe ser posterior a fecha_inicio
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion @p_id_concesion = 1, @p_fecha_inicio = '2025-06-01', @p_fecha_fin = '2025-01-01';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Empresa inexistente + pago negativo + fecha invalida';
-- Resultado esperado: error por multiples validaciones fallidas simultaneamente
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarConcesion
        @p_id_concesion = 1,
        @p_id_empresa = 9999,
        @p_pago_mensual = -100,
        @p_fecha_inicio = '2025-06-01',
        @p_fecha_fin = '2025-01-01';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

/*
==============================================================
SP: concesiones.sp_ModificarEmpresa
==============================================================
*/

PRINT '================================================';
PRINT 'TEST: concesiones.sp_ModificarEmpresa';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/

PRINT '[EXITO] Modificar razon_social y contacto';
-- Resultado esperado: se actualizan razon_social y contacto de la empresa 1.
-- Requiere: empresa insertada en TEST 13.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_empresa, razon_social, cuit, contacto
    FROM concesiones.Empresa WHERE id_empresa = 1;

    EXEC concesiones.sp_ModificarEmpresa
        @p_id_empresa = 1,
        @p_razon_social = 'Moztaza',
        @p_contacto = 'mostaza@gmail.com';

    -- Verificar resultado de la operacion
    SELECT id_empresa, razon_social, cuit, contacto
    FROM concesiones.Empresa WHERE id_empresa = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
------------------------------------------------------
*/
PRINT '[FALLA] ID de empresa inexistente';
-- Resultado esperado: error por ID de empresa inexistente
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa @p_id_empresa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Razon social vacia';
-- Resultado esperado: error por razon social vacia
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa @p_id_empresa = 1, @p_razon_social = '   ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] CUIT con letras';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa @p_id_empresa = 1, @p_cuit = '2034ABC4567';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] CUIT con menos de 11 digitos';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa @p_id_empresa = 1, @p_cuit = '12345';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] CUIT duplicado en otra empresa';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa @p_id_empresa = 1, @p_cuit = '30698765432';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Contacto vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa @p_id_empresa = 1, @p_contacto = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Razon social vacia + CUIT invalido + contacto vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarEmpresa
        @p_id_empresa = 1,
        @p_razon_social = '   ',
        @p_cuit = '123',
        @p_contacto = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

/*
==============================================================
SP: concesiones.sp_ModificarPagoConcesion
==============================================================
*/
PRINT '================================================';
PRINT 'TEST: concesiones.sp_ModificarPagoConcesion';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar monto y fecha_pago';
-- Resultado esperado: se actualizan monto y fecha_pago del pago de concesion 1.
-- Requiere: pago insertado en TEST 15.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_pago, id_empresa, id_concesion, fecha_pago, monto
    FROM concesiones.PagoConcesion WHERE id_pago = 1;

    EXEC concesiones.sp_ModificarPagoConcesion
        @p_id_pago = 1,
        @p_monto = 12000.00,
        @p_fecha_pago = '2025-07-01';

    -- Verificar resultado de la operacion
    SELECT id_pago, id_empresa, id_concesion, fecha_pago, monto
    FROM concesiones.PagoConcesion WHERE id_pago = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
------------------------------------------------------
*/
PRINT '[FALLA] ID de pago inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarPagoConcesion @p_id_pago = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Empresa inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarPagoConcesion @p_id_pago = 1, @p_id_empresa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Concesion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarPagoConcesion @p_id_pago = 1, @p_id_concesion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Monto cero';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarPagoConcesion @p_id_pago = 1, @p_monto = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Empresa inexistente + monto negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_ModificarPagoConcesion @p_id_pago = 1, @p_id_empresa = 9999, @p_monto = -500;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de parques
-- =====================================================================

/*
==============================================================
SP: parques.sp_ModificarParque
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: parques.sp_ModificarParque';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar nombre y superficie';
-- Resultado esperado: se actualizan nombre y superficie del parque 1.
-- Requiere: parque insertado en TEST 1.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_parque, nombre, ubicacion, superficie, tipo, latitud, longitud
    FROM parques.Parque WHERE id_parque = 1;

    EXEC parques.sp_ModificarParque
        @p_id_parque = 1,
        @p_nombre = 'Ecoparque',
        @p_superficie = 67620.00;

    -- Verificar resultado de la operacion
    SELECT id_parque, nombre, ubicacion, superficie, tipo, latitud, longitud
    FROM parques.Parque WHERE id_parque = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
------------------------------------------------------
*/
PRINT '[FALLA] ID de parque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarParque @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarParque @p_id_parque = 1, @p_nombre = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Ubicacion vacia';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarParque @p_id_parque = 1, @p_ubicacion = '   ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Superficie negativa';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarParque @p_id_parque = 1, @p_superficie = -100;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Tipo vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarParque @p_id_parque = 1, @p_tipo = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio + superficie negativa + tipo vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarParque
        @p_id_parque = 1,
        @p_nombre = '',
        @p_superficie = -50,
        @p_tipo = '  ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de tipos de visitante
-- =====================================================================

/*
==============================================================
SP: parques.sp_ModificarTipoVisitante
=============================================================
*/

PRINT '================================================';
PRINT 'TEST: parques.sp_ModificarTipoVisitante';
PRINT '================================================';

/*
-------------------------------------------------------
SIN TEST EXITOSO
-------------------------------------------------------

La columna descripcion posee una restriccion UNIQUE y
representa datos estaticos del sistema (residente,
extranjero, estudiante, jubilado, menor). Por decision
de diseno, no se permite su modificacion para preservar
la integridad. Solo se prueban validaciones fallidas.

-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/

PRINT '[FALLA] ID de tipo inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarTipoVisitante @p_id_tipo = 9999, @p_descripcion = 'Estudiante';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Descripcion no permitida';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarTipoVisitante @p_id_tipo = 1, @p_descripcion = 'VIP';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de precios de entrada
-- =====================================================================

/*
==============================================================
SP: parques.sp_ModificarPrecioEntrada
=============================================================
*/

PRINT '================================================';
PRINT 'TEST: parques.sp_ModificarPrecioEntrada';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar precio';
-- Resultado esperado: se actualiza el precio de la entrada 1.
-- Requiere: precio insertado en TEST 3.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_precio, id_parque, id_tipo, precio, vigencia_desde
    FROM parques.PrecioEntrada WHERE id_precio = 1;

    EXEC parques.sp_ModificarPrecioEntrada @p_id_precio = 1, @p_precio = 2500.00;

    -- Verificar resultado de la operacion
    SELECT id_precio, id_parque, id_tipo, precio, vigencia_desde
    FROM parques.PrecioEntrada WHERE id_precio = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/

PRINT '[FALLA] ID de precio inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarPrecioEntrada @p_id_precio = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarPrecioEntrada @p_id_precio = 1, @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Tipo de visitante inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarPrecioEntrada @p_id_precio = 1, @p_id_tipo = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Precio negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarPrecioEntrada @p_id_precio = 1, @p_precio = -100;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Combinacion parque+tipo+vigencia duplicada';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarPrecioEntrada @p_id_precio = 1, @p_vigencia_desde = '2025-01-01';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente + tipo inexistente + precio negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_ModificarPrecioEntrada
        @p_id_precio = 1,
        @p_id_parque = 9999,
        @p_id_tipo = 9999,
        @p_precio = -50;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de asignaciones de guardaparques
-- =====================================================================

/*
==============================================================
SP: personal.sp_ModificarAsignacionParque
=============================================================
*/

PRINT '================================================';
PRINT 'TEST: personal.sp_ModificarAsignacionParque';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/

PRINT '[EXITO] Modificar fecha_hasta y motivo_egreso';
-- Resultado esperado: se cierra la asignacion del guardaparque 1 con fecha de egreso.
-- Requiere: asignacion insertada en TEST 17.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_asignacion, id_guardaParque, id_parque, fecha_desde, fecha_hasta, motivo_egreso
    FROM personal.AsignacionParque WHERE id_asignacion = 1;

    EXEC personal.sp_ModificarAsignacionParque
        @p_id_asignacion = 1,
        @p_fecha_hasta = '2026-12-31',
        @p_motivo_egreso = 'Traslado a otra sede';

    -- Verificar resultado de la operacion
    SELECT id_asignacion, id_guardaParque, id_parque, fecha_desde, fecha_hasta, motivo_egreso
    FROM personal.AsignacionParque WHERE id_asignacion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de asignacion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarAsignacionParque @p_id_asignacion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Guardaparque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarAsignacionParque @p_id_asignacion = 1, @p_id_guardaparque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarAsignacionParque @p_id_asignacion = 1, @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Fecha hasta anterior a fecha desde';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarAsignacionParque
        @p_id_asignacion = 1,
        @p_fecha_desde = '2025-06-01',
        @p_fecha_hasta = '2025-01-01';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Guardaparque inexistente + parque inexistente + fechas invalidas';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarAsignacionParque
        @p_id_asignacion = 1,
        @p_id_guardaparque = 9999,
        @p_id_parque = 9999,
        @p_fecha_desde = '2025-06-01',
        @p_fecha_hasta = '2025-01-01';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de guardaparques
-- =====================================================================

/*
==============================================================
SP: personal.sp_ModificarGuardaparque
=============================================================
*/

PRINT '================================================';
PRINT 'TEST: personal.sp_ModificarGuardaparque';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/

PRINT '[EXITO] Modificar nombre y apellido';
-- Resultado esperado: se actualizan nombre y apellido del guardaparque 1.
-- Requiere: guardaparque insertado en TEST 16.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_guardaParque, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni
    FROM personal.Guardaparque WHERE id_guardaParque = 1;

    EXEC personal.sp_ModificarGuardaparque
        @p_id_guardaparque = 1,
        @p_nombre = 'Carlos',
        @p_apellido = 'Gomez';

    -- Verificar resultado de la operacion
    SELECT id_guardaParque, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni
    FROM personal.Guardaparque WHERE id_guardaParque = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de guardaparque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarGuardaparque @p_id_guardaparque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarGuardaparque @p_id_guardaparque = 1, @p_nombre = '  ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Apellido vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarGuardaparque @p_id_guardaparque = 1, @p_apellido = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] DNI fuera de rango';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarGuardaparque @p_id_guardaparque = 1, @p_dni = 999999999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] DNI duplicado';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarGuardaparque @p_id_guardaparque = 1, @p_dni = 33987654;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio + apellido vacio + DNI invalido';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_ModificarGuardaparque
        @p_id_guardaparque = 1,
        @p_nombre = '',
        @p_apellido = '',
        @p_dni = -1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de atracciones
-- =====================================================================

/*
==============================================================
SP: actividades.sp_ModificarAtraccion
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_ModificarAtraccion';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/

PRINT '[EXITO] Modificar nombre, tipo, costo y cupo_maximo';
-- Resultado esperado: se actualizan nombre, tipo, costo y cupo_maximo de la atraccion 1.
-- Requiere: atraccion insertada en TEST 11.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_atraccion, id_parque, nombre, tipo, duracion, cupo_maximo
    FROM actividades.Atraccion WHERE id_atraccion = 1;

    EXEC actividades.sp_ModificarAtraccion
        @p_id_atraccion = 1,
        @p_nombre = 'Monumento',
        @p_tipo = 'Paga',
        @p_costo = 340000,
        @p_cupo_maximo = 30;

    -- Verificar resultado de la operacion
    SELECT id_atraccion, id_parque, nombre, tipo, costo, duracion, cupo_maximo
    FROM actividades.Atraccion WHERE id_atraccion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de atraccion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_nombre = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Tipo no permitido';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_tipo = 'Extrema';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Costo negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_costo = -200;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Duracion cero';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_duracion = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Cupo maximo negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_cupo_maximo = -5;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[EXITO] Cambiar horario_inicio';
-- Resultado esperado: se actualiza el horario_inicio de la atraccion 1.
-- Requiere: atraccion insertada en TEST 11.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_atraccion, nombre, horario_inicio FROM actividades.Atraccion WHERE id_atraccion = 1;

    EXEC actividades.sp_ModificarAtraccion @p_id_atraccion = 1, @p_horario_inicio = '10:00';

    -- Verificar resultado de la operacion
    SELECT id_atraccion, nombre, horario_inicio FROM actividades.Atraccion WHERE id_atraccion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente + tipo invalido + costo negativo + cupo negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarAtraccion
        @p_id_atraccion = 1,
        @p_id_parque = 9999,
        @p_tipo = 'Extrema',
        @p_costo = -100,
        @p_cupo_maximo = -10;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de guias
-- =====================================================================

/*
==============================================================
SP: actividades.sp_ModificarGuia
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_ModificarGuia';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar especialidad y titulo';
-- Resultado esperado: se actualizan especialidad, titulo y vigencia_autorizacion del guia 1.
-- Requiere: guia insertado en TEST 9.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_guia, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni, especialidad, titulo, vigencia_autorizacion
    FROM actividades.Guia WHERE id_guia = 1;

    EXEC actividades.sp_ModificarGuia
        @p_id_guia = 1,
        @p_nombre = 'Luis',
        @p_apellido = 'Alvarez',
        @p_especialidad = 'Historia',
        @p_titulo = 'Licenciado en Historia',
        @p_vigencia_autorizacion = '2020-05-15';

    -- Verificar resultado de la operacion
    SELECT id_guia, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni, especialidad, titulo, vigencia_autorizacion
    FROM actividades.Guia WHERE id_guia = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de guia inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarGuia @p_id_guia = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarGuia @p_id_guia = 1, @p_nombre = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Apellido vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarGuia @p_id_guia = 1, @p_apellido = '  ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] DNI fuera de rango';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarGuia @p_id_guia = 1, @p_dni = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] DNI duplicado';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarGuia @p_id_guia = 1, @p_dni = 28765432;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio + apellido vacio + DNI invalido';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarGuia
        @p_id_guia  = 1,
        @p_nombre = '',
        @p_apellido = '',
        @p_dni = -5;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de habilitaciones de guia
-- =====================================================================

/*
==============================================================
SP: actividades.sp_ModificarHabilitacionGuia
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_ModificarHabilitacionGuia';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar descripcion y fecha_vencimiento';
-- Resultado esperado: se actualizan descripcion y fecha_vencimiento de la habilitacion 1.
-- Requiere: habilitacion insertada en TEST 10.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_habilitacion, id_guia, descripcion, fecha_vencimiento
    FROM actividades.HabilitacionGuia WHERE id_habilitacion = 1;

    EXEC actividades.sp_ModificarHabilitacionGuia
        @p_id_habilitacion = 1,
        @p_descripcion = 'Habilitacion Senderismo Nivel 5',
        @p_fecha_vencimiento = '2027-12-31';

    -- Verificar resultado de la operacion
    SELECT id_habilitacion, id_guia, descripcion, fecha_vencimiento
    FROM actividades.HabilitacionGuia WHERE id_habilitacion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de habilitacion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarHabilitacionGuia @p_id_habilitacion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Guia inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarHabilitacionGuia @p_id_habilitacion = 1, @p_id_guia = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Descripcion vacia';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarHabilitacionGuia @p_id_habilitacion = 1, @p_descripcion = '  ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Guia inexistente + descripcion vacia';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarHabilitacionGuia
        @p_id_habilitacion = 1,
        @p_id_guia = 9999,
        @p_descripcion = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de tours guiados
-- =====================================================================

/*
==============================================================
SP: actividades.sp_ModificarTourGuia
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_ModificarTourGuia';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar fecha del tour';
-- Resultado esperado: se actualiza la fecha del tour-guia 1.
-- Requiere: tour-guia insertado en TEST 12.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_tour_guia, id_guia, id_atraccion, fecha
    FROM actividades.TourGuia WHERE id_tour_guia = 1;

    EXEC actividades.sp_ModificarTourGuia
        @p_id_tour_guia = 1,
        @p_fecha = '2026-07-15';

    -- Verificar resultado de la operacion
    SELECT id_tour_guia, id_guia, id_atraccion, fecha
    FROM actividades.TourGuia WHERE id_tour_guia = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de tour-guia inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarTourGuia @p_id_tour_guia = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Guia inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarTourGuia @p_id_tour_guia = 1, @p_id_guia = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Atraccion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarTourGuia @p_id_tour_guia = 1, @p_id_atraccion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Guia + atraccion inexistentes';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_ModificarTourGuia
        @p_id_tour_guia = 1,
        @p_id_guia = 9999,
        @p_id_atraccion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de tickets
-- =====================================================================

/*
==============================================================
SP: ventas.sp_ModificarTicket
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_ModificarTicket';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar forma_pago y total_pagado';
-- Resultado esperado: se actualizan forma_pago y total_pagado del ticket 1.
-- Requiere: ticket insertado en TEST 6.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_ticket, id_parque, fecha, fecha_acceso, forma_pago, total_pagado
    FROM ventas.Ticket WHERE id_ticket = 1;

    EXEC ventas.sp_ModificarTicket
        @p_id_ticket    = 1,
        @p_forma_pago   = 'Transferencia',
        @p_total_pagado = 3500.00;

    -- Verificar resultado de la operacion
    SELECT id_ticket, id_parque, fecha, fecha_acceso, forma_pago, total_pagado
    FROM ventas.Ticket WHERE id_ticket = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de ticket inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTicket @p_id_ticket = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTicket @p_id_ticket = 1, @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Forma de pago invalida';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTicket @p_id_ticket = 1, @p_forma_pago = 'Criptomoneda';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Total pagado negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTicket @p_id_ticket = 1, @p_total_pagado = -100;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Fecha acceso anterior a fecha emision';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTicket
        @p_id_ticket = 1,
        @p_fecha = '2025-06-01',
        @p_fecha_acceso = '2025-01-01';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Parque inexistente + forma pago invalida + total negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTicket
        @p_id_ticket = 1,
        @p_id_parque = 9999,
        @p_forma_pago = 'Bitcoin',
        @p_total_pagado = -50;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de items de ticket
-- =====================================================================

/*
==============================================================
SP: ventas.sp_ModificarItemTicket
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_ModificarItemTicket';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar precio_venta y cantidad';
-- Resultado esperado: se actualizan precio_venta y cantidad del item 1.
-- Requiere: item insertado en TEST 7.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_item, id_ticket, id_precio_entrada, id_atraccion, precio_venta, cantidad
    FROM ventas.ItemTicket WHERE id_item = 1;

    EXEC ventas.sp_ModificarItemTicket
        @p_id_item = 1,
        @p_precio_venta = 2000.00,
        @p_cantidad = 2;

    -- Verificar resultado de la operacion
    SELECT id_item, id_ticket, id_precio_entrada, id_atraccion, precio_venta, cantidad
    FROM ventas.ItemTicket WHERE id_item = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de item inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket @p_id_item = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Ticket inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket @p_id_item = 1, @p_id_ticket = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Precio de entrada inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket @p_id_item = 1, @p_id_precio_entrada = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Atraccion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket @p_id_item = 1, @p_id_atraccion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Precio de venta negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket @p_id_item = 1, @p_precio_venta = -300;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Cantidad cero';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket @p_id_item = 1, @p_cantidad = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Ticket inexistente + atraccion inexistente + precio negativo + cantidad cero';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarItemTicket
        @p_id_item = 1,
        @p_id_ticket = 9999,
        @p_id_atraccion = 9999,
        @p_precio_venta = -100,
        @p_cantidad = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de tasas de cambio
-- =====================================================================

/*
==============================================================
SP: ventas.sp_ModificarTasaCambio
=============================================================
*/

PRINT '================================================';
PRINT 'TEST: ventas.sp_ModificarTasaCambio';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar tasa_a_peso';
-- Resultado esperado: se actualiza la tasa_a_peso de la tasa de cambio 1.
-- Requiere: tasa de cambio insertada en TEST 5.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_tasa, id_moneda, fecha_vigencia, tasa_a_peso
    FROM ventas.TasaCambio WHERE id_tasa = 1;

    EXEC ventas.sp_ModificarTasaCambio @p_id_tasa = 1, @p_tasa_a_peso = 950.5000;

    -- Verificar resultado de la operacion
    SELECT id_tasa, id_moneda, fecha_vigencia, tasa_a_peso
    FROM ventas.TasaCambio WHERE id_tasa = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de tasa inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTasaCambio @p_id_tasa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Moneda inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTasaCambio @p_id_tasa = 1, @p_id_moneda = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Tasa cero';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTasaCambio @p_id_tasa = 1, @p_tasa_a_peso = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Moneda inexistente + tasa negativa';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarTasaCambio @p_id_tasa = 1, @p_id_moneda = 9999, @p_tasa_a_peso = -10;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de monedas
-- =====================================================================

/*
==============================================================
SP: ventas.sp_ModificarMoneda
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_ModificarMoneda';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar nombre y simbolo';
-- Resultado esperado: se actualizan nombre y simbolo de la moneda 1.
-- Requiere: moneda insertada en TEST 4.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_moneda, codigo_iso, nombre, simbolo
    FROM ventas.Moneda WHERE id_moneda = 1;

    EXEC ventas.sp_ModificarMoneda
        @p_id_moneda = 1,
        @p_nombre = 'Dolar Blue',
        @p_simbolo = 'U$S';

    -- Verificar resultado de la operacion
    SELECT id_moneda, codigo_iso, nombre, simbolo
    FROM ventas.Moneda WHERE id_moneda = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de moneda inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarMoneda @p_id_moneda = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Codigo ISO con menos de 3 caracteres';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarMoneda @p_id_moneda = 1, @p_codigo_iso = 'US';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Codigo ISO duplicado';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarMoneda @p_id_moneda = 1, @p_codigo_iso = 'EUR';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Nombre vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarMoneda @p_id_moneda = 1, @p_nombre = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Simbolo vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarMoneda @p_id_moneda = 1, @p_simbolo = '  ';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Codigo ISO invalido + nombre vacio + simbolo vacio';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarMoneda
        @p_id_moneda = 1,
        @p_codigo_iso = 'AB',
        @p_nombre = '',
        @p_simbolo = '';
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de modificacion de pagos en moneda extranjera
-- =====================================================================

/*
==============================================================
SP: ventas.sp_ModificarPagoMonedaExtranjera
=============================================================
*/

PRINT '================================================';
PRINT 'TEST: ventas.sp_ModificarPagoMonedaExtranjera';
PRINT '================================================';

/*
-------------------------------------------------------
TEST EXITOSO
-------------------------------------------------------
*/
PRINT '[EXITO] Modificar monto_extranjero y monto_pesos';
-- Resultado esperado: se actualizan monto_extranjero y monto_pesos del pago 1.
-- Requiere: pago insertado en TEST 8.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_pago_ext, id_ticket, id_tasa, monto_extranjero, monto_pesos
    FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = 1;

    EXEC ventas.sp_ModificarPagoMonedaExtranjera
        @p_id_pago_ext = 1,
        @p_monto_extranjero = 100.00,
        @p_monto_pesos = 142500.00;

    -- Verificar resultado de la operacion
    SELECT id_pago_ext, id_ticket, id_tasa, monto_extranjero, monto_pesos
    FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

/*
-------------------------------------------------------
TESTS DE VALIDACIONES FALLIDAS
-------------------------------------------------------
*/
PRINT '[FALLA] ID de pago inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarPagoMonedaExtranjera @p_id_pago_ext = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Ticket inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarPagoMonedaExtranjera @p_id_pago_ext = 1, @p_id_ticket = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Tasa de cambio inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarPagoMonedaExtranjera @p_id_pago_ext = 1, @p_id_tasa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Monto extranjero cero';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarPagoMonedaExtranjera @p_id_pago_ext = 1, @p_monto_extranjero = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Monto pesos negativo';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarPagoMonedaExtranjera @p_id_pago_ext = 1, @p_monto_pesos = -1000;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] Ticket inexistente + tasa inexistente + montos invalidos';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_ModificarPagoMonedaExtranjera
        @p_id_pago_ext = 1,
        @p_id_ticket = 9999,
        @p_id_tasa = 9999,
        @p_monto_extranjero = -50,
        @p_monto_pesos = 0;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO


/*
===============================================================
            INICIO - PRUEBAS DE BORRADO
===============================================================
*/

-- =====================================================================
-- Pruebas de borrado de parques
-- =====================================================================

/*
==============================================================
SP: parques.sp_BorrarParque
   Dependencias: Ticket, PrecioEntrada, Atraccion,
                 AsignacionParque, Concesion
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: parques.sp_BorrarParque';
PRINT '================================================';

PRINT '[EXITO] Eliminar parque sin dependencias';
-- Resultado esperado: se elimina el parque insertado para el test y la consulta posterior retorna 0 filas.
-- Requiere: crea datos temporales para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO parques.Parque (nombre, ubicacion, superficie, tipo, latitud, longitud)
    VALUES ('Parque Test', 'Test', 1.00, 'Parque Nacional', 0, 0);
    DECLARE @id_parque_test INT = SCOPE_IDENTITY();
    SELECT id_parque, nombre, latitud, longitud FROM parques.Parque WHERE id_parque = @id_parque_test;

    EXEC parques.sp_BorrarParque @p_id_parque = @id_parque_test;

    -- Debe devolver 0 filas
    SELECT id_parque, nombre, latitud, longitud FROM parques.Parque WHERE id_parque = @id_parque_test;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Bloqueo por dependencias';
-- Resultado esperado: se rechaza el borrado porque el parque tiene precios, atracciones, etc. asociados.
-- Requiere: parque 1 con precios, atracciones, asignaciones y concesiones insertados en seccion de insercion
SELECT id_parque, nombre, latitud, longitud FROM parques.Parque WHERE id_parque = 1;

-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_BorrarParque @p_id_parque = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de parque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_BorrarParque @p_id_parque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de tipos de visitante
-- =====================================================================

/*
==============================================================
SP: parques.sp_BorrarTipoVisitante
   Dependencias: PrecioEntrada
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: parques.sp_BorrarTipoVisitante';
PRINT '================================================';

-- No hay '[EXITO] Eliminar tipo de visitante sin dependencias' porque no hay
-- descripción genérica que se pueda agregar y borrar por constraint.

PRINT '[COMPORTAMIENTO] Bloqueo por precios de entrada existentes';
-- Resultado esperado: se rechaza el borrado porque el tipo tiene precios de entrada asociados.
-- Requiere: tipo de visitante 1 con precios de entrada insertados en TEST 3.1
SELECT id_tipo, descripcion FROM parques.TipoVisitante WHERE id_tipo = 1;
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_BorrarTipoVisitante @p_id_tipo = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de tipo inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_BorrarTipoVisitante @p_id_tipo = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de precios de entrada
-- =====================================================================

/*
==============================================================
SP: parques.sp_BorrarPrecioEntrada
   Dependencias: ItemTicket
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: parques.sp_BorrarPrecioEntrada';
PRINT '================================================';

PRINT '[EXITO] Eliminar precio de entrada';
-- Resultado esperado: se elimina el precio de entrada 3 y la consulta posterior retorna 0 filas.
-- Requiere: precio de entrada insertado en TEST 3.3 (menores, precio gratuito)
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_precio, id_parque, precio, vigencia_desde
    FROM parques.PrecioEntrada WHERE id_precio = 3;

    EXEC parques.sp_BorrarPrecioEntrada @p_id_precio = 3;

    -- Debe devolver 0 filas
    SELECT id_precio, id_parque, precio, vigencia_desde
    FROM parques.PrecioEntrada WHERE id_precio = 3;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de precio inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC parques.sp_BorrarPrecioEntrada @p_id_precio = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de monedas
-- =====================================================================

/*
==============================================================
SP: ventas.sp_BorrarMoneda
   Dependencias: TasaCambio
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_BorrarMoneda';
PRINT '================================================';

PRINT '[EXITO] Eliminar moneda sin dependencias';
-- Resultado esperado: se elimina la moneda insertada (GBP) y la consulta posterior retorna 0 filas.
-- Requiere: crea moneda temporal GBP para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO ventas.Moneda (codigo_iso, nombre, simbolo) VALUES ('GBP', 'Libra Esterlina', '£');
    DECLARE @id_moneda_test INT = SCOPE_IDENTITY();
    SELECT id_moneda, codigo_iso, nombre FROM ventas.Moneda WHERE id_moneda = @id_moneda_test;

    EXEC ventas.sp_BorrarMoneda @p_id_moneda = @id_moneda_test;

    -- Debe devolver 0 filas
    SELECT id_moneda, codigo_iso, nombre FROM ventas.Moneda WHERE id_moneda = @id_moneda_test;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Bloqueo por tasas de cambio existentes';
-- Resultado esperado: se rechaza el borrado porque la moneda tiene tasas de cambio asociadas.
-- Requiere: moneda 1 (USD) con tasas de cambio insertadas en TEST 5.1
SELECT id_moneda, codigo_iso, nombre FROM ventas.Moneda WHERE id_moneda = 1;
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_BorrarMoneda @p_id_moneda = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de moneda inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_BorrarMoneda @p_id_moneda = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de tasas de cambio
-- =====================================================================

/*
==============================================================
SP: ventas.sp_BorrarTasaCambio
   Dependencias: PagoMonedaExtranjera
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_BorrarTasaCambio';
PRINT '================================================';

PRINT '[EXITO] Eliminar tasa de cambio';
-- Resultado esperado: se elimina la tasa de cambio 2 y la consulta posterior retorna 0 filas.
-- Requiere: tasa de cambio insertada en TEST 5.2 (EUR)
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_tasa, id_moneda, tasa_a_peso
    FROM ventas.TasaCambio WHERE id_tasa = 2;

    EXEC ventas.sp_BorrarTasaCambio @p_id_tasa = 2;

    -- Debe devolver 0 filas
    SELECT id_tasa, id_moneda, tasa_a_peso
    FROM ventas.TasaCambio WHERE id_tasa = 2;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de tasa inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_BorrarTasaCambio @p_id_tasa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de tickets
-- =====================================================================

/*
==============================================================
SP: ventas.sp_BorrarTicket
   Dependencias: ItemTicket, PagoMonedaExtranjera (se eliminan en cascada)
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_BorrarTicket';
PRINT '================================================';

PRINT '[EXITO] Eliminar ticket sin dependencias';
-- Resultado esperado: se inserta un ticket temporal, se elimina, y la consulta posterior retorna 0 filas.
-- Requiere: crea ticket y parque temporales para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO parques.Parque (nombre, ubicacion, superficie, tipo, latitud, longitud)
    VALUES ('Parque Test', 'Test', 1.00, 'Parque Nacional', 0, 0);
    DECLARE @id_parque_t INT = SCOPE_IDENTITY();
    INSERT INTO ventas.Ticket (id_parque, fecha, fecha_acceso, punto_de_venta, numero_comprobante, forma_pago, total_pagado)
    VALUES (@id_parque_t, '2025-06-01', '2025-06-15', 999, 999, 'Efectivo', 100);
    DECLARE @id_ticket_test INT = SCOPE_IDENTITY();
    SELECT id_ticket, id_parque, fecha, total_pagado FROM ventas.Ticket WHERE id_ticket = @id_ticket_test;

    EXEC ventas.sp_BorrarTicket @p_id_ticket = @id_ticket_test;

    -- Debe devolver 0 filas
    SELECT id_ticket, id_parque, fecha, total_pagado FROM ventas.Ticket WHERE id_ticket = @id_ticket_test;

    EXEC parques.sp_BorrarParque @p_id_parque = @id_parque_t;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Cascada: elimina items de ticket y pagos asociados';
-- Resultado esperado: se elimina el ticket 1 y sus items y pagos en moneda extranjera se eliminan en cascada.
-- Requiere: ticket 1 con items insertados en TEST 7.1 y 7.2
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_ticket, id_parque, fecha, total_pagado
    FROM ventas.Ticket WHERE id_ticket = 1;

    EXEC ventas.sp_BorrarTicket @p_id_ticket = 1;

    SELECT id_ticket, id_parque, fecha, total_pagado
    FROM ventas.Ticket WHERE id_ticket = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de ticket inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_BorrarTicket @p_id_ticket = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de items de ticket
-- =====================================================================

/*
==============================================================
SP: ventas.sp_BorrarItemTicket
   Sin dependencias adicionales.
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_BorrarItemTicket';
PRINT '================================================';

PRINT '[EXITO] Eliminar item de ticket';
-- Resultado esperado: se elimina el item de ticket 2 y la consulta posterior retorna 0 filas.
-- Requiere: item insertado en TEST 7.2
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_item, id_ticket, precio_venta, cantidad
    FROM ventas.ItemTicket WHERE id_item = 2;

    EXEC ventas.sp_BorrarItemTicket @p_id_item = 2;

    -- Debe devolver 0 filas
    SELECT id_item, id_ticket, precio_venta, cantidad
    FROM ventas.ItemTicket WHERE id_item = 2;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de item inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_BorrarItemTicket @p_id_item = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de pagos en moneda extranjera
-- =====================================================================

/*
==============================================================
SP: ventas.sp_BorrarPagoMonedaExtranjera
   Sin dependencias adicionales.
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: ventas.sp_BorrarPagoMonedaExtranjera';
PRINT '================================================';

PRINT '[EXITO] Eliminar pago en moneda extranjera';
-- Resultado esperado: se elimina el pago en moneda extranjera 1 y la consulta posterior retorna 0 filas.
-- Requiere: pago insertado en TEST 8.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_pago_ext, id_ticket, monto_extranjero, monto_pesos
    FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = 1;

    EXEC ventas.sp_BorrarPagoMonedaExtranjera @p_id_pago_ext = 1;

    -- Debe devolver 0 filas
    SELECT id_pago_ext, id_ticket, monto_extranjero, monto_pesos
    FROM ventas.PagoMonedaExtranjera WHERE id_pago_ext = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de pago inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC ventas.sp_BorrarPagoMonedaExtranjera @p_id_pago_ext = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de guias
-- =====================================================================

/*
==============================================================
SP: actividades.sp_BorrarGuia
   Dependencias: HabilitacionGuia, TourGuia
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_BorrarGuia';
PRINT '================================================';

PRINT '[EXITO] Eliminar guia sin dependencias';
-- Resultado esperado: se inserta un guia temporal, se elimina, y la consulta posterior retorna 0 filas.
-- Requiere: crea guia temporal para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO actividades.Guia (nombre, apellido, dni_cifrado, vigencia_autorizacion)
    VALUES ('Test', 'Guia', seguridad.Cifrar(87654321), '2026-12-31');
    DECLARE @id_guia_test INT = SCOPE_IDENTITY();
    SELECT id_guia, nombre, apellido FROM actividades.Guia WHERE id_guia = @id_guia_test;

    EXEC actividades.sp_BorrarGuia @p_id_guia = @id_guia_test;

    -- Debe devolver 0 filas
    SELECT id_guia, nombre, apellido FROM actividades.Guia WHERE id_guia = @id_guia_test;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Bloqueo por habilitaciones o tours asociados';
-- Resultado esperado: se rechaza el borrado porque el guia tiene habilitaciones o tours asignados.
-- Requiere: guia 1 con habilitaciones insertadas en TEST 10.1 y tours en TEST 12.1
SELECT id_guia, nombre, apellido FROM actividades.Guia WHERE id_guia = 1;
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_BorrarGuia @p_id_guia = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de guia inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_BorrarGuia @p_id_guia = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de habilitaciones de guia
-- =====================================================================

/*
==============================================================
SP: actividades.sp_BorrarHabilitacionGuia
   Sin dependencias adicionales.
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_BorrarHabilitacionGuia';
PRINT '================================================';

PRINT '[EXITO] Eliminar habilitacion de guia';
-- Resultado esperado: se elimina la habilitacion 1 y la consulta posterior retorna 0 filas.
-- Requiere: habilitacion insertada en TEST 10.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_habilitacion, id_guia, descripcion, fecha_vencimiento
    FROM actividades.HabilitacionGuia WHERE id_habilitacion = 1;

    EXEC actividades.sp_BorrarHabilitacionGuia @p_id_habilitacion = 1;

    -- Debe devolver 0 filas
    SELECT id_habilitacion, id_guia, descripcion, fecha_vencimiento
    FROM actividades.HabilitacionGuia WHERE id_habilitacion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de habilitacion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_BorrarHabilitacionGuia @p_id_habilitacion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de atracciones
-- =====================================================================

/*
==============================================================
SP: actividades.sp_BorrarAtraccion
   Dependencias: TourGuia, ItemTicket (se eliminan en cascada)
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_BorrarAtraccion';
PRINT '================================================';

PRINT '[EXITO] Eliminar atraccion sin dependencias';
-- Resultado esperado: se inserta una atraccion temporal, se elimina, y la consulta posterior retorna 0 filas.
-- Requiere: crea parque y atraccion temporales para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO parques.Parque (nombre, ubicacion, superficie, tipo, latitud, longitud)
    VALUES ('Parque Test', 'Test', 1.00, 'Parque Nacional', 0, 0);
    DECLARE @id_parque_a INT = SCOPE_IDENTITY();
    INSERT INTO actividades.Atraccion (id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo_maximo)
    VALUES (@id_parque_a, 'Atraccion Test', 'Gratuita', 0, 30, '10:00', 50);
    DECLARE @id_atraccion_test INT = SCOPE_IDENTITY();
    SELECT id_atraccion, nombre, tipo FROM actividades.Atraccion WHERE id_atraccion = @id_atraccion_test;

    EXEC actividades.sp_BorrarAtraccion @p_id_atraccion = @id_atraccion_test;

    -- Debe devolver 0 filas
    SELECT id_atraccion, nombre, tipo FROM actividades.Atraccion WHERE id_atraccion = @id_atraccion_test;

    EXEC parques.sp_BorrarParque @p_id_parque = @id_parque_a;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Cascada: elimina tours e items de ticket asociados';
-- Resultado esperado: se elimina la atraccion 1 y sus tour-guias e items de ticket se eliminan en cascada.
-- Requiere: atraccion 1 con tours insertados en TEST 12.1 y items en TEST 7.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_atraccion, nombre, tipo FROM actividades.Atraccion WHERE id_atraccion = 1;

    EXEC actividades.sp_BorrarAtraccion @p_id_atraccion = 1;

    SELECT id_atraccion, nombre, tipo FROM actividades.Atraccion WHERE id_atraccion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de atraccion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_BorrarAtraccion @p_id_atraccion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de tours guiados
-- =====================================================================

/*
==============================================================
SP: actividades.sp_BorrarTourGuia
   Sin dependencias adicionales.
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: actividades.sp_BorrarTourGuia';
PRINT '================================================';

PRINT '[EXITO] Eliminar asignacion de tour-guia';
-- Resultado esperado: se elimina la asignacion de tour-guia 1 y la consulta posterior retorna 0 filas.
-- Requiere: tour-guia insertado en TEST 12.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_tour_guia, id_guia, id_atraccion, fecha
    FROM actividades.TourGuia WHERE id_tour_guia = 1;

    EXEC actividades.sp_BorrarTourGuia @p_id_tour_guia = 1;

    -- Debe devolver 0 filas
    SELECT id_tour_guia, id_guia, id_atraccion, fecha
    FROM actividades.TourGuia WHERE id_tour_guia = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de tour-guia inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC actividades.sp_BorrarTourGuia @p_id_tour_guia = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de empresas
-- =====================================================================

/*
==============================================================
SP: concesiones.sp_BorrarEmpresa
   Dependencias: Concesion, PagoConcesion
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: concesiones.sp_BorrarEmpresa';
PRINT '================================================';

PRINT '[EXITO] Eliminar empresa sin dependencias';
-- Resultado esperado: se inserta una empresa temporal, se elimina, y la consulta posterior retorna 0 filas.
-- Requiere: crea empresa temporal para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO concesiones.Empresa (razon_social, cuit) VALUES ('Test SA', '12345678901');
    DECLARE @id_empresa_test INT = SCOPE_IDENTITY();
    SELECT id_empresa, razon_social, cuit FROM concesiones.Empresa WHERE id_empresa = @id_empresa_test;

    EXEC concesiones.sp_BorrarEmpresa @p_id_empresa = @id_empresa_test;

    -- Debe devolver 0 filas
    SELECT id_empresa, razon_social, cuit FROM concesiones.Empresa WHERE id_empresa = @id_empresa_test;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Bloqueo por concesiones asociadas';
-- Resultado esperado: se rechaza el borrado porque la empresa tiene concesiones asociadas.
-- Requiere: empresa 1 con concesiones insertadas en TEST 14.1
SELECT id_empresa, razon_social, cuit
FROM concesiones.Empresa WHERE id_empresa = 1;
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_BorrarEmpresa @p_id_empresa = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de empresa inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_BorrarEmpresa @p_id_empresa = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de concesiones
-- =====================================================================

/*
==============================================================
SP: concesiones.sp_BorrarConcesion
   Dependencias: PagoConcesion
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: concesiones.sp_BorrarConcesion';
PRINT '================================================';

PRINT '[EXITO] Eliminar concesion sin dependencias';
-- Resultado esperado: se inserta una concesion temporal, se elimina, y la consulta posterior retorna 0 filas.
-- Requiere: crea parque, empresa y concesion temporales para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO parques.Parque (nombre, ubicacion, superficie, tipo, latitud, longitud)
    VALUES ('Parque Test', 'Test', 1.00, 'Parque Nacional', 0, 0);
    DECLARE @id_parque_c INT = SCOPE_IDENTITY();
    INSERT INTO concesiones.Empresa (razon_social, cuit) VALUES ('Test SA', '10987654321');
    DECLARE @id_empresa_c INT = SCOPE_IDENTITY();
    INSERT INTO concesiones.Concesion (id_empresa, id_parque, tipo_actividad, fecha_inicio, fecha_fin, pago_mensual)
    VALUES (@id_empresa_c, @id_parque_c, 'Restaurante', '2025-01-01', '2025-12-31', 5000);
    DECLARE @id_concesion_test INT = SCOPE_IDENTITY();
    SELECT id_concesion, id_empresa, tipo_actividad, pago_mensual
    FROM concesiones.Concesion WHERE id_concesion = @id_concesion_test;

    EXEC concesiones.sp_BorrarConcesion @p_id_concesion = @id_concesion_test;

    -- Debe devolver 0 filas
    SELECT id_concesion, id_empresa, tipo_actividad, pago_mensual
    FROM concesiones.Concesion WHERE id_concesion = @id_concesion_test;

    EXEC concesiones.sp_BorrarEmpresa @p_id_empresa = @id_empresa_c;
    EXEC parques.sp_BorrarParque @p_id_parque = @id_parque_c;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Bloqueo por pagos asociados';
-- Resultado esperado: se rechaza el borrado porque la concesion tiene pagos asociados.
-- Requiere: concesion 1 con pagos insertados en TEST 15.1
SELECT id_concesion, id_empresa, tipo_actividad, pago_mensual
FROM concesiones.Concesion WHERE id_concesion = 1;
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_BorrarConcesion @p_id_concesion = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de concesion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_BorrarConcesion @p_id_concesion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de pagos de concesion
-- =====================================================================

/*
==============================================================
SP: concesiones.sp_BorrarPagoConcesion
   Sin dependencias adicionales.
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: concesiones.sp_BorrarPagoConcesion';
PRINT '================================================';

PRINT '[EXITO] Eliminar pago de concesion';
-- Resultado esperado: se elimina el pago de concesion 1 y la consulta posterior retorna 0 filas.
-- Requiere: pago insertado en TEST 15.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_pago, id_concesion, monto, fecha_pago
    FROM concesiones.PagoConcesion WHERE id_pago = 1;

    EXEC concesiones.sp_BorrarPagoConcesion @p_id_pago = 1;

    -- Debe devolver 0 filas
    SELECT id_pago, id_concesion, monto, fecha_pago
    FROM concesiones.PagoConcesion WHERE id_pago = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de pago inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC concesiones.sp_BorrarPagoConcesion @p_id_pago = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de guardaparques
-- =====================================================================

/*
==============================================================
SP: personal.sp_BorrarGuardaparque
   Dependencias: AsignacionParque
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: personal.sp_BorrarGuardaparque';
PRINT '================================================';

PRINT '[EXITO] Eliminar guardaparque sin dependencias';
-- Resultado esperado: se inserta un guardaparque temporal, se elimina, y la consulta posterior retorna 0 filas.
-- Requiere: crea guardaparque temporal para la prueba
-- Capturar errores de SQL Server
BEGIN TRY
    INSERT INTO personal.Guardaparque (nombre, apellido, dni_cifrado)
    VALUES ('Test', 'Guardaparque', seguridad.Cifrar(12345678));
    DECLARE @id_guardaparque_test INT = SCOPE_IDENTITY();
    SELECT id_guardaparque, nombre, apellido FROM personal.Guardaparque WHERE id_guardaparque = @id_guardaparque_test;

    EXEC personal.sp_BorrarGuardaparque @p_id_guardaparque = @id_guardaparque_test;

    -- Debe devolver 0 filas
    SELECT id_guardaparque, nombre, apellido FROM personal.Guardaparque WHERE id_guardaparque = @id_guardaparque_test;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[COMPORTAMIENTO] Bloqueo por asignaciones a parques';
-- Resultado esperado: se rechaza el borrado porque el guardaparque tiene asignaciones activas.
-- Requiere: guardaparque 1 con asignaciones insertadas en TEST 17.1
SELECT id_guardaparque, nombre, apellido, CAST(seguridad.Descifrar(dni_cifrado) AS INT) AS dni
FROM personal.Guardaparque WHERE id_guardaparque = 1;
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_BorrarGuardaparque @p_id_guardaparque = 1;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '[FALLA] ID de guardaparque inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_BorrarGuardaparque @p_id_guardaparque = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

-- =====================================================================
-- Pruebas de borrado de asignaciones de guardaparques
-- =====================================================================

/*
==============================================================
SP: personal.sp_BorrarAsignacionParque
   Sin dependencias adicionales.
=============================================================
*/
PRINT '================================================';
PRINT 'TEST: personal.sp_BorrarAsignacionParque';
PRINT '================================================';

PRINT '[EXITO] Eliminar asignacion de parque';
-- Resultado esperado: se elimina la asignacion de parque 1 y la consulta posterior retorna 0 filas.
-- Requiere: asignacion insertada en TEST 17.1
-- Capturar errores de SQL Server
BEGIN TRY
    SELECT id_asignacion, id_guardaParque, id_parque, fecha_desde, fecha_hasta
    FROM personal.AsignacionParque WHERE id_asignacion = 1;

    EXEC personal.sp_BorrarAsignacionParque @p_id_asignacion = 1;

    -- Debe devolver 0 filas
    SELECT id_asignacion, id_guardaParque, id_parque, fecha_desde, fecha_hasta
    FROM personal.AsignacionParque WHERE id_asignacion = 1;
    UPDATE #Resultados SET ok = ok + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  [ERROR] (inesperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET fail = fail + 1;
END CATCH
GO

PRINT '[FALLA] ID de asignacion inexistente';
-- Capturar errores de SQL Server
BEGIN TRY
    EXEC personal.sp_BorrarAsignacionParque @p_id_asignacion = 9999;
    PRINT '  [FALLA] No se lanzó el error esperado.';
    UPDATE #Resultados SET fail = fail + 1;
END TRY
BEGIN CATCH
-- Obtener mensaje de error del sistema
    PRINT '  Error capturado (esperado): ' + ERROR_MESSAGE();
    UPDATE #Resultados SET ok = ok + 1;
END CATCH
GO

PRINT '';
PRINT '==========================================================';
PRINT ' RESUMEN DE PRUEBAS ABM';
PRINT '==========================================================';
DECLARE @v_ok INT, @v_fail INT;
SELECT @v_ok = ok, @v_fail = fail FROM #Resultados;
PRINT '  Pruebas exitosas: ' + CAST(@v_ok AS VARCHAR(10));
PRINT '  Pruebas fallidas: ' + CAST(@v_fail AS VARCHAR(10));
PRINT '  Total: ' + CAST(@v_ok + @v_fail AS VARCHAR(10));
PRINT '==========================================================';
DROP TABLE #Resultados;
GO

PRINT '============================================';
PRINT ' 11_PruebasABM.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
