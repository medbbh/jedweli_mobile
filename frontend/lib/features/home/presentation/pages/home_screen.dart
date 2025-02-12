import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../../data/models/schedule_model.dart';
import '../../../../shared/widgets/show_class_dialog.dart';
import '../../../../shared/widgets/class_list.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/utils/constants.dart';

/// The main "Home" screen that displays the currently selected schedule.
/// Allows creating a new class and sharing the schedule link.
class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {
    // Check if a schedule ID was passed in
    final int? scheduleId = Get.arguments as int?;

    if (scheduleId != null) {
      // Attempt to load that schedule
      _scheduleController.getScheduleById(scheduleId).then((foundSchedule) {
        if (foundSchedule == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar("Error", "Schedule not found.");
          });
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Schedules")),
      drawer: const DrawerMenu(),
      body: Obx(() {
        final schedule = _scheduleController.selectedSchedule.value;
        if (schedule == null) {
          return const Center(
            child: Text(
              "Select a schedule from the drawer or create a new one.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                schedule.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ClassListScreen(classes: schedule.classes),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                    label: "Share",
                    onPressed: () {
                      final link = "${Constants.appBaseUrl}/schedule/${schedule.id}";
                      Get.snackbar("Share", "Link copied: $link");
                    },
                    icon: Icons.share,
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Shows a dialog to add a new class, then calls [addClassToSchedule] on success.
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
      Get.snackbar("Success", "Class added successfully!");
    }
  }
}
