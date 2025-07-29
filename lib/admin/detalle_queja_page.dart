import 'package:flutter/material.dart'; // Importa los widgets de Material Design de Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para interactuar con la base de datos

class DetalleQuejaPage extends StatefulWidget { // Define una pantalla con estado para manejar cambios dinámicos
  final DocumentSnapshot queja; // Recibe un documento de Firestore con los datos de la queja
  const DetalleQuejaPage({super.key, required this.queja}); // Constructor con clave opcional y queja requerida

  @override
  State<DetalleQuejaPage> createState() => _DetalleQuejaPageState(); // Crea el estado asociado
}

class _DetalleQuejaPageState extends State<DetalleQuejaPage> { // Clase que maneja el estado de la pantalla
  late String _estado; // Variable para almacenar el estado de la queja (pendiente, en proceso, resuelto)
  late TextEditingController _respuestaController; // Controlador para el campo de texto de la respuesta

  @override
  void initState() { // Método que se ejecuta al inicializar el estado
    super.initState();
    _estado = widget.queja['estado'] ?? 'pendiente'; // Inicializa el estado con el valor de la queja o 'pendiente' por defecto
    _respuestaController = TextEditingController(text: widget.queja['respuesta'] ?? ''); // Inicializa el controlador con la respuesta existente o vacío
  }

  Future<void> _actualizarQueja() async { // Función asíncrona para actualizar la queja en Firestore
    await FirebaseFirestore.instance.collection('quejas').doc(widget.queja.id).update({ // Actualiza el documento en la colección 'quejas'
      'estado': _estado, // Actualiza el estado
      'respuesta': _respuestaController.text, // Actualiza la respuesta
    });

    if (mounted) { // Verifica si el widget sigue activo antes de mostrar notificaciones
      ScaffoldMessenger.of(context).showSnackBar( // Muestra una notificación de éxito
        const SnackBar(content: Text('Queja actualizada correctamente')),
      );
      Navigator.pop(context); // Regresa a la pantalla anterior
    }
  }

  @override
  void dispose() { // Método que se ejecuta al destruir el widget
    _respuestaController.dispose(); // Libera los recursos del controlador de texto
    super.dispose(); // Llama al método dispose de la clase padre
  }

  @override
  Widget build(BuildContext context) { // Método que construye la interfaz de la pantalla
    final descripcion = widget.queja['descripcion'] ?? ''; // Obtiene la descripción de la queja o vacío si no existe
    final categoria = widget.queja['categoria'] ?? ''; // Obtiene la categoría de la queja o vacío si no existe
    final fecha = (widget.queja['fecha'] as Timestamp?)?.toDate(); // Convierte el timestamp de la fecha a DateTime o null

    return Scaffold(
      appBar: AppBar( // Barra superior de la aplicación
        title: const Text('Detalle de la Queja'), // Título de la pantalla
        backgroundColor: const Color(0xFF990000), // Color rojo institucional
        foregroundColor: Colors.white, // Texto blanco en la barra
      ),
      body: Padding( // Añade un espaciado interno de 20 píxeles
        padding: const EdgeInsets.all(20.0),
        child: ListView( // Lista desplazable para mostrar el contenido
          children: [
            Text('Categoría: $categoria', style: const TextStyle(fontSize: 16)), // Muestra la categoría de la queja
            const SizedBox(height: 8), // Espacio vertical de 8 píxeles
            Text('Fecha: ${fecha != null ? fecha.toLocal().toString().substring(0, 16) : 'N/D'}', style: const TextStyle(fontSize: 16)), // Muestra la fecha formateada o 'N/D' si no existe
            const SizedBox(height: 16), // Espacio vertical de 16 píxeles
            const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Etiqueta para la descripción
            const SizedBox(height: 8), // Espacio vertical de 8 píxeles
            Text(descripcion, style: const TextStyle(fontSize: 16)), // Muestra la descripción de la queja
            const SizedBox(height: 24), // Espacio vertical de 24 píxeles
            const Text('Estado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Etiqueta para el estado
            const SizedBox(height: 8), // Espacio vertical de 8 píxeles
            DropdownButtonFormField<String>( // Menú desplegable para seleccionar el estado
              value: _estado, // Valor seleccionado inicialmente
              items: const [ // Opciones del menú desplegable
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
              ],
              onChanged: (value) { // Actualiza el estado al cambiar la selección
                if (value != null) {
                  setState(() {
                    _estado = value;
                  });
                }
              },
              decoration: const InputDecoration(border: OutlineInputBorder()), // Estilo del campo con borde rectangular
            ),
            const SizedBox(height: 24), // Espacio vertical de 24 píxeles
            const Text('Respuesta / Nota del Administrador:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Etiqueta para la respuesta
            const SizedBox(height: 8), // Espacio vertical de 8 píxeles
            TextFormField( // Campo de texto para la respuesta del administrador
              controller: _respuestaController, // Usa el controlador para manejar el texto
              maxLines: 4, // Permite hasta 4 líneas de texto
              decoration: const InputDecoration( // Estilo del campo
                hintText: 'Escribe una respuesta o nota interna...', // Texto de sugerencia
                border: OutlineInputBorder(), // Borde rectangular
              ),
            ),
            const SizedBox(height: 24), // Espacio vertical de 24 píxeles
            SizedBox( // Contenedor para el botón de guardar
              width: double.infinity, // Ocupa todo el ancho disponible
              child: ElevatedButton( // Botón para guardar los cambios
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000), // Color rojo institucional
                  padding: const EdgeInsets.symmetric(vertical: 16), // Espaciado vertical
                  textStyle: const TextStyle(fontSize: 16), // Tamaño de fuente
                ),
                onPressed: _actualizarQueja, // Llama a la función para actualizar la queja
                child: const Text('Guardar Cambios'), // Texto del botón
              ),
            ),
          ],
        ),
      ),
    );
  }
}