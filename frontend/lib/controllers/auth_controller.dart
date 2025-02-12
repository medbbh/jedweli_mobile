import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/controllers/schedule_controller.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var errorMessage = RxnString();

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
        // Save tokens
        _storageService.saveTokens(responseBody['access'], responseBody['refresh']);
        
        // ✅ Now fetch schedules & favorites
        final scheduleController = Get.find<ScheduleController>();
        await scheduleController.refreshData();

        // Navigate to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        // If your server logic requires OTP first:
        Get.offAllNamed(AppRoutes.otp, arguments: {
          'username': usernameController.text.trim(),
          'message': responseBody['message'],
        });
      }
    } else {
      errorMessage.value = response.body['error'] ?? 'Login failed';
    }
  } catch (e) {
    errorMessage.value = "An error occurred: $e";
  } finally {
    isLoading.value = false;
  }
}


  Future<void> verifyOtp() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final response = await _authService.verifyOtp({
        'username': usernameController.text.trim(),
        'otp': otpController.text.trim(),
      });

      if (response.statusCode == 200) {
        _storageService.saveTokens(response.body['access'], response.body['refresh']);
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = response.body['error'] ?? 'OTP verification failed';
      }
    } catch (e) {
      errorMessage.value = "An error occurred: $e";
    } finally {
      isLoading.value = false;
    }
  }

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
      errorMessage.value = "An error occurred: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storageService.clearTokens();
    Get.offAllNamed(AppRoutes.login);
  }
}
