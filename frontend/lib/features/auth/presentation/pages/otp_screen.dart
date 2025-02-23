import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

/// A screen to verify a one-time password (OTP) sent to the user.
/// It works for both **account verification (phone)** and **password reset (email)**.
class OtpScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Get whether this OTP is for password reset
    final bool isPasswordReset = Get.arguments?['isPasswordReset'] ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              isPasswordReset
                  ? "Enter the OTP sent to your email to reset your password."
                  : "Enter the OTP sent to your phone number to verify your account.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // ✅ OTP Input Field
            CustomInput(
              label: 'Enter OTP',
              controller: authController.otpController,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // ✅ Verify OTP Button
            Obx(
              () => CustomButton(
                label: 'Verify',
                onPressed: authController.isLoading.value
                    ? null
                    : () => authController.verifyOtp(isPasswordReset),
                isLoading: authController.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
