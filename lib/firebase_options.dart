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
        return macos;
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
    apiKey: 'AIzaSyA6Tv7oQnUdLeMoimgQoQdY49h8i799seQ',
    appId: '1:869842355386:web:6e41fccc6a5f1c27782e83',
    messagingSenderId: '869842355386',
    projectId: 'studyhub-4c9d7',
    authDomain: 'studyhub-4c9d7.firebaseapp.com',
    storageBucket: 'studyhub-4c9d7.firebasestorage.app',
    measurementId: 'G-N94MVHSCG7',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCMbg4GgNnOUsXBAjA2vxcWX1EBAUWSpys',
    appId: '1:869842355386:ios:3b6b0b3a6eba7430782e83',
    messagingSenderId: '869842355386',
    projectId: 'studyhub-4c9d7',
    storageBucket: 'studyhub-4c9d7.firebasestorage.app',
    iosBundleId: 'com.example.studyHub',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCMbg4GgNnOUsXBAjA2vxcWX1EBAUWSpys',
    appId: '1:869842355386:ios:3b6b0b3a6eba7430782e83',
    messagingSenderId: '869842355386',
    projectId: 'studyhub-4c9d7',
    storageBucket: 'studyhub-4c9d7.firebasestorage.app',
    iosBundleId: 'com.example.studyHub',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDijIAY47CJMBfeO-4g_WsFCnBUyAZD_Gc',
    appId: '1:869842355386:android:d6c333794bf59c48782e83',
    messagingSenderId: '869842355386',
    projectId: 'studyhub-4c9d7',
    storageBucket: 'studyhub-4c9d7.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA6Tv7oQnUdLeMoimgQoQdY49h8i799seQ',
    appId: '1:869842355386:web:6e41fccc6a5f1c27782e83',
    messagingSenderId: '869842355386',
    projectId: 'studyhub-4c9d7',
    authDomain: 'studyhub-4c9d7.firebaseapp.com',
    storageBucket: 'studyhub-4c9d7.firebasestorage.app',
    measurementId: 'G-N94MVHSCG7',
  );

}