import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelos/sesion_caja_modelo.dart';

class Movimiento {
  final String descripcion;
  final double monto;
  final String tipo; // 'ingreso_efectivo', 'ingreso_transf', 'gasto'
  final DateTime fecha;
  Movimiento({required this.descripcion, required this.monto, required this.tipo, required this.fecha});
}

class CajaProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  SesionCaja? _sesionActual; 
  List<Movimiento> _movimientosTurno = [];
  bool _cargando = true; // <--- NUEVO: Estado de carga inicial

  bool get cajaAbierta => _sesionActual != null;
  bool get cargando => _cargando; // Getter
  SesionCaja? get sesion => _sesionActual;

  double get baseCaja => _sesionActual?.montoInicial ?? 0.0;
  double get totalEfectivo => _totalMovs('ingreso_efectivo'); 
  double get totalTransferencia => _totalMovs('ingreso_transf');
  double get totalGastos => _totalMovs('gasto');
  double get totalEnCajaFisica => baseCaja + totalEfectivo - totalGastos;
  
  List<Movimiento> get movimientos => _movimientosTurno;

  CajaProvider() {
    _buscarSesionAbierta();
  }

  double _totalMovs(String tipo) => _movimientosTurno.where((m) => m.tipo == tipo).fold(0.0, (sum, m) => sum + m.monto);

  void _buscarSesionAbierta() {
    _db.collection('sesiones_caja')
       .where('estado', isEqualTo: 'abierta')
       .limit(1)
       .snapshots()
       .listen((snapshot) {
         if (snapshot.docs.isNotEmpty) {
           _sesionActual = SesionCaja.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
           _escucharMovimientosDelTurno(_sesionActual!.id);
         } else {
           _sesionActual = null;
           _movimientosTurno = [];
         }
         _cargando = false; // <--- Ya terminamos de verificar
         notifyListeners();
       });
  }

  void _escucharMovimientosDelTurno(String idSesion) {
    _db.collection('sesiones_caja').doc(idSesion).collection('movimientos')
       .orderBy('fecha', descending: true)
       .snapshots().listen((snap) {
         _movimientosTurno = snap.docs.map((d) => Movimiento(
           descripcion: d['descripcion'],
           monto: (d['monto'] ?? 0).toDouble(),
           tipo: d['tipo'],
           fecha: DateTime.parse(d['fecha'])
         )).toList();
         notifyListeners();
       });
  }

  Future<void> abrirCaja(String usuario, double montoBase) async {
    await _db.collection('sesiones_caja').add({
      'usuarioApertura': usuario,
      'fechaApertura': DateTime.now().toIso8601String(),
      'montoInicial': montoBase,
      'estado': 'abierta',
    });
  }

  Future<void> registrarMovimiento(String desc, double monto, String tipo) async {
    if (_sesionActual == null) return;
    await _db.collection('sesiones_caja').doc(_sesionActual!.id).collection('movimientos').add({
      'descripcion': desc, 'monto': monto, 'tipo': tipo, 'fecha': DateTime.now().toIso8601String()
    });
  }

  Future<void> cerrarCaja(String usuario, double dineroFisicoReal) async {
    if (_sesionActual == null) return;
    double sistema = totalEnCajaFisica; 
    double diferencia = dineroFisicoReal - sistema; 
    await _db.collection('sesiones_caja').doc(_sesionActual!.id).update({
      'estado': 'cerrada',
      'usuarioCierre': usuario,
      'fechaCierre': DateTime.now().toIso8601String(),
      'totalVentasEfectivo': totalEfectivo,
      'totalVentasTransf': totalTransferencia,
      'totalGastos': totalGastos,
      'totalSistema': sistema,
      'totalReal': dineroFisicoReal,
      'diferencia': diferencia,
    });
  }
}