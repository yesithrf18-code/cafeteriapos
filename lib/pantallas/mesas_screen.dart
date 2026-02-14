import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/mesas_provider.dart';
import '../proveedores/auth_provider.dart';
import '../modelos/mesa_modelo.dart';
import '../modelos/seccion_modelo.dart';
import 'toma_pedidos_screen.dart';
import 'detalle_mesa_screen.dart';

class MesasScreen extends StatelessWidget {
  const MesasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MesasProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    if (provider.secciones.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
    }

    return DefaultTabController(
      length: provider.secciones.length,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          toolbarHeight: 90,
          backgroundColor: Colors.grey[50],
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hola, Equipo 👋', style: TextStyle(color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold)),
                Text(
                  auth.usuarioActual?.nombre ?? 'Mesero', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 14)
                ),
              ],
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10, top: 10),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                tooltip: 'Cerrar Sesión',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('¿Cerrar Sesión?'),
                      content: const Text('Tendrás que ingresar tu PIN nuevamente.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () {
                             Navigator.pop(ctx);
                             auth.logout();
                          },
                          child: const Text('SALIR', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 10, left: 15),
              alignment: Alignment.centerLeft,
              child: TabBar(
                isScrollable: true,
                indicator: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.label,
                padding: EdgeInsets.zero,
                dividerColor: Colors.transparent,
                tabs: provider.secciones.map((s) => Container(padding: const EdgeInsets.symmetric(horizontal: 15), child: Tab(text: s.nombre))).toList(),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: provider.secciones.map((s) => _GridMesas(seccion: s)).toList(),
        ),
      ),
    );
  }
}

class _GridMesas extends StatelessWidget {
  final Seccion seccion;
  const _GridMesas({required this.seccion});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MesasProvider>(context);
    final mesas = provider.mesasPorSeccion(seccion.nombre);

    if (mesas.isEmpty) return Center(child: Text('Zona sin mesas', style: TextStyle(color: Colors.grey[400])));

    // --- DETECCIÓN DE PANTALLA ---
    // Si el ancho es mayor a 600px, es Tablet o PC. Si es mayor a 1100, es PC Pantalla Grande.
    double ancho = MediaQuery.of(context).size.width;
    int columnas = 2; // Celular
    if (ancho > 600) columnas = 3; // Tablet
    if (ancho > 900) columnas = 4; // PC Pequeño
    if (ancho > 1200) columnas = 5; // PC Grande

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnas, // <--- AQUÍ ESTÁ LA MAGIA RESPONSIVA
        childAspectRatio: 1.0, // Cuadradas
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: mesas.length,
      itemBuilder: (ctx, i) => _MesaCard(mesa: mesas[i], colorSeccion: seccion.colorValue),
    );
  }
}

class _MesaCard extends StatelessWidget {
  final Mesa mesa;
  final int colorSeccion;
  const _MesaCard({required this.mesa, required this.colorSeccion});

  @override
  Widget build(BuildContext context) {
    bool ocupada = mesa.estado == 'ocupada';
    
    return InkWell(
      onTap: () {
        if (!ocupada) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => TomaPedidosScreen(mesa: mesa)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DetalleMesaScreen(mesa: mesa)));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: ocupada ? Colors.red.withOpacity(0.1) : Colors.black.withOpacity(0.03), 
              blurRadius: 15, 
              offset: const Offset(0, 5)
            )
          ],
          border: ocupada ? Border.all(color: Colors.redAccent, width: 2) : null
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: ocupada ? Colors.red[50] : Color(colorSeccion).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.deck_outlined, 
                size: 32, 
                color: ocupada ? Colors.red : Color(colorSeccion)
              ),
            ),
            const SizedBox(height: 15),
            Text(mesa.nombre, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: ocupada ? Colors.red : Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                ocupada ? 'OCUPADA' : 'DISPONIBLE', 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold,
                  color: ocupada ? Colors.white : Colors.green
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}