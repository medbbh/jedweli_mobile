import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
import 'package:jedweli/core/services/storage_service.dart';
import 'package:jedweli/routes/app_routes.dart';

/// A splash screen that initializes the app and navigates to the appropriate screen
/// based on the user’s authentication status.
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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

  /// Initializes the application:
  /// - Simulates a splash delay
  /// - Fetches schedules from the server
  /// - Checks if the user is logged in
  /// - Navigates to Home if logged in; otherwise, navigates to Login.
  Future<void> _initializeApp() async {
    try {
      debugPrint("[SplashScreen] Initializing app...");
      await Future.delayed(const Duration(seconds: 2)); // Simulated delay

      // Ensure schedules are fetched
      await _scheduleController.fetchSchedules();

      // Also load favorites (if using a separate FavoriteController)
      final favoriteController = Get.find<FavoriteController>();
      await favoriteController.loadFavorites();

      final bool isLoggedIn = _storageService.isLoggedIn();
      debugPrint("[SplashScreen] User logged in: $isLoggedIn");

      if (isLoggedIn) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint("[SplashScreen] Error during initialization: $e");
      Get.offAllNamed(AppRoutes.login);
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
