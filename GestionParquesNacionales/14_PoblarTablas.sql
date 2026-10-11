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

   Archivo:     14_PoblarTablas.sql
   Descripcion: Script de carga de datos de semilla (seed data) para la base
                ParquesNacionales.
===============================================================================
*/

USE ParquesNacionales;
GO

EXEC dbo.sp_VaciarTablas;
GO

-- ================================================================
-- BLOQUE 1: PARQUES (10+)
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 1: parques.sp_InsertarParque (10+ parques) ---';
GO

-- Datos de semilla: parques nacionales reales de Argentina
EXEC parques.sp_InsertarParque @p_nombre = 'Nahuel Huapi',           @p_ubicacion = 'Neuquen / Rio Negro',   @p_superficie = 717261.00, @p_tipo = 'Parque Nacional',   @p_latitud = -41.000000, @p_longitud = -71.500000;
EXEC parques.sp_InsertarParque @p_nombre = 'Los Alerces',            @p_ubicacion = 'Chubut',                 @p_superficie = 263000.00, @p_tipo = 'Reserva Nacional', @p_latitud = -42.800000, @p_longitud = -71.900000;
EXEC parques.sp_InsertarParque @p_nombre = 'Bosques Petrificados',   @p_ubicacion = 'Santa Cruz',            @p_superficie = 150000.00, @p_tipo = 'Monumento Natural', @p_latitud = -47.650000, @p_longitud = -68.100000;
EXEC parques.sp_InsertarParque @p_nombre = 'Iguazu',                 @p_ubicacion = 'Misiones',               @p_superficie = 67720.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -25.600000, @p_longitud = -54.300000;
EXEC parques.sp_InsertarParque @p_nombre = 'Talampaya',              @p_ubicacion = 'La Rioja',               @p_superficie = 215000.00, @p_tipo = 'Parque Nacional',  @p_latitud = -29.800000, @p_longitud = -67.800000;
EXEC parques.sp_InsertarParque @p_nombre = 'Perito Moreno',          @p_ubicacion = 'Santa Cruz',            @p_superficie = 126830.00, @p_tipo = 'Parque Nacional',  @p_latitud = -46.500000, @p_longitud = -70.500000;
EXEC parques.sp_InsertarParque @p_nombre = 'Los Cardones',           @p_ubicacion = 'Salta',                  @p_superficie = 65000.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -25.200000, @p_longitud = -66.000000;
EXEC parques.sp_InsertarParque @p_nombre = 'Quebrada del Condorito', @p_ubicacion = 'Cordoba',                @p_superficie = 37000.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -31.600000, @p_longitud = -64.700000;
EXEC parques.sp_InsertarParque @p_nombre = 'Pre-Delta',              @p_ubicacion = 'Entre Rios',             @p_superficie = 25000.00,  @p_tipo = 'Reserva Nacional', @p_latitud = -32.000000, @p_longitud = -60.600000;
EXEC parques.sp_InsertarParque @p_nombre = 'El Leoncito',            @p_ubicacion = 'San Juan',               @p_superficie = 76000.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -31.800000, @p_longitud = -69.400000;
EXEC parques.sp_InsertarParque @p_nombre = 'Sierra de las Quijadas', @p_ubicacion = 'San Luis',               @p_superficie = 150000.00, @p_tipo = 'Parque Nacional',  @p_latitud = -32.500000, @p_longitud = -67.000000;
EXEC parques.sp_InsertarParque @p_nombre = 'Campo de los Alisos',    @p_ubicacion = 'Tucuman',                @p_superficie = 27000.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -27.000000, @p_longitud = -65.800000;

-- Parques extra para cubrir el requerimiento de 10+ mas alla de los importados
EXEC parques.sp_InsertarParque @p_nombre = 'Tierra del Fuego',       @p_ubicacion = 'Tierra del Fuego',       @p_superficie = 63000.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -54.800000, @p_longitud = -68.300000;
EXEC parques.sp_InsertarParque @p_nombre = 'Lanin',                  @p_ubicacion = 'Neuquen',                @p_superficie = 412000.00, @p_tipo = 'Parque Nacional',  @p_latitud = -39.600000, @p_longitud = -71.500000;
EXEC parques.sp_InsertarParque @p_nombre = 'Lago Puelo',            @p_ubicacion = 'Chubut',                 @p_superficie = 27600.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -42.100000, @p_longitud = -71.600000;
EXEC parques.sp_InsertarParque @p_nombre = 'Los Glaciares',          @p_ubicacion = 'Santa Cruz',            @p_superficie = 726927.00, @p_tipo = 'Parque Nacional',  @p_latitud = -50.000000, @p_longitud = -73.000000;
EXEC parques.sp_InsertarParque @p_nombre = 'Rio Pilcomayo',          @p_ubicacion = 'Formosa',                @p_superficie = 50912.00,  @p_tipo = 'Reserva Nacional', @p_latitud = -25.050000, @p_longitud = -57.950000;
EXEC parques.sp_InsertarParque @p_nombre = 'Copo',                   @p_ubicacion = 'Santiago del Estero',    @p_superficie = 118124.00, @p_tipo = 'Parque Nacional',  @p_latitud = -25.900000, @p_longitud = -62.000000;
EXEC parques.sp_InsertarParque @p_nombre = 'El Palmar',             @p_ubicacion = 'Entre Rios',             @p_superficie = 8500.00,   @p_tipo = 'Parque Nacional',  @p_latitud = -31.850000, @p_longitud = -58.300000;
EXEC parques.sp_InsertarParque @p_nombre = 'San Guillermo',          @p_ubicacion = 'San Juan',               @p_superficie = 166000.00, @p_tipo = 'Parque Nacional',  @p_latitud = -29.300000, @p_longitud = -69.500000;
EXEC parques.sp_InsertarParque @p_nombre = 'Islas de Santa Fe',      @p_ubicacion = 'Santa Fe',               @p_superficie = 4100.00,   @p_tipo = 'Reserva Nacional', @p_latitud = -32.200000, @p_longitud = -60.700000;
EXEC parques.sp_InsertarParque @p_nombre = 'Calilegua',              @p_ubicacion = 'Jujuy',                  @p_superficie = 76306.00,  @p_tipo = 'Parque Nacional',  @p_latitud = -23.750000, @p_longitud = -64.850000;
GO

PRINT '[OK] 22 parques insertados correctamente.';
GO

-- ================================================================
-- BLOQUE 2: TIPOS DE VISITANTE
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 2: sp_InsertarTipoVisitante ---';
GO

EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Residente';
EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Extranjero';
EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Estudiante';
EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Jubilado';
EXEC parques.sp_InsertarTipoVisitante @p_descripcion = 'Menor';
GO

PRINT '[OK] 5 tipos de visitante insertados.';
GO

-- ================================================================
-- BLOQUE 3: PRECIOS DE ENTRADA (todos los parques x todos los tipos)
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 3: sp_InsertarPrecioEntrada ---';
PRINT 'Insertando precios vigentes desde 2025-01-01 para cada parque y tipo.';
GO

DECLARE @pid INT = 1, @precio_ent DECIMAL(10,2);
WHILE @pid <= 22
BEGIN
    SET @precio_ent = 2500.00 + (@pid * 100);
    EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = @pid, @p_id_tipo = 1, @p_precio = @precio_ent, @p_vigencia_desde = '2025-01-01';
    SET @precio_ent = 8000.00 + (@pid * 200);
    EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = @pid, @p_id_tipo = 2, @p_precio = @precio_ent, @p_vigencia_desde = '2025-01-01';
    SET @precio_ent = 1200.00 + (@pid * 50);
    EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = @pid, @p_id_tipo = 3, @p_precio = @precio_ent, @p_vigencia_desde = '2025-01-01';
    SET @precio_ent = 1500.00 + (@pid * 50);
    EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = @pid, @p_id_tipo = 4, @p_precio = @precio_ent, @p_vigencia_desde = '2025-01-01';
    SET @precio_ent = 0.00;
    EXEC parques.sp_InsertarPrecioEntrada @p_id_parque = @pid, @p_id_tipo = 5, @p_precio = @precio_ent, @p_vigencia_desde = '2025-01-01';
    SET @pid = @pid + 1;
END
GO

PRINT '[OK] Precios insertados para 22 parques x 5 tipos.';
GO

-- ================================================================
-- BLOQUE 4: MONEDAS Y TASAS DE CAMBIO
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 4: Monedas y tasas de cambio ---';
GO

EXEC ventas.sp_InsertarMoneda @p_codigo_iso = 'USD', @p_nombre = 'Dolar Estadounidense', @p_simbolo = 'U$S';
EXEC ventas.sp_InsertarMoneda @p_codigo_iso = 'EUR', @p_nombre = 'Euro',                 @p_simbolo = NULL;
EXEC ventas.sp_InsertarMoneda @p_codigo_iso = 'BRL', @p_nombre = 'Real Brasileño',       @p_simbolo = 'R$';
EXEC ventas.sp_InsertarMoneda @p_codigo_iso = 'CLP', @p_nombre = 'Peso Chileno',          @p_simbolo = NULL;
EXEC ventas.sp_InsertarMoneda @p_codigo_iso = 'UYU', @p_nombre = 'Peso Uruguayo',         @p_simbolo = NULL;
GO

DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 1, @p_fecha_vigencia = '2025-01-01', @p_tasa_a_peso = 1080.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 2, @p_fecha_vigencia = '2025-01-01', @p_tasa_a_peso = 1180.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 3, @p_fecha_vigencia = '2025-01-01', @p_tasa_a_peso = 195.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 4, @p_fecha_vigencia = '2025-01-01', @p_tasa_a_peso = 1.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 5, @p_fecha_vigencia = '2025-01-01', @p_tasa_a_peso = 25.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 1, @p_fecha_vigencia = @hoy,          @p_tasa_a_peso = 1250.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 2, @p_fecha_vigencia = @hoy,          @p_tasa_a_peso = 1350.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 3, @p_fecha_vigencia = @hoy,          @p_tasa_a_peso = 210.00;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 4, @p_fecha_vigencia = @hoy,          @p_tasa_a_peso = 1.15;
EXEC ventas.sp_InsertarTasaCambio @p_id_moneda = 5, @p_fecha_vigencia = @hoy,          @p_tasa_a_peso = 28.00;
GO

PRINT '[OK] Monedas y tasas de cambio insertadas.';
GO

-- ================================================================
-- BLOQUE 5: GUIAS (20)
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 5: sp_InsertarGuia (20 guias) ---';
GO

EXEC actividades.sp_InsertarGuia @p_nombre = 'Carlos',   @p_apellido = 'Mendez',     @p_dni = 20123456, @p_especialidad = 'Trekking',        @p_titulo = 'Guia de Montana',        @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Maria',    @p_apellido = 'Lopez',      @p_dni = 21234567, @p_especialidad = 'Observacion aves', @p_titulo = 'Biologa',                @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Juan',     @p_apellido = 'Perez',      @p_dni = 22345678, @p_especialidad = 'Canotaje',        @p_titulo = 'Guia de Turismo Aventura',@p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Ana',      @p_apellido = 'Gimenez',    @p_dni = 23456789, @p_especialidad = 'Interpretacion',   @p_titulo = 'Lic. en Turismo',         @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Pedro',    @p_apellido = 'Ramirez',    @p_dni = 24567890, @p_especialidad = 'Buceo',           @p_titulo = 'Buzo Profesional',        @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Laura',    @p_apellido = 'Fernandez',  @p_dni = 25678901, @p_especialidad = 'Astroturismo',    @p_titulo = 'Astronoma',               @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Diego',    @p_apellido = 'Martinez',   @p_dni = 26789012, @p_especialidad = 'Pesca deportiva', @p_titulo = 'Guia de Pesca',           @p_vigencia_autorizacion = '2027-10-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Sofia',    @p_apellido = 'Castillo',   @p_dni = 27890123, @p_especialidad = 'Senderismo',      @p_titulo = 'Tec. en Turismo',          @p_vigencia_autorizacion = '2026-09-15';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Luis',     @p_apellido = 'Alvarez',    @p_dni = 28901234, @p_especialidad = 'Montanismo',      @p_titulo = 'Guia de Alta Montana',     @p_vigencia_autorizacion = '2028-03-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Carla',    @p_apellido = 'Ruiz',       @p_dni = 29012345, @p_especialidad = 'Flora nativa',     @p_titulo = 'Ing. Agronoma',            @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Martin',   @p_apellido = 'Diaz',       @p_dni = 30123456, @p_especialidad = 'Escalada',        @p_titulo = 'Instructor de Escalada',   @p_vigencia_autorizacion = '2027-11-30';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Valeria',  @p_apellido = 'Torres',     @p_dni = 31234567, @p_especialidad = 'Fotografia',      @p_titulo = 'Fotografa Profesional',    @p_vigencia_autorizacion = '2028-06-30';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Pablo',    @p_apellido = 'Acosta',     @p_dni = 32345678, @p_especialidad = 'Kayak',           @p_titulo = 'Guia Nautico',             @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Rocio',    @p_apellido = 'Molina',     @p_dni = 33456789, @p_especialidad = 'Avistamiento',    @p_titulo = 'Guardaparque',             @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Gustavo',  @p_apellido = 'Sosa',       @p_dni = 34567890, @p_especialidad = 'Espeleologia',    @p_titulo = 'Geologo',                  @p_vigencia_autorizacion = '2027-05-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Florencia',@p_apellido = 'Vega',       @p_dni = 35678901, @p_especialidad = 'Educacion ambiental',@p_titulo = 'Prof. Biologia',          @p_vigencia_autorizacion = '2028-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Hector',   @p_apellido = 'Rojas',      @p_dni = 36789012, @p_especialidad = 'Navegacion',      @p_titulo = 'Capitan de Yate',          @p_vigencia_autorizacion = '2027-09-30';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Patricia', @p_apellido = 'Campos',     @p_dni = 37890123, @p_especialidad = 'Historia natural', @p_titulo = 'Lic. en Historia',         @p_vigencia_autorizacion = '2027-12-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Alberto',  @p_apellido = 'Navarro',    @p_dni = 38901234, @p_especialidad = 'Ornitologia',     @p_titulo = 'Ornitologo',               @p_vigencia_autorizacion = '2027-08-31';
EXEC actividades.sp_InsertarGuia @p_nombre = 'Gabriela', @p_apellido = 'Moreno',     @p_dni = 39012345, @p_especialidad = 'Senderismo',      @p_titulo = 'Guia de Turismo',           @p_vigencia_autorizacion = '2028-10-31';
GO

-- Habilitaciones para los 20 guias
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 1,  @p_descripcion = 'Guia habilitado para trekking en montana',        @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 2,  @p_descripcion = 'Guia habilitado para observacion de aves',        @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 3,  @p_descripcion = 'Guia habilitado para canotaje en rios',           @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 4,  @p_descripcion = 'Guia habilitado para interpretacion patrimonial', @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 5,  @p_descripcion = 'Guia habilitado para buceo en lagos',             @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 6,  @p_descripcion = 'Guia habilitado para astroturismo',               @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 7,  @p_descripcion = 'Guia habilitado para pesca deportiva',            @p_fecha_vencimiento = '2027-10-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 8,  @p_descripcion = 'Guia habilitado para senderismo guiado',          @p_fecha_vencimiento = '2026-09-15';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 9,  @p_descripcion = 'Guia habilitado para montanismo',                 @p_fecha_vencimiento = '2028-03-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 10, @p_descripcion = 'Guia habilitado para recorridos de flora nativa', @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 11, @p_descripcion = 'Guia habilitado para escalada en roca',           @p_fecha_vencimiento = '2027-11-30';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 12, @p_descripcion = 'Guia habilitado para fotografia de naturaleza',   @p_fecha_vencimiento = '2028-06-30';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 13, @p_descripcion = 'Guia habilitado para kayak en lagos',             @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 14, @p_descripcion = 'Guia habilitado para avistamiento de fauna',      @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 15, @p_descripcion = 'Guia habilitado para espeleologia',               @p_fecha_vencimiento = '2027-05-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 16, @p_descripcion = 'Guia habilitado para educacion ambiental',        @p_fecha_vencimiento = '2028-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 17, @p_descripcion = 'Guia habilitado para navegacion en embarcaciones',@p_fecha_vencimiento = '2027-09-30';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 18, @p_descripcion = 'Guia habilitado para historia natural',           @p_fecha_vencimiento = '2027-12-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 19, @p_descripcion = 'Guia habilitado para ornitologia',                @p_fecha_vencimiento = '2027-08-31';
EXEC actividades.sp_InsertarHabilitacionGuia @p_id_guia = 20, @p_descripcion = 'Guia habilitado para senderismo interpretativo',  @p_fecha_vencimiento = '2028-10-31';
GO

PRINT '[OK] 20 guias insertados con sus habilitaciones.';
GO

-- ================================================================
-- BLOQUE 6: ATRACCIONES/ACTIVIDADES (30+)
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 6: sp_RegistrarActividad (30+ actividades/tours) ---';
GO

-- Parque 1: Nahuel Huapi (7 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Sendero Arrayanes',        @p_tipo = 'Gratuita',    @p_costo = 0,      @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 100;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Navegacion Lago Nahuel',   @p_tipo = 'Paga',       @p_costo = 5500,   @p_duracion = 120, @p_horario_inicio = '09:00', @p_cupo_maximo = 40;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Tour Isla Victoria',       @p_tipo = 'Tour Guiado',@p_costo = 8500,   @p_duracion = 240, @p_horario_inicio = '08:30', @p_cupo_maximo = 25;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Ascenso Cerro Campanario', @p_tipo = 'Tour Guiado',@p_costo = 3500,   @p_duracion = 300, @p_horario_inicio = '07:00', @p_cupo_maximo = 15;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Mirador Bahia Lopez',      @p_tipo = 'Gratuita',    @p_costo = 0,      @p_duracion = 60,  @p_horario_inicio = '10:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Buceo en Lago',            @p_tipo = 'Paga',       @p_costo = 12000,  @p_duracion = 90,  @p_horario_inicio = '09:00', @p_cupo_maximo = 8;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 1, @p_nombre = 'Cabalgata de Montana',     @p_tipo = 'Tour Guiado',@p_costo = 7000,   @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 20;

-- Parque 4: Iguazu (6 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 4, @p_nombre = 'Circuito Inferior',        @p_tipo = 'Gratuita',   @p_costo = 0,      @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 300;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 4, @p_nombre = 'Circuito Superior',        @p_tipo = 'Gratuita',   @p_costo = 0,      @p_duracion = 90,  @p_horario_inicio = '09:00', @p_cupo_maximo = 300;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 4, @p_nombre = 'Garganta del Diablo',      @p_tipo = 'Gratuita',   @p_costo = 0,      @p_duracion = 180, @p_horario_inicio = '10:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 4, @p_nombre = 'Paseo en Lancha',          @p_tipo = 'Paga',      @p_costo = 15000,  @p_duracion = 60,  @p_horario_inicio = '08:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 4, @p_nombre = 'Excursion Isla San Martin',@p_tipo = 'Tour Guiado',@p_costo = 6000,  @p_duracion = 240, @p_horario_inicio = '07:30', @p_cupo_maximo = 30;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 4, @p_nombre = 'Sendero Macuco',           @p_tipo = 'Tour Guiado',@p_costo = 4500,  @p_duracion = 150, @p_horario_inicio = '08:00', @p_cupo_maximo = 20;

-- Parque 5: Talampaya (5 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 5, @p_nombre = 'Canon de Talampaya',       @p_tipo = 'Tour Guiado',@p_costo = 4000,  @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 30;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 5, @p_nombre = 'Ciudad Perdida',           @p_tipo = 'Tour Guiado',@p_costo = 5000,  @p_duracion = 240, @p_horario_inicio = '09:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 5, @p_nombre = 'Petroglifos',              @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 60,  @p_horario_inicio = '10:00', @p_cupo_maximo = 100;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 5, @p_nombre = 'Avistamiento Flamenco',    @p_tipo = 'Paga',      @p_costo = 3000,  @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 25;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 5, @p_nombre = 'Caminata Nocturna',        @p_tipo = 'Tour Guiado',@p_costo = 3500,  @p_duracion = 150, @p_horario_inicio = '20:00', @p_cupo_maximo = 15;

-- Parque 2: Los Alerces (4 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 2, @p_nombre = 'Sendero Lago Verde',        @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 90,  @p_horario_inicio = '08:00', @p_cupo_maximo = 100;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 2, @p_nombre = 'Kayak Rio Arrayanes',       @p_tipo = 'Paga',      @p_costo = 8000,  @p_duracion = 180, @p_horario_inicio = '09:00', @p_cupo_maximo = 12;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 2, @p_nombre = 'Trekking Alerzal Milenario',@p_tipo = 'Tour Guiado',@p_costo = 6000,  @p_duracion = 360, @p_horario_inicio = '07:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 2, @p_nombre = 'Pesca Deportiva',           @p_tipo = 'Paga',      @p_costo = 9000,  @p_duracion = 240, @p_horario_inicio = '08:00', @p_cupo_maximo = 10;

-- Parque 6: Perito Moreno (3 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 6, @p_nombre = 'Pasarelas Glaciar',          @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 500;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 6, @p_nombre = 'Mini Trekking Glaciar',      @p_tipo = 'Tour Guiado',@p_costo = 25000, @p_duracion = 360, @p_horario_inicio = '09:00', @p_cupo_maximo = 15;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 6, @p_nombre = 'Navegacion Ramos Mexia',     @p_tipo = 'Paga',      @p_costo = 12000, @p_duracion = 120, @p_horario_inicio = '10:00', @p_cupo_maximo = 40;

-- Parque 7: Los Cardones (3 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 7, @p_nombre = 'Sendero Cardones',          @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 100;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 7, @p_nombre = 'Astroturismo Valle',        @p_tipo = 'Tour Guiado',@p_costo = 7000,  @p_duracion = 180, @p_horario_inicio = '21:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 7, @p_nombre = 'Cabalgata Cactus Gigantes', @p_tipo = 'Paga',      @p_costo = 6000,  @p_duracion = 150, @p_horario_inicio = '08:00', @p_cupo_maximo = 15;

-- Parque 8: Quebrada del Condorito (2 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 8, @p_nombre = 'Balcon del Condor',          @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 8, @p_nombre = 'Trekking Quebrada',          @p_tipo = 'Tour Guiado',@p_costo = 4000,  @p_duracion = 240, @p_horario_inicio = '09:00', @p_cupo_maximo = 25;

-- Parque 9: Pre-Delta (2 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 9, @p_nombre = 'Navegacion Rio Parana',      @p_tipo = 'Paga',      @p_costo = 5000,  @p_duracion = 120, @p_horario_inicio = '09:00', @p_cupo_maximo = 30;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 9, @p_nombre = 'Avistamiento Aves',          @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 90,  @p_horario_inicio = '08:00', @p_cupo_maximo = 50;

-- Parque 10: El Leoncito (2 actividades)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 10, @p_nombre = 'Observatorio El Leoncito',  @p_tipo = 'Tour Guiado',@p_costo = 8000, @p_duracion = 180, @p_horario_inicio = '10:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 10, @p_nombre = 'Cabalgata Cielo Abierto',   @p_tipo = 'Paga',      @p_costo = 5500,  @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 15;

GO

-- Actividades para parques 3, 11, 12 que no tenian (5 actividades extra)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 3, @p_nombre = 'Sendero Bosque Petrificado',  @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 120, @p_horario_inicio = '09:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 3, @p_nombre = 'Museo Paleontologico',        @p_tipo = 'Paga',      @p_costo = 2000,  @p_duracion = 90,  @p_horario_inicio = '10:00', @p_cupo_maximo = 50;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 11, @p_nombre = 'Sendero La Porcha',          @p_tipo = 'Tour Guiado',@p_costo = 3000, @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 11, @p_nombre = 'Mirador del Potrero',        @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 60,  @p_horario_inicio = '10:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 12, @p_nombre = 'Sendero Los Alisos',         @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 100;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 12, @p_nombre = 'Cascada del Rio',            @p_tipo = 'Paga',      @p_costo = 2000,  @p_duracion = 90,  @p_horario_inicio = '09:00', @p_cupo_maximo = 30;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 12, @p_nombre = 'Mirador del Valle',          @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 45,  @p_horario_inicio = '11:00', @p_cupo_maximo = 150;

-- Actividades para los 10 parques extra (parques 13 a 22)
EXEC actividades.sp_RegistrarActividad @p_id_parque = 13, @p_nombre = 'Sendero Costero',            @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 120, @p_horario_inicio = '09:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 14, @p_nombre = 'Ascenso Volcan Lanin',       @p_tipo = 'Tour Guiado',@p_costo = 8000, @p_duracion = 480, @p_horario_inicio = '05:00', @p_cupo_maximo = 10;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 15, @p_nombre = 'Navegacion Lago Puelo',      @p_tipo = 'Paga',      @p_costo = 5000,  @p_duracion = 120, @p_horario_inicio = '10:00', @p_cupo_maximo = 30;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 16, @p_nombre = 'Pasarelas Perito Moreno',    @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 500;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 16, @p_nombre = 'Trekking Glaciar Upsala',    @p_tipo = 'Tour Guiado',@p_costo = 30000,@p_duracion = 360, @p_horario_inicio = '07:00', @p_cupo_maximo = 12;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 17, @p_nombre = 'Laguna Blanca',              @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 90,  @p_horario_inicio = '08:00', @p_cupo_maximo = 200;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 18, @p_nombre = 'Sendero del Monte',          @p_tipo = 'Tour Guiado',@p_costo = 2500, @p_duracion = 150, @p_horario_inicio = '08:00', @p_cupo_maximo = 20;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 19, @p_nombre = 'Palmar Historico',           @p_tipo = 'Gratuita',   @p_costo = 0,     @p_duracion = 90,  @p_horario_inicio = '09:00', @p_cupo_maximo = 300;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 20, @p_nombre = 'Avistamiento Guanacos',      @p_tipo = 'Paga',      @p_costo = 3500,  @p_duracion = 120, @p_horario_inicio = '08:00', @p_cupo_maximo = 25;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 21, @p_nombre = 'Navegacion Rio Coronda',     @p_tipo = 'Paga',      @p_costo = 4000,  @p_duracion = 150, @p_horario_inicio = '09:00', @p_cupo_maximo = 30;
EXEC actividades.sp_RegistrarActividad @p_id_parque = 22, @p_nombre = 'Sendero de la Selva',        @p_tipo = 'Tour Guiado',@p_costo = 3500, @p_duracion = 180, @p_horario_inicio = '08:00', @p_cupo_maximo = 20;
GO

PRINT '[OK] 47 actividades/tours insertadas (34 originales + 13 extra para nuevos parques).';
GO

-- ================================================================
-- BLOQUE 7: ASIGNACION DE GUIAS A TOURS
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 7: sp_AsignarGuia (asignar guias a tours) ---';
GO

DECLARE @fecha_asignacion DATE = '2026-07-20';

-- Tour: Tour Isla Victoria (id_atraccion=3) en Nahuel Huapi con guia Carlos (1)
EXEC actividades.sp_AsignarGuia @p_id_guia = 1,  @p_id_atraccion = 3,  @p_fecha = @fecha_asignacion;
-- Tour: Ascenso Cerro Campanario (id_atraccion=4) en Nahuel Huapi con guia Luis (9)
EXEC actividades.sp_AsignarGuia @p_id_guia = 9,  @p_id_atraccion = 4,  @p_fecha = @fecha_asignacion;
-- Tour: Excursion Isla San Martin (id_atraccion=12) en Iguazu con guia Ana (4)
EXEC actividades.sp_AsignarGuia @p_id_guia = 4,  @p_id_atraccion = 12, @p_fecha = @fecha_asignacion;
-- Tour: Canon Talampaya (id_atraccion=14) con guia Pedro (5)
EXEC actividades.sp_AsignarGuia @p_id_guia = 5,  @p_id_atraccion = 14, @p_fecha = @fecha_asignacion;
-- Tour: Trekking Alerzal Milenario (id_atraccion=21) con guia Maria (2)
EXEC actividades.sp_AsignarGuia @p_id_guia = 2,  @p_id_atraccion = 21, @p_fecha = @fecha_asignacion;
-- Tour: Mini Trekking Glaciar (id_atraccion=24) con guia Valeria (12)
EXEC actividades.sp_AsignarGuia @p_id_guia = 12, @p_id_atraccion = 24, @p_fecha = @fecha_asignacion;
-- Tour: Astroturismo Valle (id_atraccion=27) con guia Laura (6)
EXEC actividades.sp_AsignarGuia @p_id_guia = 6,  @p_id_atraccion = 27, @p_fecha = @fecha_asignacion;
-- Tour: Caminata Nocturna (id_atraccion=18) con guia Carla (10)
EXEC actividades.sp_AsignarGuia @p_id_guia = 10, @p_id_atraccion = 18, @p_fecha = @fecha_asignacion;
-- Tour: Observatorio El Leoncito (id_atraccion=33) con guia Martin (11)
EXEC actividades.sp_AsignarGuia @p_id_guia = 11, @p_id_atraccion = 33, @p_fecha = @fecha_asignacion;
-- Tour: Cabalgata de Montana (id_atraccion=7) con guia Juan (3)
EXEC actividades.sp_AsignarGuia @p_id_guia = 3,  @p_id_atraccion = 7,  @p_fecha = @fecha_asignacion;
GO

PRINT '[OK] 10 asignaciones guia-tour insertadas.';
GO

-- ================================================================
-- BLOQUE 8: GUARDAPARQUES (20) Y ASIGNACIONES
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 8: Guardaparques y asignaciones ---';
GO

EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Ricardo', @p_apellido = 'Gutierrez', @p_dni = 40123456;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Silvia',  @p_apellido = 'Mendoza',   @p_dni = 41234567;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Oscar',   @p_apellido = 'Pereyra',   @p_dni = 42345678;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Liliana', @p_apellido = 'Acosta',    @p_dni = 43456789;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Hernan',  @p_apellido = 'Silva',     @p_dni = 44567890;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Graciela',@p_apellido = 'Luna',      @p_dni = 45678901;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Fabian',  @p_apellido = 'Roldan',    @p_dni = 46789012;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Claudia', @p_apellido = 'Barrios',   @p_dni = 47890123;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Marcelo', @p_apellido = 'Figueroa',  @p_dni = 48901234;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Andrea',  @p_apellido = 'Paez',      @p_dni = 49012345;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Esteban', @p_apellido = 'Coronel',   @p_dni = 50123456;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Veronica',@p_apellido = 'Aguirre',   @p_dni = 51234567;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Raul',    @p_apellido = 'Bustos',    @p_dni = 52345678;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Monica',  @p_apellido = 'Cardenas',  @p_dni = 53456789;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Alfredo', @p_apellido = 'Mansilla',  @p_dni = 54567890;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Patricia',@p_apellido = 'Quiroga',   @p_dni = 55678901;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Gustavo', @p_apellido = 'Nunez',     @p_dni = 56789012;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Rosa',    @p_apellido = 'Medina',    @p_dni = 57890123;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Sergio',  @p_apellido = 'Villalba',  @p_dni = 58901234;
EXEC personal.sp_InsertarGuardaparque @p_nombre = 'Laura',   @p_apellido = 'Duarte',    @p_dni = 59012345;
GO

PRINT '[OK] 20 guardaparques insertados.';
GO

-- Asignaciones
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 1,  @p_id_parque = 1,  @p_fecha_desde = '2020-03-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 2,  @p_id_parque = 4,  @p_fecha_desde = '2021-06-15';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 3,  @p_id_parque = 5,  @p_fecha_desde = '2019-11-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 4,  @p_id_parque = 2,  @p_fecha_desde = '2022-01-10';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 5,  @p_id_parque = 6,  @p_fecha_desde = '2020-08-20';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 6,  @p_id_parque = 7,  @p_fecha_desde = '2023-02-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 7,  @p_id_parque = 8,  @p_fecha_desde = '2022-09-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 8,  @p_id_parque = 10, @p_fecha_desde = '2021-04-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 9,  @p_id_parque = 11, @p_fecha_desde = '2023-07-15';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 10, @p_id_parque = 12, @p_fecha_desde = '2024-01-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 11, @p_id_parque = 1,  @p_fecha_desde = '2023-05-01', @p_fecha_hasta = '2024-12-31', @p_motivo_egreso = 'Traslado';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 11, @p_id_parque = 4,  @p_fecha_desde = '2025-01-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 12, @p_id_parque = 9,  @p_fecha_desde = '2022-06-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 13, @p_id_parque = 3,  @p_fecha_desde = '2020-10-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 14, @p_id_parque = 1,  @p_fecha_desde = '2024-03-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 15, @p_id_parque = 4,  @p_fecha_desde = '2023-11-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 16, @p_id_parque = 5,  @p_fecha_desde = '2022-08-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 17, @p_id_parque = 6,  @p_fecha_desde = '2021-12-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 18, @p_id_parque = 7,  @p_fecha_desde = '2024-07-01';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 19, @p_id_parque = 8,  @p_fecha_desde = '2020-05-01', @p_fecha_hasta = '2024-06-30', @p_motivo_egreso = 'Jubilacion';
EXEC personal.sp_InsertarAsignacionParque @p_id_guardaparque = 20, @p_id_parque = 2,  @p_fecha_desde = '2024-09-01';
GO

PRINT '[OK] 21 asignaciones de guardaparques insertadas (guardaparque 11 tiene traslado).';
GO

-- ================================================================
-- BLOQUE 9: EMPRESAS Y CONCESIONES
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 9: Empresas y concesiones (10+ concesiones) ---';
GO

-- Empresas
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Gastronomia Patagonica SRL',   @p_cuit = '30111111111', @p_contacto = 'contacto@gastropat.com';
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Turismo Aventura SA',           @p_cuit = '30222222222', @p_contacto = 'info@turismaventura.com';
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Recuerdos del Parque SH',        @p_cuit = '30333333333', @p_contacto = 'ventas@recuerdosparque.com';
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Excursiones Norte Grande SA',    @p_cuit = '30444444444', @p_contacto = 'info@excursionesng.com';
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Servicios Australes SRL',        @p_cuit = '30555555555', @p_contacto = 'admin@servaustral.com';
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Helados y Postres del Parque',   @p_cuit = '30666666666', @p_contacto = NULL;
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Transporte Ecologico Argentino', @p_cuit = '30777777777', @p_contacto = 'reservas@tea.com.ar';
EXEC concesiones.sp_InsertarEmpresa @p_razon_social = 'Camping y Cabanas del Bosque',   @p_cuit = '30888888888', @p_contacto = 'camping@delbosque.com';
GO

-- Concesiones (10+)
-- Concesion 1: Restaurante en Nahuel Huapi - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 1, @p_id_parque = 1, @p_tipo_actividad = 'Restaurante', @p_fecha_inicio = '2024-01-01', @p_fecha_fin = '2027-12-31', @p_pago_mensual = 150000.00;
-- Concesion 2: Tienda de recuerdos en Nahuel Huapi - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 3, @p_id_parque = 1, @p_tipo_actividad = 'Tienda',       @p_fecha_inicio = '2024-06-01', @p_fecha_fin = '2027-06-01', @p_pago_mensual = 80000.00;
-- Concesion 3: Empresa de turismo aventura en Nahuel Huapi - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 2, @p_id_parque = 1, @p_tipo_actividad = 'Turismo aventura', @p_fecha_inicio = '2025-01-01', @p_fecha_fin = '2028-01-01', @p_pago_mensual = 200000.00;
-- Concesion 4: Restaurante en Iguazu - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 1, @p_id_parque = 4, @p_tipo_actividad = 'Restaurante', @p_fecha_inicio = '2024-03-01', @p_fecha_fin = '2026-12-31', @p_pago_mensual = 250000.00;
-- Concesion 5: Tienda en Iguazu - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 3, @p_id_parque = 4, @p_tipo_actividad = 'Tienda',       @p_fecha_inicio = '2025-02-01', @p_fecha_fin = '2028-02-01', @p_pago_mensual = 120000.00;
-- Concesion 6: Empresa de excursiones en Iguazu - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 4, @p_id_parque = 4, @p_tipo_actividad = 'Excursiones',  @p_fecha_inicio = '2024-01-01', @p_fecha_fin = '2027-06-30', @p_pago_mensual = 300000.00;
-- Concesion 7: Restaurante en Talampaya - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 1, @p_id_parque = 5, @p_tipo_actividad = 'Restaurante',  @p_fecha_inicio = '2025-03-01', @p_fecha_fin = '2028-03-01', @p_pago_mensual = 90000.00;
-- Concesion 8: Transporte en Los Alerces - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 7, @p_id_parque = 2, @p_tipo_actividad = 'Transporte',   @p_fecha_inicio = '2024-07-01', @p_fecha_fin = '2027-07-01', @p_pago_mensual = 110000.00;
-- Concesion 9: Camping en Los Alerces - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 8, @p_id_parque = 2, @p_tipo_actividad = 'Camping',      @p_fecha_inicio = '2024-11-01', @p_fecha_fin = '2027-11-01', @p_pago_mensual = 75000.00;
-- Concesion 10: Heladeria en Iguazu - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 6, @p_id_parque = 4, @p_tipo_actividad = 'Comida rapida',@p_fecha_inicio = '2025-06-01', @p_fecha_fin = '2027-06-01', @p_pago_mensual = 50000.00;
-- Concesion 11: Turismo aventura en Perito Moreno - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 2, @p_id_parque = 6, @p_tipo_actividad = 'Turismo aventura', @p_fecha_inicio = '2025-01-01', @p_fecha_fin = '2028-01-01', @p_pago_mensual = 180000.00;
-- Concesion 12: Excursiones en Talampaya - VIGENTE
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 4, @p_id_parque = 5, @p_tipo_actividad = 'Excursiones',  @p_fecha_inicio = '2024-09-01', @p_fecha_fin = '2026-09-01', @p_pago_mensual = 130000.00;
-- Concesion 13: Servicios australes en Perito Moreno - VENCIDA
EXEC concesiones.sp_InsertarConcesion @p_id_empresa = 5, @p_id_parque = 6, @p_tipo_actividad = 'Servicios generales', @p_fecha_inicio = '2022-01-01', @p_fecha_fin = '2024-12-31', @p_pago_mensual = 60000.00;
GO

PRINT '[OK] 13 concesiones insertadas.';
GO

-- ================================================================
-- BLOQUE 10: PAGOS DE CONCESIONES
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 10: sp_InsertarPagoConcesion (pagos parciales) ---';
GO

DECLARE @hoy DATE = '2026-07-15';

-- Concesion 1: Restaurante Nahuel Huapi -> AL DIA
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 1, 1, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 150000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-01-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

DECLARE @hoy DATE = '2026-07-15';

-- Concesion 4: Restaurante Iguazu -> AL DIA
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 1, 4, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 250000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-03-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24),(25),(26)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

DECLARE @hoy DATE = '2026-07-15';

-- Concesion 6: Excursiones Iguazu -> AL DIA
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 4, 6, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 300000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-01-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

DECLARE @hoy DATE = '2026-07-15';

-- Concesion 8: Transporte Los Alerces -> AL DIA
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 7, 8, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 110000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-07-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

DECLARE @hoy DATE = '2026-07-15';

-- Concesion 2: Tienda Nahuel Huapi -> DEUDORA
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 3, 2, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 80000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-06-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

DECLARE @hoy DATE = '2026-07-15';

-- Concesion 3: Turismo aventura Nahuel Huapi -> DEUDORA
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 2, 3, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 200000.00
FROM (
    SELECT DATEADD(MONTH, n, '2025-01-01') AS f
    FROM (VALUES (0),(1),(2)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

-- Concesion 5: Tienda Iguazu -> DEUDORA (sin pagos registrados)

-- Concesion 7: Restaurante Talampaya -> AL DIA
DECLARE @hoy DATE = '2026-07-15';
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 1, 7, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 90000.00
FROM (
    SELECT DATEADD(MONTH, n, '2025-03-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

-- Concesion 9: Camping Los Alerces -> AL DIA
DECLARE @hoy DATE = '2026-07-15';
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 8, 9, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 75000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-11-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

-- Concesion 10: Heladeria Iguazu -> AL DIA
DECLARE @hoy DATE = '2026-07-15';
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 6, 10, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 50000.00
FROM (
    SELECT DATEADD(MONTH, n, '2025-06-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

-- Concesion 11: Turismo aventura Perito Moreno -> AL DIA
DECLARE @hoy DATE = '2026-07-15';
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 2, 11, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 180000.00
FROM (
    SELECT DATEADD(MONTH, n, '2025-01-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

-- Concesion 12: Excursiones Talampaya -> AL DIA
DECLARE @hoy DATE = '2026-07-15';
INSERT INTO concesiones.PagoConcesion (id_empresa, id_concesion, fecha_pago, monto)
SELECT 4, 12, DATEFROMPARTS(YEAR(f), MONTH(f), 1), 130000.00
FROM (
    SELECT DATEADD(MONTH, n, '2024-09-01') AS f
    FROM (VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21)) AS nums(n)
) AS meses
WHERE f <= @hoy;
GO

-- Concesion 13: Servicios Australes Perito Moreno -> VENCIDA Y SIN PAGAR

PRINT '[OK] Pagos de concesiones insertados (algunas con deuda).';
GO

-- ================================================================
-- BLOQUE 11: TICKETS - HISTORIAL DE VENTAS (~34 tickets)
-- ================================================================
PRINT '';
PRINT '--- BLOQUE 11: Tickets e Items (historial de ventas) ---';
GO

-- Variables para tickets
DECLARE @hoy DATE = '2026-07-15';
DECLARE @tk_id INT, @total DECIMAL(10,2), @fecha DATE, @i INT, @j INT, @id_precio INT, @precio DECIMAL(10,2);
DECLARE @OutputTab TABLE (id INT);

-- ==========================================
-- Nahuel Huapi (parque 1): 8 tickets
-- ==========================================

-- Ticket 1: 2025-06-10, Residente x2
SET @fecha = '2025-06-10';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1001, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha;
SET @precio = @total/2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;

-- Ticket 2: 2025-07-15, Extranjero x1 + Tour Isla Victoria
SET @fecha = '2025-07-15';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 1 + 8500;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1002, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 1;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 3, @p_precio_venta = 8500, @p_cantidad = 1;

-- Ticket 3: 2025-08-20, Residente x4 + Buceo
SET @fecha = '2025-08-20';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 4 + 12000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1003, @p_forma_pago = 'Tarjeta de Debito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 4;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 6, @p_precio_venta = 12000, @p_cantidad = 1;

-- Ticket 4: 2025-09-05, Estudiante x10 (visita escolar)
SET @fecha = '2025-09-05';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 3 AND vigencia_desde <= @fecha ) * 10;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1004, @p_forma_pago = 'Transferencia', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 3 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 10;

-- Ticket 5: 2025-10-12, Jubilado x2 + Cabalgata
SET @fecha = '2025-10-12';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 4 AND vigencia_desde <= @fecha ) * 2 + 7000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1005, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 4 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 7, @p_precio_venta = 7000, @p_cantidad = 1;

-- Ticket 6: 2025-11-03, Menor x3 (gratis)
SET @fecha = '2025-11-03';
SET @total = 0;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1006, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 5 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = 0, @p_cantidad = 3;

-- Ticket 7: 2025-12-24, Residente x2 + Tour Cerro Campanario
SET @fecha = '2025-12-24';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 3500;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1007, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 4, @p_precio_venta = 3500, @p_cantidad = 1;

-- Ticket 8: 2026-01-15, Extranjero x1 (en dolares)
SET @fecha = '2026-01-15';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 1;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1008, @p_forma_pago = 'Moneda Extranjera', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 1;
-- Pago en USD
EXEC ventas.sp_InsertarPagoMonedaExtranjera @p_id_ticket = @tk_id, @p_id_tasa = 4, @p_monto_extranjero = 7.50, @p_monto_pesos = @total;

-- Ticket 8b: 2026-02-10, Buceo en Lago cupo COMPLETO (8 cupos vendidos de 8)
SET @fecha = '2026-02-10';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 12000 * 8;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1009, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 6, @p_precio_venta = 12000, @p_cantidad = 8;
-- Asignar guia para Ascenso Cerro Campanario (Tour Guiado, cupo completo)
EXEC actividades.sp_InsertarTourGuia @p_id_guia = 5, @p_id_atraccion = 4, @p_fecha = @fecha;
PRINT '[OK] Ticket 8b: Ascenso Cerro Campanario con cupo completo (8/8) y guia asignado.';

-- ==========================================
-- Iguazu (parque 4): 6 tickets
-- ==========================================

-- Ticket 9: 2025-06-20, Residente x5
SET @fecha = '2025-06-20';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 5;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2001, @p_forma_pago = 'Tarjeta de Debito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 5;

-- Ticket 10: 2025-07-01, Extranjero x3 + Paseo en Lancha
SET @fecha = '2025-07-01';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 3 + 15000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2002, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 3;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 11, @p_precio_venta = 15000, @p_cantidad = 1;

-- Ticket 11: 2025-08-15, Estudiante x20 (excursion escolar)
SET @fecha = '2025-08-15';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 3 AND vigencia_desde <= @fecha ) * 20;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2003, @p_forma_pago = 'Transferencia', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 3 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 20;

-- Ticket 12: 2025-09-30, Residente x2 + Excursion Isla San Martin (cupo completo: 30)
SET @fecha = '2025-09-30';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 6000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2004, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 12, @p_precio_venta = 6000, @p_cantidad = 1;

-- Ticket 13: 2025-11-10, Jubilado x1
SET @fecha = '2025-11-10';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 4 AND vigencia_desde <= @fecha ) * 1;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2005, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 4 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 1;

-- Ticket 14: 2025-12-28, Menor x4
SET @fecha = '2025-12-28';
SET @total = 0;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2006, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 5 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = 0, @p_cantidad = 4;

-- ==========================================
-- Talampaya (parque 5): 5 tickets
-- ==========================================

-- Ticket 15: 2025-07-20, Residente x3 + Canon Talampaya
SET @fecha = '2025-07-20';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 3 + 4000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 5, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 3001, @p_forma_pago = 'Tarjeta de Debito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 3;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 14, @p_precio_venta = 4000, @p_cantidad = 1;

-- Ticket 16: 2025-08-25, Extranjero x2 + Ciudad Perdida
SET @fecha = '2025-08-25';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 2 + 5000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 5, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 3002, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 15, @p_precio_venta = 5000, @p_cantidad = 1;

-- Ticket 17: 2025-09-15, Estudiante x15
SET @fecha = '2025-09-15';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 3 AND vigencia_desde <= @fecha ) * 15;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 5, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 3003, @p_forma_pago = 'Transferencia', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 3 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 15;

-- Ticket 18: 2025-10-05, Residente x1 + Caminata Nocturna
SET @fecha = '2025-10-05';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 1 + 3500;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 5, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 3004, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 1;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 18, @p_precio_venta = 3500, @p_cantidad = 1;

-- Ticket 19: 2025-11-20, Extranjero x3
SET @fecha = '2025-11-20';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 3;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 5, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 3005, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 5 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 3;

-- ==========================================
-- Los Alerces (parque 2): 4 tickets
-- ==========================================

-- Ticket 20: 2025-08-10, Residente x2 + Kayak
SET @fecha = '2025-08-10';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 8000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 2, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 4001, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 20, @p_precio_venta = 8000, @p_cantidad = 1;

-- Ticket 21: 2025-10-30, Extranjero x1 + Trekking Alerzal
SET @fecha = '2025-10-30';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 1 + 6000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 2, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 4002, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 1;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 21, @p_precio_venta = 6000, @p_cantidad = 1;

-- Ticket 22: 2025-12-05, Estudiante x12
SET @fecha = '2025-12-05';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 3 AND vigencia_desde <= @fecha ) * 12;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 2, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 4003, @p_forma_pago = 'Transferencia', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 3 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 12;

-- Ticket 23: 2026-01-08, Menor x2
SET @fecha = '2026-01-08';
SET @total = 0;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 2, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 4004, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio FROM parques.PrecioEntrada WHERE id_parque = 2 AND id_tipo = 5 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = 0, @p_cantidad = 2;

-- ==========================================
-- Perito Moreno (parque 6): 3 tickets
-- ==========================================

-- Ticket 24: 2025-09-20, Residente x4 + Mini Trekking
SET @fecha = '2025-09-20';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 6 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 4 + 25000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 6, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 5001, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 6 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 4;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 24, @p_precio_venta = 25000, @p_cantidad = 1;

-- Ticket 25: 2025-11-15, Extranjero x5 + Navegacion
SET @fecha = '2025-11-15';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 6 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 5 + 12000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 6, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 5002, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 6 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 5;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 25, @p_precio_venta = 12000, @p_cantidad = 1;

-- Ticket 26: 2026-02-10, Residente x2
SET @fecha = '2026-02-10';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 6 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 6, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 5003, @p_forma_pago = 'Tarjeta de Debito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 6 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;

-- ==========================================
-- Parque 7 (Los Cardones): 2 tickets
-- ==========================================

-- Ticket 27: 2025-10-18, Residente x2 + Astroturismo
SET @fecha = '2025-10-18';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 7 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 7000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 7, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 6001, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 7 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 27, @p_precio_venta = 7000, @p_cantidad = 1;

-- Ticket 28: 2025-12-15, Extranjero x1
SET @fecha = '2025-12-15';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 7 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 1;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 7, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 6002, @p_forma_pago = 'Moneda Extranjera', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 7 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 1;
EXEC ventas.sp_InsertarPagoMonedaExtranjera @p_id_ticket = @tk_id, @p_id_tasa = 4, @p_monto_extranjero = 8.50, @p_monto_pesos = @total;

-- ==========================================
-- Quebrada del Condorito (parque 8): 2 tickets
-- ==========================================

-- Ticket 29: 2025-09-10, Residente x6
SET @fecha = '2025-09-10';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 8 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 6;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 8, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 7001, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 8 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 6;

-- Ticket 30: 2026-01-20, Estudiante x8 + Trekking Quebrada
SET @fecha = '2026-01-20';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 8 AND id_tipo = 3 AND vigencia_desde <= @fecha ) * 8 + 4000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 8, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 7002, @p_forma_pago = 'Transferencia', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 8 AND id_tipo = 3 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 8;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 30, @p_precio_venta = 4000, @p_cantidad = 1;

-- ==========================================
-- Pre-Delta (parque 9): 2 tickets
-- ==========================================

-- Ticket 31: 2025-11-08, Residente x2 + Navegacion Rio
SET @fecha = '2025-11-08';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 9 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 5000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 9, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 8001, @p_forma_pago = 'Tarjeta de Debito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 9 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 31, @p_precio_venta = 5000, @p_cantidad = 1;

-- Ticket 32: 2026-02-28, Jubilado x4
SET @fecha = '2026-02-28';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 9 AND id_tipo = 4 AND vigencia_desde <= @fecha ) * 4;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 9, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 8002, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 9 AND id_tipo = 4 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 4;

-- ==========================================
-- El Leoncito (parque 10): 1 ticket
-- ==========================================

-- Ticket 33: 2026-03-01, Residente x2 + Observatorio
SET @fecha = '2026-03-01';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 10 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 8000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 10, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 9001, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 10 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 33, @p_precio_venta = 8000, @p_cantidad = 1;

-- ==========================================
-- Tickets en feriados (para probar sp_ReporteVisitasFeriados)
-- ==========================================

-- Ticket 35: Año Nuevo en Nahuel Huapi, Residente x3
SET @fecha = '2026-01-01';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 3;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 1, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 1010, @p_forma_pago = 'Efectivo', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 1 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 3;

-- Ticket 36: 25 de Mayo en Iguazú, Extranjero x4 + Circuito Inferior
SET @fecha = '2026-05-25';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 2 AND vigencia_desde <= @fecha ) * 4 + 0;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 4, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 2007, @p_forma_pago = 'Tarjeta de Credito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 4 AND id_tipo = 2 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 4;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 12, @p_precio_venta = 0, @p_cantidad = 4;

-- Ticket 37: 9 de Julio en Los Glaciares, Residente x2 + Tour Perito Moreno
SET @fecha = '2026-07-09';
SET @total = (SELECT precio FROM parques.PrecioEntrada WHERE id_parque = 7 AND id_tipo = 1 AND vigencia_desde <= @fecha ) * 2 + 15000;
INSERT INTO @OutputTab EXEC ventas.sp_InsertarTicket @p_id_parque = 7, @p_fecha = @fecha, @p_fecha_acceso = @fecha, @p_punto_de_venta = 1, @p_numero_comprobante = 6003, @p_forma_pago = 'Tarjeta de Debito', @p_total_pagado = @total;
SET @tk_id = (SELECT id FROM @OutputTab); DELETE FROM @OutputTab;
SELECT @id_precio = id_precio, @precio = precio FROM parques.PrecioEntrada WHERE id_parque = 7 AND id_tipo = 1 AND vigencia_desde <= @fecha;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = @id_precio, @p_id_atraccion = NULL, @p_precio_venta = @precio, @p_cantidad = 2;
EXEC ventas.sp_InsertarItemTicket @p_id_ticket = @tk_id, @p_id_precio_entrada = NULL, @p_id_atraccion = 19, @p_precio_venta = 15000, @p_cantidad = 1;

-- ==========================================
-- Venta actual usando sp_VentaEntradas (fecha = hoy)
-- ==========================================

-- Ticket 34: Venta con sp_VentaEntradas para Nahuel Huapi en USD
BEGIN TRY
    EXEC ventas.sp_VentaEntradas
        @p_id_parque = 1,
        @p_fecha_acceso = @hoy,
        @p_punto_de_venta = 2,
        @p_numero_comprobante = 1001,
        @p_forma_pago = 'Moneda Extranjera',
        @p_id_tipo_visitante = 2,
        @p_cantidad = 2,
        @p_id_atraccion = NULL,
        @p_id_moneda = 1,
        @p_monto_extranjero = 15.00;
END TRY
BEGIN CATCH
    PRINT 'Error en venta actual (sp_VentaEntradas): ' + ERROR_MESSAGE();
END CATCH
GO

PRINT '[OK] 37 tickets con items insertados.';
GO

-- ================================================================
-- EVIDENCIA: Resumen de datos cargados
-- ================================================================
PRINT '';
PRINT '============================================================';
PRINT ' RESUMEN - Conteo de registros cargados en PoblarTablas';
PRINT '============================================================';
SELECT 'parques.Parque'              AS tabla, COUNT(*) AS registros FROM parques.Parque
UNION ALL SELECT 'parques.TipoVisitante',      COUNT(*) FROM parques.TipoVisitante
UNION ALL SELECT 'parques.PrecioEntrada',      COUNT(*) FROM parques.PrecioEntrada
UNION ALL SELECT 'ventas.Ticket',              COUNT(*) FROM ventas.Ticket
UNION ALL SELECT 'ventas.ItemTicket',          COUNT(*) FROM ventas.ItemTicket
UNION ALL SELECT 'ventas.PagoMonedaExtranjera',COUNT(*) FROM ventas.PagoMonedaExtranjera
UNION ALL SELECT 'actividades.Guia',           COUNT(*) FROM actividades.Guia
UNION ALL SELECT 'actividades.HabilitacionGuia',COUNT(*) FROM actividades.HabilitacionGuia
UNION ALL SELECT 'actividades.Atraccion',      COUNT(*) FROM actividades.Atraccion
UNION ALL SELECT 'actividades.TourGuia',       COUNT(*) FROM actividades.TourGuia
UNION ALL SELECT 'concesiones.Empresa',        COUNT(*) FROM concesiones.Empresa
UNION ALL SELECT 'concesiones.Concesion',      COUNT(*) FROM concesiones.Concesion
UNION ALL SELECT 'concesiones.PagoConcesion',  COUNT(*) FROM concesiones.PagoConcesion
UNION ALL SELECT 'personal.Guardaparque',      COUNT(*) FROM personal.Guardaparque
UNION ALL SELECT 'personal.AsignacionParque',  COUNT(*) FROM personal.AsignacionParque
ORDER BY tabla;
GO

PRINT '';
PRINT '============================================================';
PRINT ' FIN - PoblarTablas.sql completado.';
PRINT '============================================================';
GO

PRINT '============================================';
PRINT ' 14_PoblarTablas.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
