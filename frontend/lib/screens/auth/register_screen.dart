// // screens/auth/register_screen.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../services/auth_service.dart';
// import '../../widgets/custom_input.dart';
// import '../../widgets/custom_button.dart';
// import '../../routes/app_routes.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();
//   final AuthService _authService = Get.find<AuthService>();

//   bool isPasswordVisible = false;
//   bool isConfirmPasswordVisible = false;
//   bool isLoading = false;

//   @override
//   void dispose() {
//     usernameController.dispose();
//     phoneController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _register() async {
//     if (!_validateInputs()) return;

//     setState(() => isLoading = true);
//     try {
//       final response = await _authService.register({
//         'username': usernameController.text.trim(),
//         'phone_number': phoneController.text.trim(),
//         'email': emailController.text.trim(),
//         'password': passwordController.text,
//         'confirm_password': confirmPasswordController.text,
//       });

//       if (response.statusCode == 201) {
//         Get.snackbar(
//           'Success',
//           'Registration successful',
//           backgroundColor: Colors.green[100],
//           colorText: Colors.green[800],
//         );
//         Get.offAllNamed(AppRoutes.login);
//       } else {
//         final error = response.body['error'] ?? 'Registration failed';
//         Get.snackbar(
//           'Error',
//           error,
//           backgroundColor: Colors.red[100],
//           colorText: Colors.red[800],
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred: $e',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.red[800],
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }

//   bool _validateInputs() {
//     if (usernameController.text.isEmpty ||
//         phoneController.text.isEmpty ||
//         emailController.text.isEmpty ||
//         passwordController.text.isEmpty ||
//         confirmPasswordController.text.isEmpty) {
//       Get.snackbar(
//         'Error',
//         'All fields are required',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.red[800],
//       );
//       return false;
//     }

//     if (passwordController.text != confirmPasswordController.text) {
//       Get.snackbar(
//         'Error',
//         'Passwords do not match',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.red[800],
//       );
//       return false;
//     }

//     if (!RegExp(r'^[2-4]\d{7}$').hasMatch(phoneController.text)) {
//       Get.snackbar(
//         'Error',
//         'Invalid phone number format',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.red[800],
//       );
//       return false;
//     }

//     if (!GetUtils.isEmail(emailController.text.trim())) {
//       Get.snackbar(
//         'Error',
//         'Invalid email format',
//         backgroundColor: Colors.red[100],
//         colorText: Colors.red[800],
//       );
//       return false;
//     }

//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Top Background Image with Logo
//             Container(
//               height: MediaQuery.of(context).size.height * 0.25,
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/background_image.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/logo.png',
//                     height: 130,
//                     width: 130,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Create Account',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: const EdgeInsets.all(24.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   CustomInput(
//                     label: 'Username',
//                     controller: usernameController,
//                     prefixIcon: Icons.person_outline,
//                   ),
//                   CustomInput(
//                     label: 'Phone Number',
//                     controller: phoneController,
//                     inputType: TextInputType.phone,
//                     prefixIcon: Icons.phone_outlined,
//                   ),
//                   CustomInput(
//                     label: 'Email Address',
//                     controller: emailController,
//                     inputType: TextInputType.emailAddress,
//                     prefixIcon: Icons.email_outlined,
//                   ),
//                   CustomInput(
//                     label: 'Password',
//                     controller: passwordController,
//                     obscureText: !isPasswordVisible,
//                     prefixIcon: Icons.lock_outline,
//                     suffixIcon: isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                     onSuffixIconPressed: () {
//                       setState(() {
//                         isPasswordVisible = !isPasswordVisible;
//                       });
//                     },
//                   ),
//                   CustomInput(
//                     label: 'Confirm Password',
//                     controller: confirmPasswordController,
//                     obscureText: !isConfirmPasswordVisible,
//                     prefixIcon: Icons.lock_outline,
//                     suffixIcon: isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                     onSuffixIconPressed: () {
//                       setState(() {
//                         isConfirmPasswordVisible = !isConfirmPasswordVisible;
//                       });
//                     },
//                   ),

//                   const SizedBox(height: 24),

//                   // Register Button using CustomButton
//                   CustomButton(
//                     label: 'Register',
//                     onPressed: isLoading ? null : _register,
//                     isLoading: isLoading,
//                     icon: Icons.person_add_outlined,
//                   ),

//                   const SizedBox(height: 24),

//                   // Login Link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text(
//                         'Already have an account? ',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       TextButton(
//                         onPressed: () => Get.offAllNamed(AppRoutes.login),
//                         child: const Text(
//                           'Login here',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
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
                  const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomInput(label: 'Username', controller: authController.usernameController, prefixIcon: Icons.person_outline),
                  CustomInput(label: 'Phone Number', controller: authController.phoneController, inputType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
                  CustomInput(label: 'Email Address', controller: authController.emailController, inputType: TextInputType.emailAddress, prefixIcon: Icons.email_outlined),
                  Obx(() => CustomInput(
                        label: 'Password',
                        controller: authController.passwordController,
                        obscureText: !authController.isPasswordVisible.value,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: authController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        onSuffixIconPressed: () {
                          authController.isPasswordVisible.toggle();
                        },
                      )),
                  Obx(() => CustomInput(
                        label: 'Confirm Password',
                        controller: authController.confirmPasswordController,
                        obscureText: !authController.isConfirmPasswordVisible.value,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: authController.isConfirmPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                        onSuffixIconPressed: () {
                          authController.isConfirmPasswordVisible.toggle();
                        },
                      )),
                  const SizedBox(height: 24),
                  Obx(() => CustomButton(
                        label: 'Register',
                        onPressed: authController.isLoading.value ? null : authController.register,
                        isLoading: authController.isLoading.value,
                        icon: Icons.person_add_outlined,
                      )),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () => Get.offAllNamed('/login'),
                        child: const Text('Login here', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
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
