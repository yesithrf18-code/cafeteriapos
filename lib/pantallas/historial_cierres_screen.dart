import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/sesion_caja_modelo.dart';

class HistorialCierresScreen extends StatelessWidget {
  const HistorialCierresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Historial de Cierres', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // TRUCO: Pedimos TODO y filtramos aquí para evitar error de índice
        stream: FirebaseFirestore.instance.collection('sesiones_caja').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          
          // 1. Filtrar solo las CERRADAS
          // 2. Convertir a Objetos
          // 3. Ordenar por fecha
          final cierres = docs
              .map((d) => SesionCaja.fromMap(d.data() as Map<String, dynamic>, d.id))
              .where((s) => s.estado == 'cerrada')
              .toList();
          
          cierres.sort((a, b) => (b.fechaCierre ?? DateTime.now()).compareTo(a.fechaCierre ?? DateTime.now()));

          if (cierres.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  const Text('No hay cierres registrados', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: cierres.length,
            itemBuilder: (context, index) {
              final sesion = cierres[index];
              
              // Cuadre perfecto si la diferencia es menor a 500 pesos (tolerancia monedas)
              bool cuadrePerfecto = sesion.diferencia.abs() < 500;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  border: cuadrePerfecto ? null : Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: cuadrePerfecto ? Colors.green[50] : Colors.red[50],
                    child: Icon(
                      cuadrePerfecto ? Icons.check : Icons.warning_amber_rounded,
                      color: cuadrePerfecto ? Colors.green : Colors.red
                    ),
                  ),
                  title: Text(
                    'Cierre: \$${sesion.totalReal.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    '${_fecha(sesion.fechaCierre!)} • ${sesion.usuarioCierre}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: Colors.grey[50],
                      child: Column(
                        children: [
                          _fila('Base Inicial', sesion.montoInicial),
                          _fila('Ventas Efectivo', sesion.totalVentasEfectivo),
                          _fila('Ventas Transf.', sesion.totalVentasTransf),
                          _fila('Gastos', sesion.totalGastos, esResta: true),
                          const Divider(),
                          _fila('Debió haber (Sistema)', sesion.totalSistema, negrita: true),
                          _fila('Hubo (Físico)', sesion.totalReal, negrita: true, color: Colors.blue),
                          const SizedBox(height: 10),
                          if (!cuadrePerfecto)
                            Text(
                              'Diferencia: ${sesion.diferencia > 0 ? "+" : ""}\$${sesion.diferencia.toStringAsFixed(0)}',
                              style: TextStyle(color: sesion.diferencia > 0 ? Colors.blue : Colors.red, fontWeight: FontWeight.bold),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _fila(String label, double valor, {bool esResta = false, bool negrita = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: negrita ? FontWeight.bold : FontWeight.normal)),
          Text(
            '${esResta ? "-" : ""}\$${valor.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: negrita ? FontWeight.bold : FontWeight.normal,
              color: color ?? (esResta ? Colors.red : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  String _fecha(DateTime d) => "${d.day}/${d.month} ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
}