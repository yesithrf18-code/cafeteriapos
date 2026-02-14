import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../modelos/usuario_modelo.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Usuario? _usuarioActual;
  
  Usuario? get usuarioActual => _usuarioActual;
  bool get esAdmin => _usuarioActual?.rol == 'admin';

  // CAMBIO: Quitamos la llamada del constructor para controlarla manualmente
  // AuthProvider() { ... } 

  // 1. VERIFICAR SESIÓN (Ahora devuelve true/false)
  Future<bool> intentarAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getString('usuario_id');

      if (usuarioId == null) return false; // No hay nada guardado

      // Si hay ID, buscamos en Firebase si sigue existiendo
      final doc = await _db.collection('usuarios').doc(usuarioId).get();
      
      if (doc.exists) {
        final usuario = Usuario.fromMap(doc.data()!, doc.id);
        if (usuario.activo) {
          _usuarioActual = usuario;
          notifyListeners();
          return true; // ¡Éxito!
        }
      }
    } catch (e) {
      debugPrint("Error auto-login: $e");
    }
    return false; // Falló algo
  }

  // 2. LOGIN CON PIN
  Future<bool> login(String pin) async {
    try {
      final query = await _db.collection('usuarios')
          .where('pin', isEqualTo: pin)
          .where('activo', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        _usuarioActual = Usuario.fromMap(query.docs.first.data(), query.docs.first.id);
        
        // GUARDAR EN MEMORIA DEL CELULAR
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('usuario_id', _usuarioActual!.id);
        
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error login: $e');
    }
    return false;
  }

  // 3. LOGOUT
  Future<void> logout() async {
    _usuarioActual = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario_id'); // Borramos la memoria
    notifyListeners();
  }

  // --- GESTIÓN DE USUARIOS (ADMIN) ---
  Stream<List<Usuario>> obtenerTodosLosUsuarios() {
    return _db.collection('usuarios').snapshots().map((s) => 
      s.docs.map((d) => Usuario.fromMap(d.data(), d.id)).toList()
    );
  }

  Future<void> crearUsuario(String nombre, String pin, String rol) async {
    await _db.collection('usuarios').add({
      'nombre': nombre, 'pin': pin, 'rol': rol, 'activo': true,
    });
  }

  Future<void> eliminarUsuario(String id) async {
    await _db.collection('usuarios').doc(id).update({'activo': false});
  }
}