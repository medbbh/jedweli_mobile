import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/schedule_controller.dart';
import '../../routes/app_routes.dart';
import 'create_schedule_screen.dart';

class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleController scheduleController = Get.find<ScheduleController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Schedules'), centerTitle: true),
      body: Obx(() {
        print("Schedules length: ${scheduleController.schedules.length}"); // ✅ Debug UI state

        if (scheduleController.schedules.isEmpty) {
          return const Center(child: Text('No schedules found'));
        }

        return ListView.builder(
          itemCount: scheduleController.schedules.length,
          itemBuilder: (context, index) {
            final schedule = scheduleController.schedules[index];
            return ListTile(
              title: Text(schedule.title),
              subtitle: Text('Schedule ID: ${schedule.id}'),
              onTap: () {
                scheduleController.selectSchedule(schedule);
                Get.toNamed(AppRoutes.scheduleDetail, arguments: schedule.id);
              },
            );
          },
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreateScheduleScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(int scheduleId) {
    Get.defaultDialog(
      title: 'Delete Schedule',
      middleText: 'Are you sure you want to delete this schedule?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        final ScheduleController scheduleController = Get.find<ScheduleController>();
        scheduleController.deleteSchedule(scheduleId);
      },
    );
  }
}
