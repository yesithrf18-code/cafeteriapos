import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/caja_provider.dart';
import '../proveedores/auth_provider.dart';

class AperturaCajaScreen extends StatefulWidget {
  const AperturaCajaScreen({super.key});

  @override
  State<AperturaCajaScreen> createState() => _AperturaCajaScreenState();
}

class _AperturaCajaScreenState extends State<AperturaCajaScreen> {
  final _montoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_clock, size: 60, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text('INICIAR TURNO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Ingresa la base de efectivo inicial', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 30),
              TextField(
                controller: _montoCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixText: '\$ ',
                  hintText: '0',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                  onPressed: () {
                    double monto = double.tryParse(_montoCtrl.text) ?? 0;
                    Provider.of<CajaProvider>(context, listen: false)
                        .abrirCaja(auth.usuarioActual?.nombre ?? 'Admin', monto);
                  },
                  child: const Text('ABRIR CAJA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
              Text('Usuario: ${auth.usuarioActual?.nombre}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              TextButton(
                onPressed: () => auth.logout(), // Si quieres cambiar de usuario
                child: const Text('Cerrar Sesión / Cambiar Usuario'),
              )
            ],
          ),
        ),
      ),
    );
  }
}