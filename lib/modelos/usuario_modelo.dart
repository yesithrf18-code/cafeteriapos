class Usuario {
  final String id;
  final String nombre;
  final String pin;
  final String rol; // 'admin' o 'mesero'
  final bool activo;

  Usuario({
    required this.id,
    required this.nombre,
    required this.pin,
    required this.rol,
    this.activo = true,
  });

  factory Usuario.fromMap(Map<String, dynamic> data, String id) {
    return Usuario(
      id: id,
      nombre: data['nombre'] ?? '',
      pin: data['pin'] ?? '',
      rol: data['rol'] ?? 'mesero',
      activo: data['activo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'pin': pin,
      'rol': rol,
      'activo': activo,
    };
  }
}