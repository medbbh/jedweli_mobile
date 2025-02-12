import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../models/class_model.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/constants.dart';

/// A remote data source handling class-related API calls.
/// 
/// Uses [GetConnect] for HTTP requests, pulling the access token from [StorageService].
class ClassService extends GetConnect {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseApiUrl;
    // You can remove defaultContentType if you're already sending JSON-encoded bodies
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  /// Helper method to inject the Bearer token into request headers.
  Map<String, String> _getHeaders() {
    final token = _storageService.getAccessToken();
    if (token == null) {
      throw Exception("[ClassService] No token found. User might not be logged in.");
    }
    return {'Authorization': 'Bearer $token'};
  }

  /// Creates a new class on the server using [classData].
  /// Returns a [ClassModel] of the newly created class, or throws an [Exception] on failure.
  Future<ClassModel> createClass(ClassModel classData) async {
    try {
      final response = await post(
        'classes/',
        {
          'schedule': classData.scheduleId,
          'name': classData.name,
          'instructor': classData.instructor,
          'day': classData.day,
          'start_time': classData.startTime,
          'end_time': classData.endTime,
          'location': classData.location,
        },
        headers: _getHeaders(),
      );
      debugPrint("[ClassService] createClass() -> ${response.statusCode}: ${response.body}");

      if (response.statusCode == 201 && response.body is Map) {
        return ClassModel.fromJson(response.body);
      } else {
        throw Exception('[ClassService] Failed to create class: ${response.body}');
      }
    } catch (e) {
      debugPrint("❌ [ClassService] createClass error: $e");
      rethrow;
    }
  }

  /// Updates an existing class on the server based on [classData].
  /// [classData.id] must not be null, or an [Exception] is thrown.
  /// Returns the updated [ClassModel] on success.
  Future<ClassModel> updateClass(ClassModel classData) async {
    if (classData.id == null) {
      throw Exception("Cannot update class with null ID");
    }

    // Use a typed PATCH request.
    final Response<Map<String, dynamic>> response = await patch<Map<String, dynamic>>(
      'classes/${classData.id}/', // Ensure your endpoint forms correctly with baseUrl.
      {
        'schedule': classData.scheduleId,
        'name': classData.name,
        'instructor': classData.instructor,
        'day': classData.day,
        'start_time': classData.startTime,
        'end_time': classData.endTime,
        'location': classData.location,
      },
      headers: _getHeaders(),
    );

    debugPrint("[ClassService] updateClass(${classData.id}) -> ${response.statusCode}: ${response.body}");

    // If the backend returns 200 with a valid body, parse it.
    if (response.statusCode == 200 && response.body != null) {
      return ClassModel.fromJson(response.body!);
    }
    // If backend returns 204 (No Content), assume the update succeeded.
    else if (response.statusCode == 204) {
      return classData;
    } else {
      throw Exception("Failed to update class: ${response.body}");
    }
  }



  /// Fetches classes from the server. If [scheduleId] is provided, fetches classes
  /// only for that schedule. Otherwise fetches all classes.
  /// Returns a list of [ClassModel] or throws an [Exception] on failure.
  Future<List<ClassModel>> getClasses({int? scheduleId}) async {
    final String endpoint = scheduleId != null
        ? 'classes?schedule=$scheduleId'
        : 'classes';

    try {
      final response = await get(endpoint, headers: _getHeaders());
      debugPrint("[ClassService] getClasses($scheduleId) -> ${response.statusCode}: ${response.body}");

      if (response.statusCode == 200 && response.body is List) {
        final data = response.body as List;
        return data.map((json) => ClassModel.fromJson(json)).toList();
      } else {
        throw Exception('[ClassService] Failed to fetch classes: ${response.body}');
      }
    } catch (e) {
      debugPrint("❌ [ClassService] getClasses error: $e");
      rethrow;
    }
  }

  /// Deletes a class identified by [classId].
  /// Throws an [Exception] if deletion fails.
  Future<void> deleteClass(int classId) async {
    try {
      final response = await delete(
        'classes/$classId/',
        headers: _getHeaders(),
      );
      debugPrint("[ClassService] deleteClass($classId) -> ${response.statusCode}");

      if (response.statusCode != 204) {
        throw Exception('[ClassService] Failed to delete class: ${response.body}');
      }
    } catch (e) {
      debugPrint("❌ [ClassService] deleteClass error: $e");
      rethrow;
    }
  }
}
