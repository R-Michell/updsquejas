import 'package:flutter/material.dart'; // Importa los widgets de Material Design de Flutter
import '../../services/firebase_service.dart'; // Importa el servicio de Firebase para guardar quejas

class FormularioQuejaPage extends StatefulWidget { // Define una pantalla con estado (permite cambios dinámicos)
  const FormularioQuejaPage({super.key}); // Constructor constante con clave opcional para optimización

  @override
  State<FormularioQuejaPage> createState() => _FormularioQuejaPageState(); // Crea el estado asociado
}

class _FormularioQuejaPageState extends State<FormularioQuejaPage> { // Clase que maneja el estado de la pantalla
  final _formKey = GlobalKey<FormState>(); // Clave para gestionar el formulario
  String _categoria = 'Académico'; // Valor inicial para la categoría de la queja
  String _descripcion = ''; // Almacena la descripción de la queja
  String _facultad = 'Facultad de Ingeniería'; // Valor inicial para la facultad

  final List<String> _categorias = [ // Lista de opciones para el menú desplegable de categorías
    'Académico',
    'Infraestructura',
    'Administración',
    'Docentes',
    'Sistemas',
    'Otro'
  ];

  final List<String> _facultades = [ // Lista de opciones para el menú desplegable de facultades
    'Facultad de Ciencias Jurídicas',
    'Facultad de ciencias Empresariales',
    'Facultad de Ciencias Sociales',
    'Facultad de Ingeniería',
    'Facultad de Ciencias De La Salud'
  ];

  Future<void> _enviarQueja() async { // Función asíncrona para enviar la queja
    if (_formKey.currentState!.validate()) { // Valida el formulario
      _formKey.currentState!.save(); // Guarda los valores del formulario

      await FirebaseService.guardarQuejaAnonima( // Llama al servicio de Firebase para guardar la queja
        categoria: _categoria,
        descripcion: _descripcion,
        facultad: _facultad,
      );

      if (mounted) { // Verifica si el widget sigue activo antes de mostrar el diálogo
        showDialog( // Muestra un diálogo de confirmación
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Enviado'), // Título del diálogo
            content: const Text('Tu queja ha sido enviada de forma anónima.'), // Mensaje de confirmación
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pop(context); // Regresa a la pantalla anterior
                },
                child: const Text('Aceptar'), // Botón para cerrar el diálogo
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) { // Método que construye la interfaz de la pantalla
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5), // Fondo gris claro para la pantalla
      appBar: AppBar( // Barra superior de la aplicación
        title: const Text('Enviar Queja Anónima'), // Título de la pantalla
        backgroundColor: const Color(0xFF003399), // Color azul institucional (UPDS)
        foregroundColor: Colors.white, // Texto blanco en la barra
      ),
      body: Center( // Centra el contenido en la pantalla
        child: Container( // Contenedor principal para el formulario
          constraints: const BoxConstraints(maxWidth: 600), // Limita el ancho máximo a 600 píxeles
          padding: const EdgeInsets.all(24.0), // Espaciado interno de 24 píxeles
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24), // Margen externo
          decoration: BoxDecoration( // Estilo visual del contenedor
            color: Colors.white, // Fondo blanco
            borderRadius: BorderRadius.circular(16), // Bordes redondeados
            boxShadow: [ // Sombra para efecto elevado
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Sombra suave
                blurRadius: 10, // Difuminado de la sombra
                offset: const Offset(0, 4), // Desplazamiento vertical
              ),
            ],
          ),
          child: Form( // Widget de formulario para validar entradas
            key: _formKey, // Asocia la clave para gestionar el formulario
            child: Column( // Organiza los elementos verticalmente, con tamaño mínimo
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
              children: [
                const Text( // Etiqueta para el campo de facultad
                  'Facultad',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8), // Espacio vertical de 8 píxeles
                DropdownButtonFormField<String>( // Menú desplegable para seleccionar facultad
                  value: _facultad, // Valor seleccionado inicialmente
                  items: _facultades.map((String fac) { // Genera los ítems del menú
                    return DropdownMenuItem<String>(
                      value: fac,
                      child: Text(fac),
                    );
                  }).toList(),
                  onChanged: (value) { // Actualiza el estado al cambiar la selección
                    setState(() {
                      _facultad = value!;
                    });
                  },
                  decoration: const InputDecoration( // Estilo del campo
                    border: OutlineInputBorder(), // Borde rectangular
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 20), // Espacio vertical de 20 píxeles
                const Text( // Etiqueta para el campo de categoría
                  'Categoría',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8), // Espacio vertical de 8 píxeles
                DropdownButtonFormField<String>( // Menú desplegable para seleccionar categoría
                  value: _categoria, // Valor seleccionado inicialmente
                  items: _categorias.map((String cat) { // Genera los ítems del menú
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) { // Actualiza el estado al cambiar la selección
                    setState(() {
                      _categoria = value!;
                    });
                  },
                  decoration: const InputDecoration( // Estilo del campo
                    border: OutlineInputBorder(), // Borde rectangular
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 20), // Espacio vertical de 20 píxeles
                const Text( // Etiqueta para el campo de descripción
                  'Descripción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8), // Espacio vertical de 8 píxeles
                TextFormField( // Campo de texto para la descripción
                  maxLines: 5, // Permite hasta 5 líneas de texto
                  decoration: const InputDecoration( // Estilo del campo
                    hintText: 'Describe tu queja o sugerencia...', // Texto de sugerencia
                    border: OutlineInputBorder(), // Borde rectangular
                  ),
                  validator: (value) { // Validación del campo
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa una descripción'; // Error si está vacío
                    }
                    if (value.trim().length < 10) {
                      return 'La descripción debe tener al menos 10 letras'; // Error si es muy corto
                    }
                    return null; // Sin errores
                  },
                  onSaved: (value) { // Guarda el valor al enviar el formulario
                    _descripcion = value ?? '';
                  },
                ),
                const SizedBox(height: 30), // Espacio vertical de 30 píxeles
                SizedBox( // Contenedor para el botón de envío
                  width: double.infinity, // Ocupa todo el ancho disponible
                  child: ElevatedButton( // Botón para enviar la queja
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003399), // Color azul institucional
                      padding: const EdgeInsets.symmetric(vertical: 16), // Espaciado vertical
                      textStyle: const TextStyle(fontSize: 16), // Tamaño de fuente
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bordes redondeados
                      ),
                    ),
                    onPressed: _enviarQueja, // Llama a la función para enviar la queja
                    child: const Text('Enviar Queja'), // Texto del botón
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