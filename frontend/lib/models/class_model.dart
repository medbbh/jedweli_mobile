class ClassModel {
  final int id;
  final String name;
  final String instructor;
  final String day;
  final String startTime;
  final String endTime;
  final String location;

  ClassModel({
    required this.id,
    required this.name,
    required this.instructor,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'],
      name: json['name'],
      instructor: json['instructor'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
    );
  }
}
