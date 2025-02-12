import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

/// A screen that allows existing users to log in using their username and password.
/// Uses [AuthController] for business logic.
class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top background image + logo
            Container(
              height: size.height * 0.35,
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
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Form inputs + buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Username
                  CustomInput(
                    label: 'Username',
                    controller: authController.usernameController,
                    prefixIcon: Icons.person_outline,
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

                  // Forgot password link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement "Forgot password?" flow
                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error message (if any)
                  Obx(
                    () => authController.errorMessage.value != null
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              authController.errorMessage.value!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )
                        : const SizedBox(),
                  ),

                  // Login button
                  Obx(
                    () => CustomButton(
                      label: 'Login',
                      onPressed: authController.isLoading.value ? null : authController.login,
                      isLoading: authController.isLoading.value,
                      icon: Icons.login,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Get.offAllNamed('/register'),
                        child: const Text(
                          'Register Now',
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
