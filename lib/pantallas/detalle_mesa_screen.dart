import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/mesa_modelo.dart';
import '../modelos/orden_modelo.dart';
import '../modelos/producto_modelo.dart';
import '../proveedores/mesas_provider.dart';
import '../proveedores/auth_provider.dart';
import 'toma_pedidos_screen.dart';
import 'pago_screen.dart';

class DetalleMesaScreen extends StatefulWidget {
  final Mesa mesa;
  const DetalleMesaScreen({super.key, required this.mesa});

  @override
  State<DetalleMesaScreen> createState() => _DetalleMesaScreenState();
}

class _DetalleMesaScreenState extends State<DetalleMesaScreen> {
  List<Producto> _productosLocales = [];
  bool _hayCambiosNoGuardados = false;
  bool _cargando = true;
  late Orden _ordenOriginal;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MesasProvider>(context, listen: false);
      final orden = provider.obtenerOrdenPorMesa(widget.mesa.id);
      if (orden != null) {
        setState(() {
          _ordenOriginal = orden;
          // Copiamos la lista para editar localmente sin afectar la BD todavía
          _productosLocales = List.from(orden.productos);
          _cargando = false;
        });
      } else {
        // Si no hay orden (error raro), salimos
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final auth = Provider.of<AuthProvider>(context);
    final bool puedeCobrar = auth.esAdmin;

    // --- LÓGICA DE AGRUPACIÓN VISUAL ---
    // Convertimos la lista plana en un mapa de cantidades
    Map<String, int> cantidades = {};
    Map<String, Producto> prodInfo = {}; 

    for (var p in _productosLocales) {
      cantidades[p.id] = (cantidades[p.id] ?? 0) + 1;
      prodInfo[p.id] = p; 
    }
    List<String> idsUnicos = cantidades.keys.toList();
    // -----------------------------------

    double totalLocal = _productosLocales.fold(0, (sum, item) => sum + item.precio);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.mesa.nombre, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // 1. CABECERA DE INFORMACIÓN
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mesero: ${_ordenOriginal.meseroId ?? "Staff"}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _hayCambiosNoGuardados ? Colors.orange[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(
                        _hayCambiosNoGuardados ? 'MODIFICANDO...' : 'ORDEN ABIERTA',
                        style: TextStyle(
                          color: _hayCambiosNoGuardados ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 10
                        ),
                      ),
                    )
                  ],
                ),
                // Mostrar nota si existe
                if (_ordenOriginal.nota.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.yellow[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.yellow[100]!)
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.comment, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_ordenOriginal.nota, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13))),
                      ],
                    ),
                  )
                ]
              ],
            ),
          ),
          const Divider(height: 1),

          // 2. LISTA DE PRODUCTOS (AGRUPADOS)
          Expanded(
            child: idsUnicos.isEmpty
                ? const Center(child: Text('Mesa vacía'))
                : ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: idsUnicos.length + 1, // +1 para el botón final
                    itemBuilder: (context, index) {
                      if (index == idsUnicos.length) {
                        // BOTÓN AGREGAR MÁS
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            onPressed: _irAAgregarProductos,
                            icon: const Icon(Icons.add, color: Colors.black),
                            label: const Text('AGREGAR PRODUCTOS', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }

                      String id = idsUnicos[index];
                      int cantidad = cantidades[id]!;
                      Producto prod = prodInfo[id]!;
                      double subtotal = prod.precio * cantidad;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]
                        ),
                        child: Row(
                          children: [
                            // Botón Restar (Borrar 1 unidad)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  // Buscamos la primera instancia de este ID y la removemos
                                  int indexBorrar = _productosLocales.indexWhere((p) => p.id == id);
                                  if (indexBorrar != -1) {
                                    _productosLocales.removeAt(indexBorrar);
                                    _hayCambiosNoGuardados = true;
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.remove, size: 20, color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 15),
                            
                            // Info Producto
                            Text('${cantidad}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                            
                            // Precio Total del grupo
                            Text('\$${subtotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 3. BARRA INFERIOR (ACCIONES)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))]
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Estimado', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('\$${totalLocal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // BOTÓN INTELIGENTE
                  if (_hayCambiosNoGuardados)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: _guardarCambios,
                        child: const Text('GUARDAR CAMBIOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: Icon(puedeCobrar ? Icons.monetization_on : Icons.lock, color: Colors.white),
                        label: Text(
                          puedeCobrar ? 'COBRAR MESA' : 'SOLO ADMIN PUEDE COBRAR',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: puedeCobrar ? Colors.green : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                        ),
                        onPressed: puedeCobrar ? () {
                          // Pasamos los datos actuales a la pantalla de pago
                          final ordenParaPagar = Orden(
                            id: _ordenOriginal.id,
                            mesaId: _ordenOriginal.mesaId,
                            nombreMesa: _ordenOriginal.nombreMesa,
                            nombreSeccion: _ordenOriginal.nombreSeccion,
                            productos: _productosLocales,
                            total: totalLocal,
                            fechaApertura: _ordenOriginal.fechaApertura,
                            nota: _ordenOriginal.nota,
                            meseroId: _ordenOriginal.meseroId,
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PagoScreen(orden: ordenParaPagar)),
                          );
                        } : null,
                      ),
                    )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _irAAgregarProductos() async {
    // Vamos a TomaPedidos con modo "No Guardar Automático" para traer los productos aquí primero
    final resultado = await Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (_) => TomaPedidosScreen(mesa: widget.mesa, guardarAutomaticamente: false)
      )
    );

    if (resultado != null && resultado is List<Producto> && resultado.isNotEmpty) {
      setState(() {
        _productosLocales.addAll(resultado);
        _hayCambiosNoGuardados = true;
      });
    }
  }

  void _guardarCambios() async {
    final provider = Provider.of<MesasProvider>(context, listen: false);
    
    // Usamos la función inteligente que actualiza la orden y recalcula el stock
    await provider.actualizarOrdenMesa(
      _ordenOriginal.id, 
      _productosLocales, 
      _ordenOriginal.productos // Le pasamos la vieja para que compare
    );

    setState(() {
      _hayCambiosNoGuardados = false;
      // Actualizamos la referencia original
      _ordenOriginal.productos = List.from(_productosLocales);
      _ordenOriginal.total = _productosLocales.fold(0, (sum, item) => sum + item.precio);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Orden actualizada y Stock ajustado')));
  }
}