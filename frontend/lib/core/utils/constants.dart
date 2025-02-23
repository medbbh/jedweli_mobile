import 'package:flutter/foundation.dart'; // ✅ Import kIsWeb

class Constants {
  static String get baseApiUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/'; // ✅ Use 127.0.0.1 for web
      // 172.20.10.7
    } else {
      // return 'http://10.0.2.2:8000/api/'; // ✅ Use 10.0.2.2 for Android emulator
      return 'http://192.168.137.1:8000/api/'; // ✅ Use for Android device connected via USB
    }
  }

  static String get baseAuthUrl => '${baseApiUrl}auth/';

  static const String tokenKey = 'auth_token';

  static const String appBaseUrl = ''; // App URL for sharing schedules

  
  static String get registerUrl => '${baseApiUrl}auth/register/';
  static String get loginUrl => '${baseApiUrl}auth/login/';
  static String get verifyOtpUrl => '${baseApiUrl}auth/verify-otp/';
  static String get passwordResetUrl => '${baseApiUrl}auth/password-reset/';
  static String get passwordResetConfirmUrl => '${baseApiUrl}auth/password-reset-confirm/';

}
