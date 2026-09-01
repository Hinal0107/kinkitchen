import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD5PZvo6CjIMdAz33VRppX7A0GqnrApYKc',
    appId: '1:968337721299:android:8c41f6fcbcc9653611d126',
    messagingSenderId: '968337721299',
    projectId: 'kinkitchen-51b17',
    storageBucket: 'kinkitchen-51b17.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5PZvo6CjIMdAz33VRppX7A0GqnrApYKc',
    appId: '1:968337721299:ios:8c41f6fcbcc9653611d126',
    messagingSenderId: '968337721299',
    projectId: 'kinkitchen-51b17',
    storageBucket: 'kinkitchen-51b17.firebasestorage.app',
    iosBundleId: 'com.example.kinkitchen',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD5PZvo6CjIMdAz33VRppX7A0GqnrApYKc',
    appId: '1:968337721299:web:8c41f6fcbcc9653611d126',
    messagingSenderId: '968337721299',
    projectId: 'kinkitchen-51b17',
    storageBucket: 'kinkitchen-51b17.firebasestorage.app',
  );
}
