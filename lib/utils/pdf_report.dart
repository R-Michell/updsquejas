import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> generatePdfReport(
  BuildContext context,
  List<QueryDocumentSnapshot> quejas,
  List<String> selectedFacultades,
  List<String> selectedCategorias,
  List<String> selectedEstados,
) async {
  final pdf = pw.Document();

  final filtradas = quejas.where((q) {
    final f = q['facultad'];
    final c = q['categoria'];
    final e = q['estado'];
    return (selectedFacultades.isEmpty || selectedFacultades.contains(f)) &&
        (selectedCategorias.isEmpty || selectedCategorias.contains(c)) &&
        (selectedEstados.isEmpty || selectedEstados.contains(e));
  }).toList();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Text('Reporte de Quejas', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),

        pw.Text('Facultades seleccionadas: ${selectedFacultades.isNotEmpty ? selectedFacultades.join(', ') : 'Todas'}'),
        pw.Text('Categorías seleccionadas: ${selectedCategorias.isNotEmpty ? selectedCategorias.join(', ') : 'Todas'}'),
        pw.Text('Estados seleccionados: ${selectedEstados.isNotEmpty ? selectedEstados.join(', ') : 'Todos'}'),
        pw.SizedBox(height: 20),

        pw.Table.fromTextArray(
          border: pw.TableBorder.all(width: 0.5),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          cellStyle: pw.TextStyle(fontSize: 10),
          cellAlignment: pw.Alignment.centerLeft,
          headerAlignment: pw.Alignment.center,
          columnWidths: {
            0: pw.FlexColumnWidth(2.5), // Facultad
            1: pw.FlexColumnWidth(1.5), // Categoría
            2: pw.FlexColumnWidth(1.5), // Estado
            3: pw.FlexColumnWidth(4),   // Descripción
            4: pw.FlexColumnWidth(2),   // Fecha
          },
          headers: ['Facultad', 'Categoría', 'Estado', 'Descripción', 'Fecha'],
          data: filtradas.map((q) {
            final facultad = q['facultad'] ?? '';
            final categoria = q['categoria'] ?? '';
            final estado = q['estado'] ?? '';
            final descripcion = q['descripcion'] ?? '';
            final fecha = (q['fecha'] != null && q['fecha'] is Timestamp)
                ? (q['fecha'] as Timestamp).toDate().toString().split(' ')[0]
                : '';
            return [facultad, categoria, estado, descripcion, fecha];
          }).toList(),
        ),
      ],
    ),
  );

  final pdfBytes = await pdf.save();

  // Opción para compartir o guardar el PDF
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdfBytes,
    name: 'reporte_quejas.pdf',
  );
}
