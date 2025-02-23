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
  final TextEditingController confirmPasswordController =
      TextEditingController();

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
        // ✅ If phone is verified, log in normally
        _storageService.saveTokens(responseBody['access'], responseBody['refresh']);
        // ✅ Fetch schedules immediately after login
        final scheduleController = Get.find<ScheduleController>();
        await scheduleController.fetchSchedules();
        Get.offAllNamed(AppRoutes.home);
      } else {
        // ❌ If phone is not verified, redirect to OTP screen
        Get.offAllNamed(
          AppRoutes.otp,
          arguments: {
            'phone_number': phoneController.text.trim(),
            'isPasswordReset': false, // This is for login OTP verification
          },
        );
      }
    } else {
      errorMessage.value = response.body['error'] ?? 'Login failed';
    }
  } catch (e) {
    errorMessage.value = "An error occurred during login: $e";
  } finally {
    isLoading.value = false;
  }
}


  /// Verifies the one-time password (OTP) and, if successful, saves the tokens.
  Future<void> verifyOtp(bool isPasswordReset) async {
  isLoading.value = true;
  errorMessage.value = null;

  final requestData = {
    'otp': otpController.text.trim(),
    'is_password_reset': isPasswordReset,  // ✅ Tell backend it's a password reset OTP
  };

  debugPrint("📡 [AuthController] Sending OTP Verification Request: $requestData");

  try {
    final response = await _authService.verifyOtp(requestData);

    debugPrint("📡 [AuthController] verifyOtp status: ${response.statusCode}");
    debugPrint("📡 [AuthController] verifyOtp body: ${response.body}");

    if (response.statusCode == 200) {
      if (isPasswordReset) {
        // ✅ Redirect to Password Reset Form (Not Verify-OTP)
        Get.offAllNamed(AppRoutes.passwordResetConfirm);
      } else {
        // ✅ If phone verification, save tokens and go to home
        final body = response.body;
        if (body['access'] != null && body['refresh'] != null) {
          _storageService.saveTokens(body['access'], body['refresh']);
          Get.offAllNamed(AppRoutes.home);
        } else {
          errorMessage.value = 'OTP verification failed.';
        }
      }
    } else {
      errorMessage.value = response.body['error'] ?? 'Invalid OTP.';
    }
  } catch (e) {
    errorMessage.value = "An error occurred: $e";
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
        // Navigate to OTP screen for verification
        Get.offAllNamed(
          AppRoutes.otp,
          arguments: {
            'phone_number': phoneController.text.trim(),
            'isPasswordReset': false, // This is for registration OTP
          },
        );
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

  /// Sends an OTP to the user's email for password reset.
Future<void> requestPasswordReset() async {
  isLoading.value = true;
  errorMessage.value = null;

  try {
    final response = await _authService.requestPasswordReset({
      'email': emailController.text.trim(),
    });

    if (response.statusCode == 200) {
      // ✅ Save phone number before navigating
      final phoneNumber = response.body['phone_number'] ?? '';
      if (phoneNumber.isNotEmpty) {
        phoneController.text = phoneNumber;
      }

      Get.snackbar('Success', 'Check your email for the OTP');
      Get.toNamed(AppRoutes.otp, arguments: {
        'phone_number': phoneController.text.trim(),
        'isPasswordReset': true,  // ✅ Tell OTP screen it's for password reset
      });
    } else {
      errorMessage.value = response.body['error'] ?? 'Failed to send OTP.';
    }
  } catch (e) {
    errorMessage.value = "An error occurred: $e";
  } finally {
    isLoading.value = false;
  }
}


  /// Confirms OTP and resets the password
  Future<void> confirmPasswordReset() async {
  isLoading.value = true;
  errorMessage.value = null;

  final requestData = {
    'otp': otpController.text.trim(),
    'password': passwordController.text.trim(),
    'confirm_password': confirmPasswordController.text.trim(),
  };

  debugPrint("📡 [AuthController] Sending Password Reset Request: $requestData");

  try {
    final response = await _authService.confirmPasswordReset(requestData);

    debugPrint("📡 [AuthController] confirmPasswordReset status: ${response.statusCode}");
    debugPrint("📡 [AuthController] confirmPasswordReset body: ${response.body}");

    if (response.statusCode == 200) {
      Get.snackbar('Success', 'Password reset successful. Please log in.');
      Get.offAllNamed(AppRoutes.login);
    } else {
      errorMessage.value = response.body['error'] ?? 'Password reset failed';
    }
  } catch (e) {
    errorMessage.value = "❌ An error occurred during password reset: $e";
  } finally {
    isLoading.value = false;
  }
}




}
