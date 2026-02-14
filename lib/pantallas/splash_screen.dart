import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/auth_provider.dart';
import 'principal_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _validarSesion();
  }

  Future<void> _validarSesion() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // TRUCO: Ejecutamos dos cosas al tiempo
    // 1. La animación de espera (mínimo 3 segundos para que se vea tu nombre)
    // 2. La verificación de la base de datos (puede tardar 0.5s o 5s)
    
    final resultados = await Future.wait([
      Future.delayed(const Duration(seconds: 3)), // Espera visual
      auth.intentarAutoLogin(), // Intento de login real
    ]);

    if (!mounted) return;

    // resultados[1] es el booleano (true o false) del login
    bool estaLogueado = resultados[1] as bool;

    if (estaLogueado) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PrincipalScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
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
            const Icon(Icons.coffee, size: 80, color: Colors.orange), // Icono naranja
            const SizedBox(height: 20),
            
            const Text(
              'COFFEE BREAK',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            
            const SizedBox(
              width: 30, height: 30,
              child: CircularProgressIndicator(color: Colors.orange, strokeWidth: 2)
            ),
            
            const SizedBox(height: 50),
            
            const Text('Desarrollado por', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 5),
            const Text(
              'YESITH',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5
              ),
            ),
          ],
        ),
      ),
    );
  }
}