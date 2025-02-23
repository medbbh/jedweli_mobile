import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/routes/app_routes.dart';
import '../controllers/schedule_controller.dart';
import '../../../../shared/widgets/custom_input.dart';
import '../../../../shared/widgets/custom_button.dart';

class CreateScheduleScreen extends StatelessWidget {
  const CreateScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController scheduleController = Get.find<ScheduleController>();
    final TextEditingController titleController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Schedule"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Large calendar icon to add life to the screen
                  Icon(
                    Icons.calendar_today,
                    size: 48,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "New Schedule",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        Get.toNamed(AppRoutes.home);
                      } catch (e) {
                        Get.snackbar("Error", "Failed to create schedule: $e");
                      }
                    },
                    // Updated button icon for added flair
                    icon: Icons.check_circle_outline,
                    backgroundColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
