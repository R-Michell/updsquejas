import 'package:flutter/material.dart';
import 'package:quejas/admin/dashboard_admin_page.dart';
import 'package:quejas/admin/detalle_queja_page.dart';
import 'package:quejas/admin/login_admin_page.dart';
import 'package:quejas/estudiante/formulario_queja_page.dart';
import 'package:quejas/screens/bienvenida_page.dart';

class Routes {
  static const String bienvenida = '/';
  static const String formularioQueja = '/formulario';
  static const String loginAdmin = '/login';
  static const String dashboardAdmin = '/dashboard';
  static const String detalleQueja = '/detalle';
  static const String dashboard = '/dashboardAdmin';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      bienvenida: (context) => const BienvenidaPage(),
      formularioQueja: (context) => const FormularioQuejaPage(),
      loginAdmin: (context) => const LoginAdminPage(),
      dashboardAdmin: (context) => const DashboardAdminPage(),
    };
  }
}
