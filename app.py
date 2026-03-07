from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector
from datetime import datetime, timedelta

app = Flask(__name__)
app.secret_key = 'clave_secreta_equipoteca'
app.config['JSON_AS_ASCII'] = False

def get_db_connection():
    # ¡AQUÍ ESTÁ LA SOLUCIÓN DEL ESPAÑOL! (use_unicode=True y collation)
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
            cursor = conn.cursor(dictionary=True)
            for rol, tabla in [('admin', 'ADMINISTRADOR'), ('estudiante', 'ESTUDIANTE')]:
                cursor.execute(f"SELECT * FROM {tabla} WHERE correo = %s AND contrasena = %s", (correo, password))
                user = cursor.fetchone()
                if user:
                    session['rut'] = user['rut']
                    session['nombre'] = f"{user['nombre']} {user['apellido']}"
                    session['rol'] = rol
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
    cursor = conn.cursor(dictionary=True)
    
    if session['rol'] == 'estudiante':
        # Catálogo
        cursor.execute("SELECT R.id_recurso, R.nombre, R.id_tipo, T.nombre_tipo FROM RECURSO R JOIN TIPO_RECURSO T ON R.id_tipo = T.id_tipo WHERE R.estado = 'Disponible'")
        recursos = cursor.fetchall()
        
        # Historial (Pendientes y Rechazadas)
        cursor.execute("""
            SELECT S.id_solicitud, R.nombre as recurso, DATE_FORMAT(S.fecha_inicio, '%d/%m/%Y') as fecha, 
                   TIME_FORMAT(S.hora_inicio, '%H:%i') as inicio, TIME_FORMAT(S.hora_fin, '%H:%i') as fin, S.estado_solicitud 
            FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso 
            WHERE S.rut_estudiante = %s AND S.estado_solicitud IN ('Pendiente', 'Rechazada')
        """, (session['rut'],))
        mis_solicitudes = cursor.fetchall()
        
        # Préstamos Activos
        cursor.execute("""
            SELECT S.id_solicitud, R.nombre as recurso, DATE_FORMAT(S.fecha_fin, '%Y-%m-%d') as fecha_fin_raw, 
                   TIME_FORMAT(S.hora_fin, '%H:%i') as fin 
            FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso 
            WHERE S.rut_estudiante = %s AND S.estado_solicitud = 'Aprobada'
        """, (session['rut'],))
        prestamos = cursor.fetchall()
        
        conn.close()
        return render_template('dashboard.html', recursos=recursos, mis_solicitudes=mis_solicitudes, prestamos=prestamos)

    else:
        # Administrador: Ver pendientes
        cursor.execute("""
            SELECT S.id_solicitud, E.nombre as est_nombre, E.apellido as est_apellido, R.nombre as recurso, R.id_tipo,
                   DATE_FORMAT(S.fecha_inicio, '%d/%m/%Y') as fecha, DATE_FORMAT(S.fecha_fin, '%d/%m/%Y') as fecha_fin, 
                   TIME_FORMAT(S.hora_inicio, '%H:%i') as inicio, TIME_FORMAT(S.hora_fin, '%H:%i') as fin 
            FROM SOLICITUD S JOIN RECURSO R ON S.id_recurso = R.id_recurso JOIN ESTUDIANTE E ON S.rut_estudiante = E.rut
            WHERE S.estado_solicitud = 'Pendiente'
        """)
        pendientes_admin = cursor.fetchall()
        conn.close()
        return render_template('dashboard.html', pendientes_admin=pendientes_admin)

@app.route('/crear_solicitud', methods=['POST'])
def crear_solicitud():
    if session.get('rol') != 'estudiante': return redirect(url_for('login'))
    
    id_recurso = request.form.get('id_recurso')
    id_tipo = int(request.form.get('id_tipo'))
    fecha_inicio = request.form.get('fecha_inicio')
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    try:
        if id_tipo in [1, 2]:  # Salas y PCs
            bloque = request.form.get('bloque')
            hora_inicio, hora_fin = bloque.split('-')
            fecha_fin = fecha_inicio
            
            # Validar que no haya una solicitud aprobada en ese bloque
            cursor.execute("""
                SELECT * FROM SOLICITUD 
                WHERE id_recurso = %s AND fecha_inicio = %s AND hora_inicio = %s AND estado_solicitud = 'Aprobada'
            """, (id_recurso, fecha_inicio, hora_inicio))
            if cursor.fetchone():
                flash("Ese bloque horario ya está ocupado por otro estudiante.", "danger")
                return redirect(url_for('dashboard'))
                
        elif id_tipo == 3:  # Notebooks/Tablets
            hora_inicio, hora_fin = '09:00:00', '21:00:00'
            fecha_obj = datetime.strptime(fecha_inicio, '%Y-%m-%d')
            fecha_fin = (fecha_obj + timedelta(days=7)).strftime('%Y-%m-%d')
            
            # Validar que el equipo no esté prestado en ese rango de fechas
            cursor.execute("""
                SELECT * FROM SOLICITUD 
                WHERE id_recurso = %s AND estado_solicitud = 'Aprobada' AND fecha_fin >= %s AND fecha_inicio <= %s
            """, (id_recurso, fecha_inicio, fecha_fin))
            if cursor.fetchone():
                flash("Este equipo ya se encuentra prestado en esas fechas.", "danger")
                return redirect(url_for('dashboard'))

        cursor.execute("""
            INSERT INTO SOLICITUD (rut_estudiante, id_recurso, fecha_inicio, fecha_fin, hora_inicio, hora_fin, estado_solicitud)
            VALUES (%s, %s, %s, %s, %s, %s, 'Pendiente')
        """, (session['rut'], id_recurso, fecha_inicio, fecha_fin, hora_inicio, hora_fin))
        conn.commit()
        flash("Solicitud creada y en espera de revisión.", "success")
    except Exception as e:
        flash(f"Error del sistema: {e}", "danger")
    finally:
        conn.close()
        
    return redirect(url_for('dashboard'))

@app.route('/accion_solicitud/<int:id_solicitud>/<accion>', methods=['POST'])
def accion_solicitud(id_solicitud, accion):
    if 'rol' not in session: return redirect(url_for('login'))
    
    conn = get_db_connection()
    cursor = conn.cursor()
    
    if session['rol'] == 'admin':
        if accion == 'aprobar':
            cursor.execute("UPDATE SOLICITUD SET estado_solicitud = 'Aprobada' WHERE id_solicitud = %s", (id_solicitud,))
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
