import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

class PasswordResetScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInput(
              label: 'Enter your email',
              controller: authController.emailController,
              inputType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            Obx(
              () => CustomButton(
                label: 'Send OTP',
                onPressed: authController.isLoading.value
                    ? null
                    : () => authController.requestPasswordReset(),
                isLoading: authController.isLoading.value,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
