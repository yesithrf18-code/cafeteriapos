class Mesa {
  final String id;
  final String nombre;
  final String seccion;
  final String estado; // 'disponible', 'ocupada'
  final String? ordenId; // ID de la orden activa en Firebase

  Mesa({
    required this.id,
    required this.nombre,
    this.seccion = 'General',
    this.estado = 'disponible',
    this.ordenId,
  });

  factory Mesa.fromMap(Map<String, dynamic> data, String id) {
    return Mesa(
      id: id,
      nombre: data['nombre'] ?? 'Mesa ?',
      seccion: data['seccion'] ?? 'General',
      estado: data['estado'] ?? 'disponible',
      ordenId: data['ordenId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'seccion': seccion,
      'estado': estado,
      'ordenId': ordenId,
    };
  }
}