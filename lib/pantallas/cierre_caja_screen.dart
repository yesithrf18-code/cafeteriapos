import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/caja_provider.dart';
import '../proveedores/auth_provider.dart';

class CierreCajaScreen extends StatefulWidget {
  const CierreCajaScreen({super.key});

  @override
  State<CierreCajaScreen> createState() => _CierreCajaScreenState();
}

class _CierreCajaScreenState extends State<CierreCajaScreen> {
  final _realCtrl = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    final caja = Provider.of<CajaProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    
    // CORRECCIÓN 1: Usar 'totalEnCajaFisica' en lugar de 'saldoActualEfectivo'
    double ingresado = double.tryParse(_realCtrl.text) ?? 0;
    double diferencia = ingresado - caja.totalEnCajaFisica;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Turno', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('RESUMEN DEL SISTEMA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 10),
            
            // TARJETA DE RESUMEN
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  // CORRECCIÓN 2: Usar los getters nuevos del Provider
                  _row('Base Inicial (+)', caja.baseCaja),
                  _row('Ventas Efectivo (+)', caja.totalEfectivo), 
                  _row('Gastos/Salidas (-)', caja.totalGastos),
                  const Divider(thickness: 2),
                  _row('DEBE HABER EN CAJA (=)', caja.totalEnCajaFisica, bold: true, size: 20),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Text('CONTEO REAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('¿Cuánto dinero contaste físicamente?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),

            TextField(
              controller: _realCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green),
              decoration: const InputDecoration(hintText: '\$ 0', border: InputBorder.none),
              onChanged: (v) => setState((){}),
            ),
            
            // INDICADOR DE CUADRE
            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              decoration: BoxDecoration(
                color: diferencia == 0 ? Colors.green[100] : (diferencia > 0 ? Colors.blue[100] : Colors.red[100]),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                diferencia == 0 ? 'CAJA CUADRADA PERFECTA' 
                : (diferencia > 0 ? 'SOBRAN \$${diferencia.toStringAsFixed(0)}' : 'FALTAN \$${diferencia.abs().toStringAsFixed(0)}'),
                style: TextStyle(fontWeight: FontWeight.bold, color: diferencia == 0 ? Colors.green : (diferencia > 0 ? Colors.blue : Colors.red))
              ),
            ),

            const SizedBox(height: 30),
            
            // CORRECCIÓN 3: Usar 'totalTransferencia' en lugar de 'ventasTransf'
            _row('Ventas Transferencia/Nequi', caja.totalTransferencia, color: Colors.purple),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  // CONFIRMACIÓN FINAL
                  showDialog(context: context, builder: (ctx) => AlertDialog(
                    title: const Text('¿Cerrar Turno Definitivamente?'),
                    content: const Text('Esto cerrará la sesión actual y guardará el reporte. No se puede deshacer.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () async {
                          // Llamamos a cerrarCaja del Provider
                          await caja.cerrarCaja(
                            auth.usuarioActual?.nombre ?? 'Admin', 
                            double.tryParse(_realCtrl.text) ?? 0
                          );
                          Navigator.pop(ctx); // Cierra dialogo
                          Navigator.pop(context); // Cierra pantalla
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Turno Cerrado Correctamente')));
                        }, 
                        child: const Text('CONFIRMAR CIERRE', style: TextStyle(color: Colors.white))
                      )
                    ],
                  ));
                },
                child: const Text('FINALIZAR TURNO E IMPRIMIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double val, {bool bold = false, double size = 16, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text('\$${val.toStringAsFixed(0)}', style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black)),
        ],
      ),
    );
  }
}