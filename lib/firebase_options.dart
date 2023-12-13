// import the necessary Dart and Flutter packages
// io package for platform-agnostic code
import 'dart:io';
// core Firebase package
import 'package:firebase_core/firebase_core.dart';
// Flutter package for determining platform code is running on
import 'package:flutter/foundation.dart';

// This class provides different Firebase configuration options for different platforms. 
class DefaultFirebaseOptions {
  // Firebase configuration for web platform
  static FirebaseOptions get webPlatform {
    return const FirebaseOptions(
      // These are various configuration parameters needed to setup Firebase for your app
      // Please replace them with your actual values when setting up Firebase for your application
      apiKey: "AIzaSyC8DWmwROAeyPru_SYh3xwDJG2BX_eNcD4",
      authDomain: "student-event-calendar-dce10.firebaseapp.com",
      projectId: "student-event-calendar-dce10",
      storageBucket: "student-event-calendar-dce10.appspot.com",
      messagingSenderId: "777878936021",
      appId: "1:777878936021:web:972eba2175a9e6eedf855c",
      measurementId: "G-6ZJTE7VPBD"
    );
  }

  // Firebase configuration for Android platform
  static FirebaseOptions get androidPlatform {
    return const FirebaseOptions(
      // Replace these with actual values from Firebase console when setting up Firebase for Android app
      apiKey: "AIzaSyDDGkg8ZG26GT2j_wTlOR5Xj2JjLZh8AY0",
      appId: "1:777878936021:android:980072560145bcc0df855c",
      messagingSenderId: "777878936021",
      projectId: "student-event-calendar-dce10",
    );
  }

  // Firebase configuration for iOS platform
  static FirebaseOptions get iosPlatform {
    return const FirebaseOptions(
      // Replace these with actual values from Firebase console when setting up Firebase for iOS app
      apiKey: "AIzaSyDDGkg8ZG26GT2j_wTlOR5Xj2JjLZh8AY0",
      appId: "1:777878936021:ios:d06f0a15a482fe84df855c",
      messagingSenderId: "777878936021",
      projectId: "student-event-calendar-dce10",
    );
  }

  // Getter for current platform's Firebase configuration
  static FirebaseOptions get currentPlatform {
    // Checks on which platform the app currently runs and returns appropriate Firebase options
    if (kIsWeb) {
      return webPlatform;
    } else if (Platform.isAndroid) {
      return androidPlatform;
    } else if (Platform.isIOS) {
      return iosPlatform;
    } else {
      // If the current platform is not web, nor Android, nor iOS, an UnsupportedError is thrown
      throw UnsupportedError('Unsupported platform');
    }
  }
}
