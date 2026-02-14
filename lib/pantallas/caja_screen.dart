import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/caja_provider.dart';
import '../proveedores/auth_provider.dart';
import 'cierre_caja_screen.dart'; 
import 'historial_cierres_screen.dart'; // <--- IMPORTANTE

class CajaScreen extends StatefulWidget {
  const CajaScreen({super.key});
  @override
  State<CajaScreen> createState() => _CajaScreenState();
}

class _CajaScreenState extends State<CajaScreen> {
  @override
  Widget build(BuildContext context) {
    final caja = Provider.of<CajaProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    // Si la caja está cerrada, mostrar aviso simple
    if (!caja.cajaAbierta) return const Scaffold(body: Center(child: Text("Caja Cerrada")));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Arqueo de Caja', style: TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.teal, 
        elevation: 0,
        actions: [
          // BOTÓN NUEVO: VER HISTORIAL
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'Ver Cierres Pasados',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistorialCierresScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.all(20)),
                icon: const Icon(Icons.lock_clock, color: Colors.white),
                label: const Text('CERRAR CAJA / TURNO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const CierreCajaScreen()));
                },
              ),
            ),

            if (caja.baseCaja == 0)
              Container(margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)), child: const Text('⚠️ Caja en 0 (Sin Base)', textAlign: TextAlign.center, style: TextStyle(color: Colors.orange))),

            _cardPrincipal(caja.totalEnCajaFisica),
            const SizedBox(height: 20),
            
            Row(children: [Expanded(child: _cardDetalle('Base Inicial', caja.baseCaja, Colors.blue, Icons.savings)), const SizedBox(width: 10), Expanded(child: _cardDetalle('Ventas Efectivo', caja.totalEfectivo, Colors.green, Icons.attach_money))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _cardDetalle('Ventas Transf.', caja.totalTransferencia, Colors.purple, Icons.qr_code)), const SizedBox(width: 10), Expanded(child: _cardDetalle('Gastos / Salidas', caja.totalGastos, Colors.red, Icons.money_off))]),
            
            const SizedBox(height: 30),
            ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 15)), icon: const Icon(Icons.remove_circle_outline, color: Colors.white), label: const Text('REGISTRAR GASTO', style: TextStyle(color: Colors.white)), onPressed: () => _dialogoGasto(context)),
            
            const Divider(height: 40, thickness: 2),
            const Text("Movimientos del Turno:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: caja.movimientos.length, itemBuilder: (context, index) {
                final mov = caja.movimientos[index];
                return Card(elevation: 0, margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: _iconoTipo(mov.tipo), title: Text(mov.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(_hora(mov.fecha)), trailing: Text('\$${mov.monto.toStringAsFixed(0)}', style: TextStyle(color: mov.tipo == 'gasto' ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 16))));
            }),
          ],
        ),
      ),
    );
  }

  // HELPERS VISUALES
  Widget _cardPrincipal(double total) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.teal, Colors.teal.shade700]), borderRadius: BorderRadius.circular(20)), child: Column(children: [const Text('DINERO EN CAJÓN', style: TextStyle(color: Colors.white70)), Text('\$${total.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold))]));
  Widget _cardDetalle(String t, double v, Color c, IconData i) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [Icon(i, color: c), Text(t, style: TextStyle(color: Colors.grey[600], fontSize: 12)), Text('\$${v.toStringAsFixed(0)}', style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.bold))]));
  Widget _iconoTipo(String t) => Icon(t == 'gasto' ? Icons.arrow_downward : Icons.arrow_upward, color: t == 'gasto' ? Colors.red : Colors.green);
  String _hora(DateTime f) => "${f.hour}:${f.minute.toString().padLeft(2, '0')}";

  void _dialogoGasto(BuildContext context) {
     final mCtrl = TextEditingController(); final vCtrl = TextEditingController();
     showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Registrar Gasto'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: mCtrl, decoration: const InputDecoration(labelText: 'Motivo')), TextField(controller: vCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto'))]), actions: [ElevatedButton(onPressed: (){ 
       if(mCtrl.text.isNotEmpty && vCtrl.text.isNotEmpty) {
          Provider.of<CajaProvider>(context, listen: false).registrarMovimiento(mCtrl.text, double.tryParse(vCtrl.text)??0, 'gasto'); 
          Navigator.pop(context);
       }
     }, child: const Text('Guardar'))]));
  }
}