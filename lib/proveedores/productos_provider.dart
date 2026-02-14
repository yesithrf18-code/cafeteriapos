import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/producto_modelo.dart';

class ProductosProvider extends ChangeNotifier {
  final CollectionReference _db = FirebaseFirestore.instance.collection('productos');
  final CollectionReference _dbCats = FirebaseFirestore.instance.collection('configuracion'); 

  List<Producto> _productos = [];
  List<String> _categorias = ['Bebidas', 'Entradas', 'Platos', 'Postres', 'Licores']; 

  ProductosProvider() {
    _db.snapshots().listen((snapshot) {
      _productos = snapshot.docs.map((doc) => Producto.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
      notifyListeners();
    });
    _cargarCategorias();
  }

  List<Producto> get productos => _productos;
  List<String> get categorias => _categorias;

  // --- CATEGORÍAS ---
  void _cargarCategorias() {
    _dbCats.doc('categorias').snapshots().listen((snap) {
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;
        _categorias = List<String>.from(data['lista'] ?? []);
        if (_categorias.isEmpty) _categorias = ['General'];
        notifyListeners();
      } else {
        _dbCats.doc('categorias').set({'lista': _categorias});
      }
    });
  }

  Future<void> agregarCategoria(String nuevaCat) async {
    if (!_categorias.contains(nuevaCat)) {
      _categorias.add(nuevaCat);
      await _actualizarFirebase();
    }
  }

  // NUEVO: Editar
  Future<void> editarCategoria(String vieja, String nueva) async {
    int index = _categorias.indexOf(vieja);
    if (index != -1) {
      _categorias[index] = nueva;
      await _actualizarFirebase();
    }
  }

  // NUEVO: Eliminar
  Future<void> eliminarCategoria(String cat) async {
    _categorias.remove(cat);
    await _actualizarFirebase();
  }

  Future<void> _actualizarFirebase() async {
    await _dbCats.doc('categorias').update({'lista': _categorias});
  }

  // --- PRODUCTOS ---
  Future<void> crearProducto(String nombre, double precio, String categoria, int stock, String? url) async {
    DocumentReference ref = await _db.add({'nombre': nombre, 'precio': precio, 'categoria': categoria, 'stock': stock, 'imagenUrl': url});
    await ref.update({'id': ref.id});
  }

  Future<void> editarProducto(String id, String nombre, double precio, String categoria, int stock, String? url) async {
    await _db.doc(id).update({'nombre': nombre, 'precio': precio, 'categoria': categoria, 'stock': stock, 'imagenUrl': url});
  }

  Future<void> eliminarProducto(String id) async => await _db.doc(id).delete();
  Future<void> reducirStock(String id, int cant) async {
    try { await _db.doc(id).update({'stock': FieldValue.increment(-cant)}); } catch(e){}
  }
}