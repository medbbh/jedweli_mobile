import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_input.dart';
import '../../widgets/custom_button.dart';
import '../../routes/app_routes.dart';

class OtpScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  final StorageService _storageService = Get.find<StorageService>();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? message = Get.arguments?['message'];
    final String? username = Get.arguments?['username']; // ✅ Get username

    if (message == null || username == null) {
      Get.offAllNamed(AppRoutes.login);
      return const Scaffold(
        body: Center(child: Text("Redirecting...")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(message, style: const TextStyle(fontSize: 16)), 
            const SizedBox(height: 16),
            CustomInput(
              label: 'Enter OTP',
              controller: otpController,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Verify',
              onPressed: () => _verifyOtp(username), 
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp(String username) async {
    final String otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the OTP.',
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
      return;
    }

    try {
      final response = await _authService.verifyOtp({
        'username': username, // ✅ Correct username usage
        'otp': otp,
      });

      print("OTP Response: ${response.body}"); // ✅ Debugging response

      if (response.statusCode == 200) {
        final responseBody = response.body;

        if (responseBody != null && responseBody.containsKey('access') && responseBody.containsKey('refresh')) {
          _storageService.saveTokens(responseBody['access'], responseBody['refresh']); // ✅ Save tokens

          print("Tokens stored successfully! Redirecting to Home...");
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar('Error', 'Invalid response from server.');
        }
      } else {
        print("Error Response: ${response.body}");
        Get.snackbar('Error', 'Verification failed.');
      }
    } catch (e) {
      print("Exception in OTP: $e");
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
