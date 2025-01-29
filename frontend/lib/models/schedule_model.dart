import 'class_model.dart';

class ScheduleModel {
  final int id;
  final String title;
  final List<ClassModel> classes;

  ScheduleModel({required this.id, required this.title, required this.classes});

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
