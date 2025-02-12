import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Feature Services & Controllers
import 'package:jedweli/features/auth/data/datasources/auth_service.dart';
import 'package:jedweli/features/favorites/data/datasources/favorite_service.dart';
import 'package:jedweli/features/favorites/presentation/controllers/favorite_controller.dart';
import 'package:jedweli/features/home/data/datasources/schedule_service.dart';
import 'package:jedweli/features/class/data/datasources/class_service.dart';
import 'package:jedweli/core/services/storage_service.dart';

import 'package:jedweli/features/auth/presentation/controllers/auth_controller.dart';
import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
import 'package:jedweli/features/class/presentation/controllers/class_controller.dart';

import 'package:jedweli/routes/app_routes.dart';

/// The entry point of the application.
///
/// Initializes GetStorage, registers all necessary services and controllers,
/// and runs the [MyApp] widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init(); // Initialize GetStorage before use

  // Use Get.putAsync for services that need asynchronous initialization.
  await Get.putAsync<StorageService>(() async => StorageService());

  // Register remote data sources
  Get.put(AuthService());
  Get.put(ScheduleService());
  Get.put(FavoriteService());
  Get.put(ClassService());

  // Register controllers
  Get.put(AuthController());
  Get.put(ScheduleController());
  Get.put(FavoriteController());
  Get.put(ClassController());

  debugPrint("App Initialized: All services are loaded");

  runApp(const MyApp());
}

/// The root widget for the application.
/// Uses [GetMaterialApp] for routing and state management.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jedweli Mobile',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
