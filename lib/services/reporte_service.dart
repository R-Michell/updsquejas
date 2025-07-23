import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReporteService {
  static Future<void> generarReportePDF() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    final snapshot = await FirebaseFirestore.instance
        .collection('quejas')
        .orderBy('fecha', descending: true)
        .get();
    final quejas = snapshot.docs;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte de Quejas - UPDS',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Generado: ${dateFormat.format(DateTime.now())}\n\n'),
          pw.Table.fromTextArray(
            headers: ['Fecha', 'Categoría', 'Estado', 'Descripción'],
            data: quejas.map((q) {
              final fecha = (q['fecha'] as Timestamp?)?.toDate();
              return [
                fecha != null ? dateFormat.format(fecha) : 'N/D',
                q['categoria'] ?? '',
                q['estado'] ?? '',
                (q['descripcion'] ?? '').toString().replaceAll('\n', ' '),
              ];
            }).toList(),
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}