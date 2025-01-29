import 'package:get/get.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleController extends GetxController {
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  final RxList<ScheduleModel> _schedules = <ScheduleModel>[].obs;
  final RxList<ScheduleModel> _favoriteSchedules = <ScheduleModel>[].obs;
  final Rxn<ScheduleModel> _selectedSchedule = Rxn<ScheduleModel>();

  List<ScheduleModel> get schedules => _schedules;
  List<ScheduleModel> get favoriteSchedules => _favoriteSchedules;
  Rxn<ScheduleModel> get selectedSchedule => _selectedSchedule;

  @override
  void onInit() {
    super.onInit();
    fetchSchedules();
    fetchFavorites();
  }

  // ✅ Fetch all schedules
  Future<void> fetchSchedules() async {
    try {
      print("Fetching schedules from API...");

      final fetchedSchedules = await _scheduleService.fetchSchedules();

      print("Fetched schedules count: ${fetchedSchedules.length}");

      if (fetchedSchedules.isNotEmpty) {
        _schedules.assignAll(fetchedSchedules);
        print("Schedules updated in controller.");

        // Auto-select first schedule if none is selected
        _selectedSchedule.value ??= _schedules.first;
      } else {
        print("No schedules found.");
      }
    } catch (e) {
      print("Error fetching schedules: $e");
      Get.snackbar("Error", "Failed to load schedules: $e");
    }
  }

  // ✅ Fetch schedule by ID
  Future<void> getScheduleById(int scheduleId) async {
    try {
      final schedule = await _scheduleService.fetchScheduleById(scheduleId);
      if (schedule != null) {
        _selectedSchedule.value = schedule;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch schedule: $e");
    }
  }

  // ✅ Fetch favorite schedules
  Future<void> fetchFavorites() async {
    try {
      final fetchedFavorites = await _scheduleService.fetchFavorites();
      _favoriteSchedules.assignAll(fetchedFavorites);
    } catch (e) {
      Get.snackbar("Error", "Failed to load favorite schedules: $e");
    }
  }

  // ✅ Select a schedule safely
  void selectSchedule(ScheduleModel? schedule) {
    _selectedSchedule.value = schedule;
  }

  // ✅ Create a new schedule
  Future<void> createSchedule(String title) async {
    try {
      final newSchedule = await _scheduleService.createSchedule(title);
      _schedules.add(newSchedule);
      Get.snackbar("Success", "Schedule created successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to create schedule: $e");
    }
  }

  // ✅ Delete a schedule
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await _scheduleService.deleteSchedule(scheduleId);
      _schedules.removeWhere((s) => s.id == scheduleId);
      if (_selectedSchedule.value?.id == scheduleId) {
        _selectedSchedule.value = null;
      }
      Get.snackbar("Success", "Schedule deleted successfully!");
    } catch (e) {
      Get.snackbar("Error", "Failed to delete schedule: $e");
    }
  }

  // ✅ Add a schedule to favorites
  Future<void> addToFavorites(int scheduleId) async {
    try {
      await _scheduleService.addToFavorites(scheduleId);
      fetchFavorites(); // Refresh favorite schedules
      Get.snackbar("Success", "Schedule added to favorites!");
    } catch (e) {
      Get.snackbar("Error", "Failed to add to favorites: $e");
    }
  }

  // ✅ Remove a schedule from favorites
  Future<void> removeFromFavorites(int scheduleId) async {
    try {
      await _scheduleService.removeFromFavorites(scheduleId);
      fetchFavorites(); // Refresh favorite schedules
      Get.snackbar("Success", "Schedule removed from favorites!");
    } catch (e) {
      Get.snackbar("Error", "Failed to remove from favorites: $e");
    }
  }

  // ✅ Add a class to a schedule
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
        _schedules[index].classes.add(newClass);
        _schedules.refresh();
        Get.snackbar("Success", "Class added successfully!");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add class: $e");
    }
  }
}
