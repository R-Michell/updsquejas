import 'package:flutter/material.dart'; // Importa los widgets de Material Design de Flutter
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth para autenticación
import '../../routes.dart'; // Importa las rutas definidas para la navegación en la aplicación

class LoginAdminPage extends StatefulWidget { // Define una pantalla con estado para manejar cambios dinámicos
  const LoginAdminPage({super.key}); // Constructor constante con clave opcional

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState(); // Crea el estado asociado
}

class _LoginAdminPageState extends State<LoginAdminPage> {
  final TextEditingController _emailController = TextEditingController(); // Controlador para el campo de correo
  final TextEditingController _passwordController = TextEditingController(); // Controlador para el campo de contraseña
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Clave para gestionar el formulario
  bool _isLoading = false; // Indicador de estado de carga durante el login

  Future<void> _login() async { // Función asíncrona para manejar el inicio de sesión
    if (!_formKey.currentState!.validate()) return; // Valida el formulario, retorna si hay errores

    setState(() => _isLoading = true); // Activa el estado de carga

    try {
      // Intenta autenticar al usuario con Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // Correo electrónico ingresado (sin espacios)
        password: _passwordController.text, // Contraseña ingresada
      );
      if (mounted) { // Verifica si el widget sigue activo
        // Navega al dashboard de administrador, reemplazando la pantalla actual
        Navigator.pushReplacementNamed(context, Routes.dashboardAdmin);
      }
    } on FirebaseAuthException catch (e) { // Captura errores de autenticación
      ScaffoldMessenger.of(context).showSnackBar( // Muestra una notificación con el error
        SnackBar(content: Text(e.message ?? 'Error de autenticación')),
      );
    } finally {
      setState(() => _isLoading = false); // Desactiva el estado de carga
    }
  }

  @override
  Widget build(BuildContext context) { // Método que construye la interfaz de la pantalla
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5), // Fondo gris claro para la pantalla
      body: Center( // Centra el contenido en la pantalla
        child: Container( // Contenedor principal para el formulario
          constraints: const BoxConstraints(maxWidth: 500), // Limita el ancho máximo a 500 píxeles
          padding: const EdgeInsets.all(24), // Espaciado interno de 24 píxeles
          margin: const EdgeInsets.all(16), // Margen externo de 16 píxeles
          decoration: BoxDecoration( // Estilo visual del contenedor
            color: Colors.white, // Fondo blanco
            borderRadius: BorderRadius.circular(16), // Bordes redondeados
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Sombra suave
                blurRadius: 12, // Difuminado de la sombra
                offset: const Offset(0, 4), // Desplazamiento vertical
              ),
            ],
          ),
          child: Form( // Widget de formulario para validar entradas
            key: _formKey, // Asocia la clave para gestionar el formulario
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
              children: [
                const Text(
                  'Acceso Administrador', // Título de la pantalla
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003399), // Color azul institucional (UPDS)
                  ),
                ),
                const SizedBox(height: 24), // Espacio vertical de 24 píxeles
                TextFormField( // Campo para ingresar el correo electrónico
                  controller: _emailController, // Usa el controlador para manejar el texto
                  keyboardType: TextInputType.emailAddress, // Teclado optimizado para correos
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico', // Etiqueta del campo
                    border: OutlineInputBorder(), // Borde rectangular
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese su correo' : null, // Validación para campo vacío
                ),
                const SizedBox(height: 16), // Espacio vertical de 16 píxeles
                TextFormField( // Campo para ingresar la contraseña
                  controller: _passwordController, // Usa el controlador para manejar el texto
                  obscureText: true, // Oculta el texto para proteger la contraseña
                  decoration: const InputDecoration(
                    labelText: 'Contraseña', // Etiqueta del campo
                    border: OutlineInputBorder(), // Borde rectangular
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese su contraseña' : null, // Validación para campo vacío
                ),
                const SizedBox(height: 30), // Espacio vertical de 30 píxeles
                SizedBox(
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: ElevatedButton( // Botón para iniciar sesión
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399), // Color azul institucional
                      padding: const EdgeInsets.symmetric(vertical: 14), // Espaciado vertical
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bordes redondeados
                      ),
                    ),
                    onPressed: _isLoading ? null : _login, // Desactiva el botón durante la carga, llama a _login
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white) // Indicador de carga
                        : const Text('Iniciar Sesión'), // Texto del botón
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}