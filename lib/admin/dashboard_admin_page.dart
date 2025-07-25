
import 'package:flutter/material.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // acceder a la base de datos Firestore
import 'package:firebase_auth/firebase_auth.dart'; // autenticación con Firebase
import 'package:fl_chart/fl_chart.dart'; // Para crear gráficos 
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Para usar selectores múltiples (chips, listas)
import 'package:quejas/utils/pdf_report.dart'; // Importa la función para generar reportes PDF

// Componente principal: Página de Dashboard para el administrador
class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  // Variables para métricas estadísticas
  int totalQuejas = 0;      // Total de quejas después de aplicar filtros
  int resueltas = 0;        // Total de quejas marcadas como "resuelta"
  int pendientes = 0;       // Total de quejas en estado "pendiente"
  int enProceso = 0;        // Total de quejas en estado "en proceso"

  // Mapa que almacena cuántas quejas hay por categoría
  Map<String, int> categoriaConteo = {};

  // Listas con las posibles opciones para filtros
  List<String> facultades = [
    "Facultad de Ciencias Jurídicas",
    "Facultad de ciencias Empresariales",
    "Facultad de Ciencias Sociales",
    "Facultad de Ingeniería",
    "Facultad de Ciencias De La Salud",
  ];

  List<String> categorias = [
    "Académico",
    "Infraestructura",
    "Administración",
    "Docentes",
    "Sistemas",
    "Otro"
  ];

  List<String> estados = [
    "pendiente",
    "recibida",
    "en proceso",
    "resuelta",
  ];

  // Listas que almacenan las selecciones actuales del usuario en los filtros
  List<String> selectedFacultades = [];
  List<String> selectedCategorias = [];
  List<String> selectedEstados = [];

  // Lista que almacenará las quejas extraídas desde Firestore
  List<QueryDocumentSnapshot> quejas = [];

  // Función para cerrar sesión del administrador
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut(); // Cierra sesión en Firebase
    if (mounted) {
      // Regresa a la primera pantalla 
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }


 // Función que actualiza las métricas estadísticas del dashboard
void _actualizarEstadisticas(List<QueryDocumentSnapshot> docs) {
  // Filtra las quejas según las selecciones actuales (facultad, categoría, estado)
  final filtradas = docs.where((doc) {
    final fac = doc['facultad'] ?? '';
    final cat = doc['categoria'] ?? '';
    final est = doc['estado'] ?? '';

    // Verifica si la facultad, categoría y estado coinciden con los filtros seleccionados
    final matchFac = selectedFacultades.isEmpty || selectedFacultades.contains(fac);
    final matchCat = selectedCategorias.isEmpty || selectedCategorias.contains(cat);
    final matchEst = selectedEstados.isEmpty || selectedEstados.contains(est);

    return matchFac && matchCat && matchEst;
  }).toList();

  // Asigna la cantidad total de quejas filtradas
  totalQuejas = filtradas.length;

  // Cuenta cuántas están en estado "resuelta"
  resueltas = filtradas.where((doc) => doc['estado'] == 'resuelta').length;

  // Cuenta cuántas están "pendientes"
  pendientes = filtradas.where((doc) => doc['estado'] == 'pendiente').length;

  // Cuenta cuántas están "en proceso"
  enProceso = filtradas.where((doc) => doc['estado'] == 'en proceso').length;

  // Limpia el conteo anterior de categorías
  categoriaConteo.clear();

  // Recorre las quejas filtradas y cuenta cuántas hay por categoría
  for (var doc in filtradas) {
    final categoria = doc['categoria'] ?? 'Sin categoría';
    categoriaConteo[categoria] = (categoriaConteo[categoria] ?? 0) + 1;
  }
}

// Función que reinicia todos los filtros seleccionados
void _restablecerFiltros() {
  setState(() {
    selectedFacultades.clear();   
    selectedCategorias.clear();   
    selectedEstados.clear();     
  });
}

// Función que genera el reporte PDF usando los filtros actuales y la lista de quejas
void _generarReportePDF() {
  generatePdfReport(
    context,                
    quejas,                 
    selectedFacultades,     
    selectedCategorias,     
    selectedEstados,        
  );
}


// Función que asigna un color específico según la categoría de la queja
Color _getColorForCategory(String categoria) {
  switch (categoria.toLowerCase()) {
    case 'sistemas':
      return const Color(0xFF1E88E5); // Azul para "Sistemas"
    case 'docentes':
    case 'académico':
      return const Color(0xFFE53935); // Rojo para "Docentes" o "Académico"
    case 'infraestructura':
      return const Color(0xFFFFB300); // Amarillo para "Infraestructura"
    case 'administración':
      return const Color(0xFF8E24AA); // Morado para "Administración"
    default:
      return const Color(0xFF009688); // Verde-azulado por defecto (para "Otro", etc.)
  }
}

// Función que construye una tarjeta (card) de estadística en el dashboard
Widget _buildStatCard(String title, String value, Color color, {bool isPercentage = false}) {
  return Container(
    width: 150, // Ancho fijo de la tarjeta
    padding: const EdgeInsets.all(16), // Espaciado interno
    decoration: BoxDecoration(
      color: color, // Color de fondo de la tarjeta (según la estadística)
      borderRadius: BorderRadius.circular(12), // Bordes redondeados
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05), // Sombra suave
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        // Valor numérico principal (ej. "20", "75%")
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPercentage ? Colors.green.shade900 : const Color(0xFF003366),
          ),
        ),
        const SizedBox(height: 2),
        // Texto descriptivo del indicador (ej. "Pendientes", "Eficiencia")
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        title: const Text('Dashboard de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar Reporte PDF',
            onPressed: _generarReportePDF,
          ),
          TextButton(
            onPressed: _logout,
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quejas')
              .orderBy('fecha', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            quejas = snapshot.data?.docs ?? [];
            _actualizarEstadisticas(quejas);

            final double porcentajeResueltas =
                totalQuejas > 0 ? (resueltas / totalQuejas) * 100 : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpansionTile(
                  title: const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        SizedBox(
                          width: 180,
                          child: MultiSelectDialogField(
                            items: facultades.map((f) => MultiSelectItem(f, f)).toList(),
                            title: const Text("Facultades"),
                            selectedColor: Colors.blue,
                            buttonText: const Text("Facultades", style: TextStyle(fontSize: 12)),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) =>
                                setState(() => selectedFacultades = List<String>.from(values)),
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          child: MultiSelectDialogField(
                            items: categorias.map((c) => MultiSelectItem(c, c)).toList(),
                            title: const Text("Categorías"),
                            selectedColor: Colors.green,
                            buttonText: const Text("Categorías", style: TextStyle(fontSize: 12)),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) =>
                                setState(() => selectedCategorias = List<String>.from(values)),
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        SizedBox(
                          width: 150,
                          child: MultiSelectDialogField(
                            items: estados.map((e) => MultiSelectItem(e, e)).toList(),
                            title: const Text("Estados"),
                            selectedColor: Colors.purple,
                            buttonText: const Text("Estados", style: TextStyle(fontSize: 12)),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) =>
                                setState(() => selectedEstados = List<String>.from(values)),
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red),
                          tooltip: 'Restablecer Filtros',
                          onPressed: _restablecerFiltros,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Quejas Totales', totalQuejas.toString(), const Color(0xFFD9E1E8)),
                    _buildStatCard(
                      'Eficiencia (Resueltas)',
                      '${porcentajeResueltas.toStringAsFixed(1)}%\n($resueltas resueltas)',
                      const Color(0xFFC3E6CB),
                      isPercentage: true,
                    ),
                    _buildStatCard('En Proceso', enProceso.toString(), const Color(0xFFFFF3CD)),
                    _buildStatCard('Pendientes', pendientes.toString(), const Color(0xFFF8D7DA)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Row(
                    children: [
                      // Gráfico de barras
                      Expanded(
                        flex: 1,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (categoriaConteo.values.isNotEmpty
                                    ? categoriaConteo.values.reduce((a, b) => a > b ? a : b).toDouble()
                                    : 10) +
                                2,
                            barGroups: categoriaConteo.entries.map((entry) {
                              final index = categoriaConteo.keys.toList().indexOf(entry.key);
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(),
                                    color: _getColorForCategory(entry.key),
                                    width: 20,
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    final label =
                                        categoriaConteo.keys.elementAt(value.toInt());
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(label,
                                          style: const TextStyle(fontSize: 10),
                                          textAlign: TextAlign.center),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                 sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1, // Muestra etiquetas de 1 en 1
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 == 0) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    }
                                    return const SizedBox.shrink(); // Oculta valores decimales
                                  },
                                ),
                              ),
                              
                            ),
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Lista de quejas
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          itemCount: quejas.length,
                          itemBuilder: (context, index) {
                            final queja = quejas[index];
                            final descripcion = queja['descripcion'] ?? '';
                            final estado = queja['estado'] ?? 'pendiente';
                            final categoria = queja['categoria'] ?? '';
                            final facultad = queja['facultad'] ?? '';
                            final fecha = (queja['fecha'] as Timestamp?)?.toDate();

                            final matchFac = selectedFacultades.isEmpty ||
                                selectedFacultades.contains(facultad);
                            final matchCat = selectedCategorias.isEmpty ||
                                selectedCategorias.contains(categoria);
                            final matchEst = selectedEstados.isEmpty ||
                                selectedEstados.contains(estado);
                            if (!matchFac || !matchCat || !matchEst) return const SizedBox.shrink();

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '$categoria - $facultad - ${fecha != null ? '${fecha.day}/${fecha.month}/${fecha.year}' : ''}'),
                                    const SizedBox(height: 4),
                                    Text(descripcion),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: estado,
                                      decoration: const InputDecoration(labelText: 'Cambiar estado'),
                                      items: const [
                                        DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                                        DropdownMenuItem(value: 'recibida', child: Text('Recibida')),
                                        DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                                        DropdownMenuItem(value: 'resuelta', child: Text('Resuelta')),
                                      ],
                                      onChanged: (nuevoEstado) {
                                        if (nuevoEstado != null) {
                                          FirebaseFirestore.instance
                                              .collection('quejas')
                                              .doc(queja.id)
                                              .update({'estado': nuevoEstado});
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
