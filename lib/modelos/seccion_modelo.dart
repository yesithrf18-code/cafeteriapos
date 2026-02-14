class Seccion {
  final String id;
  final String nombre;
  final int colorValue;

  Seccion({
    required this.id,
    required this.nombre,
    required this.colorValue,
  });

  // De Firebase a App
  factory Seccion.fromMap(Map<String, dynamic> data, String id) {
    return Seccion(
      id: id,
      nombre: data['nombre'] ?? '',
      colorValue: data['color'] ?? 0xFFFFFFFF,
    );
  }

  // De App a Firebase
  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'color': colorValue,
    };
  }
}