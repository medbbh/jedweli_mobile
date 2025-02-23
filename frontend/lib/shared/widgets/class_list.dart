import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:jedweli/shared/widgets/show_class_dialog.dart';
import '../../features/class/presentation/controllers/class_controller.dart';
import '../../features/class/data/models/class_model.dart';

class ClassListScreen extends StatelessWidget {
  final List<ClassModel> classes;
  final String title;

  ClassListScreen({
    super.key,
    required this.classes,
    this.title = "Classes",
  });

  final ClassController _classController = Get.find<ClassController>();

  @override
  Widget build(BuildContext context) {
    return MaxWidthBox(
      maxWidth: 1200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: classes.isEmpty
            ? const Center(child: Text("No classes found."))
            : ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            final classItem = classes[index];
            return Dismissible(
              key: ValueKey(classItem.id ?? classItem.name),
              // Swipe right-to-left for update action.
              secondaryBackground: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.edit, color: Colors.white),
              ),
              // Swipe left-to-right for delete action.
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  final confirmed = await _showDeleteDialog(context, classItem);
                  if (confirmed == true) {
                    await _classController.deleteClass(classItem.id!);
                    classes.removeAt(index);
                    return true;
                  }
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  _showUpdateDialog(classItem, index);
                  return false;
                }
                return false;
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      classItem.instructor.isNotEmpty
                          ? classItem.instructor[0].toUpperCase()
                          : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    classItem.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              classItem.instructor,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            "${classItem.day} | ${classItem.startTime} - ${classItem.endTime}",
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.blue),
                      const SizedBox(height: 4),
                      Text(
                        classItem.location,
                        style: const TextStyle(fontSize: 12, color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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

  void _showUpdateDialog(ClassModel classItem, int index) async {
    final updatedClass = await showClassDialog(
      scheduleId: classItem.scheduleId,
      existingClass: classItem,
    );
    if (updatedClass != null) {
      classes[index] = updatedClass;
    }
  }
}
