import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para interactuar con la base de datos

class FirebaseService { // Clase para manejar operaciones con la base de datos Firestore
  static final FirebaseFirestore _db = FirebaseFirestore.instance; // Instancia de Firestore para acceder a la base de datos

  // Guardar queja anónima
  static Future<void> guardarQuejaAnonima({ // Función asíncrona para guardar una queja anónima
    required String descripcion, // Parámetro requerido: descripción de la queja
    required String categoria, // Parámetro requerido: categoría de la queja
    required String facultad, // Parámetro requerido: facultad relacionada con la queja
  }) async {
    await _db.collection('quejas').add({ // Añade un nuevo documento a la colección 'quejas'
      'descripcion': descripcion, // Almacena la descripción
      'categoria': categoria, // Almacena la categoría
      'facultad': facultad, // Almacena la facultad
      'estado': 'pendiente', // Establece el estado inicial como 'pendiente'
      'fecha': FieldValue.serverTimestamp(), // Registra la fecha del servidor
    });
  }

  // Actualizar estado y respuesta de una queja
  static Future<void> actualizarQueja({ // Función asíncrona para actualizar una queja existente
    required String id, // Parámetro requerido: ID del documento de la queja
    required String estado, // Parámetro requerido: nuevo estado de la queja
    required String respuesta, // Parámetro requerido: respuesta o nota del administrador
  }) async {
    await _db.collection('quejas').doc(id).update({ // Actualiza el documento específico en la colección 'quejas'
      'estado': estado, // Actualiza el estado
      'respuesta': respuesta, // Actualiza la respuesta
    });
  }

  // Obtener todas las quejas (no se usa si trabajas con StreamBuilder)
  static Future<List<Map<String, dynamic>>> obtenerTodasQuejas() async { // Función asíncrona para obtener todas las quejas
    final snapshot = await _db.collection('quejas').orderBy('fecha', descending: true).get(); // Consulta las quejas ordenadas por fecha descendente
    return snapshot.docs.map((doc) => { // Mapea los documentos a una lista de mapas
      'id': doc.id, // Incluye el ID del documento
      ...doc.data(), // Incluye todos los campos del documento
    }).toList();
  }

  // Obtener estadísticas generales
  static Future<Map<String, int>> obtenerEstadisticas() async { // Función asíncrona para obtener estadísticas de quejas
    final snapshot = await _db.collection('quejas').get(); // Obtiene todos los documentos de la colección 'quejas'
    final docs = snapshot.docs; // Almacena los documentos

    int total = docs.length; // Calcula el total de quejas
    int resueltas = docs.where((d) => d['estado'] == 'resuelto').length; // Cuenta las quejas en estado 'resuelto'
    int pendientes = docs.where((d) => d['estado'] == 'pendiente').length; // Cuenta las quejas en estado 'pendiente'

    return { // Retorna un mapa con las estadísticas
      'total': total,
      'resueltas': resueltas,
      'pendientes': pendientes,
    };
  }
}