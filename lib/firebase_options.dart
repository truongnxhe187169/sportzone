import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web platform is not supported.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform $defaultTargetPlatform is not supported.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCbeQ-XyrQKZwr05paTOYNP6q-QkfZU_bA',
    appId: '1:806227551498:android:ecf9f62b1d5f723f60c6f3',
    messagingSenderId: '806227551498',
    projectId: 'sportzone-prm393',
    storageBucket: 'sportzone-prm393.firebasestorage.app',
  );
}
