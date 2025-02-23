import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

/// A screen where users enter the OTP received via email and set a new password.
class PasswordResetConfirmScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  PasswordResetConfirmScreen({super.key}) {
    // ✅ Clear previous passwords when screen is opened
    authController.passwordController.clear();
    authController.confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Your Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Enter a new password below.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // New Password Input
            Obx(
              () => CustomInput(
                label: 'New Password',
                controller: authController.passwordController,
                obscureText: !authController.isPasswordVisible.value,
                prefixIcon: Icons.lock_outline,
                suffixIcon: authController.isPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixIconPressed: () {
                  authController.isPasswordVisible.toggle();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Confirm New Password Input
            Obx(
              () => CustomInput(
                label: 'Confirm Password',
                controller: authController.confirmPasswordController,
                obscureText: !authController.isConfirmPasswordVisible.value,
                prefixIcon: Icons.lock_outline,
                suffixIcon: authController.isConfirmPasswordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
                onSuffixIconPressed: () {
                  authController.isConfirmPasswordVisible.toggle();
                },
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            Obx(
              () => CustomButton(
                label: 'Reset Password',
                onPressed: authController.isLoading.value
                    ? null
                    : authController.confirmPasswordReset,
                isLoading: authController.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
