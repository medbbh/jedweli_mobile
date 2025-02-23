// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
//
// // Feature Services & Controllers
// import 'package:jedweli/features/auth/data/datasources/auth_service.dart';
// import 'package:jedweli/features/favorites/data/datasources/favorite_service.dart';
// import 'package:jedweli/features/favorites/presentation/controllers/favorite_controller.dart';
// import 'package:jedweli/features/home/data/datasources/schedule_service.dart';
// import 'package:jedweli/features/class/data/datasources/class_service.dart';
// import 'package:jedweli/core/services/storage_service.dart';
//
// import 'package:jedweli/features/auth/presentation/controllers/auth_controller.dart';
// import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
// import 'package:jedweli/features/class/presentation/controllers/class_controller.dart';
// import 'package:jedweli/features/home/presentation/controllers/share_controller.dart';
// import 'package:jedweli/features/home/presentation/controllers/shared_schedule_controller.dart';
//
// import 'package:jedweli/routes/app_routes.dart';
//
// /// The entry point of the application.
// ///
// /// Initializes GetStorage, registers all necessary services and controllers,
// /// and runs the [MyApp] widget.
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init(); // Initialize GetStorage before use
//
//   // Use Get.putAsync for services that need asynchronous initialization.
//   await Get.putAsync<StorageService>(() async => StorageService());
//
//   // Register remote data sources
//   Get.put(AuthService());
//   Get.put(ScheduleService());
//   Get.put(FavoriteService());
//   Get.put(ClassService());
//
//   // Register controllers
//   Get.put(AuthController());
//   Get.put(ScheduleController());
//   Get.put(ShareController());
//   Get.put(SharedScheduleController());
//   Get.put(FavoriteController());
//   Get.put(ClassController());
//
//   debugPrint("App Initialized: All services are loaded");
//
//   runApp(const MyApp());
// }
//
// /// The root widget for the application.
// /// Uses [GetMaterialApp] for routing and state management.
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Jedweli Mobile',
//       debugShowCheckedModeBanner: false,
//       initialRoute: AppRoutes.splash,
//       getPages: AppRoutes.routes,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_framework/responsive_framework.dart';

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
import 'package:jedweli/features/home/presentation/controllers/share_controller.dart';
import 'package:jedweli/features/home/presentation/controllers/shared_schedule_controller.dart';

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
  Get.put(ShareController());
  Get.put(SharedScheduleController());
  Get.put(FavoriteController());
  Get.put(ClassController());

  debugPrint("App Initialized: All services are loaded");

  runApp(const MyApp());
}

/// The root widget for the application.
/// Uses [GetMaterialApp] for routing and state management.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jedweli Mobile',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Matches your logo's blue color.
      ),
      builder: (context, widget) => ResponsiveBreakpoints.builder(
        child: widget!,
        breakpoints: [
          const Breakpoint(start: 0, end: 450, name: MOBILE),
          const Breakpoint(start: 451, end: 800, name: TABLET),
          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
        ],
      ),

    );
  }
}
