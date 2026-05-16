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
    apiKey: 'AIzaSyCFuT8qHoJvuPFGSXizxY2kG2te0uSDLlg',
    appId: '1:563529601079:web:7552387d299768aebcafb2',
    messagingSenderId: '563529601079',
    projectId: 'studyhub-dffc6',
    authDomain: 'studyhub-dffc6.firebaseapp.com',
    storageBucket: 'studyhub-dffc6.firebasestorage.app',
    measurementId: 'G-6WMEB3N2KL',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCshRHV3ZkgGTxlOX3mxyAePMxbsjCOm40',
    appId: '1:563529601079:ios:17e00b168a3c25e2bcafb2',
    messagingSenderId: '563529601079',
    projectId: 'studyhub-dffc6',
    storageBucket: 'studyhub-dffc6.firebasestorage.app',
    iosBundleId: 'com.example.studyHub',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCshRHV3ZkgGTxlOX3mxyAePMxbsjCOm40',
    appId: '1:563529601079:ios:17e00b168a3c25e2bcafb2',
    messagingSenderId: '563529601079',
    projectId: 'studyhub-dffc6',
    storageBucket: 'studyhub-dffc6.firebasestorage.app',
    iosBundleId: 'com.example.studyHub',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_OefAQ5GthzokSH9YVb7PJYNI-C0E4Og',
    appId: '1:563529601079:android:d358a282d40a82aabcafb2',
    messagingSenderId: '563529601079',
    projectId: 'studyhub-dffc6',
    storageBucket: 'studyhub-dffc6.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCFuT8qHoJvuPFGSXizxY2kG2te0uSDLlg',
    appId: '1:563529601079:web:2c5203cab931d5f2bcafb2',
    messagingSenderId: '563529601079',
    projectId: 'studyhub-dffc6',
    authDomain: 'studyhub-dffc6.firebaseapp.com',
    storageBucket: 'studyhub-dffc6.firebasestorage.app',
    measurementId: 'G-4DGZ0Q9LDK',
  );

}