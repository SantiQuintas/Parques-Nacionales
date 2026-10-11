/*
================================================================================
  MATERIA:     Bases de Datos Aplicada - 3641 
  COMISION:    02-5600
  UNIVERSIDAD: Universidad Nacional de la Matanza
  GRUPO:       10
  INTEGRANTES:
      - Amarilla, Facundo Nahuel   - 46201679
      - Ávila García, Eric Luis    - 43722795
      - Borgoño Villafañe, Gonzalo - 46645738
      - Quintas, Santiago Emanuel  - 46737706

  Archivo:     01_CreacionTablasEsquemasYBdd.sql
  Descripcion: Crea la base de datos del sistema de gestión de Parques Nacionales,
               define los esquemas lógicos por dominio de negocio y crea la
               estructura base de almacenamiento, incluyendo tablas,
               relaciones y restricciones de integridad.

  NORMA DE NOMENCLATURA:
      Tablas:      PascalCase, sin prefijo  (ej: Parque, TipoVisitante)
      Esquemas:    minúsculas por dominio   (parques, ventas, actividades, concesiones, personal)
      PKs:         inline en la columna     (id_x INT IDENTITY(1,1) PRIMARY KEY)
      FKs:         FK_TablaOrigen_TablaDestino  como CONSTRAINT separado
      CHECKs:      CK_NombreTabla_Campo     como CONSTRAINT separado
      UNIQUE:      inline en la columna cuando es de una sola columna;
                   como CONSTRAINT separado solo cuando abarca dos o mas columnas
*/

USE master;
GO

-- ============================================================
-- CREACION DE LA BASE DE DATOS
-- ============================================================
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'ParquesNacionales')
BEGIN
    CREATE DATABASE ParquesNacionales COLLATE Latin1_General_CI_AI;
    PRINT 'Base de datos ParquesNacionales creada correctamente.';
END
GO

USE ParquesNacionales;
GO

-- ============================================================
-- CREACION DE ESQUEMAS
-- Cada esquema agrupa tablas relacionadas por dominio de negocio.
-- ============================================================

-- parques: informacion base de cada parque nacional, tipos de visitante y precios de entrada
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'parques')
    EXEC ('CREATE SCHEMA parques');
GO

-- ventas: tickets de entrada, items, pagos en moneda extranjera y tasas de cambio
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'ventas')
    EXEC ('CREATE SCHEMA ventas');
GO

-- actividades: atracciones, tours, guias y sus habilitaciones
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'actividades')
    EXEC ('CREATE SCHEMA actividades');
GO

-- concesiones: empresas concesionarias, contratos y registro de pagos de canon
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'concesiones')
    EXEC ('CREATE SCHEMA concesiones');
GO

-- personal: guardaparques y su historial de asignaciones a parques
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'personal')
    EXEC ('CREATE SCHEMA personal');
GO



-- ============================================================
-- CREACION DE TABLAS
-- ============================================================

-- ============================================================
-- ESQUEMA: parques
-- ============================================================

/* ---- Parque ---- */
-- Registra cada parque nacional administrado por el sistema.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Parque' AND schema_id = SCHEMA_ID(N'parques'))
-- Tabla principal de parques nacionales argentinos
CREATE TABLE parques.Parque (
    id_parque   INT           IDENTITY(1,1) PRIMARY KEY,
    nombre      VARCHAR(100)  NOT NULL,
    ubicacion   VARCHAR(200)  NOT NULL,
    superficie  DECIMAL(12,2) NOT NULL,
    tipo        VARCHAR(50)   NOT NULL,
    latitud     DECIMAL(9,6)  NOT NULL,
    longitud    DECIMAL(9,6)  NOT NULL,

    -- La superficie debe ser un valor positivo
    CONSTRAINT CK_Parque_Superficie CHECK (superficie > 0),
    -- Solo se permiten tipos predefinidos de parques
    CONSTRAINT CK_Parque_Tipo CHECK (tipo IN ( 
        'Parque Nacional',
        'Reserva Nacional',
        'Monumento Natural',
        'Reserva Natural Estricta',
        'Parque Interjurisdiccional'
    )),
    -- Rangos válidos para coordenadas geográficas
    CONSTRAINT CK_Parque_Latitud CHECK (latitud > -90 AND latitud < 90),
    CONSTRAINT CK_Parque_Longitud CHECK (longitud > -180 AND longitud < 180)
);
GO
/* ---- TipoVisitante ---- */
-- Catalogo de categorias de visitante que determinan el precio de la entrada.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'TipoVisitante' AND schema_id = SCHEMA_ID(N'parques'))
-- Categorías de visitantes para tarifas diferenciadas
CREATE TABLE parques.TipoVisitante (
    id_tipo     INT          IDENTITY(1,1) PRIMARY KEY,
    descripcion VARCHAR(50)  NOT NULL UNIQUE,

    -- Solo se permiten categorías predefinidas de visitantes
    CONSTRAINT CK_TipoVisitante_Descripcion CHECK (descripcion IN (
        'Residente',
        'Extranjero',
        'Estudiante',
        'Jubilado',
        'Menor'
    ))
);
GO

/* ---- PrecioEntrada ---- */
-- Historial de precios por parque y tipo de visitante.
-- Cada vez que cambia el precio se inserta una nueva fila con la nueva vigencia_desde.
-- El precio vigente es el de mayor vigencia_desde que no supere la fecha actual.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'PrecioEntrada' AND schema_id = SCHEMA_ID(N'parques'))
-- Tarifas vigentes por parque y tipo de visitante
CREATE TABLE parques.PrecioEntrada (
    id_precio      INT           IDENTITY(1,1) PRIMARY KEY,
    id_parque      INT           NOT NULL,
    id_tipo        INT           NOT NULL,
    precio         DECIMAL(10,2) NOT NULL,
    vigencia_desde DATE          NOT NULL,

    -- FK: cada registro pertenece a un parque
    CONSTRAINT FK_PrecioEntrada_Parque
        FOREIGN KEY (id_parque) REFERENCES parques.Parque (id_parque),
    -- FK: referencia la categoría de visitante
    CONSTRAINT FK_PrecioEntrada_TipoVisitante
        FOREIGN KEY (id_tipo)   REFERENCES parques.TipoVisitante (id_tipo),
    CONSTRAINT CK_PrecioEntrada_Precio CHECK (precio >= 0),
    -- Garantizar unicidad a nivel de negocio
    CONSTRAINT UQ_PrecioEntrada_Vigencia
    UNIQUE (
        id_parque,
        id_tipo,
        vigencia_desde
    )
);
GO

-- ============================================================
-- ESQUEMA: ventas
-- ============================================================

/* ---- Moneda ---- */
-- Catalogo de monedas extranjeras aceptadas (codigo ISO 4217: USD, EUR, BRL, etc.)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Moneda' AND schema_id = SCHEMA_ID(N'ventas'))
-- Monedas extranjeras aceptadas para conversiones
CREATE TABLE ventas.Moneda (
    id_moneda  INT         IDENTITY(1,1) PRIMARY KEY,
    codigo_iso CHAR(3)     NOT NULL UNIQUE,
    nombre     VARCHAR(50) NOT NULL,
    simbolo    VARCHAR(5)  NULL
);
GO

/* ---- TasaCambio ---- */
-- Registra la tasa de conversion a pesos para cada moneda en una fecha dada.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'TasaCambio' AND schema_id = SCHEMA_ID(N'ventas'))
-- Cotizaciones diarias de monedas extranjeras a pesos
CREATE TABLE ventas.TasaCambio (
    id_tasa        INT           IDENTITY(1,1) PRIMARY KEY,
    id_moneda      INT           NOT NULL,
    fecha_vigencia DATE          NOT NULL,
    tasa_a_peso    DECIMAL(12,4) NOT NULL,

    -- FK: referencia la moneda de la cotización
    CONSTRAINT FK_TasaCambio_Moneda
        FOREIGN KEY (id_moneda) REFERENCES ventas.Moneda (id_moneda),
    CONSTRAINT CK_TasaCambio_Tasa CHECK (tasa_a_peso > 0),
    -- Garantiza que no haya dos tasas distintas para la misma moneda en el mismo dia.
    -- Puede existir USD el 01/01 y USD el 02/01 (distintas fechas), pero no dos filas USD 01/01.
    -- Garantizar unicidad a nivel de negocio
    CONSTRAINT UQ_TasaCambio_MonedaFecha UNIQUE (id_moneda, fecha_vigencia)
);
GO

/* ---- Ticket ---- */
-- Comprobante de venta. Puede incluir entradas y/o atracciones en sus items.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Ticket' AND schema_id = SCHEMA_ID(N'ventas'))
-- Cabecera de cada venta de entradas
CREATE TABLE ventas.Ticket (
    id_ticket          INT           IDENTITY(1,1) PRIMARY KEY,
    id_parque          INT           NOT NULL,
    fecha              DATE          NOT NULL,   -- fecha de emision
    fecha_acceso       DATE          NOT NULL,   -- fecha en que el visitante ingresa al parque
    punto_de_venta     INT           NOT NULL,
    numero_comprobante INT           NOT NULL,
    forma_pago         VARCHAR(30)   NOT NULL,
    total_pagado       DECIMAL(10,2) NOT NULL,

    -- FK: cada ticket pertenece a un parque
    CONSTRAINT FK_Ticket_Parque
        FOREIGN KEY (id_parque) REFERENCES parques.Parque (id_parque),
    CONSTRAINT CK_Ticket_TotalPagado  CHECK (total_pagado >= 0),
    -- La fecha de acceso no puede ser anterior a la fecha de emisión
    CONSTRAINT CK_Ticket_FechaAcceso  CHECK (fecha_acceso >= fecha),
    -- Solo se permiten formas de pago predefinidas
    CONSTRAINT CK_Ticket_FormaPago    CHECK (forma_pago IN (
        'Efectivo',
        'Tarjeta de Debito',
        'Tarjeta de Credito',
        'Transferencia',
        'Moneda Extranjera'
    )),
    -- UNIQUE compuesto: la combinacion punto_de_venta + numero_comprobante es unica
    -- Garantizar unicidad a nivel de negocio
    CONSTRAINT UQ_Ticket_Comprobante  UNIQUE (punto_de_venta, numero_comprobante)
);
GO

-- ============================================================
-- ESQUEMA: actividades (se crea antes de ItemTicket porque ItemTicket
-- referencia a actividades.Atraccion mediante FK)
-- ============================================================

/* ---- Guia ---- */
-- Guias habilitados para conducir tours dentro de los parques.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Guia' AND schema_id = SCHEMA_ID(N'actividades'))
-- Guías autorizados para conducir tours
CREATE TABLE actividades.Guia (
    id_guia               INT          IDENTITY(1,1) PRIMARY KEY,
    nombre                VARCHAR(50)   NOT NULL,
    apellido              VARCHAR(50)   NOT NULL,
    dni_cifrado           VARBINARY(256) NOT NULL,
    especialidad          VARCHAR(100)  NULL,
    titulo                VARCHAR(100)  NULL,
    vigencia_autorizacion DATE          NOT NULL
);
GO

/* ---- HabilitacionGuia ---- */
-- Habilitaciones o certificaciones especificas de cada guia (pueden ser varias por guia).
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'HabilitacionGuia' AND schema_id = SCHEMA_ID(N'actividades'))
-- Certificaciones y habilitaciones de cada guía
CREATE TABLE actividades.HabilitacionGuia (
    id_habilitacion   INT          IDENTITY(1,1) PRIMARY KEY,
    id_guia           INT          NOT NULL,
    descripcion       VARCHAR(100) NOT NULL,
    fecha_vencimiento DATE         NULL,

    -- FK: habilitación pertenece a un guía
    CONSTRAINT FK_HabilitacionGuia_Guia
        FOREIGN KEY (id_guia) REFERENCES actividades.Guia (id_guia)
);
GO

/* ---- Atraccion ---- */
-- Atracciones y tours disponibles en cada parque.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Atraccion' AND schema_id = SCHEMA_ID(N'actividades'))
-- Atracciones y tours disponibles en cada parque
CREATE TABLE actividades.Atraccion (
    id_atraccion INT           IDENTITY(1,1) PRIMARY KEY,
    id_parque    INT           NOT NULL,
    nombre       VARCHAR(100)  NOT NULL,
    tipo         VARCHAR(30)   NOT NULL,
    costo        DECIMAL(10,2) NOT NULL,   -- 0 si es gratuita
    duracion     INT           NOT NULL,   -- en minutos
    horario_inicio TIME        NOT NULL,   -- hora de inicio de la actividad
    cupo_maximo  INT           NOT NULL,

    -- FK: cada atracción pertenece a un parque
    CONSTRAINT FK_Atraccion_Parque
        FOREIGN KEY (id_parque) REFERENCES parques.Parque (id_parque),
    -- Solo se permiten tipos de atracción predefinidos
    CONSTRAINT CK_Atraccion_Tipo CHECK (tipo IN ('Gratuita', 'Paga', 'Tour Guiado')),
    -- Gratuito = costo 0; Paga/Tour Guiado = costo mayor a 0
    CONSTRAINT CK_Atraccion_Costo
    CHECK (
        (tipo = 'Gratuita' AND costo = 0)
        OR
        (tipo IN ('Paga','Tour Guiado') AND costo > 0)
    ),
    CONSTRAINT CK_Atraccion_Duracion CHECK (duracion > 0),
    CONSTRAINT CK_Atraccion_Cupo     CHECK (cupo_maximo > 0)
);
GO

-- ============================================================
-- ESQUEMA: ventas (continuacion)
-- ============================================================

/* ---- ItemTicket ---- */
-- Cada linea de un ticket. Puede ser una entrada (id_precio_entrada) o una
-- atraccion/tour (id_atraccion). Al menos uno de los dos debe estar informado.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'ItemTicket' AND schema_id = SCHEMA_ID(N'ventas'))
-- Líneas individuales de cada ticket (entrada o atracción)
CREATE TABLE ventas.ItemTicket (
    id_item           INT           IDENTITY(1,1) PRIMARY KEY,
    id_ticket         INT           NOT NULL,
    id_precio_entrada INT           NULL,   -- NULL si el item es una atraccion
    id_atraccion      INT           NULL,   -- NULL si el item es una entrada
    precio_venta      DECIMAL(10,2) NOT NULL,
    cantidad          INT           NOT NULL,

    -- FK: ítems pertenecen a un ticket
    CONSTRAINT FK_ItemTicket_Ticket
        FOREIGN KEY (id_ticket)         REFERENCES ventas.Ticket (id_ticket),
    -- FK: referencia el precio de entrada (si el ítem es entrada)
    CONSTRAINT FK_ItemTicket_PrecioEntrada
        FOREIGN KEY (id_precio_entrada) REFERENCES parques.PrecioEntrada (id_precio),
    -- FK: referencia la atracción (si el ítem es atracción)
    CONSTRAINT FK_ItemTicket_Atraccion
        FOREIGN KEY (id_atraccion)      REFERENCES actividades.Atraccion (id_atraccion),

    -- Cada item debe ser una entrada O una atracción, nunca ambas ni ninguna
    CONSTRAINT CK_ItemTicket_TipoItem CHECK (
    (id_precio_entrada IS NOT NULL AND id_atraccion IS NULL)
    OR
    (id_precio_entrada IS NULL AND id_atraccion IS NOT NULL)
    ),
    CONSTRAINT CK_ItemTicket_Cantidad    CHECK (cantidad > 0),
    CONSTRAINT CK_ItemTicket_PrecioVenta CHECK (precio_venta >= 0)
);
GO

/* ---- PagoMonedaExtranjera ---- */
-- Registra cuando un ticket fue abonado en moneda extranjera.
-- Guarda tanto el monto en moneda original como su equivalente en pesos al momento del cobro.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'PagoMonedaExtranjera' AND schema_id = SCHEMA_ID(N'ventas'))
-- Conversión de moneda extranjera para tickets en divisa
CREATE TABLE ventas.PagoMonedaExtranjera (
    id_pago_ext      INT           IDENTITY(1,1) PRIMARY KEY,
    id_ticket        INT           NOT NULL,
    id_tasa          INT           NOT NULL,
    monto_extranjero DECIMAL(12,2) NOT NULL,
    monto_pesos      DECIMAL(12,2) NOT NULL,

    -- FK: pago asociado a un ticket
    CONSTRAINT FK_PagoExt_Ticket
        FOREIGN KEY (id_ticket) REFERENCES ventas.Ticket (id_ticket),
    -- FK: tasa de cambio aplicada al momento del pago
    CONSTRAINT FK_PagoExt_TasaCambio
        FOREIGN KEY (id_tasa)   REFERENCES ventas.TasaCambio (id_tasa),
    CONSTRAINT CK_PagoExt_MontoExtranjero CHECK (monto_extranjero > 0),
    CONSTRAINT CK_PagoExt_MontoPesos      CHECK (monto_pesos > 0)
);
GO

/* ---- TourGuia ---- */
-- Asocia un guia a una atraccion en una fecha especifica.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'TourGuia' AND schema_id = SCHEMA_ID(N'actividades'))
-- Asignaciones de guías a tours específicos por fecha
CREATE TABLE actividades.TourGuia (
    id_tour_guia INT  IDENTITY(1,1) PRIMARY KEY,
    id_guia      INT  NOT NULL,
    id_atraccion INT  NOT NULL,
    fecha        DATE NOT NULL,

    -- FK: tour asignado a un guía
    CONSTRAINT FK_TourGuia_Guia
        FOREIGN KEY (id_guia)      REFERENCES actividades.Guia (id_guia),
    -- FK: tour corresponde a una atracción
    CONSTRAINT FK_TourGuia_Atraccion
        FOREIGN KEY (id_atraccion) REFERENCES actividades.Atraccion (id_atraccion),
    -- Garantizar unicidad a nivel de negocio
    CONSTRAINT UQ_TourGuia UNIQUE
    (
        id_guia,
        id_atraccion,
        fecha
    )
);
GO

-- ============================================================
-- ESQUEMA: concesiones
-- ============================================================

/* ---- Empresa ---- */
-- Empresas que operan concesiones dentro de los parques.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Empresa' AND schema_id = SCHEMA_ID(N'concesiones'))
-- Empresas concesionarias
CREATE TABLE concesiones.Empresa (
    id_empresa   INT          IDENTITY(1,1) PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL,
    cuit         CHAR(11)     NOT NULL UNIQUE, -- El CUIT argentino tiene 11 digitos numericos (sin guiones).
    contacto     VARCHAR(100) NULL,

    -- El CUIT argentino tiene exactamente 11 dígitos numéricos (sin guiones)
    CONSTRAINT CK_Empresa_CUIT CHECK (
        cuit LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
    )
);
GO

/* ---- Concesion ---- */
-- Contrato de concesion entre una empresa y un parque.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Concesion' AND schema_id = SCHEMA_ID(N'concesiones'))
-- Contratos de concesión entre empresas y parques
CREATE TABLE concesiones.Concesion (
    id_concesion   INT           IDENTITY(1,1) PRIMARY KEY,
    id_empresa     INT           NOT NULL,
    id_parque      INT           NOT NULL,
    tipo_actividad VARCHAR(50)   NOT NULL,
    fecha_inicio   DATE          NOT NULL,
    fecha_fin      DATE          NOT NULL,
    pago_mensual   DECIMAL(12,2) NOT NULL,

    -- FK: concesión de una empresa
    CONSTRAINT FK_Concesion_Empresa
        FOREIGN KEY (id_empresa) REFERENCES concesiones.Empresa (id_empresa),
    -- FK: concesión en un parque
    CONSTRAINT FK_Concesion_Parque
        FOREIGN KEY (id_parque)  REFERENCES parques.Parque (id_parque),
    -- La fecha de fin debe ser posterior a la fecha de inicio
    CONSTRAINT CK_Concesion_Fechas      CHECK (fecha_fin > fecha_inicio),
    CONSTRAINT CK_Concesion_PagoMensual CHECK (pago_mensual > 0)
);
GO

/* ---- PagoConcesion ---- */
-- Registro historico de cada pago de canon realizado por una concesionaria.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'PagoConcesion' AND schema_id = SCHEMA_ID(N'concesiones'))
-- Pagos de canon mensual de concesiones
CREATE TABLE concesiones.PagoConcesion (
    id_pago      INT           IDENTITY(1,1) PRIMARY KEY,
    id_empresa   INT           NOT NULL,
    id_concesion INT           NOT NULL,
    fecha_pago   DATE          NOT NULL,
    monto        DECIMAL(12,2) NOT NULL,

    -- FK: pago de una empresa
    CONSTRAINT FK_PagoConcesion_Empresa
        FOREIGN KEY (id_empresa)   REFERENCES concesiones.Empresa (id_empresa),
    -- FK: pago de una concesión específica
    CONSTRAINT FK_PagoConcesion_Concesion
        FOREIGN KEY (id_concesion) REFERENCES concesiones.Concesion (id_concesion),
    CONSTRAINT CK_PagoConcesion_Monto CHECK (monto > 0)
);
GO

-- ============================================================
-- ESQUEMA: personal
-- ============================================================

/* ---- Guardaparque ---- */
-- Datos personales de los guardaparques.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'Guardaparque' AND schema_id = SCHEMA_ID(N'personal'))
-- Guardaparques del sistema
CREATE TABLE personal.Guardaparque (
    id_guardaparque INT         IDENTITY(1,1) PRIMARY KEY,
    nombre          VARCHAR(50)   NOT NULL,
    apellido        VARCHAR(50)   NOT NULL,
    dni_cifrado     VARBINARY(256) NOT NULL
);
GO

/* ---- AsignacionParque ---- */
-- Historial de asignaciones de cada guardaparque a los distintos parques.
-- fecha_hasta NULL significa que el guardaparque sigue activo en ese parque.
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = N'AsignacionParque' AND schema_id = SCHEMA_ID(N'personal'))
-- Asignaciones de guardaparques a parques
CREATE TABLE personal.AsignacionParque (
    id_asignacion   INT          IDENTITY(1,1) PRIMARY KEY,
    id_guardaparque INT          NOT NULL,
    id_parque       INT          NOT NULL,
    fecha_desde     DATE         NOT NULL,
    fecha_hasta     DATE         NULL,
    motivo_egreso   VARCHAR(200) NULL,

    -- FK: asignación de un guardaparque
    CONSTRAINT FK_AsignacionParque_Guardaparque
        FOREIGN KEY (id_guardaparque) REFERENCES personal.Guardaparque (id_guardaparque),
    -- FK: asignación a un parque
    CONSTRAINT FK_AsignacionParque_Parque
        FOREIGN KEY (id_parque)       REFERENCES parques.Parque (id_parque),
    CONSTRAINT CK_AsignacionParque_Fechas CHECK (fecha_hasta IS NULL OR fecha_hasta > fecha_desde) -- Si hay fecha de egreso, debe ser posterior al ingreso
);
GO

PRINT '============================================';
PRINT ' 01_CreacionTablasEsquemasYBdd.sql CARGADO CORRECTAMENTE';
PRINT '============================================';
GO