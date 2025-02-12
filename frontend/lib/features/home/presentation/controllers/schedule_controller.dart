import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../data/models/schedule_model.dart';
import '../../data/datasources/schedule_service.dart';

/// A GetX controller to manage schedules, favorites, and schedule details.
///
/// Holds an observable list of all [schedules], a [selectedSchedule],
/// and [favoriteSchedules].
class ScheduleController extends GetxController {
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  final RxList<ScheduleModel> _schedules = <ScheduleModel>[].obs;
  final Rxn<ScheduleModel> _selectedSchedule = Rxn<ScheduleModel>();
  final RxList<ScheduleModel> favoriteSchedules = <ScheduleModel>[].obs;

  List<ScheduleModel> get schedules => _schedules;
  Rxn<ScheduleModel> get selectedSchedule => _selectedSchedule;

  @override
  void onInit() {
    super.onInit();
    // Optionally fetch data immediately
    // fetchSchedules();
    // fetchFavoriteSchedules();
  }

  /// Convenience method to load both schedules and favorites in one go.
  Future<void> refreshData() async {
    await fetchSchedules();
  }

  // -----------------------
  // Fetching Schedules
  // -----------------------

  /// Retrieves all schedules from the API, storing them in [_schedules].
  ///
  /// If no schedules are returned, clears the list.
  Future<void> fetchSchedules() async {
    try {
      debugPrint("[ScheduleController] Fetching schedules from API...");
      final fetchedSchedules = await _scheduleService.fetchSchedules();
      debugPrint("[ScheduleController] Schedules fetched: ${fetchedSchedules.length}");

      if (fetchedSchedules.isNotEmpty) {
        _schedules.assignAll(fetchedSchedules);
        // Auto-select the first if none selected
        _selectedSchedule.value ??= _schedules.first;
      } else {
        _schedules.clear();
        debugPrint("[ScheduleController] No schedules found.");
      }
    } catch (e) {
      debugPrint("❌ [ScheduleController] Error fetching schedules: $e");
      Get.snackbar("Error", "Failed to load schedules: $e");
    }
  }

  /// Fetches a schedule by ID and sets it as [_selectedSchedule].
  Future<ScheduleModel?> getScheduleById(int scheduleId) async {
    try {
      final schedule = await _scheduleService.fetchScheduleById(scheduleId);
      if (schedule != null) {
        _selectedSchedule.value = schedule;
      }
      return schedule;
    } catch (e) {
      debugPrint("❌ [ScheduleController] Error fetching schedule by ID: $e");
      Get.snackbar("Error", "Failed to fetch schedule: $e");
      return null;
    }
  }

  /// Selects a [schedule] to be the current [selectedSchedule].
  void selectSchedule(ScheduleModel? schedule) {
    _selectedSchedule.value = schedule;
  }

  // -----------------------
  // Creating / Deleting Schedules
  // -----------------------

  /// Creates a new schedule with [title] and adds it to the [_schedules] list.
  Future<void> createSchedule(String title) async {
    try {
      final newSchedule = await _scheduleService.createSchedule(title);
      _schedules.add(newSchedule);
      Get.snackbar("Success", "Schedule created successfully!");
    } catch (e) {
      debugPrint("❌ [ScheduleController] Error creating schedule: $e");
      Get.snackbar("Error", "Failed to create schedule: $e");
    }
  }

  /// Deletes an existing schedule by [scheduleId], removing it from the local list.
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await _scheduleService.deleteSchedule(scheduleId);
      _schedules.removeWhere((s) => s.id == scheduleId);

      // If the selected schedule was deleted, reset it.
      if (_selectedSchedule.value?.id == scheduleId) {
        _selectedSchedule.value = null;
      }
      Get.snackbar("Success", "Schedule deleted successfully!");
    } catch (e) {
      debugPrint("❌ [ScheduleController] Error deleting schedule: $e");
      Get.snackbar("Error", "Failed to delete schedule: $e");
    }
  }

  // -----------------------
  // Classes
  // -----------------------

  /// Adds a new class to an existing schedule, then updates the local state.
  Future<void> addClassToSchedule({
    required int scheduleId,
    required String name,
    required String instructor,
    required String day,
    required String startTime,
    required String endTime,
    required String location,
  }) async {
    try {
      final newClass = await _scheduleService.createClass(
        scheduleId: scheduleId,
        name: name,
        instructor: instructor,
        day: day,
        startTime: startTime,
        endTime: endTime,
        location: location,
      );

      final index = _schedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        // Mutate the classes list, then refresh.
        _schedules[index].classes.add(newClass);
        _schedules.refresh();
        Get.snackbar("Success", "Class added successfully!");
      }
    } catch (e) {
      debugPrint("❌ [ScheduleController] Error adding class: $e");
      Get.snackbar("Error", "Failed to add class: $e");
    }
  }
}
