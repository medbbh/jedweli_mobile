import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/controllers/schedule_controller.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storageService = Get.find<StorageService>();
  final ScheduleController _scheduleController = Get.find<ScheduleController>();


  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print("Initializing app...");

      // ✅ Ensure GetStorage is fully loaded
      await Future.delayed(const Duration(seconds: 2)); // Simulated splash delay
      // ✅ Fetch schedules at startup
      await _scheduleController.fetchSchedules();
      await Get.putAsync(() async => StorageService()); // ✅ Ensure StorageService is loaded

      // ✅ Check if user is logged in
      final bool isLoggedIn = _storageService.isLoggedIn();
      print("User logged in: $isLoggedIn");

      if (isLoggedIn) {
        Get.offAllNamed(AppRoutes.home); // ✅ Navigate to home if token exists
      } else {
        Get.offAllNamed(AppRoutes.login); // ✅ Navigate to login otherwise
      }
    } catch (e) {
      print("Error during initialization: $e");
      Get.offAllNamed(AppRoutes.login); // ✅ Fallback to login on error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          width: 300,

        ),
      ),
    );
  }
}
