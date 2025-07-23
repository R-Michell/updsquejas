import 'package:flutter/material.dart';
import 'package:quejas/routes.dart';

class BienvenidaPage extends StatelessWidget {
  const BienvenidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 166, 206, 247), 
      body: Center(
        child: Container(
          width: 700, // ancho del contenedor
          height: 520, // alto del contenedor
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 230,
              ),
              const SizedBox(height: 24),
              const Text(
                'Sistema de Quejas',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003399), // Azul UPDS
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Universidad Privada Domingo Savio',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.formularioQueja);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0099CC), // Celeste UPDS
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Hacer una Queja',
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, Routes.loginAdmin);
                },
                child: const Text(
                  'Acceso Administrador',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF003399),
                    decoration: TextDecoration.underline,
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
