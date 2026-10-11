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

   Archivo:     07_SPImportacion.sql
   Descripcion: Stored Procedures de importacion de datos externos (Entrega 6).
               Importa desde tres fuentes:
                 1. Excel (.xlsx) via OPENROWSET -> parques.Parque
                 2. API dolarapi.com (OPENROWSET+OPENJSON) -> ventas.TasaCambio
                 3. API date.nager.at (OPENROWSET+OPENJSON)-> importacion.Feriado

               El SP de parques lee el Excel directamente con el proveedor
               Microsoft.ACE.OLEDB.16.0, sin conversion manual a CSV.

   Requisitos previos:
      - Microsoft Access Database Engine 2016 (64-bit) instalado

  Fuentes de datos:
     - Excel parques: Sistema de Informacion de Biodiversidad de Argentina (https://sib.gob.ar/areas-protegidas)
     - JSON tasas: https://dolarapi.com/v1/cotizaciones
     - JSON feriados: https://date.nager.at/api/v3/PublicHolidays/2026/AR
===============================================================================
*/

-- Llama a: parques.sp_InsertarParque (03_SPInsercion.sql)

USE ParquesNacionales;
GO

-- ============================================================
-- ESQUEMA: importacion
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'importacion')
    EXEC ('CREATE SCHEMA importacion');
GO

-- ============================================================
-- TABLAS AUXILIARES
-- ============================================================

/* ---- LogImportacion ---- */
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'LogImportacion' AND schema_id = SCHEMA_ID(N'importacion'))
CREATE TABLE importacion.LogImportacion (
    id_log        INT            IDENTITY(1,1) PRIMARY KEY,
    proceso       VARCHAR(50)    NOT NULL,
    fecha         DATETIME2      NOT NULL DEFAULT SYSDATETIME(),
    fila_origen   NVARCHAR(500)  NULL,
    mensaje_error NVARCHAR(2000) NOT NULL
);
GO

/* ---- Feriado ---- */
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Feriado' AND schema_id = SCHEMA_ID(N'importacion'))
CREATE TABLE importacion.Feriado (
    id_feriado    INT           IDENTITY(1,1) PRIMARY KEY,
    fecha         DATE          NOT NULL,
    nombre        VARCHAR(100)  NOT NULL,
    nombre_local  VARCHAR(100)  NOT NULL,
    tipo          VARCHAR(50)   NOT NULL,

    CONSTRAINT UQ_Feriado_Fecha UNIQUE (fecha)
);
GO

-- ============================================================
-- SP DE IMPORTACION 1: Parques desde Excel via OPENROWSET
-- Lee el .xlsx directamente usando el provider Microsoft.ACE.OLEDB.
-- No requiere convertir a CSV manualmente.
-- ============================================================
CREATE OR ALTER PROCEDURE importacion.sp_ImportarParquesDesdeExcel
    @p_ruta_excel NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_fila          INT = 0;
    DECLARE @v_insertados    INT = 0;
    DECLARE @v_omitidos      INT = 0;
    DECLARE @v_provider      NVARCHAR(100) = N'Microsoft.ACE.OLEDB.16.0';
    DECLARE @v_conn_string   NVARCHAR(500);
    DECLARE @v_sql           NVARCHAR(MAX);
    DECLARE @v_tipo          VARCHAR(50);
    DECLARE @v_nombre        NVARCHAR(200);
    DECLARE @v_provincia     NVARCHAR(200);
    DECLARE @v_superficie_ha NVARCHAR(50);
    DECLARE @v_superficie_hectareas    DECIMAL(12,4);
    DECLARE @v_superficie_km2       DECIMAL(12,2);
    DECLARE @v_id_parque     INT;
    DECLARE @v_latitud       DECIMAL(9,6);
    DECLARE @v_longitud      DECIMAL(9,6);
    DECLARE @v_latitud_str   NVARCHAR(50);
    DECLARE @v_longitud_str  NVARCHAR(50);
    DECLARE @Output TABLE (id INT);

    -- ============================================================
    -- 1) CONFIGURAR REQUISITOS DE SQL SERVER
    -- ============================================================
    -- Habilitar Ad Hoc Distributed Queries (para OPENROWSET)
    IF (SELECT CAST(value_in_use AS INT) FROM sys.configurations WHERE name = 'Ad Hoc Distributed Queries') = 0
    BEGIN
        EXEC sp_configure 'show advanced options', 1; RECONFIGURE;
        EXEC sp_configure 'Ad Hoc Distributed Queries', 1; RECONFIGURE;
        PRINT 'Ad Hoc Distributed Queries habilitado.';
    END
    ELSE
        PRINT 'Ad Hoc Distributed Queries ya esta habilitado.';

    -- Configurar AllowInProcess para el provider
    BEGIN TRY
        EXEC master.sys.sp_MSset_oledb_prop @v_provider, N'AllowInProcess', 1;
        PRINT 'AllowInProcess configurado.';
    END TRY
    BEGIN CATCH
        PRINT 'Advertencia: No se pudo configurar AllowInProcess.';
        PRINT 'Si falla la lectura, ejecutar manualmente:';
        PRINT '  EXEC master.sys.sp_MSset_oledb_prop N''' + @v_provider + ''', N''AllowInProcess'', 1';
    END CATCH;

    PRINT 'Proveedor: ' + @v_provider;

    -- ============================================================
    -- 2) LEER EXCEL VIA OPENROWSET A TABLA STAGING
    -- ============================================================
    SET @v_conn_string = 'Excel 12.0 Xml;Database=' + @p_ruta_excel + ';HDR=NO;IMEX=1';

    -- Tabla temporal para almacenar datos crudos del Excel antes de procesarlos
    -- Crear tabla staging con IDENTITY para WHILE
    CREATE TABLE #Staging_ParquesExcel (
        id            INT IDENTITY(1,1) PRIMARY KEY,
        provincia     NVARCHAR(200),
        nombre        NVARCHAR(200),
        anio_creacion NVARCHAR(50),
        region        NVARCHAR(200),
        superficie_ha NVARCHAR(50),
        latitud       NVARCHAR(50),
        longitud      NVARCHAR(50),
        instrumento   NVARCHAR(500),
        ecorregiones  NVARCHAR(500),
        cat_internac  NVARCHAR(200),
        especies      NVARCHAR(50),
        animales      NVARCHAR(50),
        bacterias     NVARCHAR(50),
        hongos        NVARCHAR(50),
        plantas       NVARCHAR(50)
    );

    SET @v_sql = N'
        INSERT INTO #Staging_ParquesExcel
        SELECT
            CAST([F1]  AS NVARCHAR(200)),
            CAST([F2]  AS NVARCHAR(200)),
            CAST([F3]  AS NVARCHAR(50)),
            CAST([F4]  AS NVARCHAR(200)),
            CAST([F5]  AS NVARCHAR(50)),
            CAST([F6]  AS NVARCHAR(50)),
            CAST([F7]  AS NVARCHAR(50)),
            CAST([F8]  AS NVARCHAR(500)),
            CAST([F9]  AS NVARCHAR(500)),
            CAST([F10] AS NVARCHAR(200)),
            CAST([F11] AS NVARCHAR(50)),
            CAST([F12] AS NVARCHAR(50)),
            CAST([F13] AS NVARCHAR(50)),
            CAST([F14] AS NVARCHAR(50)),
            CAST([F15] AS NVARCHAR(50))
        FROM OPENROWSET(
            N''' + @v_provider + N''',
            N''' + @v_conn_string + N''',
            N''SELECT * FROM [Sheet1$]''
        ) AS x
        WHERE CAST([F2] AS NVARCHAR(200)) IS NOT NULL
          AND LTRIM(RTRIM(CAST([F2] AS NVARCHAR(200)))) <> N''''
          AND CAST([F1] AS NVARCHAR(200)) <> N''Provincia''
    ';

    BEGIN TRY
        EXEC sp_executesql @v_sql;
    END TRY
    BEGIN CATCH
        BEGIN TRY
            EXEC master.sys.sp_MSset_oledb_prop @v_provider, N'AllowInProcess', 0;
        END TRY BEGIN CATCH END CATCH;
        EXEC sp_configure 'Ad Hoc Distributed Queries', 0; RECONFIGURE;
        EXEC sp_configure 'show advanced options', 0; RECONFIGURE;

        DECLARE @v_errores NVARCHAR(2000) = N'[sp_ImportarParquesDesdeExcel] Error al leer el Excel.'
            + N'Verifique: (1) La ruta existe, (2) El provider ACE.OLEDB 16.0 esta instalado, '
            + N'(3) SQL Server tiene permiso de lectura. '
            + N'Detalle: ' + ERROR_MESSAGE();
        THROW 50000, @v_errores, 1;
    END CATCH;

    -- Mostrar cuantas filas se cargaron
    DECLARE @v_staging_count INT;
    SELECT @v_staging_count = COUNT(*) FROM #Staging_ParquesExcel;
    PRINT 'Filas cargadas desde Excel: ' + CAST(@v_staging_count AS VARCHAR(10));

    -- ============================================================
    -- 3) PROCESAR CADA FILA (WHILE con IDENTITY)
    -- ============================================================
    -- Limpiar filas que no pasan el filtro
    DELETE FROM #Staging_ParquesExcel
    WHERE nombre IS NULL OR LTRIM(RTRIM(nombre)) = ''
       OR ISNULL(provincia, '') = '';

    DECLARE @v_id_max INT, @v_id_act INT = 1;
    SELECT @v_id_max = MAX(id) FROM #Staging_ParquesExcel;

    -- Procesar cada fila del staging mediante WHILE con IDENTITY (evita cursores)
    WHILE @v_id_act <= @v_id_max
    BEGIN
        SELECT
            @v_nombre        = LTRIM(RTRIM(nombre)),
            @v_provincia     = LTRIM(RTRIM(ISNULL(provincia, N'Argentina'))),
            @v_superficie_ha = REPLACE(superficie_ha, N',', N'.'),
            @v_latitud_str   = REPLACE(ISNULL(latitud, N'0'), N',', N'.'),
            @v_longitud_str  = REPLACE(ISNULL(longitud, N'0'), N',', N'.')
        FROM #Staging_ParquesExcel
        WHERE id = @v_id_act;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @v_fila += 1;

            -- Inferir tipo desde el nombre
            SET @v_tipo =
                CASE
                    WHEN @v_nombre LIKE N'Parque Nacional %' THEN N'Parque Nacional'
                    WHEN @v_nombre LIKE N'Monumento Natural %' THEN N'Monumento Natural'
                    WHEN @v_nombre LIKE N'Reserva Natural Estricta %' THEN N'Reserva Natural Estricta'
                    WHEN @v_nombre LIKE N'Reserva Natural Silvestre %' THEN N'Reserva Nacional'
                    WHEN @v_nombre LIKE N'Reserva Natural Educativa %' THEN N'Reserva Nacional'
                    WHEN @v_nombre LIKE N'Reserva Natural Formosa%' THEN N'Reserva Nacional'
                    WHEN @v_nombre LIKE N'Reserva Natural %' THEN N'Reserva Nacional'
                    WHEN @v_nombre LIKE N'Reserva Nacional %' THEN N'Reserva Nacional'
                    WHEN @v_nombre LIKE N'Parque Interjurisdiccional %' THEN N'Parque Interjurisdiccional'
                    WHEN @v_nombre LIKE N'Área Marina Protegida %' THEN N'Parque Nacional'
                    ELSE NULL
                END;

            IF @v_tipo IS NULL
            BEGIN
                INSERT INTO importacion.LogImportacion (proceso, fila_origen, mensaje_error)
                VALUES ('PARQUES', @v_nombre, N'Tipo no identificado para: ' + @v_nombre);
                SET @v_omitidos += 1;
                SET @v_id_act += 1;
                CONTINUE;
            END;

            -- Convertir hectareas a km2 (1 ha = 0.01 km2)
            SET @v_superficie_hectareas = ISNULL(TRY_CAST(NULLIF(@v_superficie_ha, '') AS DECIMAL(12,4)), 0);
            SET @v_superficie_km2 = @v_superficie_hectareas * 0.01;
            -- Conversión de hectáreas a km² (1 km² = 100 ha)

            -- Convertir latitud y longitud de NVARCHAR a DECIMAL(9,6)
            SET @v_latitud  = ISNULL(TRY_CAST(NULLIF(@v_latitud_str, '')  AS DECIMAL(9,6)), 0);
            SET @v_longitud = ISNULL(TRY_CAST(NULLIF(@v_longitud_str, '') AS DECIMAL(9,6)), 0);

            IF @v_provincia IS NULL OR LTRIM(RTRIM(@v_provincia)) = ''
                SET @v_provincia = N'Argentina';

            BEGIN TRY
                SELECT @v_id_parque = id_parque
                FROM parques.Parque
                WHERE nombre = @v_nombre;

                IF @v_id_parque IS NULL
                BEGIN
                    -- Insertar parque solo si no existe otro con el mismo nombre en la tabla
                    INSERT INTO @Output (id)
                    EXEC parques.sp_InsertarParque
                        @p_nombre     = @v_nombre,
                        @p_ubicacion  = @v_provincia,
                        @p_superficie = @v_superficie_km2,
                        @p_tipo       = @v_tipo,
                        @p_latitud    = @v_latitud,
                        @p_longitud   = @v_longitud;
                    SET @v_insertados += 1;
                END
                ELSE
                BEGIN
                    EXEC parques.sp_ModificarParque
                        @p_id_parque   = @v_id_parque,
                        @p_ubicacion   = @v_provincia,
                        @p_superficie  = @v_superficie_km2,
                        @p_tipo        = @v_tipo,
                        @p_latitud     = @v_latitud,
                        @p_longitud    = @v_longitud;
                END;

                DELETE FROM @Output;
            END TRY
            BEGIN CATCH
                INSERT INTO importacion.LogImportacion (proceso, fila_origen, mensaje_error)
                VALUES ('PARQUES', @v_nombre, N'Error al procesar: ' + ERROR_MESSAGE());
                SET @v_omitidos += 1;
            END CATCH;
        END;

        SET @v_id_act += 1;
    END;

    PRINT '============================================';
    PRINT 'IMPORTACION DE PARQUES FINALIZADA';
    PRINT '  Filas leidas:     ' + CAST(@v_fila AS VARCHAR(10));
    PRINT '  Parques creados:  ' + CAST(@v_insertados AS VARCHAR(10));
    PRINT '  Omitidos/error:   ' + CAST(@v_omitidos AS VARCHAR(10));
    PRINT '============================================';

    DROP TABLE #Staging_ParquesExcel;

    BEGIN TRY
        EXEC master.sys.sp_MSset_oledb_prop @v_provider, N'AllowInProcess', 0;
    END TRY BEGIN CATCH END CATCH;
    EXEC sp_configure 'Ad Hoc Distributed Queries', 0; RECONFIGURE;
    EXEC sp_configure 'show advanced options', 0; RECONFIGURE;
END;
GO

-- ============================================================
-- SP DE IMPORTACION 2: Tasas de cambio desde archivo JSON
-- ============================================================
CREATE OR ALTER PROCEDURE importacion.sp_ImportarTasaCambio
    @p_ruta_json NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_response     NVARCHAR(MAX);
    DECLARE @v_insertados   INT = 0;
    DECLARE @v_actualizados INT = 0;
    DECLARE @v_errores      INT = 0;
    DECLARE @v_fecha_hoy    DATE = CAST(GETDATE() AS DATE);
    DECLARE @v_moneda       VARCHAR(10);
    DECLARE @v_casa         VARCHAR(30);
    DECLARE @v_compra       DECIMAL(12,4);
    DECLARE @v_venta        DECIMAL(12,4);
    DECLARE @v_id_moneda    INT;
    DECLARE @v_id_tasa      INT;
    DECLARE @v_tasa         DECIMAL(12,4);
    DECLARE @Output TABLE (id INT);

    BEGIN TRY
        DECLARE @v_sql NVARCHAR(MAX);
        -- Consultar API de dolarapi.com para obtener cotizaciones del día
        SET @v_sql = N'SELECT @v_response = BulkColumn FROM OPENROWSET(BULK N''' + @p_ruta_json + N''', SINGLE_CLOB) AS j;';
        EXEC sp_executesql @v_sql, N'@v_response NVARCHAR(MAX) OUTPUT', @v_response OUTPUT;

        IF @v_response IS NULL OR LTRIM(@v_response) = ''
        BEGIN
            PRINT 'ERROR: Archivo JSON vacio o no se pudo leer: ' + @p_ruta_json;
            RETURN;
        END;

        -- Parsear JSON a tabla temporal con IDENTITY para WHILE
        CREATE TABLE #cotizaciones (
            id INT IDENTITY(1,1) PRIMARY KEY,
            moneda VARCHAR(10),
            casa   VARCHAR(30),
            compra DECIMAL(12,4),
            venta  DECIMAL(12,4)
        );

        -- Parsear respuesta JSON y extraer campos relevantes
        INSERT INTO #cotizaciones
        SELECT moneda, casa, compra, venta
        FROM OPENJSON(@v_response)
        WITH (
            moneda VARCHAR(10)    '$.moneda',
            casa   VARCHAR(30)    '$.casa',
            compra DECIMAL(12,4)  '$.compra',
            venta  DECIMAL(12,4)  '$.venta'
        )
        WHERE casa = 'oficial';

        DECLARE @id_act_t INT = 1, @id_max_t INT;
        SELECT @id_max_t = MAX(id) FROM #cotizaciones;

        WHILE @id_act_t <= @id_max_t
        BEGIN
            SELECT
                @v_moneda = moneda,
                @v_casa = casa,
                @v_compra = compra,
                @v_venta = venta
            FROM #cotizaciones
            WHERE id = @id_act_t;

            SELECT @v_id_moneda = id_moneda
            FROM ventas.Moneda
            WHERE codigo_iso = @v_moneda;

            IF @v_id_moneda IS NOT NULL AND @v_compra IS NOT NULL
            BEGIN
                SET @v_tasa = (@v_compra + ISNULL(@v_venta, @v_compra)) / 2;

                SET @v_id_tasa = NULL;
                SELECT @v_id_tasa = id_tasa
                FROM ventas.TasaCambio
                WHERE id_moneda = @v_id_moneda
                  AND fecha_vigencia = @v_fecha_hoy;

                IF @v_id_tasa IS NOT NULL
                BEGIN
                    BEGIN TRY
                        EXEC ventas.sp_ModificarTasaCambio
                            @p_id_tasa     = @v_id_tasa,
                            @p_tasa_a_peso = @v_tasa;
                        SET @v_actualizados += 1;
                    END TRY
                    BEGIN CATCH
                        INSERT INTO importacion.LogImportacion (
                            proceso, fila_origen, mensaje_error
                        ) VALUES (
                            'TASA_CAMBIO',
                            @v_moneda + ' (' + @v_casa + ')',
                            N'Error al actualizar tasa: ' + ERROR_MESSAGE()
                        );
                        SET @v_errores += 1;
                    END CATCH
                END
                ELSE
                BEGIN
                    BEGIN TRY
                        INSERT INTO @Output (id)
                        EXEC ventas.sp_InsertarTasaCambio
                            @p_id_moneda      = @v_id_moneda,
                            @p_fecha_vigencia = @v_fecha_hoy,
                            @p_tasa_a_peso    = @v_tasa;

                        DELETE FROM @Output;
                        SET @v_insertados += 1;
                    END TRY
                    BEGIN CATCH
                        INSERT INTO importacion.LogImportacion (
                            proceso, fila_origen, mensaje_error
                        ) VALUES (
                            'TASA_CAMBIO',
                            @v_moneda + ' (' + @v_casa + ')',
                            N'Error al insertar tasa: ' + ERROR_MESSAGE()
                        );
                        SET @v_errores += 1;
                    END CATCH
                END;
            END;

            SET @id_act_t += 1;
        END;

        PRINT '============================================';
        PRINT 'IMPORTACION TASAS DE CAMBIO FINALIZADA';
        PRINT '  Tasas insertadas: ' + CAST(@v_insertados   AS VARCHAR(10));
        PRINT '  Tasas actualizadas: ' + CAST(@v_actualizados AS VARCHAR(10));
        PRINT '  Errores:          ' + CAST(@v_errores AS VARCHAR(10));
        PRINT '============================================';

        DROP TABLE #cotizaciones;
    END TRY
    BEGIN CATCH
        INSERT INTO importacion.LogImportacion (proceso, fila_origen, mensaje_error)
        VALUES ('TASA_CAMBIO', @p_ruta_json, N'Error: ' + ERROR_MESSAGE());
        PRINT 'ERROR en importacion de tasas: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

-- ============================================================
-- SP DE IMPORTACION 3: Feriados desde archivo JSON
-- ============================================================
CREATE OR ALTER PROCEDURE importacion.sp_ImportarFeriados
    @p_ruta_json NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @v_response     NVARCHAR(MAX);
    DECLARE @v_insertados   INT = 0;
    DECLARE @v_omitidos     INT = 0;

    BEGIN TRY
        DECLARE @v_sql NVARCHAR(MAX);
        -- Consultar API de date.nager.at para feriados del año actual
        SET @v_sql = N'SELECT @v_response = BulkColumn FROM OPENROWSET(BULK N''' + @p_ruta_json + N''', SINGLE_CLOB) AS j;';
        EXEC sp_executesql @v_sql, N'@v_response NVARCHAR(MAX) OUTPUT', @v_response OUTPUT;

        IF @v_response IS NULL OR LTRIM(@v_response) = ''
        BEGIN
            PRINT 'ERROR: Archivo JSON vacio o no se pudo leer: ' + @p_ruta_json;
            RETURN;
        END;

        -- Parsear JSON a tabla temporal
        SELECT
            TRY_CAST(fecha AS DATE) AS fecha,
            LTRIM(RTRIM(localName)) AS nombre,
            LTRIM(RTRIM(name)) AS nombre_local,
            LTRIM(RTRIM(JSON_VALUE(types, '$[0]'))) AS tipo
        INTO #feriados
        FROM OPENJSON(@v_response)
        WITH (
            fecha     VARCHAR(10)    '$.date',
            name      VARCHAR(100)   '$.name',
            localName VARCHAR(100)   '$.localName',
            types     NVARCHAR(MAX)  '$.types' AS JSON
        );

        BEGIN TRY
            -- Insertar solo feriados nuevos (evitar duplicados por UNIQUE constraint)
            INSERT INTO importacion.Feriado (fecha, nombre, nombre_local, tipo)
            SELECT f.fecha, f.nombre, f.nombre_local, ISNULL(f.tipo, 'Public')
            FROM #feriados f
            WHERE f.fecha IS NOT NULL AND f.nombre IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM importacion.Feriado WHERE fecha = f.fecha);

            SET @v_insertados = @@ROWCOUNT;

            SELECT @v_omitidos = COUNT(*)
            FROM #feriados f
            WHERE f.fecha IS NOT NULL AND f.nombre IS NOT NULL
              AND EXISTS (SELECT 1 FROM importacion.Feriado WHERE fecha = f.fecha);
        END TRY
        BEGIN CATCH
            INSERT INTO importacion.LogImportacion (proceso, fila_origen, mensaje_error)
            VALUES ('FERIADOS', @p_ruta_json, N'Error: ' + ERROR_MESSAGE());
            PRINT 'ERROR en importacion de feriados: ' + ERROR_MESSAGE();
        END CATCH;

        PRINT '============================================';
        PRINT 'IMPORTACION FERIADOS FINALIZADA';
        PRINT '  Insertados: ' + CAST(@v_insertados AS VARCHAR(10));
        PRINT '  Omitidos:   ' + CAST(@v_omitidos AS VARCHAR(10));
        PRINT '============================================';

        DROP TABLE #feriados;
    END TRY
    BEGIN CATCH
        INSERT INTO importacion.LogImportacion (proceso, fila_origen, mensaje_error)
        VALUES ('FERIADOS', @p_ruta_json, N'Error: ' + ERROR_MESSAGE());
        PRINT 'ERROR en importacion de feriados: ' + ERROR_MESSAGE();
    END CATCH;
END;
GO

PRINT '============================================';
PRINT ' 07_SPImportacion.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO

