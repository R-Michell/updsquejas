import 'package:flutter/material.dart'; // Importa los widgets de Material Design de Flutter
import 'package:firebase_core/firebase_core.dart'; // Importa el paquete principal de Firebase para inicialización
import 'firebase_options.dart'; // Importa las opciones de configuración de Firebase
import 'routes.dart'; // Importa las rutas definidas para la navegación en la aplicación

void main() async { // Punto de entrada de la aplicación
  WidgetsFlutterBinding.ensureInitialized(); // Asegura que los bindings de Flutter estén inicializados antes de operaciones asíncronas

  await Firebase.initializeApp( // Inicializa Firebase con las opciones de configuración
    options: DefaultFirebaseOptions.currentPlatform, // Usa las opciones definidas en DefaultFirebaseOptions
  );

  runApp(const MyApp()); // Ejecuta la aplicación Flutter con el widget raíz MyApp
}

class MyApp extends StatelessWidget { // Clase principal de la aplicación, un widget sin estado
  const MyApp({super.key}); // Constructor constante con clave opcional

  @override
  Widget build(BuildContext context) { // Método que construye la interfaz de la aplicación
    return MaterialApp( // Widget que define la estructura de la app con Material Design
      title: 'Sistema de Quejas - UPDS', // Título de la aplicación
      theme: ThemeData( // Define el tema visual de la aplicación
        primarySwatch: Colors.red, // Paleta de colores primaria basada en rojo
        scaffoldBackgroundColor: Colors.white, // Color de fondo predeterminado para los Scaffolds
        appBarTheme: const AppBarTheme( // Tema personalizado para las barras de aplicación
          backgroundColor: Color(0xFF990000), // Color rojo institucional para la barra
          foregroundColor: Colors.white, // Color blanco para el texto e iconos de la barra
        ),
      ),
      debugShowCheckedModeBanner: false, // Oculta la bandera de modo depuración
      initialRoute: Routes.bienvenida, // Ruta inicial de la aplicación (pantalla de bienvenida)
      routes: Routes.getRoutes(), // Define las rutas de navegación de la aplicación
    );
  }
}