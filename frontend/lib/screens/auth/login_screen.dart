import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';
import '../../routes/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();

  bool isPasswordVisible = false;
  bool isLoading = false;
  String? errorMessage; // ✅ Store error message

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

    Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _authService.login({
        'username': usernameController.text.trim(),
        'password': passwordController.text.trim(),
      });

      print("Login Response: ${response.body}"); // ✅ Debug API response

      if (response.statusCode == 200) {
        final responseBody = response.body;
          print("Redirecting to OTP screen with message: ${responseBody['message']}");

          Get.offAllNamed(
            AppRoutes.otp,
            arguments: {
              'username': usernameController.text.trim(), // ✅ Pass username
              'message': responseBody['message'], // ✅ Pass message
            },
          );
      } else {
        print("Error Response: ${response.body}");
        setState(() => errorMessage = response.body['error'] ?? 'Login failed');
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => errorMessage = "An error occurred: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // ✅ Ensure content is scrollable
        child: Column(
          children: [
            // Background Image and Logo
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
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
                  Image.asset(
                    'assets/logo.png',
                    height: 130,
                    width: 130,
                  ),
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

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomInput(
                    label: 'Username',
                    controller: usernameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  CustomInput(
                    label: 'Password',
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    onSuffixIconPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // ✅ Implement forgot password functionality here
                      child: const Text('Forgot Password?', style: TextStyle(color: Colors.blue)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Error Message Display (Scrollable)
                  if (errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ),

                  // Login Button
                  CustomButton(
                    label: 'Login',
                    onPressed: isLoading ? null : _login,
                    isLoading: isLoading,
                    icon: Icons.login,
                  ),

                  const SizedBox(height: 16),

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Get.toNamed(AppRoutes.register),
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
