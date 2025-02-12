class FavoriteModel {
  final int id;
  final int scheduleId;
  final DateTime addedAt;

  FavoriteModel({
    required this.id,
    required this.scheduleId,
    required this.addedAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      scheduleId: json['schedule'],
      addedAt: DateTime.parse(json['added_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'schedule': scheduleId,
    'added_at': addedAt.toIso8601String(),
  };
}
