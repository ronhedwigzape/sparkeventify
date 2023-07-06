import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get webPlatform {
    return const FirebaseOptions(
      apiKey: "AIzaSyC8DWmwROAeyPru_SYh3xwDJG2BX_eNcD4",
      authDomain: "student-event-calendar-dce10.firebaseapp.com",
      projectId: "student-event-calendar-dce10",
      storageBucket: "student-event-calendar-dce10.appspot.com",
      messagingSenderId: "777878936021",
      appId: "1:777878936021:web:972eba2175a9e6eedf855c",
      measurementId: "G-6ZJTE7VPBD"
    );
  }

  static FirebaseOptions get androidPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDDGkg8ZG26GT2j_wTlOR5Xj2JjLZh8AY0',
      appId: '1:777878936021:android:980072560145bcc0df855c',
      messagingSenderId: '777878936021',
      projectId: 'student-event-calendar-dce10',
    );
  }

  static FirebaseOptions get iosPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyDDGkg8ZG26GT2j_wTlOR5Xj2JjLZh8AY0',
      appId: '1:777878936021:ios:d06f0a15a482fe84df855c',
      messagingSenderId: '777878936021',
      projectId: 'student-event-calendar-dce10',
    );
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return webPlatform;
    } else if (Platform.isAndroid) {
      return androidPlatform;
    } else if (Platform.isIOS) {
      return iosPlatform;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}