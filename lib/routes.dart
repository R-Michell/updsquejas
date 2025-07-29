import 'package:flutter/material.dart'; // Importa los widgets de Material Design de Flutter
import 'package:quejas/admin/dashboard_admin_page.dart'; // Importa la página del dashboard de administrador
import 'package:quejas/admin/detalle_queja_page.dart'; // Importa la página de detalles de una queja
import 'package:quejas/admin/login_admin_page.dart'; // Importa la página de login para administradores
import 'package:quejas/estudiante/formulario_queja_page.dart'; // Importa la página del formulario de quejas
import 'package:quejas/screens/bienvenida_page.dart'; // Importa la página de bienvenida

class Routes { // Clase para definir las rutas de navegación de la aplicación
  static const String bienvenida = '/'; // Ruta raíz para la pantalla de bienvenida
  static const String formularioQueja = '/formulario'; // Ruta para el formulario de quejas
  static const String loginAdmin = '/login'; // Ruta para el login de administrador
  static const String dashboardAdmin = '/dashboard'; // Ruta para el dashboard de administrador
  static const String detalleQueja = '/detalle'; // Ruta para los detalles de una queja
  static const String dashboard = '/dashboardAdmin'; // Ruta alternativa para el dashboard (parece redundante)

  static Map<String, WidgetBuilder> getRoutes() { // Método estático que retorna un mapa de rutas
    return {
      bienvenida: (context) => const BienvenidaPage(), // Asocia la ruta raíz con la pantalla de bienvenida
      formularioQueja: (context) => const FormularioQuejaPage(), // Asocia la ruta con el formulario de quejas
      loginAdmin: (context) => const LoginAdminPage(), // Asocia la ruta con el login de administrador
      dashboardAdmin: (context) => const DashboardAdminPage(), // Asocia la ruta con el dashboard de administrador
    };
  }
}