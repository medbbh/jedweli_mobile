import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

/// A screen that allows new users to create an account.
/// Uses [AuthController] for registration logic.
class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  RegisterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top background image + logo
            Container(
              height: size.height * 0.25,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background_image.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', height: 130, width: 130),
                  const SizedBox(height: 16),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form inputs + button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomInput(
                    label: 'Username',
                    controller: authController.usernameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  CustomInput(
                    label: 'Phone Number',
                    controller: authController.phoneController,
                    inputType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  CustomInput(
                    label: 'Email Address',
                    controller: authController.emailController,
                    inputType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),

                  // Password
                  Obx(
                    () => CustomInput(
                      label: 'Password',
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

                  // Confirm Password
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

                  // Register button
                  Obx(
                    () => CustomButton(
                      label: 'Register',
                      onPressed: authController.isLoading.value ? null : authController.register,
                      isLoading: authController.isLoading.value,
                      icon: Icons.person_add_outlined,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Already have an account? Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Get.offAllNamed('/login'),
                        child: const Text(
                          'Login here',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
