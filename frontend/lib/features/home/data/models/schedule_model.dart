import '../../../class/data/models/class_model.dart';

/// Represents a schedule with an [id], [title], and a list of [classes].
///
/// If you move to a full Clean Architecture, you'd have a `ScheduleEntity` in your domain
/// layer and a `.toEntity()` / `.fromEntity()` method here.
class ScheduleModel {
  final int id;
  final String title;
  final List<ClassModel> classes;

  ScheduleModel({
    required this.id,
    required this.title,
    required this.classes,
  });

  /// Factory constructor to create a [ScheduleModel] from JSON.
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      title: json['title'],
      classes: (json['classes'] as List)
          .map((classJson) => ClassModel.fromJson(classJson))
          .toList(),
    );
  }
}
