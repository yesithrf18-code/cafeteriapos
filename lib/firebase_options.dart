import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA-Gj8Unnz3F0S5koIVR_ocVabAYPPkUTo',
    authDomain: 'cafeteriapos-8cedc.firebaseapp.com',
    projectId: 'cafeteriapos-8cedc',
    storageBucket: 'cafeteriapos-8cedc.firebasestorage.app',
    messagingSenderId: '474716747660',
    appId: '1:474716747660:web:5e2c3afb978fe9646908a9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA-Gj8Unnz3F0S5koIVR_ocVabAYPPkUTo',
    appId: '1:474716747660:android:placeholder',
    messagingSenderId: '474716747660',
    projectId: 'cafeteriapos-8cedc',
    storageBucket: 'cafeteriapos-8cedc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA-Gj8Unnz3F0S5koIVR_ocVabAYPPkUTo',
    appId: '1:474716747660:ios:placeholder',
    messagingSenderId: '474716747660',
    projectId: 'cafeteriapos-8cedc',
    storageBucket: 'cafeteriapos-8cedc.firebasestorage.app',
    iosBundleId: 'com.example.cafeteriapos',
  );
}
