from flask import Flask, render_template, request, redirect

app = Flask(__name__)

@app.route('/')
def home():
    # Por ahora, si entran a la raíz, los mandamos al login
    return redirect('/login')

@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        correo = request.form.get('correo')
        password = request.form.get('password')
        
        # Credenciales de prueba (Mock)
        if correo == 'admin@usach.cl' and password == '1234':
            return "<h1>¡Bienvenido, Administrador de Equipoteca!</h1>"
        else:
            error = "Credenciales inválidas. Intenta de nuevo."
            
    return render_template('login.html', error=error)

if __name__ == '__main__':
    # host='0.0.0.0' es vital para que Docker exponga el puerto correctamente
    app.run(host='0.0.0.0', port=5000, debug=True)
