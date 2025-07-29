import 'package:flutter/material.dart';
import 'package:quejas/routes.dart'; // Importa las rutas definidas para la navegación en la aplicación

class BienvenidaPage extends StatelessWidget { // Define una pantalla sin estado (no cambia dinámicamente)
  const BienvenidaPage({super.key}); // Constructor constante con clave opcional para optimización

  @override
  Widget build(BuildContext context) { // Método que construye la interfaz de la pantalla
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 206, 247), // Fondo azul claro para la pantalla
      body: Center( // Centra todo el contenido en la pantalla
        child: Container( // Contenedor principal para el contenido
          width: 700, // Ancho fijo del contenedor
          height: 520, // Alto fijo del contenedor
          padding: const EdgeInsets.all(32), // Espaciado interno uniforme de 32 píxeles
          decoration: BoxDecoration( // Estilo visual del contenedor
            color: Colors.white, // Fondo blanco
            borderRadius: BorderRadius.circular(24), // Bordes redondeados de 24 píxeles
            boxShadow: [ // Sombra para dar efecto elevado
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Color de sombra con baja opacidad
                blurRadius: 16, // Difuminado de la sombra
                offset: const Offset(0, 8), // Desplazamiento vertical de la sombra
              ),
            ],
          ),
          child: Column( // Organiza los elementos verticalmente, centrados
            mainAxisAlignment: MainAxisAlignment.center, // Alinea el contenido al centro vertical
            children: [
              Image.asset( // Muestra el logo de la aplicación
                'assets/logo.png', // Ruta del archivo de imagen
                height: 230, // Altura fija de 230 píxeles
              ),
              const SizedBox(height: 24), // Espacio vertical de 24 píxeles
              const Text( // Título principal
                'Sistema de Quejas', 
                style: TextStyle(
                  fontSize: 28, // Tamaño de fuente grande
                  fontWeight: FontWeight.bold, // Texto en negrita
                  color: Color(0xFF003399), // Color azul institucional (UPDS)
                ),
              ),
              const SizedBox(height: 8), // Espacio vertical de 8 píxeles
              const Text( // Subtítulo con el nombre de la universidad
                'Universidad Privada Domingo Savio',
                style: TextStyle(
                  fontSize: 18, // Tamaño de fuente más pequeño
                  color: Colors.grey, // Color gris para menor énfasis
                ),
              ),
              const SizedBox(height: 32), // Espacio vertical de 32 píxeles
              ElevatedButton( // Botón principal para enviar quejas
                onPressed: () {
                  Navigator.pushNamed(context, Routes.formularioQueja); // Navega a la pantalla de formulario de quejas
                },
                style: ElevatedButton.styleFrom( // Estilo personalizado del botón
                  backgroundColor: const Color(0xFF0099CC), // Color celeste institucional (UPDS)
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), // Espaciado interno
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Bordes redondeados
                  ),
                ),
                child: const Text(
                  'Hacer una Queja',
                  style: TextStyle(fontSize: 17, color: Colors.white), // Texto blanco, tamaño 17
                ),
              ),
              const SizedBox(height: 16), // Espacio vertical de 16 píxeles
              TextButton( // Botón secundario para acceso administrativo
                onPressed: () {
                  Navigator.pushNamed(context, Routes.loginAdmin); // Navega a la pantalla de login de administrador
                },
                child: const Text(
                  'Acceso Administrador',
                  style: TextStyle(
                    fontSize: 16, // Tamaño de fuente moderado
                    color: Color(0xFF003399), // Color azul institucional
                    decoration: TextDecoration.underline, // Subrayado para estilo de enlace
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}