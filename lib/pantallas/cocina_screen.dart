import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../modelos/orden_modelo.dart';
import '../proveedores/mesas_provider.dart';

class CocinaScreen extends StatelessWidget {
  const CocinaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Comandas Cocina', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ordenes')
            .where('estado', isEqualTo: 'abierta')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data!.docs;
          
          // Filtro manual para evitar índices complejos
          final ordenes = docs
              .map((d) => Orden.fromMap(d.data() as Map<String, dynamic>, d.id))
              .where((o) => o.estadoCocina != 'listo') // Solo pendientes
              .toList();

          // Ordenar por hora (Lo más viejo primero para que salga rápido)
          ordenes.sort((a, b) => a.fechaApertura.compareTo(b.fechaApertura));

          if (ordenes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80, color: Colors.green[200]),
                  const SizedBox(height: 20),
                  const Text('Cocina al día. ¡Excelente!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              return _TarjetaCocina(orden: ordenes[index]);
            },
          );
        },
      ),
    );
  }
}

class _TarjetaCocina extends StatelessWidget {
  final Orden orden;
  const _TarjetaCocina({super.key, required this.orden});

  @override
  Widget build(BuildContext context) {
    final minutos = DateTime.now().difference(orden.fechaApertura).inMinutes;
    final provider = Provider.of<MesasProvider>(context, listen: false);

    // Agrupación de productos
    Map<String, int> cantidades = {};
    Map<String, String> nombres = {};
    for (var p in orden.productos) {
      cantidades[p.id] = (cantidades[p.id] ?? 0) + 1;
      nombres[p.id] = p.nombre;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: minutos > 20 ? Border.all(color: Colors.red.withOpacity(0.5), width: 2) : null,
      ),
      child: Column(
        children: [
          // CABECERA (Con Zona Agregada)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            decoration: BoxDecoration(
              color: minutos > 20 ? Colors.red[50] : Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // AQUÍ ESTÁ EL CAMBIO: MESA + ZONA
                      Text(
                        '${orden.nombreMesa} (${orden.nombreSeccion})', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                      ),
                      Text('Mesero: ${orden.meseroId ?? "Staff"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                  child: Text('$minutos min', style: TextStyle(fontWeight: FontWeight.bold, color: minutos > 20 ? Colors.red : Colors.green[700])),
                )
              ],
            ),
          ),
          
          // NOTA (Grande)
          if (orden.nota.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.yellow[100],
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  const SizedBox(width: 10),
                  Expanded(child: Text(orden.nota, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                ],
              ),
            ),

          // LISTA DE PLATOS (Checks Persistentes)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cantidades.length,
            itemBuilder: (context, i) {
              String id = cantidades.keys.elementAt(i);
              int cant = cantidades[id]!;
              String nombre = nombres[id]!;
              
              // LEEMOS EL ESTADO DIRECTAMENTE DE LA ORDEN (BASE DE DATOS)
              bool isChecked = orden.checksCocina[id] ?? false;

              return CheckboxListTile(
                value: isChecked,
                activeColor: Colors.grey,
                // AL CAMBIAR, LLAMAMOS AL PROVIDER PARA GUARDAR EN FIREBASE
                onChanged: (val) => provider.toggleCheckCocina(orden.id, id, val!),
                title: Text(
                  '${cant}x  $nombre', 
                  style: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    decoration: isChecked ? TextDecoration.lineThrough : null,
                    color: isChecked ? Colors.grey : Colors.black
                  )
                ),
              );
            },
          ),

          // BOTÓN DESPACHAR
          Padding(
            padding: const EdgeInsets.all(15),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('DESPACHAR / LISTO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () => _confirmarDespacho(context, orden.id),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _confirmarDespacho(BuildContext context, String ordenId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Despachar Orden?'),
        content: const Text('La comanda desaparecerá de la pantalla.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Provider.of<MesasProvider>(context, listen: false).marcarOrdenDespachada(ordenId);
              Navigator.pop(ctx);
            },
            child: const Text('SÍ, DESPACHAR', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}