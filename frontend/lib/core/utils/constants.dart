import 'package:flutter/foundation.dart'; // ✅ Import kIsWeb

class Constants {
  static String get baseApiUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/'; // ✅ Use 127.0.0.1 for web
    } else {
      return 'http://10.0.2.2:8000/api/'; // ✅ Use 10.0.2.2 for Android emulator
    }
  }

  static String get baseAuthUrl => '${baseApiUrl}auth/';

  static const String tokenKey = 'auth_token';

  static const String appBaseUrl = ''; // App URL for sharing schedules
}
