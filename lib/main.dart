import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'proveedores/mesas_provider.dart';
import 'proveedores/productos_provider.dart';
import 'proveedores/auth_provider.dart';
import 'proveedores/caja_provider.dart';
import 'pantallas/splash_screen.dart'; // <--- IMPORTANTE
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'tema/app_theme.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // WEB necesita options
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Android / iOS usan google-services.json
    await Firebase.initializeApp();
  }

  runApp(const MiAppCafeteria());
}



class MiAppCafeteria extends StatelessWidget {
  const MiAppCafeteria({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MesasProvider()),
        ChangeNotifierProvider(create: (_) => ProductosProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CajaProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Coffe Break POS',

        theme: AppTheme.lightTheme, // Tema Claro
        darkTheme: AppTheme.darkTheme, // Tema Oscuro
        themeMode: ThemeMode.system,
       
        home: const SplashScreen(), 
      ),
    );
  }
}