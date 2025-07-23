import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para acceder a los datos de Firestore
import 'package:pdf/pdf.dart'; // Para manejar el formato PDF
import 'package:pdf/widgets.dart' as pw; // Para construir widgets del PDF
import 'package:printing/printing.dart'; // Para compartir o imprimir el PDF

// Función que genera un reporte PDF con filtros aplicados
Future<void> generatePdfReport(
  BuildContext context,
  List<QueryDocumentSnapshot> quejas, // Lista de quejas obtenidas de Firestore
  List<String> selectedFacultades,
  List<String> selectedCategorias,
  List<String> selectedEstados,
) async {
  final pdf = pw.Document(); // Crea un nuevo documento PDF

  // Filtra las quejas según las facultades, categorías y estados seleccionados
  final filtradas = quejas.where((q) {
    final f = q['facultad'];
    final c = q['categoria'];
    final e = q['estado'];
    return (selectedFacultades.isEmpty || selectedFacultades.contains(f)) &&
           (selectedCategorias.isEmpty || selectedCategorias.contains(c)) &&
           (selectedEstados.isEmpty || selectedEstados.contains(e));
  }).toList();

  // Crea una nueva página en el PDF con el contenido del reporte
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        // Título del reporte
        pw.Text('Reporte de Quejas', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),

        // Información sobre los filtros aplicados
        pw.Text('Facultades seleccionadas: ${selectedFacultades.join(', ')}'),
        pw.Text('Categorías seleccionadas: ${selectedCategorias.join(', ')}'),
        pw.Text('Estados seleccionados: ${selectedEstados.join(', ')}'),
        pw.SizedBox(height: 20),

        // Tabla con los datos de las quejas filtradas
        pw.Table.fromTextArray(
          headers: ['Facultad', 'Categoría', 'Estado', 'Descripción', 'Fecha'],
          data: filtradas.map((q) {
            return [
              q['facultad'] ?? '',
              q['categoria'] ?? '',
              q['estado'] ?? '',
              q['descripcion'] ?? '',
              (q['fecha'] as Timestamp?)?.toDate().toString().split(' ')[0] ?? '',
            ];
          }).toList(),
        )
      ],
    ),
  );

  final pdfBytes = await pdf.save(); // Guarda el documento como bytes

  // Abre la opción para compartir o guardar el PDF generado
  await Printing.sharePdf(
    bytes: pdfBytes,
    filename: 'reporte_quejas.pdf',
  );
}
