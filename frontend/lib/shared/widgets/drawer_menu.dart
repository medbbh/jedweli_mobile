import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
import 'package:jedweli/features/favorites/presentation/controllers/favorite_controller.dart';

// Services & Routes
import 'package:jedweli/core/services/storage_service.dart';
import 'package:jedweli/routes/app_routes.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final scheduleController = Get.find<ScheduleController>();
    final favoriteController = Get.find<FavoriteController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header with Logo and Title
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),

            // Expanded section for main content
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // My Schedules Section
                  Obx(() {
                    final allSchedules = scheduleController.schedules;
                    final validSchedules =
                    allSchedules.where((s) => s != null).toList();
                    if (validSchedules.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No schedules available."),
                      );
                    }
                    return ExpansionTile(
                      leading: const Icon(Icons.folder_open,
                          color: Colors.blueAccent),
                      title: Text("My Schedules (${validSchedules.length})"),
                      initiallyExpanded: true,
                      children: validSchedules.map((schedule) {
                        final scheduleId = schedule.id;
                        final isFav = favoriteController.isFavorite(scheduleId);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          title: Text(schedule.title),
                          onTap: () {
                            scheduleController.selectSchedule(schedule);
                            Get.back(); // Close the drawer
                            Future.delayed(Duration.zero, () {
                              Get.toNamed(AppRoutes.home,
                                  arguments: scheduleId);
                            });
                          },
                          trailing: IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
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
                    final favoriteSchedules = favoriteEntries
                        .map((fav) => scheduleController.schedules
                        .firstWhereOrNull((s) => s.id == fav.scheduleId))
                        .where((s) => s != null)
                        .toList();
                    return ExpansionTile(
                      leading:
                      const Icon(Icons.star, color: Colors.amber),
                      title: Text(
                          "Favorite Schedules (${favoriteSchedules.length})"),
                      initiallyExpanded: false,
                      children: favoriteSchedules.map((schedule) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4),
                          title: Text(schedule!.title),
                          onTap: () {
                            scheduleController.selectSchedule(schedule);
                            Get.back();
                            Future.delayed(Duration.zero, () {
                              Get.toNamed(AppRoutes.scheduleDetail,
                                  arguments: schedule.id);
                            });
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            onPressed: () {
                              favoriteController.removeFavorite(schedule.id);
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  // New Schedule Button
                  ListTile(
                    leading: const Icon(Icons.add, color: Colors.green),
                    title: const Text("New Schedule"),
                    onTap: () {
                      Get.toNamed(AppRoutes.createSchedule);
                    },
                  ),
                  // Shared With Me
                  ListTile(
                    leading:
                    const Icon(Icons.group, color: Colors.orange),
                    title: const Text("Shared With Me"),
                    onTap: () {
                      Get.toNamed(AppRoutes.sharedSchedules);
                    },
                  ),
                ],
              ),
            ),
            // Divider and Logout button fixed at the bottom
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                storageService.clearTokens();
                Get.offAllNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
