import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../../../../routes/app_routes.dart';
import 'create_schedule_screen.dart';

/// Displays a list of all schedules retrieved by [ScheduleController].
///
/// Tapping on a schedule navigates to the schedule detail (HomeScreen) with [AppRoutes.scheduleDetail].
class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheduleController = Get.find<ScheduleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Schedules'),
        centerTitle: true,
      ),
      body: Obx(() {
        final allSchedules = scheduleController.schedules;
        if (allSchedules.isEmpty) {
          return const Center(
            child: Text('No schedules found'),
          );
        }

        return ListView.builder(
          itemCount: allSchedules.length,
          itemBuilder: (context, index) {
            final schedule = allSchedules[index];
            return ListTile(
              title: Text(schedule.title),
              subtitle: Text('Schedule ID: ${schedule.id}'),
              onTap: () {
                scheduleController.selectSchedule(schedule);
                Get.toNamed(
                  AppRoutes.scheduleDetail,
                  arguments: schedule.id,
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(schedule.id),
              ),
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

  /// Shows a confirmation dialog, then deletes the schedule via [ScheduleController].
  void _confirmDelete(int scheduleId) {
    Get.defaultDialog(
      title: 'Delete Schedule',
      middleText: 'Are you sure you want to delete this schedule?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        final scheduleController = Get.find<ScheduleController>();
        scheduleController.deleteSchedule(scheduleId);
      },
    );
  }
}
