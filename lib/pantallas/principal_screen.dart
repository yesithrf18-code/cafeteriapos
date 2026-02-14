import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/auth_provider.dart';
import '../proveedores/caja_provider.dart';
import 'mesas_screen.dart';
import 'admin_screen.dart';
import 'apertura_caja_screen.dart';
import 'login_screen.dart';

class PrincipalScreen extends StatefulWidget {
  const PrincipalScreen({super.key});
  @override
  State<PrincipalScreen> createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final caja = Provider.of<CajaProvider>(context);

    // 1. PANTALLA DE CARGA (Solo verificamos la CAJA, porque el Auth ya cargó en el Splash)
    if (caja.cargando) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    // 2. SI NO HAY USUARIO -> LOGIN (Por seguridad extra)
    if (auth.usuarioActual == null) {
      // Usamos un micro-delay para evitar errores de renderizado si pasa muy rápido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      });
      return const Scaffold(body: SizedBox()); // Pantalla blanca mientras redirige
    }

    // 3. SI CAJA CERRADA -> ABRIR
    if (!caja.cajaAbierta) {
      return const AperturaCajaScreen();
    }

    // 4. APP NORMAL
    final esAdmin = auth.esAdmin;
    final List<Widget> pantallas = esAdmin 
      ? [const MesasScreen(), const AdminScreen()] 
      : [const MesasScreen()];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: pantallas[_indiceActual >= pantallas.length ? 0 : _indiceActual],
      ),
      bottomNavigationBar: esAdmin ? NavigationBar(
        height: 65,
        backgroundColor: Colors.white,
        selectedIndex: _indiceActual,
        onDestinationSelected: (int index) => setState(() => _indiceActual = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront), label: 'Ventas'),
          NavigationDestination(icon: Icon(Icons.grid_view), label: 'Control'),
        ],
      ) : null,
    );
  }
}