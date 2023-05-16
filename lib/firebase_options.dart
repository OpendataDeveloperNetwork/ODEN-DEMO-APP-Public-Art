// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDzOypuS53B_sKybgAxUvmAoXutkHd2vJo',
    appId: '1:218422175053:web:06a9f0a1ad4709debfc304',
    messagingSenderId: '218422175053',
    projectId: 'oden-542d3',
    authDomain: 'oden-542d3.firebaseapp.com',
    storageBucket: 'oden-542d3.appspot.com',
    measurementId: 'G-5FKC07Q4KH',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFNuqcSAUAdayavOOqdtwWdq5sf-_BiWs',
    appId: '1:218422175053:android:0013d2ba23bf68d9bfc304',
    messagingSenderId: '218422175053',
    projectId: 'oden-542d3',
    storageBucket: 'oden-542d3.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAtlpH2wwD67CwHuMqs2ni6TohtTOOxSls',
    appId: '1:218422175053:ios:b058c60ff8d520d3bfc304',
    messagingSenderId: '218422175053',
    projectId: 'oden-542d3',
    storageBucket: 'oden-542d3.appspot.com',
    iosClientId: '218422175053-rks4mk2qobqf68u8d4qaho7p6bn3pfl0.apps.googleusercontent.com',
    iosBundleId: 'com.example.odenApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAtlpH2wwD67CwHuMqs2ni6TohtTOOxSls',
    appId: '1:218422175053:ios:b058c60ff8d520d3bfc304',
    messagingSenderId: '218422175053',
    projectId: 'oden-542d3',
    storageBucket: 'oden-542d3.appspot.com',
    iosClientId: '218422175053-rks4mk2qobqf68u8d4qaho7p6bn3pfl0.apps.googleusercontent.com',
    iosBundleId: 'com.example.odenApp',
  );
}
