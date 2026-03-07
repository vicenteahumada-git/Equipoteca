from flask import Flask, render_template, request, redirect
import mysql.connector

app = Flask(__name__)

# Función para conectarse a la caja de la base de datos
def get_db_connection():
    return mysql.connector.connect(
        host='db',              # Nombre del servicio en docker-compose
        user='root',
        password='password',    # La contraseña que definimos en docker-compose
        database='equipoteca_db'
    )

@app.route('/')
def home():
    return redirect('/login')

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        correo = request.form.get('correo')
        password = request.form.get('password')
        
        try:
            conn = get_db_connection()
            cursor = conn.cursor(dictionary=True)
            
            # 1. Buscar en la tabla ADMINISTRADOR
            cursor.execute("SELECT * FROM ADMINISTRADOR WHERE correo = %s AND contrasena = %s", (correo, password))
            admin = cursor.fetchone()
            
            if admin:
                conn.close()
                return f"<h1>¡Bienvenido Administrador, {admin['nombre']}!</h1>"
            
            # 2. Si no es admin, buscar en la tabla ESTUDIANTE
            cursor.execute("SELECT * FROM ESTUDIANTE WHERE correo = %s AND contrasena = %s", (correo, password))
            estudiante = cursor.fetchone()
            
            if estudiante:
                conn.close()
                return f"<h1>¡Bienvenido Estudiante, {estudiante['nombre']}!</h1>"
            
            # Si no está en ninguna, las credenciales son malas
            error = "Credenciales inválidas. Intenta de nuevo."
            conn.close()
            
        except mysql.connector.Error as err:
            error = f"Error de base de datos: {err}"

    return render_template('login.html', error=error)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
