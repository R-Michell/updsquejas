import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetalleQuejaPage extends StatefulWidget {
  final DocumentSnapshot queja;
  const DetalleQuejaPage({super.key, required this.queja});

  @override
  State<DetalleQuejaPage> createState() => _DetalleQuejaPageState();
}

class _DetalleQuejaPageState extends State<DetalleQuejaPage> {
  late String _estado;
  late TextEditingController _respuestaController;

  @override
  void initState() {
    super.initState();
    _estado = widget.queja['estado'] ?? 'pendiente';
    _respuestaController = TextEditingController(text: widget.queja['respuesta'] ?? '');
  }

  Future<void> _actualizarQueja() async {
    await FirebaseFirestore.instance.collection('quejas').doc(widget.queja.id).update({
      'estado': _estado,
      'respuesta': _respuestaController.text,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Queja actualizada correctamente')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final descripcion = widget.queja['descripcion'] ?? '';
    final categoria = widget.queja['categoria'] ?? '';
    final fecha = (widget.queja['fecha'] as Timestamp?)?.toDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Queja'),
        backgroundColor: const Color(0xFF990000),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text('Categoría: $categoria', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Fecha: ${fecha != null ? fecha.toLocal().toString().substring(0, 16) : 'N/D'}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Descripción:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(descripcion, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text('Estado:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _estado,
              items: const [
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                DropdownMenuItem(value: 'en proceso', child: Text('En proceso')),
                DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _estado = value;
                  });
                }
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            const Text('Respuesta / Nota del Administrador:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _respuestaController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Escribe una respuesta o nota interna...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF990000),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: _actualizarQueja,
                child: const Text('Guardar Cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
