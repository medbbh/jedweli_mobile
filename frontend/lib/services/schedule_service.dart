import 'package:get/get.dart';
import '../models/favorite_model.dart';
import '../models/schedule_model.dart';
import '../models/class_model.dart';
import 'storage_service.dart';
import '../utils/constants.dart';

class ScheduleService extends GetConnect {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseApiUrl; // ✅ Ensure this is correct
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  // ✅ Helper Function to Get Headers with Token
  Map<String, String> _getHeaders() {
    final token = _storageService.getAccessToken();
    print("Authorization Token: $token"); // ✅ Debugging token

    if (token == null) {
      throw Exception("No token found. User might not be logged in.");
    }
    return {'Authorization': 'Bearer $token'};
  }

  // ✅ Fetch All Schedules
  Future<List<ScheduleModel>> fetchSchedules() async {
    try {
      final response = await get('schedules/', headers: _getHeaders());
      print("Fetch Schedules Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return (response.body as List)
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
      }
      throw Exception("Failed to fetch schedules: ${response.body}");
    } catch (e) {
      print("Error fetching schedules: $e");
      return [];
    }
  }

  // ✅ Fetch Schedule by ID
  Future<ScheduleModel?> fetchScheduleById(int scheduleId) async {
    try {
      final response = await get('schedules/$scheduleId/', headers: _getHeaders());

      if (response.statusCode == 200) {
        return ScheduleModel.fromJson(response.body);
      }
      throw Exception("Failed to fetch schedule: ${response.body}");
    } catch (e) {
      print("Error fetching schedule by ID: $e");
      return null;
    }
  }

  // ✅ Fetch Favorite Schedules
  Future<List<ScheduleModel>> fetchFavorites() async {
    try {
      final response = await get('favorites/', headers: _getHeaders());

      if (response.statusCode == 200) {
        return (response.body as List)
            .map((json) => ScheduleModel.fromJson(json))
            .toList();
      }
      throw Exception("Failed to fetch favorite schedules: ${response.body}");
    } catch (e) {
      print("Error fetching favorite schedules: $e");
      return [];
    }
  }

  // ✅ Add Schedule to Favorites
  Future<List<FavoriteModel>> getFavoriteEntries() async {
    final response = await get(
      'favorites/',
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.body;
      return data.map((json) => FavoriteModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch favorite entries: ${response.body}');
    }
  }

  Future<void> addFavorite(int scheduleId) async {
    final response = await post(
      'favorites/',
      {'schedule': scheduleId},
      headers: _getHeaders(),
    );

    // Treat 201 (created) or 200 (already exists with a message) as success.
    if (response.statusCode == 201 || 
        (response.statusCode == 200 && response.body['message'] != null)) {
      // Success – do nothing (or you could log the message if needed)
      return;
    } else {
      throw Exception('Failed to add favorite: ${response.body}');
    }
  }

  Future<void> removeFavorite(int scheduleId) async {
    final favorites = await getFavoriteEntries();
    final favoriteEntry = favorites.firstWhere(
          (f) => f.scheduleId == scheduleId,
      orElse: () => throw Exception('Favorite entry not found for schedule $scheduleId'),
    );

    final response = await delete(
      'favorites/${favoriteEntry.id}/',
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to remove favorite: ${response.body}');
    }
  }

  // Create a New Schedule
  Future<ScheduleModel> createSchedule(String title) async {
    final response = await post(
      'schedules/',
      {'title': title},
      headers: _getHeaders(),
    );

    if (response.statusCode == 201) {
      return ScheduleModel.fromJson(response.body);
    } else {
      throw Exception('Failed to create schedule: ${response.body}');
    }
  }

  // ✅ Delete a Schedule
  Future<void> deleteSchedule(int scheduleId) async {
    final response = await delete('schedules/$scheduleId', headers: _getHeaders());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete schedule: ${response.body}');
    }
  }

  // ✅ Add a Class to a Schedule
  Future<ClassModel> createClass({
    required int scheduleId,
    required String name,
    required String instructor,
    required String day,
    required String startTime,
    required String endTime,
    required String location,
  }) async {
    final response = await post(
      'classes/',
      {
        'schedule': scheduleId,
        'name': name,
        'instructor': instructor,
        'day': day,
        'start_time': startTime,
        'end_time': endTime,
        'location': location
      },
      headers: _getHeaders(),
    );

    if (response.statusCode == 201) {
      return ClassModel.fromJson(response.body);
    } else {
      throw Exception('Failed to add class: ${response.body}');
    }
  }
}
