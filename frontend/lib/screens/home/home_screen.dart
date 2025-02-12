import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../models/schedule_model.dart';
import '../../widgets/show_class_dialog.dart';
import '../../widgets/class_list.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/custom_button.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {

    final int? scheduleId = Get.arguments as int?;

    if (scheduleId != null) {
      final foundSchedule = _scheduleController.getScheduleById(scheduleId);
      _scheduleController.selectSchedule(foundSchedule as ScheduleModel?);
    }else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Schedule not found.");
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
                schedule.title, // ✅ Fixed: No .value needed
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            Expanded(child: ClassListScreen(classes: schedule.classes,)),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    width: 180,
                    label: "Create Class",
                    // onPressed: () => Get.to(() => const CreateScheduleScreen()),
                    onPressed: () => _addClass(schedule.id),
                    icon: Icons.add,
                    backgroundColor: Colors.green,
                  ),
                  CustomButton(
                    label: "Share",
                    onPressed: () {
                      String link = "${Constants.appBaseUrl}/schedule/${schedule.id}";
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
