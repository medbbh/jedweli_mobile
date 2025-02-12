import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/shared/widgets/show_class_dialog.dart';
import '../../features/class/presentation/controllers/class_controller.dart';
import '../../features/class/data/models/class_model.dart';

/// Displays a list of classes with swipe-to-delete and swipe-to-update actions.
/// 
/// If the list is empty, a "No classes found" message is displayed.
/// Swipe from left to right to delete a class (with a confirmation dialog),
/// and swipe from right to left to update a class.
class ClassListScreen extends StatelessWidget {
  /// Creates a [ClassListScreen].
  /// 
  /// The [classes] list is expected to be non-reactive. If you need reactivity,
  /// consider passing an RxList and wrapping this widget with an [Obx].
  final List<ClassModel> classes;
  final String title;

  ClassListScreen({
    Key? key,
    required this.classes,
    this.title = "Classes",
  }) : super(key: key);

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
                  // Swipe from left to right for Delete action.
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  // Swipe from right to left for Update action.
                  secondaryBackground: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      // Delete action
                      final confirmed = await _showDeleteDialog(context, classItem);
                      if (confirmed == true) {
                        await _classController.deleteClass(classItem.id!);
                        classes.removeAt(index);
                        return true;
                      }
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      // Update action
                      _showUpdateDialog(classItem, index);
                      return false;
                    }
                    return false;
                  },
                  child: ListTile(
                    title: Text(classItem.name),
                    subtitle: Text(
                      "${classItem.day} | ${classItem.startTime} - ${classItem.endTime}",
                    ),
                    trailing: Text(classItem.location),
                  ),
                );
              },
            ),
    );
  }

  /// Displays a confirmation dialog before deleting a class.
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
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the update dialog to update an existing class.
  void _showUpdateDialog(ClassModel classItem, int index) async {
    final updatedClass = await showClassDialog(
      scheduleId: classItem.scheduleId,
      existingClass: classItem,
    );
    if (updatedClass != null) {
      // Replace the class in the local list.
      classes[index] = updatedClass;
    }
  }
}
