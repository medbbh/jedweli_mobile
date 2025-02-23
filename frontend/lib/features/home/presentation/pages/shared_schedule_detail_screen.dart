import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/features/home/data/models/schedule_model.dart';
import 'package:jedweli/features/class/data/models/class_model.dart';
import 'package:jedweli/features/class/presentation/controllers/class_controller.dart';
import 'package:jedweli/features/home/presentation/controllers/schedule_controller.dart';
import 'package:jedweli/shared/widgets/show_class_dialog.dart';
import '../controllers/shared_schedule_controller.dart';

class SharedScheduleDetailScreen extends StatelessWidget {
  SharedScheduleDetailScreen({Key? key}) : super(key: key);

  final ScheduleController scheduleController = Get.find<ScheduleController>();
  final SharedScheduleController sharedScheduleController =
  Get.find<SharedScheduleController>();
  final ClassController classController = Get.find<ClassController>();

  // For now, assume editing is allowed.
  final bool editable = true;

  @override
  Widget build(BuildContext context) {
    // Expect the shareable ID as an argument.
    final String shareableId = Get.arguments as String;
    sharedScheduleController.fetchSharedScheduleByShareableId(shareableId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shared Schedule Detail",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Obx(() {
            final ScheduleModel? schedule =
                sharedScheduleController.sharedSchedule.value;
            if (schedule == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Hero animation and fixed height.
                Hero(
                  tag: "sharedSchedule_${schedule.shareableId}",
                  child: Container(
                    width: double.infinity,
                    height: 200, // fixed height to prevent overflow
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule,
                            size: 48, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          schedule.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _buildClassList(schedule.classes, editable)),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: editable
          ? FloatingActionButton(
        onPressed: () {
          _addClass(sharedScheduleController.sharedSchedule.value?.id);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildClassList(List<ClassModel> classes, bool editable) {
    if (classes.isEmpty) {
      return const Center(child: Text("No classes available."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final classItem = classes[index];
        return editable
            ? Dismissible(
          key: ValueKey(classItem.id ?? classItem.name),
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              final confirmed =
              await _showDeleteDialog(context, classItem);
              if (confirmed == true) {
                await classController.deleteClass(classItem.id!);
                classes.removeAt(index);
                return true;
              }
              return false;
            } else if (direction == DismissDirection.endToStart) {
              _showUpdateDialog(context, classItem, index, classes);
              return false;
            }
            return false;
          },
          child: _buildClassTile(classItem),
        )
            : _buildClassTile(classItem);
      },
    );
  }

  Widget _buildClassTile(ClassModel classItem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: const Icon(Icons.class_, color: Colors.blue),
        ),
        title: Text(
          classItem.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            "${classItem.day} | ${classItem.startTime} - ${classItem.endTime}"),
        trailing: Text(classItem.location),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context, ClassModel classItem) {
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Class"),
        content: Text("Are you sure you want to delete '${classItem.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, ClassModel classItem, int index,
      List<ClassModel> classes) async {
    final updatedClass = await showClassDialog(
      scheduleId: classItem.scheduleId,
      existingClass: classItem,
    );
    if (updatedClass != null) {
      classes[index] = updatedClass;
      // Optionally refresh state if needed.
    }
  }

  void _addClass(int? scheduleId) async {
    if (scheduleId == null) return;
    final newClass = await showClassDialog(scheduleId: scheduleId);
    if (newClass != null) {
      await scheduleController.addClassToSchedule(
        scheduleId: scheduleId,
        name: newClass.name,
        instructor: newClass.instructor,
        day: newClass.day,
        startTime: newClass.startTime,
        endTime: newClass.endTime,
        location: newClass.location,
      );
      // Update the reactive shared schedule so the UI rebuilds automatically.
      sharedScheduleController.sharedSchedule.update((s) {
        if (s != null) {
          s.classes.add(newClass);
        }
      });
      Get.snackbar("Success", "Class added successfully!");
    }
  }
}
