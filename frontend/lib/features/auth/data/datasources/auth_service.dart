import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/services/storage_service.dart';

/// A remote data source responsible for handling all authentication-related API calls.
/// Uses `GetConnect` for network requests.
class AuthService extends GetConnect {
  @override
  void onInit() {
    httpClient.timeout = const Duration(seconds: 15);

    // ✅ Log all API requests for debugging
    httpClient.addRequestModifier<dynamic>((request) {
      debugPrint("📡 [AuthService] Request: ${request.method} ${request.url}");
      debugPrint("📡 [AuthService] Headers: ${request.headers}");
      return request;
    });

    super.onInit();
  }

  /// ✅ **Login API**
  Future<Response> login(Map<String, dynamic> data) async {
    final url = '${Constants.baseAuthUrl}login/';
    debugPrint("\n📡 [AuthService] login() -> $url with data: $data");

    try {
      final response = await post(url, data, headers: {"Content-Type": "application/json"});

      debugPrint("📡 [AuthService] login status: ${response.statusCode}");
      debugPrint("📡 [AuthService] login body: ${response.body}\n");
      return response;
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during login: $e");
      throw Exception("❌ [AuthService] Failed to login: $e");
    }
  }

  /// ✅ **Register API**
  Future<Response> register(Map<String, dynamic> data) async {
    final url = '${Constants.baseAuthUrl}register/';
    debugPrint("\n📡 [AuthService] register() -> $url with data: $data");

    try {
      final response = await post(url, data, headers: {"Content-Type": "application/json"});

      debugPrint("📡 [AuthService] register status: ${response.statusCode}");
      debugPrint("📡 [AuthService] register body: ${response.body}\n");
      return response;
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during register: $e");
      throw Exception("❌ [AuthService] Failed to register: $e");
    }
  }

  /// ✅ **OTP Verification API**
Future<Response> verifyOtp(Map<String, dynamic> data) async {
  final url = Constants.verifyOtpUrl;
  debugPrint("\n📡 [AuthService] verifyOtp() -> $url with data: $data");

  try {
    final response = await post(url, data, headers: {"Content-Type": "application/json"});

    debugPrint("📡 [AuthService] verifyOtp status: ${response.statusCode}");
    debugPrint("📡 [AuthService] verifyOtp body: ${response.body}\n");
    return response;
  } catch (e) {
    debugPrint("❌ [AuthService] Exception during OTP verification: $e");
    throw Exception("❌ [AuthService] Failed to verify OTP: $e");
  }
}



  /// ✅ **Request Password Reset API**
  Future<Response> requestPasswordReset(Map<String, dynamic> data) async {
    final url = Constants.passwordResetUrl;
    debugPrint("\n📡 [AuthService] requestPasswordReset() -> $url with data: $data");

    try {
      final response = await post(url, data, headers: {"Content-Type": "application/json"});

      debugPrint("📡 [AuthService] requestPasswordReset status: ${response.statusCode}");
      debugPrint("📡 [AuthService] requestPasswordReset body: ${response.body}\n");
      return response;
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during password reset request: $e");
      throw Exception("❌ [AuthService] Failed to request password reset: $e");
    }
  }

  /// ✅ **Confirm Password Reset API**
Future<Response> confirmPasswordReset(Map<String, dynamic> data) async {
  final url = Constants.passwordResetConfirmUrl;
  debugPrint("\n📡 [AuthService] confirmPasswordReset() -> $url with data: $data");

  try {
    final response = await post(
      url,
      data,  // ✅ No need to include phone number
      headers: {"Content-Type": "application/json"},
    );

    debugPrint("📡 [AuthService] confirmPasswordReset status: ${response.statusCode}");
    debugPrint("📡 [AuthService] confirmPasswordReset body: ${response.body}\n");
    return response;
  } catch (e) {
    debugPrint("❌ [AuthService] Exception during password reset: $e");
    throw Exception("❌ [AuthService] Failed to reset password: $e");
  }
}


  /// ✅ **Logout User**
  Future<void> logout() async {
    debugPrint("\n📡 [AuthService] Logging out user");
    try {
      Get.find<StorageService>().clearTokens();
      debugPrint("✅ [AuthService] User logged out successfully");
      Get.offAllNamed('/login');
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during logout: $e");
    }
  }
}
