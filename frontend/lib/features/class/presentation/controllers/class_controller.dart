import 'package:get/get.dart';
import '../../../class/data/models/class_model.dart';
import '../../../class/data/datasources/class_service.dart';

/// A GetX controller that manages the state of class sessions.
///
/// It provides methods to load, create, update, and delete classes.
/// The result is stored in an observable [classes] list.
class ClassController extends GetxController {
  final ClassService _classService = Get.find<ClassService>();

  /// A reactive list of classes for display in the UI.
  final RxList<ClassModel> classes = <ClassModel>[].obs;

  /// Loads classes from the server. If [scheduleId] is provided,
  /// fetches classes only for that schedule.
  Future<void> loadClasses({int? scheduleId}) async {
    try {
      final fetchedClasses = await _classService.getClasses(scheduleId: scheduleId);
      classes.assignAll(fetchedClasses);
    } catch (e) {
      Get.snackbar("Error", "Failed to load classes: $e");
    }
  }

  /// Creates a new class using the [classData].
  /// If successful, adds it to [classes].
  Future<ClassModel?> createClass(ClassModel classData) async {
    try {
      final newClass = await _classService.createClass(classData);
      classes.add(newClass);
      classes.refresh();
      Get.snackbar("Success", "Class created successfully!");
      return newClass;
    } catch (e) {
      Get.snackbar("Error", "Failed to create class: $e");
      return null;
    }
  }

  /// Updates an existing class using the [classData].
  /// If successful, replaces the old class instance in [classes].
  Future<ClassModel?> updateClass(ClassModel classData) async {
    try {
      final updatedClass = await _classService.updateClass(classData);

      final idx = classes.indexWhere((c) => c.id == updatedClass.id);
      if (idx != -1) {
        classes[idx] = updatedClass;
        classes.refresh();
      }
      Get.snackbar("Success", "Class updated successfully!");
      return updatedClass;
    } catch (e) {
      Get.snackbar("Error", "Failed to update class: $e");
      return null;
    }
  }

  /// Deletes the class identified by [classId] from the server
  /// and removes it from the [classes] list.
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
