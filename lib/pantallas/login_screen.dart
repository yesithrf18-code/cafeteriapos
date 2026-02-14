import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/auth_provider.dart';
import 'principal_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _pin = "";
  bool _loading = false;

  void _agregar(String n) { if (_pin.length < 4) setState(() => _pin += n); }
  void _borrar() { if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1)); }

  void _validar() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool ok = await auth.login(_pin);
    
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrincipalScreen()));
    } else {
      setState(() { _loading = false; _pin = ""; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN Incorrecto'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NUEVO ICONO Y TEXTO
            const Icon(Icons.coffee, size: 60, color: Colors.orange), // Icono Café
            const SizedBox(height: 15),
            const Text(
              'COFFEE BREAK', 
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)
            ),
            const SizedBox(height: 10),
            const Text('Ingresa tu PIN de acceso', style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 40),
            
            // Puntos PIN
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.all(10), width: 15, height: 15, decoration: BoxDecoration(color: i < _pin.length ? Colors.orange : Colors.grey[800], shape: BoxShape.circle)))),
            const SizedBox(height: 40),

            if (_loading) 
              const CircularProgressIndicator(color: Colors.orange)
            else
              SizedBox(
                width: 300,
                child: GridView.count(
                  shrinkWrap: true, crossAxisCount: 3, childAspectRatio: 1.2,
                  children: [
                    ...['1','2','3','4','5','6','7','8','9'].map((n) => _btn(n)),
                    IconButton(onPressed: _borrar, icon: const Icon(Icons.backspace_outlined, color: Colors.white)),
                    _btn('0'),
                    IconButton(onPressed: _validar, icon: const Icon(Icons.arrow_forward, color: Colors.orange)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _btn(String n) => TextButton(onPressed: () => _agregar(n), child: Text(n, style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)));
}