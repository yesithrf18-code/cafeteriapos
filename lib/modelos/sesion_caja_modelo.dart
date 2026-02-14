class SesionCaja {
  final String id;
  final String usuarioApertura;
  final String? usuarioCierre;
  final DateTime fechaApertura;
  final DateTime? fechaCierre;
  final double montoInicial; // Base
  final double totalVentasEfectivo;
  final double totalVentasTransf;
  final double totalGastos;
  final double totalSistema; // Cuánto dice la app que debe haber
  final double totalReal;    // Cuánto contaste tú
  final double diferencia;   // Si sobró o faltó
  final String estado;       // 'abierta' o 'cerrada'

  SesionCaja({
    required this.id,
    required this.usuarioApertura,
    this.usuarioCierre,
    required this.fechaApertura,
    this.fechaCierre,
    required this.montoInicial,
    this.totalVentasEfectivo = 0.0,
    this.totalVentasTransf = 0.0,
    this.totalGastos = 0.0,
    this.totalSistema = 0.0,
    this.totalReal = 0.0,
    this.diferencia = 0.0,
    this.estado = 'abierta',
  });

  factory SesionCaja.fromMap(Map<String, dynamic> data, String id) {
    return SesionCaja(
      id: id,
      usuarioApertura: data['usuarioApertura'] ?? '',
      usuarioCierre: data['usuarioCierre'],
      fechaApertura: DateTime.parse(data['fechaApertura']),
      fechaCierre: data['fechaCierre'] != null ? DateTime.parse(data['fechaCierre']) : null,
      montoInicial: (data['montoInicial'] ?? 0).toDouble(),
      totalVentasEfectivo: (data['totalVentasEfectivo'] ?? 0).toDouble(),
      totalVentasTransf: (data['totalVentasTransf'] ?? 0).toDouble(),
      totalGastos: (data['totalGastos'] ?? 0).toDouble(),
      totalSistema: (data['totalSistema'] ?? 0).toDouble(),
      totalReal: (data['totalReal'] ?? 0).toDouble(),
      diferencia: (data['diferencia'] ?? 0).toDouble(),
      estado: data['estado'] ?? 'abierta',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioApertura': usuarioApertura,
      'usuarioCierre': usuarioCierre,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'montoInicial': montoInicial,
      'totalVentasEfectivo': totalVentasEfectivo,
      'totalVentasTransf': totalVentasTransf,
      'totalGastos': totalGastos,
      'totalSistema': totalSistema,
      'totalReal': totalReal,
      'diferencia': diferencia,
      'estado': estado,
    };
  }
}