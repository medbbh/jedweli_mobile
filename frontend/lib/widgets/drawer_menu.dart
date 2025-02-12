// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/schedule_controller.dart';
// import '../services/storage_service.dart';
// import '../routes/app_routes.dart';
//
// class DrawerMenu extends StatelessWidget {
//   const DrawerMenu({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final StorageService storageService = Get.find<StorageService>();
//     final ScheduleController scheduleController = Get.find<ScheduleController>();
//
//     return Drawer(
//       child: Column(
//         children: [
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blueAccent,
//             ),
//             child: Center(
//               child: Text(
//                 "Schedules",
//                 style: TextStyle(fontSize: 24, color: Colors.white),
//               ),
//             ),
//           ),
//
//
//           Obx(() {
//             if (scheduleController.schedules.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }
//
//             return ExpansionTile(
//               title: Text(
//                 "📌 My Schedules (${scheduleController.schedules.length})",
//               ),
//               initiallyExpanded: true,
//               children: scheduleController.schedules.map((schedule) {
//                 return ListTile(
//                   title: Text(schedule.title),
//                   onTap: () {
//                     scheduleController.selectSchedule(schedule);
//
//                     Get.back();
//
//                     Future.delayed(Duration.zero, () {
//                       Get.toNamed(AppRoutes.home, arguments: schedule.id);
//                     });
//                   },
//                 );
//               }).toList(),
//             );
//           }),
//
//           Obx(() {
//             if (scheduleController.favoriteSchedules.isEmpty) {
//               return const Center(child: Text("No favorites yet."));
//             }
//
//             return ExpansionTile(
//               title: Text(
//                 "⭐ Favorite Schedules (${scheduleController.favoriteSchedules.length})",
//               ),
//               initiallyExpanded: false,
//               children: scheduleController.favoriteSchedules.map((schedule) {
//                 return ListTile(
//                   title: Text(schedule.title),
//                   onTap: () {
//                     // Same logic for favorites
//                     scheduleController.selectSchedule(schedule);
//                     Get.back();
//                     Future.delayed(Duration.zero, () {
//                       Get.toNamed(AppRoutes.scheduleDetail, arguments: schedule.id);
//                     });
//                   },
//                 );
//               }).toList(),
//             );
//           }),
//
//           const Spacer(),
//
//           // Logout Button
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.red),
//             title: const Text("Logout", style: TextStyle(color: Colors.red)),
//             onTap: () {
//               storageService.clearTokens();
//               Get.offAllNamed(AppRoutes.login);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }


// drawer_menu.dart
// widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../services/storage_service.dart';
import '../routes/app_routes.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = Get.find<StorageService>();
    final ScheduleController scheduleController = Get.find<ScheduleController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove any default padding
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blueAccent,
            ),
            child: Center(
              child: Text(
                "Schedules",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),

          Obx(() {
            if (scheduleController.schedules.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No schedules available."),
              );
            }

            return ExpansionTile(
              title: Text(
                "📌 My Schedules (${scheduleController.schedules.length})",
              ),
              initiallyExpanded: true,
              children: scheduleController.schedules.map((schedule) {
                final isFav = scheduleController.isFavorite(schedule.id);
                return ListTile(
                  title: Text(schedule.title),
                  onTap: () {
                    scheduleController.selectSchedule(schedule);
                    Get.back();
                    Future.delayed(Duration.zero, () {
                      Get.toNamed(AppRoutes.home, arguments: schedule.id);
                    });
                  },
                  trailing: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (isFav) {
                        scheduleController.removeFromFavorites(schedule.id);
                      } else {
                        scheduleController.addToFavorites(schedule.id);
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }),

          Obx(() {
            if (scheduleController.favoriteSchedules.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No favorites yet."),
              );
            }

            return ExpansionTile(
              title: Text(
                "⭐ Favorite Schedules (${scheduleController.favoriteSchedules.length})",
              ),
              initiallyExpanded: false,
              children: scheduleController.favoriteSchedules.map((schedule) {
                return ListTile(
                  title: Text(schedule.title),
                  onTap: () {
                    scheduleController.selectSchedule(schedule);
                    Get.back();
                    Future.delayed(Duration.zero, () {
                      Get.toNamed(AppRoutes.scheduleDetail, arguments: schedule.id);
                    });
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      scheduleController.removeFromFavorites(schedule.id);
                    },
                  ),
                );
              }).toList(),
            );
          }),

          // const Spacer(),
          SizedBox(height: 30),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              storageService.clearTokens();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
