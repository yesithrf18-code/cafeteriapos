class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String categoria;
  int stock;
  final String? imagenUrl;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    this.stock = 0,
    this.imagenUrl,
  });

  // 1. Convertir de Firebase a App
  factory Producto.fromMap(Map<String, dynamic> data, String documentId) {
    return Producto(
      id: documentId, // Aquí usamos el ID del documento
      nombre: data['nombre'] ?? 'Sin Nombre',
      precio: (data['precio'] ?? 0).toDouble(),
      categoria: data['categoria'] ?? 'Varios',
      stock: data['stock'] ?? 0,
      imagenUrl: data['imagenUrl'],
    );
  }

  // 2. Convertir de App a Firebase (AQUÍ ESTABA EL ERROR)
  Map<String, dynamic> toMap() {
    return {
      'id': id, // <--- ¡ESTO FALTABA! Ahora el ID viaja con el producto
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'stock': stock,
      'imagenUrl': imagenUrl,
    };
  }
}