# TP de Bases de Datos Aplicada — Grupo 10

## Prerrequisitos

- SQL Server 2017+
- SQL Server Management Studio (SSMS) con **SQLCMD Mode**
- Microsoft Access Database Engine 2016 (64-bit)
  ([descargar](https://www.microsoft.com/en-us/download/details.aspx?id=54920))
- ODBC Driver 17 for SQL Server
- Python 3.8+ con `pyodbc` (`pip install pyodbc`)
- Power BI Desktop (opcional, para los reportes visuales)

## Estructura del proyecto

```
TP ParquesNacionales/
├── ArchivosImportacion/              # Datasets externos (Excel SIB, etc.)
├── AppEntrega9/                      # Aplicación Python (ABM + importación + reportes)
│   ├── Parques_Nacionales-ABM.py     # App de escritorio con Tkinter
│   └── config.py                     # Configuración de conexión a SQL Server
├── GestionParquesNacionales/         # Scripts SQL (00-16)
│   ├── 00_ReiniciarBDD.sql           # Orquestador: crea base, tablas, SPs, roles
│   ├── 01_CreacionTablasEsquemasYBdd.sql
│   ├── 02_SPEncriptacion.sql
│   ├── 03_SPInsercion.sql
│   ├── 04_SPModificacion.sql
│   ├── 05_SPBorrado.sql
│   ├── 06_SPLogicaNegocio.sql
│   ├── 07_SPImportacion.sql
│   ├── 08_SPReportes.sql
│   ├── 09_SPRoles.sql
│   ├── 10_SPVaciarTablas.sql
│   ├── 11_PruebasABM.sql
│   ├── 12_PruebasLogicaNegocio.sql
│   ├── 13_PruebasSeguridad.sql
│   ├── 14_PoblarTablas.sql
│   ├── 15_ImportarDatos.sql
│   └── 16_PruebasReportes.sql
└── Informes y DER/                   # Documentación adjunta
    ├── Entrega 3 - DER.png           # Diagrama Entidad-Relación
    ├── ParquesNacionales_BI.pbix     # Dashboard Power BI
    ├── ParquesNacionales_BI.pdf      # Exportación del dashboard
    └── Documentacion de Roles.pdf    # Roles, permisos y política de backup
```

## Inicializar la base de datos

1. Abrir `00_ReiniciarBDD.sql` en SSMS
2. Habilitar **SQLCMD Mode** (Query → SQLCMD Mode)
3. Ejecutar

`00_ReiniciarBDD.sql` ejecuta internamente los scripts `01` a `10` en orden, creando:

- Base `ParquesNacionales`, esquemas y tablas (`01`)
- Funciones de cifrado (`02`)
- SPs de inserción, modificación, borrado (`03`–`05`)
- SPs de lógica de negocio (`06`)
- SPs de importación (`07`)
- SPs de reportes (`08`)
- Roles de seguridad (`09`)
- Procedimiento `sp_VaciarTablas` (`10`)

## Orden de ejecución (scripts `11` — `16`)

Una vez ejecutado `00_ReiniciarBDD.sql`, correr los scripts `11` a `16` en orden numérico:

| Paso | Archivo                       | Descripción                                                                                                   |
| ---- | ----------------------------- | ------------------------------------------------------------------------------------------------------------- |
| 2    | `11_PruebasABM.sql`           | Pruebas de inserción, modificación y borrado (autocontenido)                                                  |
| 3    | `12_PruebasLogicaNegocio.sql` | Pruebas de lógica de negocio (venta entradas, actividades, guías, concesiones)                                |
| 4    | `13_PruebasSeguridad.sql`     | Pruebas de cifrado/descifrado y roles                                                                         |
| 5    | `14_PoblarTablas.sql`         | Carga datos de semilla (22 parques, 52 actividades, 20 guías, 20 guardaparques, 13 concesiones, 38 tickets) |
| 6    | `15_ImportarDatos.sql`        | Importación desde archivos Excel/JSON **(opcional, configurar rutas)**                                        |
| 7    | `16_PruebasReportes.sql`      | Ejecuta los 6 reportes contra los datos cargados                                                              |

### Notas

- Los scripts `11` a `13` llaman a `sp_VaciarTablas` al arrancar, por lo que siempre parten de una base vacía (autocontenidos).
- `13_PruebasSeguridad` prueba roles y cifrado sobre BD vacía, por diseño.
- `14_PoblarTablas` también llama a `sp_VaciarTablas` al iniciar, así que borra cualquier dato previo y deja el seed listo.
- `16_PruebasReportes` debe ejecutarse **después** de `14_PoblarTablas` (o `15_ImportarDatos`) para que haya datos contra los cuales correr los reportes.

## Scripts en detalle

### Creación y estructura (`01` — `10`)

| Archivo                             | Contenido                                                                                                                                                |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `01_CreacionTablasEsquemasYBdd.sql` | Base de datos, esquemas (`parques`, `ventas`, `actividades`, `concesiones`, `personal`, `importacion`, `seguridad`) y todas las tablas con restricciones |
| `02_SPEncriptacion.sql`             | Funciones `seguridad.Cifrar` y `seguridad.Descifrar` para DNI de guardaparques y guías                                                                   |
| `03_SPInsercion.sql`                | SPs de inserción para todas las tablas (~17 SPs)                                                                                                         |
| `04_SPModificacion.sql`             | SPs de modificación con `COALESCE` para actualización parcial                                                                                            |
| `05_SPBorrado.sql`                  | SPs de borrado con validaciones de integridad referencial                                                                                                |
| `06_SPLogicaNegocio.sql`            | SPs transaccionales: `sp_VentaEntradas`, `sp_RegistrarActividad`, `sp_AsignarGuia`, `sp_CrearConcesion`, `sp_PagarConcesion`                             |
| `07_SPImportacion.sql`              | SPs de importación: `sp_ImportarParquesDesdeExcel` (upsert vía WHILE+IDENTITY, sin CURSOR), `sp_ImportarTasaCambio` (JSON + upsert), `sp_ImportarFeriados` (JSON) |
| `08_SPReportes.sql`                 | 6 SPs de reportes (3 con salida XML) + 4 vistas auxiliares                                                                                               |
| `09_SPRoles.sql`                    | 8 roles de seguridad (Admin, ImportadorDatos, Consultas, AdminParques, etc.)                                                                             |
| `10_SPVaciarTablas.sql`             | `sp_VaciarTablas`: limpia todas las tablas en orden inverso de dependencias                                                                              |

### Testing (`11` — `13`, `16`)

| Archivo                       | Líneas | Descripción                                                                |
| ----------------------------- | ------ | -------------------------------------------------------------------------- |
| `11_PruebasABM.sql`           | 2865   | Tests de inserción, modificación y borrado (casos exitosos + validaciones) |
| `12_PruebasLogicaNegocio.sql` | 670    | Tests de los 5 SPs de lógica de negocio                                    |
| `13_PruebasSeguridad.sql`     | 204    | Tests de cifrado/descifrado y verificación de roles                        |
| `16_PruebasReportes.sql`      | 109    | Ejecuta los 6 reportes y verifica que devuelvan datos                      |

### Datos (`14` — `15`)

| Archivo                | Descripción                                                                                                                                                                          |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `14_PoblarTablas.sql`  | Datos de semilla: 22 parques, 5 tipos de visitante, 110 precios, 5 monedas, 10 tasas de cambio, 20 guías, 52 actividades, 20 guardaparques, 8 empresas, 13 concesiones, 38 tickets |
| `15_ImportarDatos.sql` | Orquestador de importación: habilita `xp_cmdshell`, importa parques desde Excel SIB, tasas desde JSON, feriados desde JSON, y deshabilita `xp_cmdshell`                              |

#### Importación de datos externos (Entrega 6)

Antes de ejecutar `15_ImportarDatos.sql`:

1. Colocar el archivo Excel del SIB en `ArchivosImportacion\`
2. Editar `@ruta_excel` al inicio del script con la ruta a ese archivo
3. Dar permiso a la base de datos (en general al usuario "Nt Service\MSSQL$SQLEXPRESS") para leer el archivo Excel.

El script luego:

- Descarga automáticamente tasas de cambio desde `dolarapi.com` (JSON)
- Descarga automáticamente feriados desde `date.nager.at` (JSON)
- Copia el Excel al `DATA directory` de SQL Server (accesible por OPENROWSET)
- Importa registros válidos y omite los inválidos, registrando cada error en `importacion.LogImportacion`

## Aplicación Python (Entrega 9)

La app de escritorio en `AppEntrega9/` ofrece tres funcionalidades con pestañas:

### Funcionalidades

| Pestaña           | Descripción                                                                                                                                                                     |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Atracciones**   | ABM completo sobre `actividades.Atraccion` vía SPs. Tabla con búsqueda, formulario modal con validaciones (horario, costo, cupo, etc.)                                          |
| **Importar JSON** | Descarga cotizaciones desde `dolarapi.com`, filtera solo oficiales, cruza con monedas existentes y hace upsert en `TasaCambio`. Muestra log con insertadas/actualizadas/errores |
| **Reportes**      | Ejecuta `sp_ReporteDeudores` (tabla formateada) o `sp_ReporteMatrizVisitas` (XML formateado). Permite guardar el XML a archivo                                                  |

Todas las operaciones se realizan mediante `EXEC` a Stored Procedures (sin acceso directo a tablas).

### Configurar conexión

Editar `AppEntrega9/config.py` o usar variables de entorno:

| Variable    | Default                         |
| ----------- | ------------------------------- |
| `DB_SERVER` | `localhost\SQLEXPRESS`          |
| `DB_NAME`   | `ParquesNacionales`             |
| `DB_USER`   | (vacío → autenticación Windows) |
| `DB_PASS`   | (vacío)                         |

### Ejecutar

```bash
cd AppEntrega9
pip install pyodbc
python Parques_Nacionales-ABM.py
```

## Power BI (Entrega 9)

Abrir `Informes y DER/ParquesNacionales_BI.pbix` en Power BI Desktop.

Requiere conexión a la base `ParquesNacionales` para que los reportes se carguen con datos actualizados. Si los datos cambian, usar **Actualizar** en Power BI.

## Respaldo (Entrega 8)

La política de backup (RPO, esquema de rotación, tipos de respaldo) está documentada en `Informes y DER/Documentacion de Roles.pdf`.
