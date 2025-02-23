import 'package:get/get.dart';
import 'package:jedweli/features/home/data/models/schedule_model.dart';
import 'package:jedweli/features/home/data/datasources/schedule_service.dart';

class SharedScheduleController extends GetxController {
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  var sharedSchedules = <ScheduleModel>[].obs;
  var isLoading = false.obs;
  final Rxn<ScheduleModel> sharedSchedule = Rxn<ScheduleModel>(); // For shared schedule details

  /// Fetch shared schedules from the backend.
  Future<void> fetchSharedSchedules() async {
    try {
      isLoading.value = true;
      final response = await _scheduleService.getSharedWithMeSchedules();
      if (response.statusCode == 200 && response.body is List) {
        sharedSchedules.assignAll(
          (response.body as List)
              .map((json) => ScheduleModel.fromJson(json))
              .toList(),
        );
      } else {
        Get.snackbar("Error", "Failed to fetch shared schedules");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch shared schedules: $e");
    } finally {
      isLoading.value = false;
    }
  }
  /// Fetch a shared schedule by its unique shareable ID.
  Future<void> fetchSharedScheduleByShareableId(String shareableId) async {
    try {
      final fetchedSchedule = await _scheduleService.fetchSharedScheduleByShareableId(shareableId);
      if (fetchedSchedule != null) {
        sharedSchedule.value = fetchedSchedule;
      } else {
        Get.snackbar("Error", "Shared schedule not found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch shared schedule: $e");
    }
  }
}
