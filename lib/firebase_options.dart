// File được tạo bởi FlutterFire CLI + web config thêm thủ công.
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB_BP9npQ9dR-gAvsCRdNKQ0cK6IzZ_C-Q',
    authDomain: 'sportzone-prm393.firebaseapp.com',
    projectId: 'sportzone-prm393',
    storageBucket: 'sportzone-prm393.firebasestorage.app',
    messagingSenderId: '806227551498',
    appId: '1:806227551498:web:2622d63b859a072860c6f3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbeQ-XyrQKZwr05paTOYNP6q-QkfZU_bA',
    appId: '1:806227551498:android:ecf9f62b1d5f723f60c6f3',
    messagingSenderId: '806227551498',
    projectId: 'sportzone-prm393',
    storageBucket: 'sportzone-prm393.firebasestorage.app',
  );
}
