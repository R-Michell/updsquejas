import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Guardar queja anónima
  static Future<void> guardarQuejaAnonima({
    required String descripcion,
    required String categoria,
    required String facultad, // <-- nuevo parámetro
  }) async {
    await _db.collection('quejas').add({
      'descripcion': descripcion,
      'categoria': categoria,
      'facultad': facultad, // <-- nuevo campo guardado
      'estado': 'pendiente',
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  // Actualizar estado y respuesta de una queja
  static Future<void> actualizarQueja({
    required String id,
    required String estado,
    required String respuesta,
  }) async {
    await _db.collection('quejas').doc(id).update({
      'estado': estado,
      'respuesta': respuesta,
    });
  }

  // Obtener todas las quejas (no se usa si trabajas con StreamBuilder)
  static Future<List<Map<String, dynamic>>> obtenerTodasQuejas() async {
    final snapshot = await _db.collection('quejas').orderBy('fecha', descending: true).get();
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // Obtener estadísticas generales
  static Future<Map<String, int>> obtenerEstadisticas() async {
    final snapshot = await _db.collection('quejas').get();
    final docs = snapshot.docs;

    int total = docs.length;
    int resueltas = docs.where((d) => d['estado'] == 'resuelto').length;
    int pendientes = docs.where((d) => d['estado'] == 'pendiente').length;

    return {
      'total': total,
      'resueltas': resueltas,
      'pendientes': pendientes,
    };
  }
}
