// controllers/class_controller.dart

import 'package:get/get.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';

class ClassController extends GetxController {
  final ClassService _classService = Get.find<ClassService>();

  // A local list of classes to display in the UI
  final RxList<ClassModel> classes = <ClassModel>[].obs;

  /// Load classes from the server (optionally for a given schedule)
  Future<void> loadClasses({int? scheduleId}) async {
    try {
      final fetched = await _classService.getClasses(scheduleId: scheduleId);
      classes.assignAll(fetched);
    } catch (e) {
      Get.snackbar("Error", "Failed to load classes: $e");
    }
  }

  /// Create a new class
  Future<ClassModel?> createClass(ClassModel classData) async {
    try {
      final newClass = await _classService.createClass(classData);
      // Add to local list
      classes.add(newClass);
      classes.refresh();
      Get.snackbar("Success", "Class created successfully!");
      return newClass;
    } catch (e) {
      Get.snackbar("Error", "Failed to create class: $e");
      return null;
    }
  }

  /// Update an existing class
  Future<ClassModel?> updateClass(ClassModel classData) async {
    try {
      final updatedClass = await _classService.updateClass(classData);

      // Replace it in local list
      final idx = classes.indexWhere((c) => c.id == updatedClass.id);
      if (idx != -1) {
        classes[idx] = updatedClass;
        classes.refresh();
      }
      Get.snackbar("Success", "Class updated successfully!");
      return updatedClass;
    } catch (e) {
      print("Failed to update class: $e");
      Get.snackbar("Error", "Failed to update class: $e");
      return null;
    }
  }

  /// Delete a class
  Future<void> deleteClass(int classId) async {
    try {
      await _classService.deleteClass(classId);
      classes.removeWhere((c) => c.id == classId);
      Get.snackbar("Success", "Class deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete class: $e");
    }
  }
}
