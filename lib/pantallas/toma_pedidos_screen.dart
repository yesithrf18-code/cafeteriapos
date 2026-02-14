import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../modelos/mesa_modelo.dart';
import '../modelos/producto_modelo.dart';
import '../proveedores/productos_provider.dart';
import '../proveedores/mesas_provider.dart';
import '../proveedores/auth_provider.dart';

class TomaPedidosScreen extends StatefulWidget {
  final Mesa mesa;
  final bool guardarAutomaticamente; 
  const TomaPedidosScreen({super.key, required this.mesa, this.guardarAutomaticamente = true});
  @override
  State<TomaPedidosScreen> createState() => _TomaPedidosScreenState();
}

class _TomaPedidosScreenState extends State<TomaPedidosScreen> {
  List<Producto> carrito = [];
  String _categoriaSeleccionada = 'Todas';
  String _busqueda = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _notaCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prodProvider = Provider.of<ProductosProvider>(context);
    
    // --- DETECCIÓN DE PC PARA LAS COLUMNAS ---
    double ancho = MediaQuery.of(context).size.width;
    int columnas = ancho > 900 ? 4 : 2; // Si es PC 4 columnas, si es celular 2.

    List<Producto> productosFiltrados = prodProvider.productos.where((p) {
      bool pasaCategoria = _categoriaSeleccionada == 'Todas' || p.categoria == _categoriaSeleccionada;
      bool pasaBusqueda = p.nombre.toLowerCase().contains(_busqueda.toLowerCase());
      return pasaCategoria && pasaBusqueda;
    }).toList();
    
    Set<String> cats = {'Todas', ...prodProvider.productos.map((p) => p.categoria)};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.mesa.nombre, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(widget.guardarAutomaticamente ? 'Nueva Orden' : 'Agregando items', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ]),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl, 
                  decoration: InputDecoration(
                    hintText: 'Buscar...', 
                    prefixIcon: const Icon(Icons.search), 
                    filled: true, 
                    fillColor: Colors.grey[100], 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), 
                    contentPadding: EdgeInsets.zero
                  ), 
                  onChanged: (v) => setState(() => _busqueda = v)
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal, 
                  child: Row(
                    children: cats.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 5), 
                      child: FilterChip(
                        label: Text(c), 
                        selected: _categoriaSeleccionada == c, 
                        onSelected: (v) => setState(() => _categoriaSeleccionada = c), 
                        backgroundColor: Colors.white, 
                        selectedColor: Colors.black, 
                        labelStyle: TextStyle(color: _categoriaSeleccionada == c ? Colors.white : Colors.black), 
                        checkmarkColor: Colors.white
                      )
                    )).toList()
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnas, // <--- AQUÍ APLICA EL CAMBIO PARA PC
                childAspectRatio: 0.75, 
                crossAxisSpacing: 10, 
                mainAxisSpacing: 10
              ),
              itemCount: productosFiltrados.length,
              itemBuilder: (ctx, i) => _itemProducto(productosFiltrados[i]),
            ),
          ),
          if (carrito.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0,-5))]),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.guardarAutomaticamente)
                      TextField(
                        controller: _notaCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nota para cocina (Opcional)',
                          hintText: 'Ej: Sin azúcar, salsa aparte...',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.edit_note)
                        ),
                      ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                            Text('${carrito.length} Items', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('\$${_calcularTotal().toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ]),
                        const Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                          onPressed: _procesar,
                          child: Text(widget.guardarAutomaticamente ? 'CONFIRMAR' : 'LISTO', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _itemProducto(Producto prod) {
    int enCarrito = carrito.where((p) => p.id == prod.id).length;
    int stockReal = prod.stock - enCarrito;
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[200]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: prod.imagenUrl != null ? Image.network(prod.imagenUrl!, fit: BoxFit.cover) : Container(color: Colors.grey[100], child: const Icon(Icons.fastfood, color: Colors.grey)))),
          Padding(padding: const EdgeInsets.all(10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prod.nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('\$${prod.precio.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)), Text('Stock: $stockReal', style: TextStyle(fontSize: 10, color: stockReal > 0 ? Colors.green : Colors.red))]),
              const SizedBox(height: 5),
              if (enCarrito == 0) SizedBox(width: double.infinity, height: 30, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: EdgeInsets.zero), onPressed: stockReal > 0 ? () => setState(() => carrito.add(prod)) : null, child: Text(stockReal > 0 ? 'AGREGAR' : 'AGOTADO', style: const TextStyle(fontSize: 10, color: Colors.white))))
              else Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_btn(Icons.remove, () => setState(() => carrito.remove(carrito.firstWhere((p) => p.id == prod.id)))), Text('$enCarrito', style: const TextStyle(fontWeight: FontWeight.bold)), _btn(Icons.add, stockReal > 0 ? () => setState(() => carrito.add(prod)) : null)])
          ]))
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap) => InkWell(onTap: onTap, child: Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5)), child: Icon(icon, size: 16, color: onTap != null ? Colors.black : Colors.grey)));
  double _calcularTotal() => carrito.fold(0, (sum, item) => sum + item.precio);

  void _procesar() async {
    if (widget.guardarAutomaticamente) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final mesas = Provider.of<MesasProvider>(context, listen: false);
      final prods = Provider.of<ProductosProvider>(context, listen: false);
      
      await mesas.agregarProductosAMesa(
          widget.mesa.id, 
          widget.mesa.nombre, 
          widget.mesa.seccion, 
          carrito, 
          auth.usuarioActual?.nombre ?? 'Mesero', 
          nota: _notaCtrl.text
      );
      
      for (var p in carrito) {
        prods.reducirStock(p.id, 1);
      }
      Navigator.pop(context);
    } else {
      Navigator.pop(context, carrito);
    }
  }
}