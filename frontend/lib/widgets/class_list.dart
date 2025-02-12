import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/widgets/show_class_dialog.dart';
import '../controllers/class_controller.dart';
import '../models/class_model.dart';

class ClassListScreen extends StatelessWidget {
  ClassListScreen({
    super.key,
    required this.classes,
    this.title = "Classes",
  });

  // A normal list of classes. If you need reactivity, pass an RxList and wrap with Obx.
  final List<ClassModel> classes;
  final String title;

  final ClassController _classController = Get.find<ClassController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: classes.isEmpty
          ? const Center(child: Text("No classes found."))
          : ListView.builder(
        itemCount: classes.length,
        itemBuilder: (context, index) {
          final classItem = classes[index];

          return Dismissible(
            key: ValueKey(classItem.id ?? classItem.name),
            // Swipe from left to right => Delete
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            // Swipe from right to left => Update
            secondaryBackground: Container(
              color: Colors.blue,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),

            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                // LEFT -> RIGHT => Delete
                final confirmed = await _showDeleteDialog(context, classItem);
                if (confirmed == true) {
                  // If confirmed, call the controller's delete
                  await _classController.deleteClass(classItem.id!);
                  classes.removeAt(index);
                  return true; // Actually remove the item from the list
                }
                return false;
              } else if (direction == DismissDirection.endToStart) {
                // RIGHT -> LEFT => Update
                _showUpdateDialog(classItem, index);
                return false; // Don't remove from list automatically
              }
              return false;
            },
            child: ListTile(
              title: Text(classItem.name),
              subtitle: Text("${classItem.day} | ${classItem.startTime} - ${classItem.endTime}"),
              trailing: Text(classItem.location),
            ),
          );
        },
      ),

    );
  }

  // Simple confirm dialog for deleting
  Future<bool?> _showDeleteDialog(BuildContext ctx, ClassModel classItem) {
    return showDialog<bool>(
      context: ctx,
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

  // Update an existing class
  void _showUpdateDialog(ClassModel classItem, int index) async {
    final updatedClass = await showClassDialog(
      scheduleId: classItem.scheduleId,
      existingClass: classItem
    );
    if (updatedClass != null) {
      // If updated, replace in local list
      classes[index] = updatedClass;
    }
  }
}
