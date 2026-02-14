import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../proveedores/mesas_provider.dart';
import '../proveedores/productos_provider.dart';
import '../proveedores/auth_provider.dart';
import '../modelos/seccion_modelo.dart';
import '../modelos/producto_modelo.dart';
import '../modelos/usuario_modelo.dart';
import 'cocina_screen.dart';
import 'caja_screen.dart';
import 'historial_ventas_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text('Panel de Control', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24)),
        actions: [
           IconButton(
             icon: const Icon(Icons.logout, color: Colors.red),
             onPressed: () {
                // ALERTA DE LOGOUT
                _confirmarAccion(context, '¿Cerrar Sesión?', 'Tendrás que ingresar tu PIN nuevamente.', () {
                   auth.logout(); 
                });
             },
           )
        ],
      ),
      body: Column(
        children: [
          // BARRA DE NAVEGACIÓN
          Container(
            height: 60,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              children: [
                _pillTab('General', 0),
                _pillTab('Productos', 1),
                _pillTab('Usuarios', 2),
                _pillTab('Categorías', 3),
              ],
            ),
          ),
          
          // CONTENIDO
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                const _TabGeneral(),
                const _TabProductos(),
                const _TabUsuarios(),
                const _TabCategorias(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _pillTab(String text, int index) {
    bool active = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
      ),
    );
  }
}

// ==========================================
// PESTAÑA 1: GENERAL
// ==========================================
class _TabGeneral extends StatefulWidget {
  const _TabGeneral({super.key});
  @override
  State<_TabGeneral> createState() => _TabGeneralState();
}

class _TabGeneralState extends State<_TabGeneral> {
  final _nombreSeccionController = TextEditingController();
  final _nombreMesaController = TextEditingController();
  Color _colorSeleccionado = Colors.blue;
  Seccion? _seccionParaNuevaMesa;
  final List<Color> _paletaColores = [Colors.blue, Colors.indigo, Colors.teal, Colors.green, Colors.orange, Colors.red, Colors.pink, Colors.purple, Colors.brown];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MesasProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('ACCESOS RÁPIDOS', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _botonDashboard(context, 'Caja', Icons.savings_outlined, Colors.teal, const CajaScreen())),
            const SizedBox(width: 15),
            Expanded(child: _botonDashboard(context, 'Cocina', Icons.soup_kitchen_outlined, Colors.orange, const CocinaScreen())),
          ],
        ),
        const SizedBox(height: 15),
        _botonDashboardWide(context, 'Historial de Ventas', Icons.receipt_long, Colors.purple, const HistorialVentasScreen()),
        
        const SizedBox(height: 30),
        const Text('CONFIGURACIÓN DEL LOCAL', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 15),

        // CREAR ZONA
        _CleanTile(
          title: 'Crear Nueva Zona',
          icon: Icons.layers_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _nombreSeccionController, decoration: _inputDeco('Nombre Zona (Ej: VIP)')),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: _paletaColores.map((c) => GestureDetector(onTap: () => setState(() => _colorSeleccionado = c), child: CircleAvatar(radius: 12, backgroundColor: c, child: _colorSeleccionado == c ? const Icon(Icons.check, color: Colors.white, size: 14) : null))).toList()),
              const SizedBox(height: 15),
              _BlackButton('Guardar Zona', () {
                 if(_nombreSeccionController.text.isNotEmpty) {
                   Provider.of<MesasProvider>(context, listen: false).crearSeccion(_nombreSeccionController.text, _colorSeleccionado.value);
                   _nombreSeccionController.clear();
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Zona Creada')));
                 }
              })
            ],
          ),
        ),
        const SizedBox(height: 10),

        // CREAR MESA
        _CleanTile(
          title: 'Crear Mesa',
          icon: Icons.table_restaurant_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(controller: _nombreMesaController, decoration: _inputDeco('Nombre Mesa (Ej: Mesa 5)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<Seccion>(
                decoration: _inputDeco('Seleccionar Zona'),
                items: provider.secciones.map((s) => DropdownMenuItem(value: s, child: Text(s.nombre))).toList(),
                onChanged: (v) => setState(() => _seccionParaNuevaMesa = v),
              ),
              const SizedBox(height: 15),
              _BlackButton('Guardar Mesa', () {
                if(_nombreMesaController.text.isNotEmpty && _seccionParaNuevaMesa != null){
                  provider.crearMesa(_nombreMesaController.text, _seccionParaNuevaMesa!.nombre);
                  _nombreMesaController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesa Creada')));
                }
              })
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ELIMINAR MESAS (CON ALERTA)
        _CleanTile(
          title: 'Eliminar Mesas',
          icon: Icons.delete_outline,
          colorIcon: Colors.red,
          child: Column(
            children: provider.mesas.map((m) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(m.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(m.seccion),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // ALERTA DE BORRADO DE MESA
                  _confirmarAccion(context, '¿Eliminar Mesa?', 'Estás a punto de borrar "${m.nombre}".', () {
                    provider.eliminarMesa(m.id);
                  });
                },
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}

// ==========================================
// PESTAÑA 2: PRODUCTOS
// ==========================================
class _TabProductos extends StatelessWidget {
  const _TabProductos({super.key});
  @override
  Widget build(BuildContext context) {
    final prodProvider = Provider.of<ProductosProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Producto', style: TextStyle(color: Colors.white)),
        onPressed: () => _mostrarFormularioProducto(context, null),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: prodProvider.productos.length,
        itemBuilder: (context, index) {
          final prod = prodProvider.productos[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: prod.imagenUrl != null && prod.imagenUrl!.isNotEmpty 
                  ? Image.network(prod.imagenUrl!, fit: BoxFit.cover, errorBuilder: (_,_,_)=> const Icon(Icons.fastfood, size: 20)) 
                  : const Icon(Icons.fastfood, size: 20, color: Colors.grey),
              ),
              title: Text(prod.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${prod.categoria} | Stock: ${prod.stock}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('\$${prod.precio.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.blue), onPressed: () => _mostrarFormularioProducto(context, prod)),
                  
                  // ALERTA DE BORRADO DE PRODUCTO
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red), 
                    onPressed: () {
                      _confirmarAccion(context, '¿Borrar Producto?', 'Se eliminará "${prod.nombre}" del menú permanentemente.', () {
                         prodProvider.eliminarProducto(prod.id);
                      });
                    }
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _mostrarFormularioProducto(BuildContext context, Producto? p) {
    final n = TextEditingController(text: p?.nombre);
    final pr = TextEditingController(text: p?.precio.toString());
    final s = TextEditingController(text: p?.stock.toString());
    final u = TextEditingController(text: p?.imagenUrl);
    final prov = Provider.of<ProductosProvider>(context, listen: false);
    String c = (p?.categoria != null && prov.categorias.contains(p!.categoria)) ? p.categoria : prov.categorias.first;

    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(p==null ? 'Nuevo Producto' : 'Editar Producto'),
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(mainAxisSize: MainAxisSize.min, children: [
               TextField(controller: n, decoration: _inputDeco('Nombre')), const SizedBox(height: 10),
               Row(children: [Expanded(child: TextField(controller: pr, keyboardType: TextInputType.number, decoration: _inputDeco('Precio'))), const SizedBox(width: 10), Expanded(child: TextField(controller: s, keyboardType: TextInputType.number, decoration: _inputDeco('Stock')))]), const SizedBox(height: 10),
               DropdownButtonFormField(initialValue: c, decoration: _inputDeco('Categoría'), items: prov.categorias.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: (v) => setState(() => c = v!)), const SizedBox(height: 10),
               TextField(controller: u, decoration: _inputDeco('URL Imagen (Opcional)')),
            ]);
          }
        ),
      ),
      actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black), onPressed: (){
          if(p==null) {
            prov.crearProducto(n.text, double.tryParse(pr.text)??0, c, int.tryParse(s.text)??0, u.text);
          } else {
            prov.editarProducto(p.id, n.text, double.tryParse(pr.text)??0, c, int.tryParse(s.text)??0, u.text);
          }
          Navigator.pop(ctx);
      }, child: const Text('Guardar', style: TextStyle(color: Colors.white)))]
    ));
  }
}

// ==========================================
// PESTAÑA 3: USUARIOS
// ==========================================
class _TabUsuarios extends StatelessWidget {
  const _TabUsuarios({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () => _dialogoUsuario(context),
      ),
      body: StreamBuilder<List<Usuario>>(
        stream: auth.obtenerTodosLosUsuarios(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: users.length,
            itemBuilder: (ctx, i) {
              final u = users[i];
              if (!u.activo) return const SizedBox();
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: u.rol=='admin' ? Colors.red[100] : Colors.blue[100], child: Icon(u.rol=='admin' ? Icons.security : Icons.person, color: u.rol=='admin' ? Colors.red : Colors.blue)),
                  title: Text(u.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('PIN: ${u.pin} | Rol: ${u.rol.toUpperCase()}'),
                  
                  // ALERTA DE BORRADO DE USUARIO
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red), 
                    onPressed: () {
                       _confirmarAccion(context, '¿Desactivar Usuario?', 'El usuario "${u.nombre}" ya no podrá ingresar al sistema.', () {
                          auth.eliminarUsuario(u.id);
                       });
                    }
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _dialogoUsuario(BuildContext context) {
    final n = TextEditingController(); final p = TextEditingController(); String r = 'mesero';
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Nuevo Usuario'),
      content: StatefulBuilder(builder: (context, setState) => Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: n, decoration: _inputDeco('Nombre')), const SizedBox(height: 10),
        TextField(controller: p, keyboardType: TextInputType.number, decoration: _inputDeco('PIN (4 dígitos)')), const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: r, decoration: _inputDeco('Rol'), items: ['mesero', 'admin'].map((e)=>DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(), onChanged: (v)=>setState(()=>r=v!))
      ])),
      actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black), onPressed: (){
        Provider.of<AuthProvider>(context, listen: false).crearUsuario(n.text, p.text, r);
        Navigator.pop(ctx);
      }, child: const Text('Crear', style: TextStyle(color: Colors.white)))],
    ));
  }
}

// ==========================================
// PESTAÑA 4: CATEGORÍAS
// ==========================================
class _TabCategorias extends StatelessWidget {
  const _TabCategorias({super.key});
  @override
  Widget build(BuildContext context) {
    final prodProv = Provider.of<ProductosProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.category, color: Colors.white),
        onPressed: () => _dialogoCat(context, null, null), // Crear
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: prodProv.categorias.length,
        itemBuilder: (ctx, i) {
          final cat = prodProv.categorias[i];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.label, color: Colors.orange),
              title: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Editar
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _dialogoCat(context, cat, prodProv),
                  ),
                  // Eliminar
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmarAccion(context, '¿Eliminar Categoría?', 'Se borrará "$cat" de la lista.', () {
                        prodProv.eliminarCategoria(cat);
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _dialogoCat(BuildContext context, String? catVieja, ProductosProvider? prov) {
    final c = TextEditingController(text: catVieja);
    final provider = prov ?? Provider.of<ProductosProvider>(context, listen: false);

    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: Text(catVieja == null ? 'Nueva Categoría' : 'Editar Categoría'), 
        content: TextField(controller: c, decoration: _inputDeco('Nombre')), 
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black), 
            onPressed: (){ 
              if (c.text.isNotEmpty) {
                if (catVieja == null) {
                  provider.agregarCategoria(c.text);
                } else {
                  provider.editarCategoria(catVieja, c.text);
                }
                Navigator.pop(ctx); 
              }
            }, 
            child: const Text('Guardar', style: TextStyle(color: Colors.white))
          )
        ]
      )
    );
  }
}

// --- WIDGETS AUXILIARES ---

InputDecoration _inputDeco(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15));

Widget _botonDashboard(BuildContext context, String titulo, IconData icon, Color color, Widget destino) {
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
    child: Container(
      height: 100,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
        const SizedBox(height: 10),
        Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))
      ]),
    ),
  );
}

Widget _botonDashboardWide(BuildContext context, String titulo, IconData icon, Color color, Widget destino) {
  return GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destino)),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 15), Text(titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]),
        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16)
      ]),
    ),
  );
}

class _CleanTile extends StatelessWidget {
  final String title; final IconData icon; final Widget child; final Color colorIcon;
  const _CleanTile({required this.title, required this.icon, required this.child, this.colorIcon = Colors.black});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        leading: Icon(icon, color: colorIcon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        childrenPadding: const EdgeInsets.all(20),
        children: [child],
      ),
    );
  }
}

class _BlackButton extends StatelessWidget {
  final String text; final VoidCallback onTap;
  const _BlackButton(this.text, this.onTap);
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.all(15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: onTap, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
}

// --- FUNCIÓN GLOBAL DE ALERTA DE SEGURIDAD ---
void _confirmarAccion(BuildContext context, String titulo, String mensaje, VoidCallback onConfirm) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(titulo),
      content: Text(mensaje),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            onConfirm();
            Navigator.pop(ctx);
          },
          child: const Text('CONFIRMAR', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}