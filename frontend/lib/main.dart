import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jedweli/controllers/auth_controller.dart';
import 'package:jedweli/controllers/class_controller.dart';
import 'package:jedweli/services/class_service.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/schedule_service.dart';
import 'services/storage_service.dart';
import 'controllers/schedule_controller.dart';
// import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // ✅ Initialize GetStorage before using it

  // ✅ Initialize GetX Services & Controllers
  Get.put(StorageService());
  Get.put(AuthService());
  Get.put(ScheduleService());
  Get.put(ClassService());

  Get.put(AuthController());
  Get.put(ScheduleController());
  Get.put(ClassController());


  print("App Initialized: All services are loaded");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash, 
      getPages: AppRoutes.routes,
    );
  }
}
