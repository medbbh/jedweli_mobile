import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
import '../../data/datasources/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

/// A GetX controller responsible for coordinating authentication logic.
///
/// It depends on [AuthService] for remote data operations and
/// [StorageService] for token storage.
class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  /// Observables to manage loading state, error messages, and password visibility.
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;

  /// Reactive holder for any error messages to display in the UI.
  var errorMessage = RxnString();

  /// Controllers for handling user input in forms.
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    otpController.dispose();
    emailController.dispose();
    phoneController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// Logs the user in, saving tokens if successful.
  ///
  /// If the API indicates an OTP is required, navigates to the OTP screen with the server’s message.
  Future<void> login() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authService.login({
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      });

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody['access'] != null && responseBody['refresh'] != null) {
          // Save tokens if returned
          _storageService.saveTokens(responseBody['access'], responseBody['refresh']);

          // Optionally refresh schedule & favorites
          final scheduleController = Get.find<ScheduleController>();
          await scheduleController.refreshData();

          // Navigate to home
          Get.offAllNamed(AppRoutes.home);
        } else {
          // If your server logic requires OTP first, show the OTP screen
          Get.offAllNamed(
            AppRoutes.otp,
            arguments: {
              'username': usernameController.text.trim(),
              'message': responseBody['message'],
            },
          );
        }
      } else {
        // Extract an error from the response body if available.
        errorMessage.value = response.body['error'] ?? 'Login failed';
      }
    } catch (e) {
      errorMessage.value = "An error occurred during login: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies the one-time password (OTP) and, if successful, saves the tokens.
  Future<void> verifyOtp() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authService.verifyOtp({
        'username': usernameController.text.trim(),
        'otp': otpController.text.trim(),
      });

      if (response.statusCode == 200) {
        final body = response.body;
        if (body != null && body['access'] != null && body['refresh'] != null) {
          _storageService.saveTokens(body['access'], body['refresh']);
          Get.offAllNamed(AppRoutes.home);
        } else {
          errorMessage.value = 'OTP verification: invalid response from server.';
        }
      } else {
        errorMessage.value = response.body['error'] ?? 'OTP verification failed';
      }
    } catch (e) {
      errorMessage.value = "An error occurred during OTP verification: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Registers a new user with the server, navigating to the login screen if successful.
  Future<void> register() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authService.register({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'phone_number': phoneController.text.trim(),
        'password': passwordController.text.trim(),
        'confirm_password': confirmPasswordController.text.trim(),
      });

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Registration successful');
        Get.offAllNamed(AppRoutes.login);
      } else {
        errorMessage.value = response.body['error'] ?? 'Registration failed';
      }
    } catch (e) {
      errorMessage.value = "An error occurred during registration: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs out the user by clearing tokens, then navigates to the login screen.
  void logout() {
    _storageService.clearTokens();
    Get.offAllNamed(AppRoutes.login);
  }
}
