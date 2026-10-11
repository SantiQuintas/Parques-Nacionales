/*
==================================================================================
  MATERIA:     Bases de Datos Aplicada - 3641
  COMISION:    02-5600
  UNIVERSIDAD: Universidad Nacional de la Matanza
  GRUPO:       10
  INTEGRANTES:
      - Amarilla, Facundo Nahuel   - 46201679
      - Ávila García, Eric Luis    - 43722795
      - Borgoño Villafañe, Gonzalo - 46645738
      - Quintas, Santiago Emanuel  - 46737706

  Archivo:     08_SPReportes.sql
  Descripcion: Vistas de apoyo y procedimientos almacenados para la generacion
               de reportes del sistema de gestion de Parques Nacionales.
               Contiene 4 vistas y 6 SPs para reportes (5 de Entrega 7 + 1 extra).
==================================================================================
*/

USE ParquesNacionales;
GO

-- =============================================
-- VISTAS DE APOYO PARA REPORTES
-- =============================================

/* ============================================================
   vw_visitas_por_fecha
   Vista de apoyo: cantidad de visitantes por parque y fecha.
   Filtra solo items de tipo entrada (excluye atracciones).
   ============================================================ */
CREATE OR ALTER VIEW ventas.vw_visitas_por_fecha
AS
SELECT
    t.id_parque,
    t.fecha_acceso AS fecha,
    SUM(it.cantidad) AS visitas
FROM ventas.Ticket t
INNER JOIN ventas.ItemTicket it ON it.id_ticket = t.id_ticket
WHERE it.id_precio_entrada IS NOT NULL
GROUP BY t.id_parque, t.fecha_acceso;
GO

/* ============================================================
   vw_ingresos_entradas
   Vista de apoyo: ingresos por venta de entradas por parque y fecha.
   Filtra solo items de tipo entrada.
   ============================================================ */
CREATE OR ALTER VIEW ventas.vw_ingresos_entradas
AS
SELECT
    t.id_parque,
    t.fecha,
    SUM(it.precio_venta * it.cantidad) AS ingresos
FROM ventas.Ticket t
INNER JOIN ventas.ItemTicket it ON it.id_ticket = t.id_ticket
WHERE it.id_precio_entrada IS NOT NULL
GROUP BY t.id_parque, t.fecha;
GO

/* ============================================================
   vw_ingresos_atracciones
   Vista de apoyo: ingresos por contratacion de atracciones/tours
   por parque y fecha.
   ============================================================ */
CREATE OR ALTER VIEW ventas.vw_ingresos_atracciones
AS
SELECT
    t.id_parque,
    t.fecha,
    SUM(it.precio_venta * it.cantidad) AS ingresos
FROM ventas.Ticket t
INNER JOIN ventas.ItemTicket it ON it.id_ticket = t.id_ticket
WHERE it.id_atraccion IS NOT NULL
GROUP BY t.id_parque, t.fecha;
GO

/* ============================================================
   vw_ingresos_concesiones
   Vista de apoyo: ingresos por cobro de canon de concesiones
   por parque y fecha de pago.
   ============================================================ */
CREATE OR ALTER VIEW ventas.vw_ingresos_concesiones
AS
SELECT
    c.id_parque,
    pc.fecha_pago AS fecha,
    SUM(pc.monto) AS ingresos
FROM concesiones.PagoConcesion pc
INNER JOIN concesiones.Concesion c ON c.id_concesion = pc.id_concesion
GROUP BY c.id_parque, pc.fecha_pago;
GO

/* ============================================================
   sp_ReporteVisitasPorPeriodo
   Genera reporte de visitas agrupadas por parque, año, mes y semana.
   Formato de salida: XML.

   Sin parametros de entrada.
   ============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_ReporteVisitasPorPeriodo
AS
BEGIN
    SET NOCOUNT ON;
    -- Fuente: ventas.vw_visitas_por_fecha (definida en este archivo)

    SELECT
        p.nombre                       AS 'Parque',
        DATEPART(YEAR, v.fecha)        AS 'Anio',
        DATEPART(MONTH, v.fecha)       AS 'Mes',
        DATEPART(WEEK, v.fecha)        AS 'Semana',
        SUM(v.visitas)                 AS 'Visitantes'
    FROM ventas.vw_visitas_por_fecha v
    INNER JOIN parques.Parque p ON p.id_parque = v.id_parque
    GROUP BY p.nombre, DATEPART(YEAR, v.fecha), DATEPART(MONTH, v.fecha), DATEPART(WEEK, v.fecha)
    ORDER BY p.nombre, DATEPART(YEAR, v.fecha), DATEPART(MONTH, v.fecha), DATEPART(WEEK, v.fecha)
    FOR XML PATH('Visita'), ROOT('ReporteVisitas');
END;
GO

/* ============================================================
   sp_ReporteIngresosPorPeriodo
   Genera reporte de ingresos por parque, año, mes y semana.
   Suma entradas, atracciones/tours y concesiones cobradas.

   Sin parametros de entrada.
   ============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_ReporteIngresosPorPeriodo
AS
BEGIN
    SET NOCOUNT ON;
    -- Fuente: ventas.vw_ingresos_entradas, vw_ingresos_atracciones, vw_ingresos_concesiones

    ;WITH ingresos_unidos AS (
        -- Unificar ingresos de entradas, atracciones y concesiones
        SELECT id_parque, fecha, ingresos FROM ventas.vw_ingresos_entradas
        UNION ALL
        SELECT id_parque, fecha, ingresos FROM ventas.vw_ingresos_atracciones
        UNION ALL
        SELECT id_parque, fecha, ingresos FROM ventas.vw_ingresos_concesiones
    )
    SELECT
        p.nombre                              AS Parque,
        DATEPART(YEAR, i.fecha)               AS Anio,
        DATEPART(MONTH, i.fecha)              AS Mes,
        DATEPART(WEEK, i.fecha)               AS Semana,
        SUM(i.ingresos)                       AS IngresoTotal
    FROM ingresos_unidos i
    INNER JOIN parques.Parque p ON p.id_parque = i.id_parque
    GROUP BY p.nombre, DATEPART(YEAR, i.fecha), DATEPART(MONTH, i.fecha), DATEPART(WEEK, i.fecha)
    ORDER BY p.nombre, DATEPART(YEAR, i.fecha), DATEPART(MONTH, i.fecha), DATEPART(WEEK, i.fecha);
END;
GO

/* ============================================================
   sp_ReporteDeudores
   Identifica concesiones con pagos atrasados. Genera una serie
   de meses esperados usando CTE recursivo (MAXRECURSION 0),
   los cruza con pagos reales y calcula la deuda acumulada.

   Sin parametros de entrada.
   Salida: tabla con Parque, Empresa, Actividad, Fechas,
           PagoMensual, MesesAdeudados, DeudaTotal.
   ============================================================ */
CREATE OR ALTER PROCEDURE concesiones.sp_ReporteDeudores
AS
BEGIN
    SET NOCOUNT ON;
    -- Usa CTE recursivo para generar serie temporal de meses

    -- Generar números del 0 al 1200 para expandir meses
    ;WITH nums AS (
        SELECT 0 AS n
        UNION ALL
        SELECT n + 1 FROM nums WHERE n < 1200
    ),
    -- Obtener datos base de cada concesión con rango de meses
    con_meses AS (
        SELECT
            c.id_concesion,
            c.id_parque,
            c.id_empresa,
            e.razon_social,
            c.tipo_actividad,
            c.fecha_inicio,
            c.fecha_fin,
            c.pago_mensual,
            DATEFROMPARTS(YEAR(c.fecha_inicio), MONTH(c.fecha_inicio), 1) AS mes_inicio,
            DATEFROMPARTS(
                YEAR(CASE WHEN c.fecha_fin < GETDATE() THEN c.fecha_fin ELSE GETDATE() END),
                MONTH(CASE WHEN c.fecha_fin < GETDATE() THEN c.fecha_fin ELSE GETDATE() END),
                1
            ) AS mes_fin
        FROM concesiones.Concesion c
        INNER JOIN concesiones.Empresa e ON e.id_empresa = c.id_empresa
    ),
    -- Generar una fila por cada mes esperado de cada concesión
    meses_esperados AS (
        SELECT
            cm.id_concesion,
            cm.id_parque,
            cm.pago_mensual,
            DATEADD(MONTH, nums.n, cm.mes_inicio) AS mes_esperado
        FROM con_meses cm
        CROSS JOIN nums
        WHERE DATEADD(MONTH, nums.n, cm.mes_inicio) <= cm.mes_fin
    ),
    -- Sumar pagos reales por concesión y mes calendario
    pagos_por_mes AS (
        SELECT
            pc.id_concesion,
            DATEFROMPARTS(YEAR(pc.fecha_pago), MONTH(pc.fecha_pago), 1) AS mes_pago,
            SUM(pc.monto) AS total_pagado
        FROM concesiones.PagoConcesion pc
        GROUP BY pc.id_concesion, DATEFROMPARTS(YEAR(pc.fecha_pago), MONTH(pc.fecha_pago), 1)
    ),
    -- Calcular diferencia entre lo esperado y lo pagado
    deuda_mensual AS (
        SELECT
            me.id_concesion,
            me.mes_esperado,
            me.pago_mensual,
            ISNULL(ppm.total_pagado, 0) AS monto_pagado,
            me.pago_mensual - ISNULL(ppm.total_pagado, 0) AS deuda_mes
        FROM meses_esperados me
        LEFT JOIN pagos_por_mes ppm
            ON ppm.id_concesion = me.id_concesion
            AND ppm.mes_pago = me.mes_esperado
        WHERE ppm.id_concesion IS NULL
            OR ppm.total_pagado < me.pago_mensual
    )
    -- Resultado: concesiones con deuda, agrupadas por parque/empresa
    SELECT
        p.nombre                            AS Parque,
        e.razon_social                      AS Empresa,
        c.tipo_actividad                    AS Actividad,
        c.fecha_inicio                      AS FechaInicio,
        c.fecha_fin                         AS FechaFin,
        c.pago_mensual                      AS PagoMensual,
        COUNT(*)                            AS MesesAdeudados,
        SUM(dm.deuda_mes)                   AS DeudaTotal
    FROM deuda_mensual dm
    INNER JOIN concesiones.Concesion c ON c.id_concesion = dm.id_concesion
    INNER JOIN concesiones.Empresa e ON e.id_empresa = c.id_empresa
    INNER JOIN parques.Parque p ON p.id_parque = c.id_parque
    GROUP BY p.nombre, e.razon_social, c.tipo_actividad,
             c.fecha_inicio, c.fecha_fin, c.pago_mensual
    ORDER BY p.nombre, e.razon_social
    OPTION (MAXRECURSION 0);
END;
GO

/* ============================================================
   sp_ReporteMatrizVisitas
   Genera matriz pivote de visitantes por parque y mes.
   Formato de salida: XML.

   Sin parametros de entrada.
   ============================================================ */
CREATE OR ALTER PROCEDURE ventas.sp_ReporteMatrizVisitas
AS
BEGIN
    SET NOCOUNT ON;
    -- Fuente: ventas.vw_visitas_por_fecha

    -- Pivotear meses a columnas para vista matricial
    SELECT
        Parque,
        [1]  AS Ene,
        [2]  AS Feb,
        [3]  AS Mar,
        [4]  AS Abr,
        [5]  AS May,
        [6]  AS Jun,
        [7]  AS Jul,
        [8]  AS Ago,
        [9]  AS Sep,
        [10] AS Oct,
        [11] AS Nov,
        [12] AS Dic
    FROM (
        SELECT
            p.nombre     AS Parque,
            MONTH(v.fecha) AS Mes,
            v.visitas
        FROM ventas.vw_visitas_por_fecha v
        INNER JOIN parques.Parque p ON p.id_parque = v.id_parque
    ) AS origen
    PIVOT (
        SUM(visitas)
        FOR Mes IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
    ) AS pvt
    ORDER BY Parque
    FOR XML PATH('Parque'), ROOT('MatrizVisitas'); --Comentar linea para ver como tabla
END;
GO

/* ============================================================
   sp_ReporteParquesConcesiones
   Genera XML con datos de parques y sus concesiones anidadas
   como subelementos, usando subconsulta correlacionada.

   Sin parametros de entrada.
   ============================================================ */
CREATE OR ALTER PROCEDURE parques.sp_ReporteParquesConcesiones
AS
BEGIN
    SET NOCOUNT ON;
    -- Usa subconsulta correlacionada con FOR XML PATH para concesiones anidadas

    SELECT
        p.nombre                    AS '@nombre',
        p.ubicacion                 AS '@ubicacion',
        p.tipo                      AS '@tipo',
        p.superficie                AS '@superficie',
        (   -- Subconsulta anidada: concesiones de cada parque en XML
            SELECT
                e.razon_social      AS '@titular',
                c.tipo_actividad    AS '@servicio',
                c.fecha_inicio      AS '@fechaInicio',
                c.fecha_fin         AS '@fechaFin',
                c.pago_mensual      AS '@canonMensual'
            FROM concesiones.Concesion c
            INNER JOIN concesiones.Empresa e ON e.id_empresa = c.id_empresa
            WHERE c.id_parque = p.id_parque
            ORDER BY c.fecha_inicio
            FOR XML PATH('Concesion'), TYPE
        ) AS Concesiones
    FROM parques.Parque p
    ORDER BY p.nombre
    FOR XML PATH('Parque'), ROOT('ParquesConcesiones');
END;
GO

/* ============================================================
   sp_ReporteVisitasFeriados
   Compara visitas e ingresos en dias feriados vs. dias comunes.
   Genera un resumen con porcentajes de impacto.

   Sin parametros de entrada.
   ============================================================ */
CREATE OR ALTER PROCEDURE importacion.sp_ReporteVisitasFeriados
AS
BEGIN
    SET NOCOUNT ON;
    -- Fuente: importacion.Feriado + ventas.vw_visitas_por_fecha + vw_ingresos_*

    -- Calcular totales en días feriados vs días comunes
    -- Variables de trabajo
    DECLARE @v_total_feriados   INT = 0;
    DECLARE @v_total_no_feriados INT = 0;
    DECLARE @v_ing_feriados     DECIMAL(12,2) = 0;
    DECLARE @v_ing_no_feriados  DECIMAL(12,2) = 0;

    SELECT
        @v_total_feriados    = COALESCE(SUM(v.visitas), 0),
        @v_ing_feriados      = COALESCE(ROUND(SUM(i.ingresos), 2), 0)
    FROM importacion.Feriado f
    LEFT JOIN (
        SELECT fecha, SUM(visitas) AS visitas
        FROM ventas.vw_visitas_por_fecha
        GROUP BY fecha
    ) v ON v.fecha = f.fecha
    LEFT JOIN (
        SELECT fecha, SUM(ingresos) AS ingresos
        FROM (
            SELECT fecha, ingresos FROM ventas.vw_ingresos_entradas
            UNION ALL
            SELECT fecha, ingresos FROM ventas.vw_ingresos_atracciones
        ) i
        GROUP BY fecha
    ) i ON i.fecha = f.fecha;

    SELECT @v_total_no_feriados = COALESCE(SUM(visitas), 0)
    FROM ventas.vw_visitas_por_fecha v
    WHERE NOT EXISTS (SELECT 1 FROM importacion.Feriado f WHERE f.fecha = v.fecha);

    SELECT @v_ing_no_feriados = COALESCE(ROUND(SUM(ingresos), 2), 0)
    FROM (
        SELECT fecha, ingresos FROM ventas.vw_ingresos_entradas
        UNION ALL
        SELECT fecha, ingresos FROM ventas.vw_ingresos_atracciones
    ) i
    WHERE NOT EXISTS (SELECT 1 FROM importacion.Feriado f WHERE f.fecha = i.fecha);

    -- Detalle: cada feriado con visitantes e ingresos
    SELECT
        f.fecha,
        f.nombre      AS feriado,
        f.tipo,
        COALESCE(v.visitas, 0)    AS visitantes,
        ROUND(COALESCE(i.ingresos, 0), 2) AS ingresos
    FROM importacion.Feriado f
    LEFT JOIN (
        SELECT fecha, SUM(visitas) AS visitas
        FROM ventas.vw_visitas_por_fecha
        GROUP BY fecha
    ) v ON v.fecha = f.fecha
    LEFT JOIN (
        SELECT fecha, SUM(ingresos) AS ingresos
        FROM (
            SELECT fecha, ingresos FROM ventas.vw_ingresos_entradas
            UNION ALL
            SELECT fecha, ingresos FROM ventas.vw_ingresos_atracciones
        ) i
        GROUP BY fecha
    ) i ON i.fecha = f.fecha
    ORDER BY f.fecha;

    -- Resumen
    PRINT '';
    PRINT '--- RESUMEN IMPACTO DE FERIADOS ---';
    PRINT 'Visitantes en feriados:     ' + CAST(@v_total_feriados AS VARCHAR(10));
    PRINT 'Visitantes en dias comunes: ' + CAST(@v_total_no_feriados AS VARCHAR(10));
    PRINT 'Total visitantes:           ' + CAST(@v_total_feriados + @v_total_no_feriados AS VARCHAR(10));

    IF (@v_total_feriados + @v_total_no_feriados) > 0
    BEGIN
        -- Variables de trabajo
        DECLARE @v_porc DECIMAL(5,2);
        SET @v_porc = ROUND(100.0 * @v_total_feriados / (@v_total_feriados + @v_total_no_feriados), 2);
        PRINT 'Porcentaje en feriados:     ' + CAST(@v_porc AS VARCHAR(10)) + '%';
        PRINT '';
        PRINT 'Ingresos en feriados:       $' + CAST(@v_ing_feriados AS VARCHAR(20));
        PRINT 'Ingresos en dias comunes:   $' + CAST(@v_ing_no_feriados AS VARCHAR(20));
        PRINT 'Total ingresos:             $' + CAST(@v_ing_feriados + @v_ing_no_feriados AS VARCHAR(20));
        SET @v_porc = ROUND(100.0 * @v_ing_feriados / (@v_ing_feriados + @v_ing_no_feriados), 2);
        PRINT 'Porcentaje ingresos en feriados: ' + CAST(@v_porc AS VARCHAR(10)) + '%';
    END;
    PRINT '--------------------------------';
END;
GO

PRINT '============================================';
PRINT ' 08_SPReportes.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO
