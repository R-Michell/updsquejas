import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';

class FormularioQuejaPage extends StatefulWidget {
  const FormularioQuejaPage({super.key});

  @override
  State<FormularioQuejaPage> createState() => _FormularioQuejaPageState();
}

class _FormularioQuejaPageState extends State<FormularioQuejaPage> {
  final _formKey = GlobalKey<FormState>();
  String _categoria = 'Académico';
  String _descripcion = '';
  String _facultad = 'Facultad de Ingeniería'; // ✅ Valor predeterminado

  final List<String> _categorias = [
    'Académico',
    'Infraestructura',
    'Administración',
    'Docentes',
    'Sistemas',
    'Otro'
  ];

  final List<String> _facultades = [
    'Facultad de Ciencias Jurídicas',
    'Facultad de ciencias Empresariales',
    'Facultad de Ciencias Sociales',
    'Facultad de Ingeniería',
    'Facultad de Ciencias De La Salud'
  ];

  Future<void> _enviarQueja() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await FirebaseService.guardarQuejaAnonima(
        categoria: _categoria,
        descripcion: _descripcion,
        facultad: _facultad,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enviado'),
            content: const Text('Tu queja ha sido enviada de forma anónima.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Aceptar'),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      appBar: AppBar(
        title: const Text('Enviar Queja Anónima'),
        backgroundColor: const Color(0xFF003399),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Facultad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _facultad,
                  items: _facultades.map((String fac) {
                    return DropdownMenuItem<String>(
                      value: fac,
                      child: Text(fac),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _facultad = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Categoría',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _categoria,
                  items: _categorias.map((String cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoria = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Describe tu queja o sugerencia...',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _descripcion = value ?? '';
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _enviarQueja,
                    child: const Text('Enviar Queja'),
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
