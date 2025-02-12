class ClassModel {
  final int? id;
  final int scheduleId;
  final String name;
  final String instructor;
  final String day;
  final String startTime;
  final String endTime;
  final String location;

  ClassModel({
    this.id,
    required this.scheduleId,
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
      scheduleId: json['schedule'],
      name: json['name'],
      instructor: json['instructor'],
      day: json['day'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schedule': scheduleId,
    'name': name,
    'instructor': instructor,
    'day': day,
    'start_time': startTime,
    'end_time': endTime,
    'location': location,
  };

  ClassModel copyWith({
    int? id,
    int? scheduleId,
    String? name,
    String? instructor,
    String? day,
    String? startTime,
    String? endTime,
    String? location,
  }) {
    return ClassModel(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
    );
  }
}
