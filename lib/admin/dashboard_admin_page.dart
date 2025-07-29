import 'package:flutter/material.dart'; // Importa los widgets de Material Design de Flutter
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para interactuar con la base de datos
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth para autenticación de usuarios
import 'package:fl_chart/fl_chart.dart'; // Importa la librería para crear gráficos (gráfico de barras)
import 'package:multi_select_flutter/multi_select_flutter.dart'; // Importa el paquete para selectores múltiples (chips)
import 'package:quejas/utils/pdf_report.dart'; // Importa la función para generar reportes en PDF

// Componente principal: Página de Dashboard para el administrador
class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key}); // Constructor constante con clave opcional

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState(); // Crea el estado asociado
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
    await FirebaseAuth.instance.signOut(); // Cierra la sesión del usuario en Firebase
    if (mounted) { // Verifica si el widget sigue activo
      // Regresa a la primera pantalla de la pila de navegación
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // Función que actualiza las métricas estadísticas del dashboard
  void _actualizarEstadisticas(List<QueryDocumentSnapshot> docs) {
    // Filtra las quejas según las selecciones actuales (facultad, categoría, estado)
    final filtradas = docs.where((doc) {
      final fac = doc['facultad'] ?? ''; // Obtiene la facultad o vacío si no existe
      final cat = doc['categoria'] ?? ''; // Obtiene la categoría o vacío si no existe
      final est = doc['estado'] ?? ''; // Obtiene el estado o vacío si no existe

      // Verifica si la facultad, categoría y estado coinciden con los filtros seleccionados
      final matchFac = selectedFacultades.isEmpty || selectedFacultades.contains(fac);
      final matchCat = selectedCategorias.isEmpty || selectedCategorias.contains(cat);
      final matchEst = selectedEstados.isEmpty || selectedEstados.contains(est);

      return matchFac && matchCat && matchEst; // Retorna true si cumple todos los filtros
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
      selectedFacultades.clear();   // Limpia las facultades seleccionadas
      selectedCategorias.clear();   // Limpia las categorías seleccionadas
      selectedEstados.clear();      // Limpia los estados seleccionados
    });
  }

  // Función que genera el reporte PDF usando los filtros actuales y la lista de quejas
  void _generarReportePDF() {
    generatePdfReport(
      context,                // Contexto para generar el PDF
      quejas,                // Lista de quejas
      selectedFacultades,    // Filtros de facultades
      selectedCategorias,    // Filtros de categorías
      selectedEstados,       // Filtros de estados
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
              color: isPercentage ? Colors.green.shade900 : const Color(0xFF003366), // Verde oscuro para porcentajes, azul oscuro para otros
            ),
          ),
          const SizedBox(height: 2), // Espacio vertical
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
      backgroundColor: const Color(0xFFF1F3F6), // Fondo gris claro para la pantalla
      appBar: AppBar(
        backgroundColor: const Color(0xFF003366), // Color azul institucional para la barra
        foregroundColor: Colors.white, // Texto blanco en la barra
        title: const Text('Dashboard de Administración'), // Título de la pantalla
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf), // Icono para generar PDF
            tooltip: 'Exportar Reporte PDF', // Texto emergente
            onPressed: _generarReportePDF, // Llama a la función para generar el PDF
          ),
          TextButton(
            onPressed: _logout, // Llama a la función de cerrar sesión
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Espaciado interno de 8 píxeles
        child: StreamBuilder<QuerySnapshot>( // Escucha los cambios en tiempo real de Firestore
          stream: FirebaseFirestore.instance
              .collection('quejas') // Consulta la colección 'quejas'
              .orderBy('fecha', descending: true) // Ordena por fecha descendente
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) { // Muestra un indicador de carga si los datos no están listos
              return const Center(child: CircularProgressIndicator());
            }

            quejas = snapshot.data?.docs ?? []; // Asigna las quejas o una lista vacía si no hay datos
            _actualizarEstadisticas(quejas); // Actualiza las estadísticas con las quejas obtenidas

            final double porcentajeResueltas =
                totalQuejas > 0 ? (resueltas / totalQuejas) * 100 : 0; // Calcula el porcentaje de quejas resueltas

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
              children: [
                ExpansionTile( // Panel desplegable para los filtros
                  title: const Text('Filtros', style: TextStyle(fontWeight: FontWeight.bold)),
                  children: [
                    Wrap(
                      spacing: 8, // Espacio horizontal entre elementos
                      runSpacing: 4, // Espacio vertical entre elementos
                      children: [
                        SizedBox(
                          width: 180, // Ancho fijo para el selector de facultades
                          child: MultiSelectDialogField( // Selector múltiple para facultades
                            items: facultades.map((f) => MultiSelectItem(f, f)).toList(),
                            title: const Text("Facultades"),
                            selectedColor: Colors.blue, // Color de selección
                            buttonText: const Text("Facultades", style: TextStyle(fontSize: 12)),
                            listType: MultiSelectListType.CHIP, // Muestra como chips
                            onConfirm: (values) =>
                                setState(() => selectedFacultades = List<String>.from(values)), // Actualiza las facultades seleccionadas
                            chipDisplay: MultiSelectChipDisplay.none(), // No muestra chips en el campo
                          ),
                        ),
                        SizedBox(
                          width: 160, // Ancho fijo para el selector de categorías
                          child: MultiSelectDialogField( // Selector múltiple para categorías
                            items: categorias.map((c) => MultiSelectItem(c, c)).toList(),
                            title: const Text("Categorías"),
                            selectedColor: Colors.green,
                            buttonText: const Text("Categorías", style: TextStyle(fontSize: 12)),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) =>
                                setState(() => selectedCategorias = List<String>.from(values)), // Actualiza las categorías seleccionadas
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        SizedBox(
                          width: 150, // Ancho fijo para el selector de estados
                          child: MultiSelectDialogField( // Selector múltiple para estados
                            items: estados.map((e) => MultiSelectItem(e, e)).toList(),
                            title: const Text("Estados"),
                            selectedColor: Colors.purple,
                            buttonText: const Text("Estados", style: TextStyle(fontSize: 12)),
                            listType: MultiSelectListType.CHIP,
                            onConfirm: (values) =>
                                setState(() => selectedEstados = List<String>.from(values)), // Actualiza los estados seleccionados
                            chipDisplay: MultiSelectChipDisplay.none(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.red), // Icono para restablecer filtros
                          tooltip: 'Restablecer Filtros',
                          onPressed: _restablecerFiltros, // Llama a la función para reiniciar filtros
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Espacio vertical
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, // Distribuye las tarjetas uniformemente
                  children: [
                    _buildStatCard('Quejas Totales', totalQuejas.toString(), const Color(0xFFD9E1E8)), // Tarjeta para total de quejas
                    _buildStatCard(
                      'Eficiencia (Resueltas)',
                      '${porcentajeResueltas.toStringAsFixed(1)}%\n($resueltas resueltas)', // Tarjeta para porcentaje de resolución
                      const Color(0xFFC3E6CB),
                      isPercentage: true,
                    ),
                    _buildStatCard('En Proceso', enProceso.toString(), const Color(0xFFFFF3CD)), // Tarjeta para quejas en proceso
                    _buildStatCard('Pendientes', pendientes.toString(), const Color(0xFFF8D7DA)), // Tarjeta para quejas pendientes
                  ],
                ),
                const SizedBox(height: 8), // Espacio vertical
                Expanded(
                  child: Row(
                    children: [
                      // Gráfico de barras
                      Expanded(
                        flex: 1, // Ocupa 1/3 del espacio horizontal
                        child: BarChart( // Gráfico de barras para mostrar quejas por categoría
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround, // Espacia las barras uniformemente
                            maxY: (categoriaConteo.values.isNotEmpty
                                    ? categoriaConteo.values.reduce((a, b) => a > b ? a : b).toDouble()
                                    : 10) +
                                2, // Ajusta el eje Y al valor máximo de quejas + 2
                            barGroups: categoriaConteo.entries.map((entry) {
                              final index = categoriaConteo.keys.toList().indexOf(entry.key);
                              return BarChartGroupData(
                                x: index, // Índice para la barra
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.toDouble(), // Altura de la barra
                                    color: _getColorForCategory(entry.key), // Color según la categoría
                                    width: 20, // Ancho de la barra
                                  ),
                                ],
                              );
                            }).toList(),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) { // Etiquetas en el eje X (categorías)
                                    final label = categoriaConteo.keys.elementAt(value.toInt());
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
                                  getTitlesWidget: (value, meta) { // Etiquetas en el eje Y (números enteros)
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
                            borderData: FlBorderData(show: false), // Oculta los bordes del gráfico
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Espacio horizontal entre el gráfico y la lista
                      // Lista de quejas
                      Expanded(
                        flex: 2, // Ocupa 2/3 del espacio horizontal
                        child: ListView.builder( // Lista desplazable de quejas
                          itemCount: quejas.length, // Número total de quejas
                          itemBuilder: (context, index) {
                            final queja = quejas[index]; // Obtiene la queja actual
                            final descripcion = queja['descripcion'] ?? ''; // Descripción o vacío
                            final estado = queja['estado'] ?? 'pendiente'; // Estado o 'pendiente' por defecto
                            final categoria = queja['categoria'] ?? ''; // Categoría o vacío
                            final facultad = queja['facultad'] ?? ''; // Facultad o vacío
                            final fecha = (queja['fecha'] as Timestamp?)?.toDate(); // Fecha convertida a DateTime

                            // Verifica si la queja cumple con los filtros seleccionados
                            final matchFac = selectedFacultades.isEmpty ||
                                selectedFacultades.contains(facultad);
                            final matchCat = selectedCategorias.isEmpty ||
                                selectedCategorias.contains(categoria);
                            final matchEst = selectedEstados.isEmpty ||
                                selectedEstados.contains(estado);
                            if (!matchFac || !matchCat || !matchEst) return const SizedBox.shrink(); // Oculta si no cumple los filtros

                            return Card(
                              elevation: 2, // Sombra ligera para la tarjeta
                              margin: const EdgeInsets.symmetric(vertical: 6), // Margen vertical
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)), // Bordes redondeados
                              child: Padding(
                                padding: const EdgeInsets.all(12.0), // Espaciado interno
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
                                  children: [
                                    Text(
                                        '$categoria - $facultad - ${fecha != null ? '${fecha.day}/${fecha.month}/${fecha.year}' : ''}'), // Muestra categoría, facultad y fecha
                                    const SizedBox(height: 4), // Espacio vertical
                                    Text(descripcion), // Muestra la descripción
                                    const SizedBox(height: 8), // Espacio vertical
                                    DropdownButtonFormField<String>( // Menú para cambiar el estado
                                      value: estado, // Estado actual
                                      decoration: const InputDecoration(labelText: 'Cambiar estado'),
                                      items: const [
                                        DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                                        DropdownMenuItem(value: 'recibida', child: Text('Recibida')),
                                        DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                                        DropdownMenuItem(value: 'resuelta', child: Text('Resuelta')),
                                      ],
                                      onChanged: (nuevoEstado) { // Actualiza el estado en Firestore
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