import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/mesa_modelo.dart';
import '../modelos/orden_modelo.dart';
import '../modelos/producto_modelo.dart';
import '../modelos/seccion_modelo.dart';

class MesasProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<Seccion> _secciones = [];
  List<Mesa> _mesas = [];
  final Map<String, Orden> _ordenesActivas = {}; 

  MesasProvider() { _inicializarEscuchas(); }

  void _inicializarEscuchas() {
    _db.collection('secciones').snapshots().listen((s) { _secciones = s.docs.map((d) => Seccion.fromMap(d.data(), d.id)).toList(); notifyListeners(); });
    _db.collection('mesas').snapshots().listen((s) { _mesas = s.docs.map((d) => Mesa.fromMap(d.data(), d.id)).toList(); notifyListeners(); });
    _db.collection('ordenes').where('estado', isEqualTo: 'abierta').snapshots().listen((s) {
      _ordenesActivas.clear();
      for (var d in s.docs) {
        _ordenesActivas[Orden.fromMap(d.data(), d.id).mesaId] = Orden.fromMap(d.data(), d.id);
      }
      notifyListeners();
    });
  }

  List<Seccion> get secciones => _secciones;
  List<Mesa> get mesas => _mesas;
  Orden? obtenerOrdenPorMesa(String id) => _ordenesActivas[id];

  List<Mesa> mesasPorSeccion(String nombreSeccion) {
    var lista = _mesas.where((m) => m.seccion == nombreSeccion).toList();
    lista.sort((a, b) {
      final numA = int.tryParse(a.nombre.replaceAll(RegExp(r'[^0-9]'), ''));
      final numB = int.tryParse(b.nombre.replaceAll(RegExp(r'[^0-9]'), ''));
      if (numA != null && numB != null) return numA.compareTo(numB);
      return a.nombre.compareTo(b.nombre);
    });
    return lista;
  }

  // 1. AGREGAR PRODUCTOS (Con Sección)
  Future<void> agregarProductosAMesa(String idMesa, String nombreMesa, String nombreSeccion, List<Producto> nuevosProductos, String usuarioId, {String nota = ''}) async {
    if (_ordenesActivas.containsKey(idMesa)) {
      final orden = _ordenesActivas[idMesa]!;
      List<Producto> listaCombinada = [...orden.productos, ...nuevosProductos];
      String nuevaNota = orden.nota;
      if (nota.isNotEmpty) nuevaNota = nuevaNota.isEmpty ? nota : "$nuevaNota | $nota";

      await actualizarOrdenMesa(orden.id, listaCombinada, orden.productos);
      await _db.collection('ordenes').doc(orden.id).update({'nota': nuevaNota});
    } else {
      double total = nuevosProductos.fold(0, (sum, item) => sum + item.precio);
      DocumentReference refOrden = await _db.collection('ordenes').add({
        'mesaId': idMesa, 
        'nombreMesa': nombreMesa, 
        'nombreSeccion': nombreSeccion, // <--- GUARDAMOS LA ZONA
        'meseroId': usuarioId,
        'productos': nuevosProductos.map((p) => p.toMap()).toList(), 
        'total': total,
        'fechaApertura': DateTime.now().toIso8601String(), 
        'estado': 'abierta',
        'nota': nota,
        'estadoCocina': 'pendiente'
      });
      await _db.collection('mesas').doc(idMesa).update({'estado': 'ocupada', 'ordenId': refOrden.id});
    }
  }

  // 2. ACTUALIZACIÓN INTELIGENTE
  Future<void> actualizarOrdenMesa(String ordenId, List<Producto> nuevaLista, List<Producto> listaOriginal) async {
    double nuevoTotal = nuevaLista.fold(0, (sum, item) => sum + item.precio);
    await _db.collection('ordenes').doc(ordenId).update({
      'productos': nuevaLista.map((p) => p.toMap()).toList(),
      'total': nuevoTotal,
    });

    Map<String, int> conteoNuevo = {};
    Map<String, int> conteoViejo = {};
    for(var p in nuevaLista) {
      conteoNuevo[p.id] = (conteoNuevo[p.id] ?? 0) + 1;
    }
    for(var p in listaOriginal) {
      conteoViejo[p.id] = (conteoViejo[p.id] ?? 0) + 1;
    }
    Set<String> todosIds = {...conteoNuevo.keys, ...conteoViejo.keys};
    
    for (var id in todosIds) {
      int dif = (conteoNuevo[id] ?? 0) - (conteoViejo[id] ?? 0);
      if (dif != 0) {
        try { await _db.collection('productos').doc(id).update({'stock': FieldValue.increment(-dif)}); } catch (e) {}
      }
    }
  }

  // Despachar cocina
  

  Future<void> toggleCheckCocina(String ordenId, String productoId, bool estado) async {
    // Usamos notación de punto para actualizar solo ese campo del mapa sin borrar los otros
    await _db.collection('ordenes').doc(ordenId).update({
      'checksCocina.$productoId': estado
    });
  }

  Future<void> marcarOrdenDespachada(String ordenId) async {
    await _db.collection('ordenes').doc(ordenId).update({'estadoCocina': 'listo'});
  }

  Future<void> finalizarVenta({required String idMesa, required String cajeroId, required double descuento, required double propina, required double totalFinal, required String metodoPago, required double pagoEfectivo, required double pagoTransferencia}) async {
    if (_ordenesActivas.containsKey(idMesa)) {
      final orden = _ordenesActivas[idMesa]!;
      await _db.collection('ordenes').doc(orden.id).update({
        'estado': 'pagada', 'fechaCierre': DateTime.now().toIso8601String(), 'cajeroId': cajeroId,
        'descuento': descuento, 'propina': propina, 'totalFinal': totalFinal,
        'metodoPago': metodoPago, 'pagoEfectivo': pagoEfectivo, 'pagoTransferencia': pagoTransferencia,
      });
      await _db.collection('mesas').doc(idMesa).update({'estado': 'disponible', 'ordenId': null});
    }
  }

  // Admin
  Future<void> crearSeccion(String n, int c) async => await _db.collection('secciones').add({'nombre': n, 'color': c});
  Future<void> crearMesa(String n, String s) async => await _db.collection('mesas').add({'nombre': n, 'seccion': s, 'estado': 'disponible'});
  Future<void> eliminarMesa(String id) async => await _db.collection('mesas').doc(id).delete();
}