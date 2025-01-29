import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../widgets/class_list.dart';
import '../../widgets/drawer_menu.dart';
import '../../widgets/custom_button.dart';
import 'create_schedule_screen.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedules")),
      drawer: const DrawerMenu(),
      body: Obx(() {
        // ✅ Use ?. to avoid null errors
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

            Expanded(child: ClassList(schedule.classes)),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    label: "Create Schedule",
                    onPressed: () => Get.to(() => const CreateScheduleScreen()),
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreateScheduleScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
