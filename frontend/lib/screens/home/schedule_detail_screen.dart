import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/schedule_model.dart';
import '../../widgets/add_class_dialog.dart';
import '../../controllers/schedule_controller.dart';
import '../../models/class_model.dart';

class ScheduleDetailScreen extends StatelessWidget {
  ScheduleDetailScreen({super.key});

  final ScheduleController _scheduleController = Get.find<ScheduleController>();

  @override
  Widget build(BuildContext context) {
    final int? scheduleId = Get.arguments as int?;

    if (scheduleId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "No schedule ID provided.");
        Get.back();
      });
      return Scaffold(body: Container());
    }

    final ScheduleModel? schedule;
    try {
      schedule = _scheduleController.getScheduleById(scheduleId) as ScheduleModel?;
      _scheduleController.selectSchedule(schedule);
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar("Error", "Schedule not found.");
        Get.back();
      });
      return Scaffold(body: Container());
    }

    return Scaffold(
      appBar: AppBar(title: Text("Schedule: ${schedule?.title}")),
      body: schedule!.classes.isEmpty
          ? const Center(child: Text("No classes in this schedule."))
          : ListView.builder(
        itemCount: schedule.classes.length,
        itemBuilder: (context, index) {
          final classItem = schedule?.classes[index];
          return ListTile(
            title: Text(classItem!.name),
            subtitle: Text('${classItem.day} | ${classItem.startTime} - ${classItem.endTime}'),
            trailing: Text(classItem.location),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addClass(schedule!.id),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addClass(int scheduleId) async {
    final newClass = await showDialog<ClassModel>(
      context: Get.context!,
      builder: (context) => AddClassDialog(scheduleId: scheduleId),
    );

    if (newClass != null) {
      _scheduleController.addClassToSchedule(
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
