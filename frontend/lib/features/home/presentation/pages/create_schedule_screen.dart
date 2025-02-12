import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

/// A simple screen that allows the user to create a new schedule by entering a title.
class CreateScheduleScreen extends StatelessWidget {
  const CreateScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScheduleController scheduleController = Get.find<ScheduleController>();
    final TextEditingController titleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomInput(
              label: "Schedule Title",
              controller: titleController,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: "Create",
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  Get.snackbar("Error", "Please enter a schedule title.");
                  return;
                }
                try {
                  await scheduleController.createSchedule(titleController.text.trim());
                  Get.snackbar("Success", "Schedule created!");
                  Get.back();
                } catch (e) {
                  Get.snackbar("Error", "Failed to create schedule: $e");
                }
              },
              icon: Icons.add,
              backgroundColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
