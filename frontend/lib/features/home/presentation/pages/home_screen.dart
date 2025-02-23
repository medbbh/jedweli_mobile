import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:jedweli/shared/widgets/show_class_dialog.dart';
import 'package:jedweli/shared/widgets/class_list.dart';
import 'package:jedweli/shared/widgets/drawer_menu.dart';
import 'package:jedweli/shared/widgets/custom_button.dart';
import 'package:jedweli/routes/app_routes.dart';
import '../controllers/schedule_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {
    // Check for an optional schedule ID argument.
    final int? scheduleId = Get.arguments as int?;

    if (scheduleId != null) {
      _scheduleController.getScheduleById(scheduleId).then((foundSchedule) {
        if (foundSchedule == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar("Error", "Schedule not found.");
          });
        }
      });
    }

    return SafeArea(
      child: Scaffold(
        // A colorful AppBar with an icon and centered title.
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.schedule, color: Colors.white),
              SizedBox(width: 8),
              Text(
                "My Schedules",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 4,
          backgroundColor: Colors.blue,
        ),
        drawer: const DrawerMenu(),
        // Add a gradient background to give the home screen some life.
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blue.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: MaxWidthBox(
            maxWidth: 1200,
            child: Obx(() {
              final schedule = _scheduleController.selectedSchedule.value;
              if (schedule == null) {
                return const Center(
                  child: Text(
                    "Select a schedule from the drawer or create a new one.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.blueGrey),
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A styled card for the schedule title with an icon.
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              schedule.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // The list of classes.
                  Expanded(child: ClassListScreen(classes: schedule.classes)),
                  // Action buttons at the bottom.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomButton(
                          width: 180,
                          label: "Create Class",
                          onPressed: () => _addClass(schedule.id),
                          icon: Icons.add,
                          backgroundColor: Colors.green,
                        ),
                        CustomButton(
                          width: 180,
                          label: "Share Schedule",
                          onPressed: () => Get.toNamed(
                              AppRoutes.shareSchedule, arguments: schedule),
                          icon: Icons.share,
                          backgroundColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  void _addClass(int scheduleId) async {
    final newClass = await showClassDialog(scheduleId: scheduleId);
    if (newClass != null) {
      await _scheduleController.addClassToSchedule(
        scheduleId: scheduleId,
        name: newClass.name,
        instructor: newClass.instructor,
        day: newClass.day,
        startTime: newClass.startTime,
        endTime: newClass.endTime,
        location: newClass.location,
      );
      // Use update() on the reactive selectedSchedule to force a UI rebuild.
      _scheduleController.selectedSchedule.update((s) {
        if (s != null) {
          s.classes.add(newClass);
        }
      });
      Get.snackbar("Success", "Class added successfully!");
    }
  }
}
