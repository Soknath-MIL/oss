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
    apiKey: 'AIzaSyCNguu2uWjZgDbFkbneXV5SrlPImZNDo9A',
    appId: '1:415242114196:web:ad193ada519d0b7a2f5081',
    messagingSenderId: '415242114196',
    projectId: 'moeve-app-c296d',
    authDomain: 'moeve-app-c296d.firebaseapp.com',
    databaseURL: 'https://moeve-app-c296d-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'moeve-app-c296d.appspot.com',
    measurementId: 'G-Q4REKYW9YD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOhS5YJVA6oQabPl9Kbf86BfAlK9hMQ8o',
    appId: '1:415242114196:android:435ffb26068b4c9a2f5081',
    messagingSenderId: '415242114196',
    projectId: 'moeve-app-c296d',
    databaseURL: 'https://moeve-app-c296d-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'moeve-app-c296d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDL5HdWIHw4aEwfTFIZA1DL46GRu7SNHCk',
    appId: '1:415242114196:ios:444be64d1d5d1d762f5081',
    messagingSenderId: '415242114196',
    projectId: 'moeve-app-c296d',
    databaseURL: 'https://moeve-app-c296d-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'moeve-app-c296d.appspot.com',
    androidClientId: '415242114196-tmsch4labptdsunh19k2i8m5mefvr8io.apps.googleusercontent.com',
    iosClientId: '415242114196-gn5qgh0sbco0v10mgpp3auhu04lbokpu.apps.googleusercontent.com',
    iosBundleId: 'com.example.ossApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDL5HdWIHw4aEwfTFIZA1DL46GRu7SNHCk',
    appId: '1:415242114196:ios:444be64d1d5d1d762f5081',
    messagingSenderId: '415242114196',
    projectId: 'moeve-app-c296d',
    databaseURL: 'https://moeve-app-c296d-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'moeve-app-c296d.appspot.com',
    androidClientId: '415242114196-tmsch4labptdsunh19k2i8m5mefvr8io.apps.googleusercontent.com',
    iosClientId: '415242114196-gn5qgh0sbco0v10mgpp3auhu04lbokpu.apps.googleusercontent.com',
    iosBundleId: 'com.example.ossApp',
  );
}
