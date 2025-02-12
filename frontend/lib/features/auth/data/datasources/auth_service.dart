import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/services/storage_service.dart';

/// A remote data source responsible for handling all authentication-related API calls.
///
/// This class uses GetConnect (via `extends GetConnect`) for making network requests,
/// and includes basic logging & error handling for debugging.
class AuthService extends GetConnect {
  @override
  void onInit() {
    // Avoid forcing a default Content-Type header to let requests handle JSON encoding properly.
    httpClient.timeout = const Duration(seconds: 15);

    // Add an HTTP request modifier to log requests for debugging.
    httpClient.addRequestModifier<dynamic>((request) {
      debugPrint("📡 [AuthService] Sending request to: ${request.url}");
      debugPrint("📡 [AuthService] Headers: ${request.headers}");
      return request;
    });
    super.onInit();
  }

  /// Logs the user in using the provided [data].
  ///
  /// Expects `username` and `password` in [data], then returns the raw [Response].
  /// Throws an [Exception] if the request fails or times out.
  Future<Response> login(Map<String, dynamic> data) async {
    final url = 'login/';
    debugPrint("\n🔍 [AuthService] login() -> ${Constants.baseAuthUrl}$url with data: $data");

    try {
      final response = await httpClient.post(
        Constants.baseAuthUrl + url,
        body: jsonEncode(data), // JSON-encode the request body
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("🔍 [AuthService] login status: ${response.statusCode}");
      debugPrint("🔍 [AuthService] login body: ${response.body}\n");
      return response;
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during login: $e");
      // You could throw a custom AuthException here
      throw Exception("❌ [AuthService] Failed to login: $e");
    }
  }

  /// Registers a new user with the provided [data].
  ///
  /// Expects fields such as `username`, `email`, `phone_number`, `password`, etc.
  /// Returns the raw [Response], or throws an [Exception] on failure.
  Future<Response> register(Map<String, dynamic> data) async {
    final url = 'register/';
    debugPrint("\n🔍 [AuthService] register() -> ${Constants.baseAuthUrl}$url with data: $data");

    try {
      final response = await httpClient.post(
        Constants.baseAuthUrl + url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("🔍 [AuthService] register status: ${response.statusCode}");
      debugPrint("🔍 [AuthService] register body: ${response.body}\n");
      return response;
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during register: $e");
      throw Exception("❌ [AuthService] Failed to register: $e");
    }
  }

  /// Verifies an OTP code for the given [data].
  ///
  /// Typically includes `username` and `otp`.
  Future<Response> verifyOtp(Map<String, dynamic> data) async {
    final url = 'verify-otp/';
    debugPrint("\n🔍 [AuthService] verifyOtp() -> ${Constants.baseAuthUrl}$url with data: $data");

    try {
      final response = await httpClient.post(
        Constants.baseAuthUrl + url,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      debugPrint("🔍 [AuthService] verifyOtp status: ${response.statusCode}");
      debugPrint("🔍 [AuthService] verifyOtp body: ${response.body}\n");
      return response;
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during OTP verification: $e");
      throw Exception("❌ [AuthService] Failed to verify OTP: $e");
    }
  }

  /// Logs out the current user by clearing tokens in [StorageService].
  ///
  /// Optionally navigates to the login screen.
  Future<void> logout() async {
    debugPrint("\n🔍 [AuthService] Logging out user");
    try {
      // Clear stored authentication tokens
      Get.find<StorageService>().clearTokens();
      debugPrint("✅ [AuthService] User logged out successfully");
      Get.offAllNamed('/login'); // or your AppRoutes.login
    } catch (e) {
      debugPrint("❌ [AuthService] Exception during logout: $e");
      // In a future refactor, throw a custom exception or handle gracefully.
    }
  }
}
