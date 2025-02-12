import 'dart:convert';
import 'package:get/get.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

class AuthService extends GetConnect {
  @override
  void onInit() {
    // Remove or comment out the defaultContentType to avoid duplicate content-type headers
    // httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);

    // Log request info for debugging
    httpClient.addRequestModifier<dynamic>((request) {
      print("📡 Sending request: \${request.url}");
      print("📡 Headers: \${request.headers}");
      return request;
    });
    super.onInit();
  }

  Future<Response> login(Map<String, dynamic> data) async {
    final url = 'login/';
    print("\n🔍 Login request to: \${Constants.baseAuthUrl}\$url with data: \$data");

    try {
      // Encode the body as JSON, rely on the request's single Content-Type
      final response = await httpClient.post(
        Constants.baseAuthUrl + url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      print("🔍 Status Code: \${response.statusCode}");
      print("🔍 Response Body: \${response.body}");
      print("🔍 Headers: \${response.headers}\n");

      return response;
    } catch (e) {
      print("❌ Exception during login: \$e");
      throw Exception("❌ Failed to login: \$e");
    }
  }

  Future<Response> register(Map<String, dynamic> data) async {
    final url = 'register/';
    print("\n🔍 Register request to: \${Constants.baseAuthUrl}\$url with data: \$data");

    try {
      final response = await httpClient.post(
        Constants.baseAuthUrl + url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      print("🔍 Status Code: \${response.statusCode}");
      print("🔍 Response Body: \${response.body}");
      print("🔍 Headers: \${response.headers}\n");
      return response;
    } catch (e) {
      print("❌ Exception during register: \$e");
      throw Exception("❌ Failed to register: \$e");
    }
  }

  Future<Response> verifyOtp(Map<String, dynamic> data) async {
    final url = 'verify-otp/';
    print("\n🔍 OTP verification request to: \${Constants.baseAuthUrl}\$url with data: \$data");

    try {
      final response = await httpClient.post(
        Constants.baseAuthUrl + url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      print("🔍 Status Code: \${response.statusCode}");
      print("🔍 Response Body: \${response.body}");
      print("🔍 Headers: \${response.headers}\n");
      return response;
    } catch (e) {
      print("❌ Exception during OTP verification: \$e");
      throw Exception("❌ Failed to verify OTP: \$e");
    }
  }

  Future<void> logout() async {
    print("\n🔍 Logging out user");
    try {
      // Clear stored authentication tokens
      Get.find<StorageService>().clearTokens();
      print("✅ User logged out successfully");
      Get.offAllNamed('/login'); // Navigate to login screen
    } catch (e) {
      print("❌ Exception during logout: \$e");
    }
  }
}
