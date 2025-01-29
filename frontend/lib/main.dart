import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/schedule_service.dart';
import 'services/storage_service.dart';
import 'controllers/schedule_controller.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize GetX Services & Controllers
  Get.put(StorageService());
  Get.put(AuthService());
  Get.put(ScheduleService());
  Get.put(ScheduleController());

  print("App Initialized: All services are loaded");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // 
      getPages: AppRoutes.routes,
    );
  }
}
