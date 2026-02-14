class LogRegistro {
  final String id;
  final String accion;      // Ej: "Abrió Mesa 5", "Borró Coca-Cola"
  final String usuario;     // Ej: "Mesero Juan", "Cajero Ana"
  final DateTime fechaHora; // Cuándo ocurrió exactamenente
  final String detalles;    // Info extra técnica (opcional)

  LogRegistro({
    required this.id,
    required this.accion,
    required this.usuario,
    required this.fechaHora,
    this.detalles = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'accion': accion,
      'usuario': usuario,
      'fechaHora': fechaHora.toIso8601String(), // Guardamos fecha en formato estándar
      'detalles': detalles,
    };
  }
}