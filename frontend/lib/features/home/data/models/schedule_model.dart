import '../../../class/data/models/class_model.dart';

class ScheduleModel {
  final int id;
  final int owner;
  final String title;
  final bool isPublic;
  final String shareableId;
  final List<ClassModel> classes;

  ScheduleModel({
    required this.id,
    required this.owner,
    required this.title,
    required this.isPublic,
    required this.shareableId,
    required this.classes,
  });

  /// Factory constructor to create a [ScheduleModel] from JSON.
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'],
      owner: json['owner'],
      title: json['title'],
      isPublic: json['is_public'] ?? false,
      shareableId: json['shareable_id'] ?? "",
      classes: (json['classes'] as List)
          .map((classJson) => ClassModel.fromJson(classJson))
          .toList(),
    );
  }
}
