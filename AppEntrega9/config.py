'''
================================================================================
  MATERIA:     Bases de Datos Aplicada - 3641 
  COMISION:    02-5600
  UNIVERSIDAD: Universidad Nacional de la Matanza
  FECHA:       26/06/2026
  GRUPO:       10
  INTEGRANTES:
      - Amarilla, Facundo Nahuel   - 46201679
      - Ávila García, Eric Luis    - 43722795
      - Borgoño Villafañe, Gonzalo - 46645738
      - Quintas, Santiago Emanuel  - 46737706

  Archivo:      config.py
  Descripcion:  Archivo de configuración desarrollado en Python que guarda los 
                datos necesarios para conectarse a la base de datos SQL Server 
                mediante ODBC, como el servidor, el nombre de la base de datos 
                y las credenciales. Si no se configuran credenciales, se conecta 
                automáticamente usando el usuario de Windows.
================================================================================
'''

import os

SERVIDOR = os.environ.get("DB_SERVER", "localhost\\SQLEXPRESS")
BASE_DATOS = os.environ.get("DB_NAME", "ParquesNacionales")
USUARIO = os.environ.get("DB_USER", "")
CONTRASENA = os.environ.get("DB_PASS", "")

def conexionSql():
    if USUARIO and CONTRASENA:
        return f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVIDOR};DATABASE={BASE_DATOS};UID={USUARIO};PWD={CONTRASENA};TrustServerCertificate=yes"
    return f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={SERVIDOR};DATABASE={BASE_DATOS};Trusted_Connection=yes;TrustServerCertificate=yes"
