import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/orden_modelo.dart';
import '../proveedores/mesas_provider.dart';
import '../proveedores/auth_provider.dart';
import '../proveedores/caja_provider.dart'; // <--- Importamos la Caja

class PagoScreen extends StatefulWidget {
  final Orden orden;

  const PagoScreen({super.key, required this.orden});

  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

class _PagoScreenState extends State<PagoScreen> {
  double _descuento = 0.0;
  double _propina = 0.0;
  String _metodoPago = 'Efectivo';
  final _efectivoCtrl = TextEditingController();
  final _transfCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _efectivoCtrl.text = widget.orden.total.toStringAsFixed(0);
    _transfCtrl.text = "0";
  }

  double get _totalConDescuento => widget.orden.total - _descuento;
  double get _totalFinal => _totalConDescuento + _propina;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facturación y Cobro'), backgroundColor: Colors.green[700]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Resumen
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    _fila('Subtotal:', widget.orden.total),
                    const Divider(),
                    _fila('(-) Descuento:', _descuento, color: Colors.red),
                    _fila('(+) Propina:', _propina, color: Colors.blue),
                    const Divider(thickness: 2),
                    _fila('TOTAL A COBRAR:', _totalFinal, bold: true, size: 24, color: Colors.green[800]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Campos Descuento / Propina
            Row(children: [
              Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Descuento', prefixIcon: Icon(Icons.money_off)), onChanged: (v) => setState(() => _descuento = double.tryParse(v) ?? 0))),
              const SizedBox(width: 10),
              Expanded(child: TextField(keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Propina', prefixIcon: Icon(Icons.favorite)), onChanged: (v) => setState(() => _propina = double.tryParse(v) ?? 0))),
            ]),
            const SizedBox(height: 20),

            // Método Pago
            const Text('¿Cómo paga el cliente?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _botonPago('Efectivo', Icons.money),
              _botonPago('Transferencia', Icons.qr_code),
              _botonPago('Mixto', Icons.call_split),
            ]),
            
            if (_metodoPago == 'Mixto')
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(children: [
                  Expanded(child: TextField(controller: _efectivoCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto Efectivo'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: _transfCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto Transferencia'))),
                ]),
              ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
                onPressed: _cobrar,
                child: Text('CONFIRMAR PAGO \$${_totalFinal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _fila(String label, double val, {bool bold = false, double size = 16, Color? color}) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)), Text('\$${val.toStringAsFixed(0)}', style: TextStyle(fontSize: size, color: color, fontWeight: bold ? FontWeight.bold : FontWeight.normal))]));
  }

  Widget _botonPago(String tipo, IconData icon) {
    bool sel = _metodoPago == tipo;
    return InkWell(
      onTap: () => setState(() { _metodoPago = tipo; if(tipo!='Mixto') { _efectivoCtrl.text = _totalFinal.toString(); _transfCtrl.text = '0'; } }),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: sel ? Colors.green[100] : Colors.white, border: Border.all(color: sel ? Colors.green : Colors.grey), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [Icon(icon, color: sel ? Colors.green : Colors.grey), Text(tipo, style: TextStyle(color: sel ? Colors.green : Colors.grey))]),
      ),
    );
  }

void _cobrar() {
    // Validar montos
    double pagoEf = _metodoPago == 'Efectivo' ? _totalFinal : double.tryParse(_efectivoCtrl.text) ?? 0;
    double pagoTr = _metodoPago == 'Transferencia' ? _totalFinal : double.tryParse(_transfCtrl.text) ?? 0;

    if (_metodoPago == 'Mixto' && (pagoEf + pagoTr) < _totalFinal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Faltan cubrir el total')));
      return;
    }

    // ALERTA DE SEGURIDAD
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total a cobrar: \$${_totalFinal.toStringAsFixed(0)}'),
            Text('Método: $_metodoPago'),
            const SizedBox(height: 10),
            const Text('¿Estás seguro que recibiste el dinero?', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Esperar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              Navigator.pop(ctx); // Cerrar alerta
              
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final mesas = Provider.of<MesasProvider>(context, listen: false);
              final caja = Provider.of<CajaProvider>(context, listen: false);

              // 1. Caja
              if (pagoEf > 0) await caja.registrarMovimiento('Venta Mesa ${widget.orden.nombreMesa}', pagoEf, 'ingreso_efectivo');
              if (pagoTr > 0) await caja.registrarMovimiento('Venta Mesa ${widget.orden.nombreMesa}', pagoTr, 'ingreso_transf');

              // 2. Cerrar Mesa
              await mesas.finalizarVenta(
                idMesa: widget.orden.mesaId,
                cajeroId: auth.usuarioActual?.nombre ?? 'Admin',
                descuento: _descuento,
                propina: _propina,
                totalFinal: _totalFinal,
                metodoPago: _metodoPago,
                pagoEfectivo: pagoEf,
                pagoTransferencia: pagoTr,
              );

              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Venta Cobrada! 💰')));
            },
            child: const Text('SÍ, COBRAR', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}