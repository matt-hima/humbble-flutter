import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase configuration for the photo-hubble project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const web = FirebaseOptions(
    apiKey: 'AIzaSyDYy0l4CQ8pgxmSAc0rv6SEVJcHZ88B62k',
    appId: '1:366297617713:web:57957b0e5e3eff5b228c10',
    messagingSenderId: '366297617713',
    projectId: 'photo-hubble',
    authDomain: 'photo-hubble.firebaseapp.com',
    storageBucket: 'photo-hubble.firebasestorage.app',
    measurementId: 'G-FCCB5YFX0N',
  );
  static const android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_ANDROID_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'photo-hubble',
  );
  static const ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_IOS_API_KEY',
    appId: 'REPLACE_WITH_FIREBASE_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'photo-hubble',
    iosBundleId: 'com.example.photoHubble',
  );
}
