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

  Archivo:     Parques_Nacionales-ABM.py
  Descripcion:  Programa desarrollado en lenguaje Python que permite visualizar,
                agregar, editar y eliminar atracciones turísticas desde una 
                interfaz gráfica de escritorio, conectada a una base de datos 
                SQL Server. Así también incluye importación desde archivos CSV, 
                generación de reporte de matriz de visitas en formato XML y 
                reporte de deudores mostrado por pantalla.
================================================================================
'''

import re
import json
import urllib.request
import xml.etree.ElementTree as ET
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from datetime import datetime, date

import pyodbc
import config

'''
=============================================================================
Variables Globales
=============================================================================
'''

TIPOS_ATRACCION = ["Gratuita", "Paga", "Tour Guiado"]


tabla_atracciones = None

log_importacion = None

tabla_reportes = None
combo_reporte = None
xml_actual = ""


dialogo_combo_parque = None
dialogo_entrada_nombre = None
dialogo_combo_tipo = None
dialogo_entrada_costo = None
dialogo_entrada_duracion = None
dialogo_entrada_horario = None
dialogo_entrada_cupo = None
dialogo_resultado = None  

parques_en_memoria = []

'''
=============================================================================
 BASE DE DATOS
=============================================================================
'''
def db_conectar():
    return pyodbc.connect(config.conexionSql(), autocommit=True)


def db_obtener_parques():
    conn = db_conectar()
    cur = conn.execute(
        "SELECT id_parque, nombre FROM parques.Parque ORDER BY nombre"
    )
    filas = cur.fetchall()
    conn.close()
    return filas


def db_obtener_atracciones():
    conn = db_conectar()
    cur = conn.execute(
        "SELECT a.id_atraccion, a.nombre, a.tipo, a.costo, a.duracion, "
        "a.horario_inicio, a.cupo_maximo, p.nombre AS parque, a.id_parque "
        "FROM actividades.Atraccion a "
        "INNER JOIN parques.Parque p ON p.id_parque = a.id_parque "
        "ORDER BY a.id_parque, a.id_atraccion"
    )
    filas = cur.fetchall()
    conn.close()
    return filas


def db_insertar_atraccion(id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo):
    conn = db_conectar()
    conn.execute(
        "EXEC actividades.sp_InsertarAtraccion "
        "@p_id_parque=?, @p_nombre=?, @p_tipo=?, @p_costo=?, @p_duracion=?, @p_horario_inicio=?, @p_cupo_maximo=?",
        id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo,
    )
    conn.close()


def db_modificar_atraccion(id_atraccion, id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo):
    conn = db_conectar()
    conn.execute(
        "EXEC actividades.sp_ModificarAtraccion "
        "@id_atraccion=?, @id_parque=?, @nombre=?, @tipo=?, @costo=?, @duracion=?, @horario_inicio=?, @cupo_maximo=?",
        id_atraccion, id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo,
    )
    conn.close()


def db_borrar_atraccion(id_atraccion):
    conn = db_conectar()
    conn.execute("EXEC actividades.sp_BorrarAtraccion @p_id_atraccion=?", id_atraccion)
    conn.close()


def db_obtener_tasas():
    conn = db_conectar()
    cur = conn.execute(
        "SELECT m.codigo_iso, m.nombre, tc.tasa_a_peso, tc.fecha_vigencia "
        "FROM ventas.TasaCambio tc "
        "INNER JOIN ventas.Moneda m ON m.id_moneda = tc.id_moneda "
        "ORDER BY m.codigo_iso, tc.fecha_vigencia DESC"
    )
    filas = cur.fetchall()
    conn.close()
    return filas


def db_obtener_monedas_existentes():
    conn = db_conectar()
    cur = conn.execute("SELECT codigo_iso FROM ventas.Moneda")
    filas = cur.fetchall()
    conn.close()
    return {f.codigo_iso for f in filas}


def db_obtener_id_moneda(codigo_iso):
    conn = db_conectar()
    cur = conn.execute("SELECT id_moneda FROM ventas.Moneda WHERE codigo_iso = ?", codigo_iso)
    fila = cur.fetchone()
    conn.close()
    return fila.id_moneda if fila else None


def db_reporte_matriz_visitas():
    conn = db_conectar()
    cur = conn.execute("EXEC ventas.sp_ReporteMatrizVisitas")
    filas = cur.fetchall()
    conn.close()
    return filas


def db_reporte_deudores():
    conn = db_conectar()
    cur = conn.execute("EXEC concesiones.sp_ReporteDeudores")
    filas = cur.fetchall()
    conn.close()
    return filas

'''
=============================================================================
 Tabla Atracciones
============================================================================
'''

def cargar_atracciones():
    for row in tabla_atracciones.get_children():
        tabla_atracciones.delete(row)
    try:
        filas = db_obtener_atracciones()
        for i, f in enumerate(filas):
            tag = "even" if i % 2 == 0 else "odd"
            horario = str(f.horario_inicio)[:5] if f.horario_inicio else ""
            tabla_atracciones.insert("", "end", tags=(tag,), values=(
                f.id_atraccion, f.nombre, f.tipo, f.costo, f.duracion,
                horario, f.cupo_maximo, f.parque, f.id_parque
            ))
    except pyodbc.Error as e:
        messagebox.showerror("Error BD", str(e))


def obtener_atraccion_seleccionada():
    sel = tabla_atracciones.selection()
    if not sel:
        messagebox.showwarning("Seleccionar", "Seleccioná una atracción de la lista.")
        return None
    return tabla_atracciones.item(sel[0])["values"]


def cargar_parques_en_combo():
    global parques_en_memoria
    try:
        parques_en_memoria = db_obtener_parques()
    except pyodbc.Error:
        parques_en_memoria = []
    valores = [f"{p.id_parque} - {p.nombre}" for p in parques_en_memoria]
    dialogo_combo_parque["values"] = valores


def nueva_atraccion():
    abrir_dialogo("Nueva Atracción")
    if dialogo_resultado is None:
        return
    id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo = dialogo_resultado
    try:
        db_insertar_atraccion(id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo)
        cargar_atracciones()
        messagebox.showinfo("OK", "Atracción creada correctamente.")
    except pyodbc.Error as e:
        messagebox.showerror("Error", str(e))


def editar_atraccion():
    vals = obtener_atraccion_seleccionada()
    if vals is None:
        return
    abrir_dialogo("Editar Atracción", vals[8], vals[1], vals[2], vals[3], vals[4], vals[5], vals[6])
    if dialogo_resultado is None:
        return
    id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo = dialogo_resultado
    try:
        db_modificar_atraccion(vals[0], id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo)
        cargar_atracciones()
        messagebox.showinfo("OK", "Atracción actualizada correctamente.")
    except pyodbc.Error as e:
        messagebox.showerror("Error", str(e))


def eliminar_atraccion():
    vals = obtener_atraccion_seleccionada()
    if vals is None:
        return
    if not messagebox.askyesno("Confirmar", f"Eliminar '{vals[1]}'?"):
        return
    try:
        db_borrar_atraccion(vals[0])
        cargar_atracciones()
        messagebox.showinfo("OK", "Atracción eliminada.")
    except pyodbc.Error as e:
        messagebox.showerror("Error", str(e))

'''
=============================================================================
 Ventana Atracciones 
=============================================================================
'''
def dialogo_aceptar(ventana):
    global dialogo_resultado

    texto = dialogo_combo_parque.get()
    id_parque = None
    for p in parques_en_memoria:
        if texto.startswith(str(p.id_parque)):
            id_parque = p.id_parque
            break
    if id_parque is None and parques_en_memoria:
        messagebox.showerror("Error", "Seleccioná un parque válido.", parent=ventana)
        return

    nombre = dialogo_entrada_nombre.get().strip()
    tipo   = dialogo_combo_tipo.get()

    try:
        costo = float(dialogo_entrada_costo.get().strip())
    except ValueError:
        messagebox.showerror("Error", "Costo debe ser un número.", parent=ventana)
        return

    try:
        duracion = int(dialogo_entrada_duracion.get().strip())
    except ValueError:
        messagebox.showerror("Error", "Duración debe ser un número entero.", parent=ventana)
        return

    horario_inicio = dialogo_entrada_horario.get().strip()
    if not horario_inicio:
        messagebox.showerror("Error", "Horario de inicio es obligatorio.", parent=ventana)
        return
    if not re.match(r'^([01]\d|2[0-3]):([0-5]\d)(?::([0-5]\d))?$', horario_inicio):
        messagebox.showerror("Error", "Horario de inicio debe ser HH:MM o HH:MM:SS.", parent=ventana)
        return
    if len(horario_inicio) == 5:
        horario_inicio += ":00"

    try:
        cupo = int(dialogo_entrada_cupo.get().strip())
    except ValueError:
        messagebox.showerror("Error", "Cupo máximo debe ser un número entero.", parent=ventana)
        return

    if not nombre or not tipo:
        messagebox.showerror("Error", "Completá todos los campos.", parent=ventana)
        return
    if costo < 0:
        messagebox.showerror("Error", "Costo no puede ser negativo.", parent=ventana)
        return
    if duracion <= 0:
        messagebox.showerror("Error", "Duración debe ser mayor a 0.", parent=ventana)
        return
    if cupo <= 0:
        messagebox.showerror("Error", "Cupo máximo debe ser mayor a 0.", parent=ventana)
        return
    if tipo == "Gratuita" and costo != 0:
        messagebox.showerror("Error", "Una atracción Gratuita debe tener costo 0.", parent=ventana)
        return

    dialogo_resultado = (id_parque, nombre, tipo, costo, duracion, horario_inicio, cupo)
    ventana.destroy()


def dialogo_cancelar(ventana):
    global dialogo_resultado
    dialogo_resultado = None
    ventana.destroy()


def abrir_dialogo(titulo, id_parque=None, nombre="", tipo="", costo="", duracion="", horario_inicio="", cupo=""):
    global dialogo_combo_parque, dialogo_entrada_nombre, dialogo_combo_tipo
    global dialogo_entrada_costo, dialogo_entrada_duracion, dialogo_entrada_horario, dialogo_entrada_cupo, dialogo_resultado

    dialogo_resultado = None

    ventana = tk.Toplevel()
    ventana.title(titulo)
    ventana.grab_set()

    frame = ttk.Frame(ventana, padding=15)
    frame.pack(fill="both", expand=True)

    ttk.Label(frame, text="Parque:").grid(row=0, column=0, sticky="w", pady=2)
    dialogo_combo_parque = ttk.Combobox(frame, state="readonly", width=47)
    dialogo_combo_parque.grid(row=0, column=1, pady=2)
    cargar_parques_en_combo()
    if id_parque is not None:
        for i, p in enumerate(parques_en_memoria):
            if p.id_parque == id_parque:
                dialogo_combo_parque.current(i)
                break

    ttk.Label(frame, text="Nombre:").grid(row=1, column=0, sticky="w", pady=2)
    dialogo_entrada_nombre = ttk.Entry(frame, width=50)
    dialogo_entrada_nombre.grid(row=1, column=1, pady=2)
    dialogo_entrada_nombre.insert(0, nombre)

    ttk.Label(frame, text="Tipo:").grid(row=2, column=0, sticky="w", pady=2)
    dialogo_combo_tipo = ttk.Combobox(frame, state="readonly", width=47)
    dialogo_combo_tipo["values"] = TIPOS_ATRACCION
    dialogo_combo_tipo.grid(row=2, column=1, pady=2)
    if tipo:
        dialogo_combo_tipo.set(tipo)

    ttk.Label(frame, text="Costo ($):").grid(row=3, column=0, sticky="w", pady=2)
    dialogo_entrada_costo = ttk.Entry(frame, width=20)
    dialogo_entrada_costo.grid(row=3, column=1, sticky="w", pady=2)
    dialogo_entrada_costo.insert(0, str(costo) if costo else "0")

    ttk.Label(frame, text="Duración (min):").grid(row=4, column=0, sticky="w", pady=2)
    dialogo_entrada_duracion = ttk.Entry(frame, width=20)
    dialogo_entrada_duracion.grid(row=4, column=1, sticky="w", pady=2)
    dialogo_entrada_duracion.insert(0, str(duracion) if duracion else "60")

    ttk.Label(frame, text="Horario inicio:").grid(row=5, column=0, sticky="w", pady=2)
    dialogo_entrada_horario = ttk.Entry(frame, width=20)
    dialogo_entrada_horario.grid(row=5, column=1, sticky="w", pady=2)
    dialogo_entrada_horario.insert(0, horario_inicio if horario_inicio else "08:00")

    ttk.Label(frame, text="Cupo máximo:").grid(row=6, column=0, sticky="w", pady=2)
    dialogo_entrada_cupo = ttk.Entry(frame, width=20)
    dialogo_entrada_cupo.grid(row=6, column=1, sticky="w", pady=2)
    dialogo_entrada_cupo.insert(0, str(cupo) if cupo else "50")

    ttk.Button(frame, text="Aceptar",  command=lambda: dialogo_aceptar(ventana)).grid(row=7, column=0, pady=15)
    ttk.Button(frame, text="Cancelar", command=lambda: dialogo_cancelar(ventana)).grid(row=7, column=1, sticky="w", pady=15)

    ventana.wait_window()

'''
=============================================================================
 Importar desde API 
=============================================================================
'''

def log_importar(msg):
    log_importacion.configure(state="normal")
    log_importacion.insert("end", msg + "\n")
    log_importacion.see("end")
    log_importacion.configure(state="disabled")


def importar_tasas():
    log_importacion.configure(state="normal")
    log_importacion.delete("1.0", "end")
    log_importacion.configure(state="disabled")

    log_importar("Descargando tasas de cambio desde dolarapi.com...")

    try:
        req = urllib.request.Request(
            "https://dolarapi.com/v1/cotizaciones",
            headers={"User-Agent": "ParquesNacionales-ABM/1.0"}
        )
        with urllib.request.urlopen(req, timeout=15) as resp:
            datos = json.loads(resp.read().decode("utf-8"))
    except Exception as e:
        log_importar(f"ERROR: No se pudo descargar - {e}")
        messagebox.showerror("Error", f"No se pudo descargar tasas de cambio:\n{e}")
        return

    solo_oficial = [d for d in datos if d.get("casa") == "oficial"]
    if not solo_oficial:
        log_importar("ERROR: No se encontraron tasas oficiales en la respuesta.")
        return

    monedas_json = {d.get("moneda") for d in solo_oficial if d.get("moneda")}

    try:
        monedas_bd = db_obtener_monedas_existentes()
    except pyodbc.Error as e:
        log_importar(f"ERROR al consultar monedas: {e}")
        messagebox.showerror("Error BD", str(e))
        return

    monedas_validas  = monedas_json & monedas_bd
    monedas_saltadas = monedas_json - monedas_bd

    log_importar(f"Monedas en API: {', '.join(sorted(monedas_json))}")
    if monedas_validas:
        log_importar(f"A procesar: {', '.join(sorted(monedas_validas))}")
    else:
        log_importar("Ninguna moneda existe en la base. No se importara nada.")
        return
    if monedas_saltadas:
        log_importar(f"SALTADAS (no estan en ventas.Moneda): {', '.join(sorted(monedas_saltadas))}")

    log_importar("")
    log_importar("Procesando tasas de cambio...")

    hoy = date.today()
    insertadas = 0
    actualizadas = 0
    errores = 0

    for d in solo_oficial:
        moneda = d["moneda"]
        if moneda not in monedas_validas:
            continue
        tasa = (d["compra"] + d["venta"]) / 2

        try:
            id_moneda = db_obtener_id_moneda(moneda)
            if id_moneda is None:
                log_importar(f"  {moneda}: saltada (no encontrada en BD)")
                errores += 1
                continue

            conn = db_conectar()
            cur = conn.execute(
                "SELECT id_tasa FROM ventas.TasaCambio WHERE id_moneda = ? AND fecha_vigencia = ?",
                id_moneda, hoy
            )
            existente = cur.fetchone()
            if existente:
                conn.execute(
                    "EXEC ventas.sp_ModificarTasaCambio @id_tasa=?, @id_moneda=?, @fecha_vigencia=?, @tasa_a_peso=?",
                    existente.id_tasa, id_moneda, hoy, tasa
                )
                actualizadas += 1
                log_importar(f"  {moneda}: actualizada ({tasa:.4f})")
            else:
                conn.execute(
                    "EXEC ventas.sp_InsertarTasaCambio @p_id_moneda=?, @p_fecha_vigencia=?, @p_tasa_a_peso=?",
                    id_moneda, hoy, tasa
                )
                insertadas += 1
                log_importar(f"  {moneda}: insertada ({tasa:.4f})")
            conn.close()
        except pyodbc.Error as e:
            errores += 1
            log_importar(f"  {moneda}: ERROR - {e}")

    log_importar("")
    log_importar("--- Tasas de cambio actuales ---")
    try:
        filas = db_obtener_tasas()
        if filas:
            ultimas = {}
            for f in filas:
                if f.codigo_iso not in ultimas:
                    ultimas[f.codigo_iso] = f
            log_importar(f"{'Moneda':<10} {'Tasa':>10} {'Vigencia':>12}")
            log_importar("-" * 35)
            for iso in sorted(ultimas):
                f = ultimas[iso]
                log_importar(f"{f.codigo_iso:<10} {f.tasa_a_peso:>10.4f} {str(f.fecha_vigencia):>12}")
            log_importar("")
            log_importar(f"Total de monedas con tasa vigente: {len(ultimas)}")
        else:
            log_importar("(no hay tasas cargadas)")
    except pyodbc.Error as e:
        log_importar(f"ERROR al consultar tasas: {e}")

    resumen = f"Insertadas: {insertadas} | Actualizadas: {actualizadas} | Errores: {errores}"
    log_importar("")
    log_importar(resumen)
    messagebox.showinfo("Resultado", resumen)

'''
=============================================================================
 Reportes
=============================================================================
'''

def ejecutar_reporte():
    global xml_actual
    xml_actual = ""
    for row in tabla_reportes.get_children():
        tabla_reportes.delete(row)

    try:
        idx = combo_reporte.current()
        if idx == 0:
            filas = db_reporte_deudores()
            if not filas:
                tabla_reportes["columns"] = ("mensaje",)
                tabla_reportes.heading("mensaje", text="")
                tabla_reportes.column("mensaje", width=200)
                tabla_reportes.insert("", "end", values=("(sin datos)",))
                return

            cols = [c[0] for c in filas[0].cursor_description]

            if "MesAdeudado" in cols:
                columnas = ("Parque", "Empresa", "Mes", "Esperado", "Pagado", "Deuda")
                tabla_reportes["columns"] = columnas
                for c in columnas:
                    tabla_reportes.heading(c, text=c)
                tabla_reportes.column("Parque",  width=150)
                tabla_reportes.column("Empresa", width=180)
                tabla_reportes.column("Mes",     width=100)
                tabla_reportes.column("Esperado", width=110, anchor="e")
                tabla_reportes.column("Pagado",   width=110, anchor="e")
                tabla_reportes.column("Deuda",    width=110, anchor="e")

                for f in filas:
                    mes = f.MesAdeudado
                    if hasattr(mes, 'strftime'):
                        mes = mes.strftime('%Y-%m')
                    tabla_reportes.insert("", "end", values=(
                        f.Parque, f.Empresa, mes,
                        f"${f.MontoEsperado:,.2f}",
                        f"${f.MontoPagado:,.2f}",
                        f"${f.Deuda:,.2f}",
                    ))
            else:
                columnas = ("Parque", "Empresa", "Actividad", "Inicio", "Fin",
                            "Pago Mens.", "Meses Adeud.", "Deuda Total")
                tabla_reportes["columns"] = columnas
                for c in columnas:
                    tabla_reportes.heading(c, text=c)
                tabla_reportes.column("Parque",       width=150)
                tabla_reportes.column("Empresa",      width=180)
                tabla_reportes.column("Actividad",    width=120)
                tabla_reportes.column("Inicio",       width=110)
                tabla_reportes.column("Fin",          width=110)
                tabla_reportes.column("Pago Mens.",   width=110, anchor="e")
                tabla_reportes.column("Meses Adeud.", width=120, anchor="e")
                tabla_reportes.column("Deuda Total",  width=120, anchor="e")

                for f in filas:
                    inicio = f.FechaInicio.strftime('%Y-%m-%d') if hasattr(f.FechaInicio, 'strftime') else str(f.FechaInicio)
                    fin = f.FechaFin.strftime('%Y-%m-%d') if hasattr(f.FechaFin, 'strftime') else str(f.FechaFin)
                    tabla_reportes.insert("", "end", values=(
                        f.Parque, f.Empresa, f.Actividad, inicio, fin,
                        f"${f.PagoMensual:,.2f}",
                        f.MesesAdeudados,
                        f"${f.DeudaTotal:,.2f}",
                    ))
        else:
            filas = db_reporte_matriz_visitas()
            if filas and filas[0][0]:
                xml_actual = filas[0][0]
                root = ET.fromstring(xml_actual)

                meses = ["Ene", "Feb", "Mar", "Abr", "May", "Jun",
                         "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
                columnas = ("Parque",) + tuple(meses)
                tabla_reportes["columns"] = columnas
                for c in columnas:
                    tabla_reportes.heading(c, text=c)
                tabla_reportes.column("Parque", width=180)
                for m in meses:
                    tabla_reportes.column(m, width=80, anchor="e")

                for parque in root.findall("Parque"):
                    nom = parque.findtext("Parque", "")
                    vals = [nom]
                    for m in meses:
                        v = parque.findtext(m, "0")
                        vals.append(v)
                    tabla_reportes.insert("", "end", values=tuple(vals))
            else:
                tabla_reportes["columns"] = ("mensaje",)
                tabla_reportes.heading("mensaje", text="")
                tabla_reportes.column("mensaje", width=200)
                tabla_reportes.insert("", "end", values=("(sin datos)",))
    except Exception as e:
        messagebox.showerror("Error", f"{type(e).__name__}: {e}")


def guardar_xml():
    if not xml_actual:
        messagebox.showwarning("Sin datos", "Ejecutá un reporte primero.")
        return
    ruta = filedialog.asksaveasfilename(
        defaultextension=".xml",
        filetypes=[("XML", "*.xml")],
        initialfile=f"reporte_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xml",
    )
    if not ruta:
        return
    try:
        with open(ruta, "w", encoding="utf-8") as f:
            f.write(xml_actual)
        messagebox.showinfo("OK", f"XML guardado en:\n{ruta}")
    except Exception as e:
        messagebox.showerror("Error", str(e))

'''
=============================================================================
 Interfaz
=============================================================================
'''

def construir_tab_atracciones(parent):
    global tabla_atracciones

    frame_botones = ttk.Frame(parent)
    frame_botones.pack(fill="x", pady=(0, 10))

    ttk.Button(frame_botones, text="+ Nueva",   command=nueva_atraccion).pack(side="left", padx=2)
    ttk.Button(frame_botones, text="Editar",    command=editar_atraccion).pack(side="left", padx=2)
    ttk.Button(frame_botones, text="Eliminar",  command=eliminar_atraccion).pack(side="left", padx=2)
    ttk.Button(frame_botones, text="Refrescar", command=cargar_atracciones).pack(side="right", padx=2)

    # Frame contenedor para Treeview + scrollbar
    frame_tree = ttk.Frame(parent)
    frame_tree.pack(fill="both", expand=True)
    frame_tree.rowconfigure(0, weight=1)
    frame_tree.columnconfigure(0, weight=1)

    cols = ("id", "nombre", "tipo", "costo", "duracion", "horario", "cupo", "parque")
    tabla_atracciones = ttk.Treeview(frame_tree, columns=cols, show="headings", selectmode="browse")
    tabla_atracciones.heading("id",       text="ID")
    tabla_atracciones.heading("nombre",   text="Nombre")
    tabla_atracciones.heading("tipo",     text="Tipo")
    tabla_atracciones.heading("costo",    text="Costo ($)")
    tabla_atracciones.heading("duracion", text="Duración (min)")
    tabla_atracciones.heading("horario",  text="Horario")
    tabla_atracciones.heading("cupo",     text="Cupo máx")
    tabla_atracciones.heading("parque",   text="Parque")
    tabla_atracciones.column("id",       width=50)
    tabla_atracciones.column("nombre",   width=180)
    tabla_atracciones.column("tipo",     width=120)
    tabla_atracciones.column("costo",    width=100)
    tabla_atracciones.column("duracion", width=100)
    tabla_atracciones.column("horario",  width=80)
    tabla_atracciones.column("cupo",     width=90)
    tabla_atracciones.column("parque",   width=180)
    tabla_atracciones.grid(row=0, column=0, sticky="nsew")

    scroll = ttk.Scrollbar(frame_tree, orient="vertical", command=tabla_atracciones.yview)
    scroll.grid(row=0, column=1, sticky="ns")
    tabla_atracciones.configure(yscrollcommand=scroll.set)

    tabla_atracciones.tag_configure("even", background="#2a2a2a")
    tabla_atracciones.tag_configure("odd",  background="#1a1a1a")

    tabla_atracciones.bind("<Double-1>", lambda e: editar_atraccion())


def construir_tab_importar(parent):
    global log_importacion

    ttk.Label(parent, text="Importar Tasas de Cambio", font=("Arial", 14)).pack(pady=20)
    ttk.Label(parent, text="Descarga automatica desde dolarapi.com (tasas oficiales)").pack()
    ttk.Button(parent, text="Descargar e importar", command=importar_tasas).pack(pady=20)

    log_importacion = tk.Text(parent, height=20, state="disabled", bg="#1a1a1a", fg="#eeeeee", insertbackground="#eeeeee", font=("Consolas", 10))
    log_importacion.pack(fill="both", expand=True, padx=20, pady=10)


def construir_tab_reportes(parent):
    global tabla_reportes, combo_reporte

    ttk.Label(parent, text="Reportes", font=("Arial", 14)).pack(pady=20)

    frame_ctrls = ttk.Frame(parent)
    frame_ctrls.pack(fill="x", padx=20)

    ttk.Label(frame_ctrls, text="Reporte:").pack(side="left")

    combo_reporte = ttk.Combobox(frame_ctrls, state="readonly", width=40)
    combo_reporte["values"] = [
        "Deudores",
        "Matriz de Visitas (XML)",
    ]
    combo_reporte.current(0)
    combo_reporte.pack(side="left", padx=10)

    ttk.Button(frame_ctrls, text="Ejecutar",       command=ejecutar_reporte).pack(side="left", padx=5)
    ttk.Button(frame_ctrls, text="Guardar XML...", command=guardar_xml).pack(side="left", padx=5)

    ttk.Label(parent, text="Resultado:").pack(anchor="w", padx=20, pady=(20, 0))

    frame_tabla = ttk.Frame(parent)
    frame_tabla.pack(fill="both", expand=True, padx=20, pady=5)
    frame_tabla.rowconfigure(0, weight=1)
    frame_tabla.columnconfigure(0, weight=1)

    tabla_reportes = ttk.Treeview(frame_tabla, show="headings", style="Treeview")
    tabla_reportes.grid(row=0, column=0, sticky="nsew")

    scroll_y = ttk.Scrollbar(frame_tabla, orient="vertical", command=tabla_reportes.yview)
    scroll_y.grid(row=0, column=1, sticky="ns")
    tabla_reportes.configure(yscrollcommand=scroll_y.set)


def aplicar_tema_oscuro(ventana):
    estilo = ttk.Style()
    estilo.theme_use("clam")
    bg  = "#0a0a0a"
    fg  = "#eeeeee"
    sel = "#666666"
    sup = "#1a1a1a"
    estilo.configure(".",           background=bg,  foreground=fg,  fieldbackground=sup, borderwidth=0)
    estilo.configure("TFrame",      background=bg)
    estilo.configure("TLabel",      background=bg,  foreground=fg)
    estilo.configure("TButton",     background=sup, foreground=fg,  bordercolor=fg, focuscolor="none")
    estilo.map("TButton",           background=[("active", sel)])
    estilo.configure("TEntry",      fieldbackground=sup, foreground=fg, insertcolor=fg)
    estilo.configure("TCombobox",   fieldbackground=sup, foreground=fg, arrowcolor=fg)
    estilo.map("TCombobox",         fieldbackground=[("readonly", sup)])
    estilo.configure("Treeview", background=sup, foreground=fg, fieldbackground=sup, font=("Segoe UI", 10), rowheight=28)
    estilo.map("Treeview", background=[("selected", sel)], foreground=[("selected", bg)])
    estilo.configure("Treeview.Heading", background=bg, foreground=fg, bordercolor=sup, font=("Segoe UI", 10, "bold"))
    estilo.configure("TNotebook",   background=bg, bordercolor=sup)
    estilo.configure("TNotebook.Tab", background=sup, foreground=fg, padding=[10, 4])
    estilo.map("TNotebook.Tab",     background=[("selected", sel)])
    estilo.configure("Vertical.TScrollbar",   background="#888888", troughcolor="#2a2a2a", width=10, relief="flat", borderwidth=0)
    estilo.configure("Horizontal.TScrollbar", background="#888888", troughcolor="#2a2a2a", width=10, relief="flat", borderwidth=0)
    estilo.map("Vertical.TScrollbar",   background=[("active", "#aaaaaa")])
    estilo.map("Horizontal.TScrollbar", background=[("active", "#aaaaaa")])
    ventana.configure(bg=bg)


def construir_ventana_principal():
    ventana = tk.Tk()
    ventana.title("Parques Nacionales")
    ventana.geometry("1000x650")
    aplicar_tema_oscuro(ventana)
    ttk.Sizegrip(ventana).pack(side="bottom", anchor="se")

    notebook = ttk.Notebook(ventana)
    notebook.pack(fill="both", expand=True, padx=10, pady=10)

    tab_atracciones = ttk.Frame(notebook)
    tab_importar    = ttk.Frame(notebook)
    tab_reportes    = ttk.Frame(notebook)

    notebook.add(tab_atracciones, text="Atracciones")
    notebook.add(tab_importar,    text="Importar JSON")
    notebook.add(tab_reportes,    text="Reportes")

    construir_tab_atracciones(tab_atracciones)
    construir_tab_importar(tab_importar)
    construir_tab_reportes(tab_reportes)

    return ventana


def main():
    ventana = construir_ventana_principal()
    cargar_atracciones()
    ventana.mainloop()


if __name__ == "__main__":
    main()
