import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

/// A screen to verify a one-time password (OTP) sent to the user.
/// Relies on [AuthController] for OTP validation.
class OtpScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The server might have sent a message to show, e.g. “OTP sent to your phone”.
    final String? message = Get.arguments?['message'];
    final String? username = Get.arguments?['username'];

    // If the user arrived here without arguments, redirect to login.
    if (message == null || username == null) {
      Get.offAllNamed('/login');
      return const Scaffold(body: Center(child: Text("Redirecting...")));
    }

    // Pre-fill the controller’s username if needed.
    authController.usernameController.text = username;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            CustomInput(
              label: 'Enter OTP',
              controller: authController.otpController,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButton(
                label: 'Verify',
                onPressed: authController.isLoading.value ? null : authController.verifyOtp,
                isLoading: authController.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
