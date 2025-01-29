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
  final StorageService storageService = Get.put(StorageService());
  final ScheduleController scheduleController = Get.put(ScheduleController());
    return Drawer(
      child: Column(
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

          // My Schedules Section
          Obx(() => ExpansionTile(
                title: Text(
                    "📌 My Schedules (${scheduleController.schedules.length})"),
                initiallyExpanded: true,
                children: scheduleController.schedules.map((schedule) {
                  return InkWell(
                    onTap: () {
                    //  _scheduleController.selectSchedule(schedule);
                      // Navigate using named route and pass schedule.id as argument
                      print("id from drawe ${schedule.id}");
                      Get.toNamed(AppRoutes.scheduleDetail,
                          arguments: schedule.id,);
                      // Navigator.push(

                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => MySApp(
                      //               id: schedule.id,
                      //             )));
                    //  Get.back(); // Close drawer
                    },
                    child: ListTile(
                      title: Text(schedule.title),
                      // onTap: () {
                      //   _scheduleController.selectSchedule(schedule);
                      //   // Navigate using named route and pass schedule.id as argument
                      //   print("id from drawe ${schedule.id}");
                      //   // Get.toNamed(AppRoutes.scheduleDetail,
                      //   //     arguments: schedule.id);
                      //   Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //           builder: (context) => MySApp(
                      //                 id: schedule.id,
                      //               )));
                      //   Get.back(); // Close drawer
                      // },
                    ),
                  );
                }).toList(),
              )),

          // const Divider(),

          // Favorite Schedules Section
          Obx(() => ExpansionTile(
                title: Text(
                    "⭐ Favorite Schedules (${scheduleController.favoriteSchedules.length})"),
                initiallyExpanded: false,
                children: scheduleController.favoriteSchedules.map((schedule) {
                  return ListTile(
                    title: Text(schedule.title),
                    onTap: () {
                      scheduleController.selectSchedule(schedule);
                      // Navigate using named route and pass schedule.id as argument
                      Get.toNamed(AppRoutes.scheduleDetail,
                          arguments: schedule.id);
                      Get.back(); // Close drawer
                    },
                  );
                }).toList(),
              )),

          const Spacer(),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              storageService.clearTokens(); // Remove JWT token
              Get.offAllNamed(AppRoutes.login); // Navigate to login screen
            },
          ),
        ],
      ),
    );
  }
}
