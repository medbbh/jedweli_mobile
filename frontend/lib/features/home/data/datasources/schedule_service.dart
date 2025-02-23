import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/schedule_model.dart';
import '../../../class/data/models/class_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/constants.dart';

/// A remote data source that manages Schedules and Favorites API calls.
///
/// Uses GetConnect for HTTP requests and extracts an Authorization header
/// from the [StorageService] tokens.
class ScheduleService extends GetConnect {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    // Base URL for your schedule endpoints
    httpClient.baseUrl = Constants.baseApiUrl;
    // You can remove defaultContentType if you're manually setting JSON
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  /// Helper method to inject the Bearer token into request headers.
  Map<String, String> _getHeaders() {
    final token = _storageService.getAccessToken();
    debugPrint("[ScheduleService] Using Authorization Token: $token");

    if (token == null) {
      throw Exception("[ScheduleService] No token found. User might not be logged in.");
    }
    return {'Authorization': 'Bearer $token'};
  }

  // -----------------------
  // Schedule CRUD Operations
  // -----------------------

  /// Fetches all schedules from the server.
  /// Returns a list of [ScheduleModel] or throws an [Exception] on failure.
  Future<List<ScheduleModel>> fetchSchedules() async {
    try {
      final response = await get('schedules/', headers: _getHeaders());
      debugPrint("[ScheduleService] fetchSchedules() -> ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 && response.body is List) {
        return (response.body as List)
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
      }
      throw Exception("Failed to fetch schedules: ${response.body}");
    } catch (e) {
      debugPrint("❌ [ScheduleService] Error fetching schedules: $e");
      return [];
    }
  }

  /// Fetches a single schedule by its [scheduleId].
  /// Returns a [ScheduleModel], or null if not found or on error.
  Future<ScheduleModel?> fetchScheduleById(int scheduleId) async {
    try {
      final response = await get('schedules/$scheduleId/', headers: _getHeaders());
      debugPrint("[ScheduleService] fetchScheduleById($scheduleId) -> ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 && response.body is Map) {
        return ScheduleModel.fromJson(response.body);
      }
      throw Exception("Failed to fetch schedule: ${response.body}");
    } catch (e) {
      debugPrint("❌ [ScheduleService] Error fetching schedule by ID: $e");
      return null;
    }
  }

  /// Creates a new schedule with the given [title].
  /// Returns the created [ScheduleModel] on success, throws otherwise.
  Future<ScheduleModel> createSchedule(String title) async {
    try {
      final response = await post(
        'schedules/',
        {'title': title},
        headers: _getHeaders(),
      );
      debugPrint("[ScheduleService] createSchedule($title) -> ${response.statusCode}: ${response.body}");

      if (response.statusCode == 201 && response.body is Map) {
        return ScheduleModel.fromJson(response.body);
      }
      throw Exception("Failed to create schedule: ${response.body}");
    } catch (e) {
      debugPrint("❌ [ScheduleService] createSchedule error: $e");
      throw Exception("Failed to create schedule: $e");
    }
  }

  /// Deletes a schedule by its [scheduleId].
  /// Throws an [Exception] if the deletion fails.
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      final response = await delete('schedules/$scheduleId', headers: _getHeaders());
      debugPrint("[ScheduleService] deleteSchedule($scheduleId) -> ${response.statusCode}");

      if (response.statusCode != 204) {
        throw Exception("Failed to delete schedule: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ [ScheduleService] deleteSchedule error: $e");
      throw Exception("Failed to delete schedule: $e");
    }
  }

    /// Toggle schedule sharing (Enable/Disable public sharing)
  Future<Response> toggleSharing(int scheduleId) async {
    return await post("schedules/$scheduleId/toggle-sharing/", {}, headers: _getHeaders(),);
  }

  /// Fetch list of users with access to a schedule
  Future<Response> getScheduleAccessList(int scheduleId) async {
    return await get("schedules/$scheduleId/access-list/", headers: _getHeaders(),);
  }

  /// Grant access to a user (View/Edit)
  Future<Response> grantAccess(int scheduleId, String username, String permission) async {
    return await post(
      "schedules/$scheduleId/access/",
      {"username": username, "permission": permission},
      headers: _getHeaders(),
    );
  }

  /// Revoke access from a user
  Future<Response> revokeAccess(int scheduleId, String username) async {
    return await delete("schedules/$scheduleId/access/$username/",headers: _getHeaders(),);
  }

  /// Fetch shared-with-me schedules for the authenticated user.
  Future<Response> getSharedWithMeSchedules() async {
    return await get("shared-with-me/", headers: _getHeaders());
  }

  Future<ScheduleModel?> fetchSharedScheduleByShareableId(String shareableId) async {
    try {
      final response = await get("shared/$shareableId/", headers: _getHeaders());
      debugPrint("[ScheduleService] fetchSharedScheduleByShareableId($shareableId) -> ${response.statusCode}: ${response.body}");
      if (response.statusCode == 200 && response.body is Map) {
        return ScheduleModel.fromJson(response.body);
      }
      throw Exception("Failed to fetch shared schedule: ${response.body}");
    } catch (e) {
      debugPrint("❌ [ScheduleService] Error fetching shared schedule: $e");
      return null;
    }
  }


  // -----------------------
  // Classes
  // -----------------------

  /// Creates a new [ClassModel] in the specified [scheduleId] with all required fields.
  /// Returns the created [ClassModel] on success.
  Future<ClassModel> createClass({
    required int scheduleId,
    required String name,
    required String instructor,
    required String day,
    required String startTime,
    required String endTime,
    required String location,
  }) async {
    try {
      final response = await post(
        'classes/',
        {
          'schedule': scheduleId,
          'name': name,
          'instructor': instructor,
          'day': day,
          'start_time': startTime,
          'end_time': endTime,
          'location': location,
        },
        headers: _getHeaders(),
      );
      debugPrint("[ScheduleService] createClass($scheduleId) -> ${response.statusCode}: ${response.body}");

      if (response.statusCode == 201 && response.body is Map) {
        return ClassModel.fromJson(response.body);
      }
      throw Exception('Failed to add class: ${response.body}');
    } catch (e) {
      debugPrint("❌ [ScheduleService] createClass error: $e");
      throw Exception("Failed to add class: $e");
    }
  }
}
