// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCriVuNe4bxYM641o4c6Gc9cEg93p39i4E',
    appId: '1:190915594946:web:349bbd140e4ea6a5f1495b',
    messagingSenderId: '190915594946',
    projectId: 'flutter-app-flowerdex',
    authDomain: 'flutter-app-flowerdex.firebaseapp.com',
    storageBucket: 'flutter-app-flowerdex.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDoS1bLTxeABN01VQGwkxQ_eYbPmMwdQvE',
    appId: '1:190915594946:android:ab053cc0e4f39f3cf1495b',
    messagingSenderId: '190915594946',
    projectId: 'flutter-app-flowerdex',
    storageBucket: 'flutter-app-flowerdex.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjWQ2IysF7dSvG6MfC2V2GzUFEtOQBMSQ',
    appId: '1:190915594946:ios:0257a9ae3292c473f1495b',
    messagingSenderId: '190915594946',
    projectId: 'flutter-app-flowerdex',
    storageBucket: 'flutter-app-flowerdex.firebasestorage.app',
    iosBundleId: 'com.example.appFlowerdex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCriVuNe4bxYM641o4c6Gc9cEg93p39i4E',
    appId: '1:190915594946:web:d0ba5a9e53f41844f1495b',
    messagingSenderId: '190915594946',
    projectId: 'flutter-app-flowerdex',
    authDomain: 'flutter-app-flowerdex.firebaseapp.com',
    storageBucket: 'flutter-app-flowerdex.firebasestorage.app',
  );
}
