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
          'DefaultFirebaseOptions have not been configured for ios - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBuSp3UexP4WYotewt0Nnh8NzwBY8Gc7A0',
    appId: '1:157115216541:web:0274bfac44a57fe0565a74',
    messagingSenderId: '157115216541',
    projectId: 'fitsugar-9e5b9',
    authDomain: 'fitsugar-9e5b9.firebaseapp.com',
    storageBucket: 'fitsugar-9e5b9.firebasestorage.app',
    measurementId: 'G-XQ1BL6D5N8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBSThrUudr9vUlE-prCcFev5SdoSLVRWk8',
    appId: '1:157115216541:android:a8af671b0a35b154565a74',
    messagingSenderId: '157115216541',
    projectId: 'fitsugar-9e5b9',
    storageBucket: 'fitsugar-9e5b9.firebasestorage.app',
  );
}