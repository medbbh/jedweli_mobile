import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
import '../../features/favorites/presentation/controllers/favorite_controller.dart';

// Services & Routes
import '../../core/services/storage_service.dart';
import '../../routes/app_routes.dart';

/// A navigation drawer listing the user’s schedules and favorites.
/// 
/// - Schedules come from [ScheduleController].
/// - Favorites come from [FavoriteController].
/// - Includes a logout option at the bottom.
class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final scheduleController = Get.find<ScheduleController>();
    final favoriteController = Get.find<FavoriteController>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Center(
              child: Text(
                "Schedules",
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ),

          // My Schedules Section
          Obx(() {
            final allSchedules = scheduleController.schedules;
            if (allSchedules.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No schedules available."),
              );
            }

            return ExpansionTile(
              title: Text(
                "📌 My Schedules (${allSchedules.length})",
              ),
              initiallyExpanded: true,
              children: allSchedules.map((schedule) {
                final scheduleId = schedule.id;
                final isFav = favoriteController.isFavorite(scheduleId);

                return ListTile(
                  title: Text(schedule.title),
                  onTap: () {
                    // When tapping a schedule, select it and navigate to details
                    scheduleController.selectSchedule(schedule);
                    Get.back(); // Close the drawer
                    Future.delayed(Duration.zero, () {
                      // Navigate to your schedule detail/home screen
                      Get.toNamed(AppRoutes.home, arguments: scheduleId);
                    });
                  },
                  trailing: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (isFav) {
                        favoriteController.removeFavorite(scheduleId);
                      } else {
                        favoriteController.addFavorite(scheduleId);
                      }
                    },
                  ),
                );
              }).toList(),
            );
          }),

          // Favorite Schedules Section
          Obx(() {
            final favoriteEntries = favoriteController.favoriteEntries;
            if (favoriteEntries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("No favorites yet."),
              );
            }

            // Build a list of full ScheduleModels for each favorite entry
            // so we can display schedule titles, IDs, etc.
            final favoriteSchedules = favoriteEntries
                .map((fav) => scheduleController.schedules
                    .firstWhereOrNull((s) => s.id == fav.scheduleId))
                .whereType() // Filter out any null if schedule not found
                .toList();

            return ExpansionTile(
              title: Text(
                "⭐ Favorite Schedules (${favoriteSchedules.length})",
              ),
              initiallyExpanded: false,
              children: favoriteSchedules.map((schedule) {
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
                      favoriteController.removeFavorite(schedule.id);
                    },
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 30),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Clear tokens and navigate to login
              storageService.clearTokens();
              Get.offAllNamed(AppRoutes.login);
            },
          ),
        ],
      ),
    );
  }
}
