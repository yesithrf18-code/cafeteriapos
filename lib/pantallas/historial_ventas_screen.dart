import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/orden_modelo.dart';

class HistorialVentasScreen extends StatelessWidget {
  const HistorialVentasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Fondo limpio
      appBar: AppBar(
        title: const Text('Historial de Ventas', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ordenes').where('estado', isEqualTo: 'pagada').limit(50).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text('Sin ventas registradas'));

          final docs = snapshot.data!.docs;
          final ordenes = docs.map((d) => Orden.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
          
          // Ordenar por fecha reciente
          ordenes.sort((a, b) => (b.fechaCierre ?? DateTime.now()).compareTo(a.fechaCierre ?? DateTime.now()));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              final orden = ordenes[index];
              return _VentaCard(orden: orden);
            },
          );
        },
      ),
    );
  }
}

class _VentaCard extends StatelessWidget {
  final Orden orden;
  const _VentaCard({required this.orden});

  @override
  Widget build(BuildContext context) {
    // Determinamos colores e iconos según pago
    bool esEfectivo = orden.metodoPago == 'Efectivo';
    bool esMixto = orden.metodoPago == 'Mixto';
    
    Color colorPago = esEfectivo ? Colors.green : (esMixto ? Colors.orange : Colors.purple);
    IconData iconoPago = esEfectivo ? Icons.attach_money : (esMixto ? Icons.call_split : Icons.qr_code);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorPago.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconoPago, color: colorPago),
          ),
          title: Text(
            '\$${orden.totalFinal.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Row(
            children: [
              Text(orden.nombreMesa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 5),
              Text('• ${_hora(orden.fechaCierre!)}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _filaDetalle('Método', orden.metodoPago, bold: true, color: colorPago),
                  const Divider(),
                  ...orden.productos.map((p) => _filaDetalle(p.nombre, '\$${p.precio.toStringAsFixed(0)}')),
                  const Divider(),
                  if(orden.propina > 0) _filaDetalle('Propina', '+\$${orden.propina.toStringAsFixed(0)}', color: Colors.blue),
                  if(orden.descuento > 0) _filaDetalle('Descuento', '-\$${orden.descuento.toStringAsFixed(0)}', color: Colors.red),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Neto', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${orden.totalFinal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _filaDetalle(String label, String valor, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          Text(valor, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black, fontSize: 13)),
        ],
      ),
    );
  }

  String _hora(DateTime f) => "${f.hour}:${f.minute.toString().padLeft(2, '0')}";
}