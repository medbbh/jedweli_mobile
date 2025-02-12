/// Represents the user data returned from the server or stored locally.
///
/// If you introduce a domain `UserEntity`, consider adding a `.toEntity()` method
/// here to map between model and entity.
class UserModel {
  final int id;
  final String username;
  final String email;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
  });

  /// Creates a [UserModel] from JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
    );
  }

  /// Converts this [UserModel] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
    };
  }
}
