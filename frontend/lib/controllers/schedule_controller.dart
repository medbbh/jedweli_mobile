import 'package:get/get.dart';
import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleController extends GetxController {
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  final RxList<ScheduleModel> _schedules = <ScheduleModel>[].obs;
  final Rxn<ScheduleModel> _selectedSchedule = Rxn<ScheduleModel>();

  List<ScheduleModel> get schedules => _schedules;
  // List<ScheduleModel> get favoriteSchedules => _favoriteSchedules;
  Rxn<ScheduleModel> get selectedSchedule => _selectedSchedule;
  var favoriteSchedules = <ScheduleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // If you WANT to fetch immediately at app start, you can do:
    // fetchSchedules();
    // fetchFavoriteSchedules();
  }

  Future<void> refreshData() async {
    await fetchSchedules();
    await fetchFavoriteSchedules();
  }

  // ✅ Fetch all schedules
    // ✅ Fetch all schedules
  Future<void> fetchSchedules() async {
    try {
      print("Fetching schedules from API...");
      final fetchedSchedules = await _scheduleService.fetchSchedules();
      print("🌟Fetched schedules count🌟: ${fetchedSchedules.length}");

      if (fetchedSchedules.isNotEmpty) {
        _schedules.assignAll(fetchedSchedules);
        print("Schedules updated in controller.");
        // Auto-select the first if none selected
        _selectedSchedule.value ??= _schedules.first;
      } else {
        print("No schedules found.");
        _schedules.clear();
      }
    } catch (e) {
      print("Error fetching schedules: $e");
      Get.snackbar("Error", "Failed to load schedules: $e");
    }
  }

  // ✅ Fetch schedule by ID
  Future<ScheduleModel?> getScheduleById(int scheduleId) async {
    try {
      final schedule = await _scheduleService.fetchScheduleById(scheduleId);
      if (schedule != null) {
        _selectedSchedule.value = schedule;
      }
      return schedule;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch schedule: $e");
      return null;
    }
  }

  // ✅ Fetch favorite schedules
  Future<void> fetchFavoriteSchedules() async {
    try {
      final favoriteEntries = await _scheduleService.getFavoriteEntries();
      final favoriteIds = favoriteEntries.map((f) => f.scheduleId).toList();
      final favoriteSchedulesList =
          schedules.where((s) => favoriteIds.contains(s.id)).toList();
      favoriteSchedules.assignAll(favoriteSchedulesList);
      print("Fetched favorite schedules: ${favoriteSchedules.length}");
    } catch (e) {
      print("Error fetching favorite schedules: $e");
      Get.snackbar("Error", "Failed to fetch favorite schedules: $e");
    }
  }

  // ✅ check if in favorites
  bool isFavorite(int scheduleId) {
    return favoriteSchedules.any((s) => s.id == scheduleId);
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

void addToFavorites(int scheduleId) async {
  try {
    // Call the service method
    await _scheduleService.addFavorite(scheduleId);
    
    // Refresh the favorites from the backend
    await fetchFavoriteSchedules();

    Get.snackbar(
      "Success",
      "Added to favorites",
    );
  } catch (e) {
    Get.snackbar(
      "Error",
      "Failed to add to favorites: $e",
    );
  }
}

  void removeFromFavorites(int scheduleId) async {
    try {
      await _scheduleService.removeFavorite(scheduleId);
      favoriteSchedules.removeWhere((s) => s.id == scheduleId);
      Get.snackbar("Success", "Removed from favorites");
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
      print("failed to add class $e");
      Get.snackbar("Error", "Failed to add class");
    }
  }
}
