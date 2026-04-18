// Replace these placeholder values with your own Firebase project configuration.
// You can generate this file automatically using `flutterfire configure`.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform. '
      'Please add Android and/or iOS options or configure Firebase using flutterfire.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD6tH9Za5FzunHSojPCtAByKHnK-1PxJdg',
    authDomain: 'smart-helmet-monitoring-app.firebaseapp.com',
    projectId: 'smart-helmet-monitoring-app',
    storageBucket: 'smart-helmet-monitoring-app.firebasestorage.app',
    messagingSenderId: '284764298852',
    appId: '1:284764298852:web:3132ca456a5c9880928971',
    measurementId: 'G-88ZVVY5TGK',
    databaseURL:
        'https://smart-helmet-monitoring-app-default-rtdb.firebaseio.com',
  );
}
