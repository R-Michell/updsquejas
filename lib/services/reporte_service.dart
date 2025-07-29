import 'dart:typed_data'; // Importa tipos de datos para manejar bytes (usado por el PDF)
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore para acceder a la base de datos
import 'package:intl/intl.dart'; // Importa la librería para formatear fechas
import 'package:pdf/pdf.dart'; // Importa herramientas para crear documentos PDF
import 'package:pdf/widgets.dart' as pw; // Importa widgets de PDF con prefijo 'pw'
import 'package:printing/printing.dart'; // Importa herramientas para manejar la impresión de PDFs

class ReporteService { // Clase para manejar la generación de reportes en PDF
  static Future<void> generarReportePDF() async { // Función estática asíncrona para generar el reporte
    final pdf = pw.Document(); // Crea un nuevo documento PDF
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm'); // Define el formato de fecha y hora

    // Obtiene todas las quejas de Firestore, ordenadas por fecha descendente
    final snapshot = await FirebaseFirestore.instance
        .collection('quejas')
        .orderBy('fecha', descending: true)
        .get();
    final quejas = snapshot.docs; // Almacena los documentos de quejas obtenidos

    // Añade una página al documento PDF
    pdf.addPage(
      pw.MultiPage( // Usa MultiPage para soportar múltiples páginas si hay muchas quejas
        pageFormat: PdfPageFormat.a4, // Establece el formato de página como A4
        build: (pw.Context context) => [ // Define el contenido de la página
          pw.Header( // Encabezado del reporte
            level: 0, // Nivel de encabezado (principal)
            child: pw.Text(
              'Reporte de Quejas - UPDS', // Título del reporte
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold), // Estilo del título
            ),
          ),
          pw.Text('Generado: ${dateFormat.format(DateTime.now())}\n\n'), // Muestra la fecha y hora de generación
          pw.Table.fromTextArray( // Crea una tabla con los datos de las quejas
            headers: ['Fecha', 'Categoría', 'Estado', 'Descripción'], // Encabezados de la tabla
            data: quejas.map((q) { // Mapea cada queja a una fila de la tabla
              final fecha = (q['fecha'] as Timestamp?)?.toDate(); // Convierte el timestamp a DateTime o null
              return [
                fecha != null ? dateFormat.format(fecha) : 'N/D', // Formatea la fecha o muestra 'N/D'
                q['categoria'] ?? '', // Categoría de la queja o vacío
                q['estado'] ?? '', // Estado de la queja o vacío
                (q['descripcion'] ?? '').toString().replaceAll('\n', ' '), // Descripción, reemplazando saltos de línea por espacios
              ];
            }).toList(),
            cellStyle: const pw.TextStyle(fontSize: 10), // Estilo de las celdas (tamaño pequeño)
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold), // Estilo de los encabezados (negrita)
            cellAlignment: pw.Alignment.centerLeft, // Alinea el contenido de las celdas a la izquierda
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300), // Fondo gris claro para los encabezados
          ),
        ],
      ),
    );

    // Genera el PDF y lo pasa al sistema de impresión o visualización
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(), // Guarda el documento PDF como bytes
    );
  }
}