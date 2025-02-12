import 'package:get/get.dart';
import '../models/class_model.dart';
import 'storage_service.dart';
import '../utils/constants.dart';

class ClassService extends GetConnect {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseApiUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Map<String, String> _getHeaders() {
    final token = _storageService.getAccessToken();
    if (token == null) {
      throw Exception("No token found. User might not be logged in.");
    }
    return {'Authorization': 'Bearer $token'};
  }

  /// Create a new class on the server
  Future<ClassModel> createClass(ClassModel classData) async {
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

    if (response.statusCode == 201) {
      return ClassModel.fromJson(response.body);
    } else {
      throw Exception('Failed to create class: ${response.body}');
    }
  }

  Future<ClassModel> updateClass(ClassModel classData) async {
    if (classData.id == null) {
      throw Exception("Cannot update class with null ID");
    }

    final response = await put(
      'classes/${classData.id}/',
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

    if (response.statusCode == 200) {
      return ClassModel.fromJson(response.body);
    } else {
      print('Failed to update class: ${response.body}');
      throw Exception('Failed to update class: ${response.body}');
    }
  }

  /// Fetch all classes for a given schedule, or all classes if no scheduleId is needed
  Future<List<ClassModel>> getClasses({int? scheduleId}) async {
    final String endpoint =
        scheduleId != null ? 'classes?schedule=$scheduleId' : 'classes';

    final response = await get(endpoint, headers: _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = response.body;
      return data.map((json) => ClassModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch classes: ${response.body}');
    }
  }

  /// Delete a class on the server
  Future<void> deleteClass(int classId) async {
    final response = await delete(
      'classes/$classId/',
      headers: _getHeaders(),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete class: ${response.body}');
    }
  }
}
