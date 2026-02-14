import 'producto_modelo.dart';

class Orden {
  final String id;
  final String mesaId;
  final String nombreMesa;
  final String nombreSeccion;
  List<Producto> productos;
  double total;
  final DateTime fechaApertura;
  DateTime? fechaCierre;
  final String estado;
  final String estadoCocina; 
  final String nota;
  final String? meseroId;
  final String? cajeroId;
  final double descuento;
  final double propina;
  final double totalFinal;
  final String metodoPago;
  final double pagoEfectivo; 
  final double pagoTransferencia;
  
  // NUEVO: Mapa para saber qué productos ya se marcaron en cocina
  // Ejemplo: {'id_hamburguesa': true, 'id_coca': false}
  final Map<String, bool> checksCocina; 

  Orden({
    required this.id,
    required this.mesaId,
    required this.nombreMesa,
    required this.nombreSeccion,
    required this.productos,
    required this.total,
    required this.fechaApertura,
    this.fechaCierre,
    this.estado = 'abierta',
    this.estadoCocina = 'pendiente',
    this.nota = '',
    this.meseroId,
    this.cajeroId,
    this.descuento = 0.0,
    this.propina = 0.0,
    this.totalFinal = 0.0,
    this.metodoPago = 'Efectivo',
    this.pagoEfectivo = 0.0,
    this.pagoTransferencia = 0.0,
    this.checksCocina = const {}, // Por defecto vacío
  });

  factory Orden.fromMap(Map<String, dynamic> data, String id) {
    return Orden(
      id: id,
      mesaId: data['mesaId'] ?? '',
      nombreMesa: data['nombreMesa'] ?? 'Mesa ?',
      nombreSeccion: data['nombreSeccion'] ?? '',
      productos: (data['productos'] as List<dynamic>? ?? [])
          .map((item) => Producto.fromMap(item, item['id'] ?? 'x'))
          .toList(),
      total: (data['total'] ?? 0).toDouble(),
      fechaApertura: DateTime.tryParse(data['fechaApertura'] ?? '') ?? DateTime.now(),
      fechaCierre: data['fechaCierre'] != null ? DateTime.tryParse(data['fechaCierre']) : null,
      estado: data['estado'] ?? 'abierta',
      estadoCocina: data['estadoCocina'] ?? 'pendiente',
      nota: data['nota'] ?? '',
      meseroId: data['meseroId'],
      cajeroId: data['cajeroId'],
      descuento: (data['descuento'] ?? 0).toDouble(),
      propina: (data['propina'] ?? 0).toDouble(),
      totalFinal: (data['totalFinal'] ?? 0).toDouble(),
      metodoPago: data['metodoPago'] ?? 'Efectivo',
      pagoEfectivo: (data['pagoEfectivo'] ?? 0).toDouble(),
      pagoTransferencia: (data['pagoTransferencia'] ?? 0).toDouble(),
      // Convertir el mapa de checks
      checksCocina: Map<String, bool>.from(data['checksCocina'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mesaId': mesaId,
      'nombreMesa': nombreMesa,
      'nombreSeccion': nombreSeccion,
      'productos': productos.map((p) => p.toMap()).toList(),
      'total': total,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'estado': estado,
      'estadoCocina': estadoCocina,
      'nota': nota,
      'meseroId': meseroId,
      'cajeroId': cajeroId,
      'descuento': descuento,
      'propina': propina,
      'totalFinal': totalFinal,
      'metodoPago': metodoPago,
      'pagoEfectivo': pagoEfectivo,
      'pagoTransferencia': pagoTransferencia,
      'checksCocina': checksCocina, // Guardamos los checks
    };
  }
}