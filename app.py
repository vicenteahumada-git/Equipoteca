from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
import datetime
import json

app = Flask(__name__)
app.secret_key = 'clave_secreta_equipoteca'
app.config['JSON_AS_ASCII'] = False

def get_db_connection():
    return mysql.connector.connect(
        host='db', user='root', password='password', database='equipoteca_db', 
        charset='utf8mb4', collation='utf8mb4_spanish_ci', use_unicode=True
    )

@app.route('/')
def index():
    if 'rut' in session: return redirect(url_for('dashboard'))
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        correo = request.form.get('correo')
        password = request.form.get('password')
        try:
            conn = get_db_connection()
            cursor = conn.cursor(dictionary=True, buffered=True)
            for rol, tabla in [('admin', 'ADMINISTRADOR'), ('estudiante', 'ESTUDIANTE')]:
                cursor.execute(f"SELECT * FROM {tabla} WHERE correo = %s AND contrasena = %s", (correo, password))
                user = cursor.fetchone()
                if user:
                    session['rut'], session['rol'], session['correo'] = user['rut'], rol, correo
                    session['nombre'] = f"{user['nombre']} {user['apellido']}"
                    conn.close()
                    return redirect(url_for('dashboard'))
            flash("Correo o contraseña incorrectos.", "danger")
            conn.close()
        except Exception as e:
            flash(f"Error: {e}", "danger")
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    if 'rut' not in session: return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True, buffered=True)

    # --- AUTO-LIMPIEZA (Cronjob perezoso) ---
    # Caducar solicitudes pendientes cuyo bloque ya pasó
    cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Caducada' WHERE estado_solicitud = 'Pendiente' AND TIMESTAMP(fecha_inicio, hora_inicio) < NOW()")
    # Finalizar préstamos aprobados cuyo bloque ya terminó
    cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Finalizada' WHERE estado_solicitud = 'Aprobada' AND TIMESTAMP(fecha_fin, hora_fin) < NOW()")
    conn.commit()
    # ----------------------------------------
    
    if session['rol'] == 'estudiante':
        # Historial (Ahora trae biblioteca)
        cursor.execute("""
            SELECT S.id_solicitud, R.nombre as recurso, R.biblioteca, S.fecha_inicio, S.hora_inicio, S.hora_fin, S.estado_solicitud 
            FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso 
            WHERE S.rut_estudiante = %s AND S.estado_solicitud IN ('Pendiente', 'Rechazada', 'Caducada')
        """, (session['rut'],))
        mis_solicitudes = cursor.fetchall()
        for s in mis_solicitudes:
            s['fecha_str'] = s['fecha_inicio'].strftime('%d/%m/%Y')
            s['inicio_str'], s['fin_str'] = str(s['hora_inicio'])[:5], str(s['hora_fin'])[:5]
        
        # Préstamos Activos (Genera fecha ISO para la cuenta regresiva)
        cursor.execute("""
            SELECT S.id_solicitud, R.nombre as recurso, S.fecha_fin, S.hora_fin 
            FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso 
            WHERE S.rut_estudiante = %s AND S.estado_solicitud = 'Aprobada'
        """, (session['rut'],))
        prestamos = cursor.fetchall()
        for p in prestamos:
            p['fin_str'] = str(p['hora_fin'])[:5]
            # Combinar fecha y hora para el JS Countdown
            dt_fin = datetime.datetime.combine(p['fecha_fin'], datetime.datetime.min.time()) + p['hora_fin']
            p['iso_fin'] = dt_fin.isoformat()

        # JSON para bloquear frontend de la misma persona
        cursor.execute("SELECT id_recurso, fecha_inicio, hora_inicio as bloque FROM SOLICITUD WHERE rut_estudiante = %s AND estado_solicitud IN ('Pendiente', 'Aprobada')", (session['rut'],))
        reqs = cursor.fetchall()
        for r in reqs:
            r['fecha'] = r['fecha_inicio'].strftime('%Y-%m-%d')
            r['bloque'] = str(r['bloque'])[:5]
            del r['fecha_inicio'] # Evitar error de JSON en fechas
        mis_solicitudes_json = json.dumps(reqs)

        # Catálogo
        cursor.execute("""
            SELECT R.id_recurso, R.nombre, R.id_tipo, T.nombre_tipo, R.biblioteca, R.estado 
            FROM RECURSO R JOIN TIPO_RECURSO T ON R.id_tipo = T.id_tipo 
            WHERE R.estado = 'Disponible'
        """)
        todos_recursos = cursor.fetchall()
        
        # Obtener IDs de equipos portátiles que ya están prestados o pendientes
        cursor.execute("SELECT id_recurso FROM SOLICITUD WHERE estado_solicitud IN ('Aprobada', 'Pendiente') AND fecha_fin >= CURDATE()")
        equipos_ocupados = [row['id_recurso'] for row in cursor.fetchall()]

        bibliotecas_salas_pcs = {}
        equipos_por_tipo = {}
        
        for r in todos_recursos:
            if r['id_tipo'] in [1, 2]:
                bib = r['biblioteca']
                if bib not in bibliotecas_salas_pcs: bibliotecas_salas_pcs[bib] = {'salas': [], 'pcs': []}
                if r['id_tipo'] == 1: bibliotecas_salas_pcs[bib]['salas'].append(r)
                else: bibliotecas_salas_pcs[bib]['pcs'].append(r)
            else:
                # Filtrar si es equipo portátil (tipo 3 o 4) y alguien ya lo pidió
                if r['id_recurso'] not in equipos_ocupados:
                    tipo = r['nombre_tipo']
                    if tipo not in equipos_por_tipo: equipos_por_tipo[tipo] = []
                    equipos_por_tipo[tipo].append(r)
        
        conn.close()
        return render_template('dashboard.html', mis_solicitudes=mis_solicitudes, prestamos=prestamos, 
                               mis_solicitudes_json=mis_solicitudes_json, bibliotecas=bibliotecas_salas_pcs,
                               equipos=equipos_por_tipo, todos_recursos=todos_recursos)

    else:
        # VISTA ADMIN - Agrupado por Bibliotecas
        cursor.execute("""
            SELECT S.id_solicitud, E.nombre as est_nombre, E.apellido as est_apellido, R.nombre as recurso, R.id_tipo, R.biblioteca,
                   S.fecha_inicio, S.fecha_fin, S.hora_inicio, S.hora_fin 
            FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso JOIN ESTUDIANTE E ON S.rut_estudiante = E.rut
            WHERE S.estado_solicitud = 'Pendiente'
        """)
        pendientes_raw = cursor.fetchall()
        pendientes_admin = {}
        for p in pendientes_raw:
            bib = p['biblioteca']
            if bib not in pendientes_admin: pendientes_admin[bib] = []
            p['fecha_str'] = p['fecha_inicio'].strftime('%d/%m/%Y')
            p['fecha_fin_str'] = p['fecha_fin'].strftime('%d/%m/%Y')
            p['inicio_str'], p['fin_str'] = str(p['hora_inicio'])[:5], str(p['hora_fin'])[:5]
            pendientes_admin[bib].append(p)

        conn.close()
        return render_template('dashboard.html', pendientes_admin=pendientes_admin)

@app.route('/crear_solicitud', methods=['POST'])
def crear_solicitud():
    if session.get('rol') != 'estudiante': return redirect(url_for('login'))
    
    id_recurso, id_tipo, fecha_inicio = request.form.get('id_recurso'), int(request.form.get('id_tipo')), request.form.get('fecha_inicio')
    conn = get_db_connection()
    cursor = conn.cursor(buffered=True)
    
    try:
        if id_tipo in [1, 2]:
            hora_inicio, hora_fin = request.form.get('bloque').split('-')
            fecha_fin = fecha_inicio
        else:
            hora_inicio, hora_fin = '09:00:00', '21:00:00'
            fecha_fin = (datetime.datetime.strptime(fecha_inicio, '%Y-%m-%d') + datetime.timedelta(days=7)).strftime('%Y-%m-%d')

        cursor.execute("""
            INSERT INTO SOLICITUD (rut_estudiante, id_recurso, fecha_inicio, fecha_fin, hora_inicio, hora_fin, estado_solicitud)
            VALUES (%s, %s, %s, %s, %s, %s, 'Pendiente')
        """, (session['rut'], id_recurso, fecha_inicio, fecha_fin, hora_inicio, hora_fin))
        conn.commit()
        flash("Solicitud creada y en espera de revisión.", "success")
    except Exception as e:
        flash(f"Error: {e}", "danger")
    finally:
        conn.close()
    return redirect(url_for('dashboard'))

@app.route('/accion_solicitud/<int:id_solicitud>/<accion>', methods=['POST'])
def accion_solicitud(id_solicitud, accion):
    if 'rol' not in session: return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True, buffered=True)
    
    if session['rol'] == 'admin':
        if accion == 'aprobar':
            cursor.execute("SELECT S.id_recurso, S.fecha_inicio, S.hora_inicio, R.id_tipo FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso WHERE S.id_solicitud = %s", (id_solicitud,))
            sol = cursor.fetchone()
            cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Aprobada' WHERE id_solicitud = %s", (id_solicitud,))
            
            # Rechazar concurrencia
            if sol['id_tipo'] in [1, 2]:
                cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Rechazada' WHERE id_recurso = %s AND fecha_inicio = %s AND hora_inicio = %s AND id_solicitud != %s AND estado_solicitud = 'Pendiente'", (sol['id_recurso'], sol['fecha_inicio'], sol['hora_inicio'], id_solicitud))
            else:
                cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Rechazada' WHERE id_recurso = %s AND id_solicitud != %s AND estado_solicitud = 'Pendiente'", (sol['id_recurso'], id_solicitud))
            flash("Solicitud aprobada.", "success")
            
        elif accion == 'rechazar':
            cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Rechazada' WHERE id_solicitud = %s", (id_solicitud,))
            flash("Solicitud rechazada.", "warning")
            
    elif session['rol'] == 'estudiante':
        if accion in ['cancelar', 'borrar']:
            cursor.execute("DELETE FROM SOLICITUD WHERE id_solicitud = %s AND rut_estudiante = %s", (id_solicitud, session['rut']))
            flash("Solicitud retirada de tu historial.", "info")
            
    conn.commit()
    conn.close()
    return redirect(url_for('dashboard'))

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
