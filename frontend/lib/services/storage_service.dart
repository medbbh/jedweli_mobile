import 'package:get_storage/get_storage.dart';

class StorageService {
  final _storage = GetStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // ✅ Save Both Access and Refresh Tokens
  void saveTokens(String accessToken, String refreshToken) {
    _storage.write(_accessTokenKey, accessToken);
    _storage.write(_refreshTokenKey, refreshToken);
    print("Tokens saved: Access - $accessToken, Refresh - $refreshToken"); // ✅ Debugging
  }

  // ✅ Get Access Token
  String? getAccessToken() {
    return _storage.read(_accessTokenKey);
  }

  // ✅ Get Refresh Token
  String? getRefreshToken() {
    return _storage.read(_refreshTokenKey);
  }

  // ✅ Check if User is Logged In
  bool isLoggedIn() {
    return getAccessToken() != null;
  }

  // ✅ Clear Tokens (Logout)
  void clearTokens() {
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
    print("Tokens cleared!"); // ✅ Debugging
  }
}
