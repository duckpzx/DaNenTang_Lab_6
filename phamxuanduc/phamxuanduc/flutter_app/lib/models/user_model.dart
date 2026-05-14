class UserModel {
  final int id;
  final String username;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:        json['id'] as int,
      username:  json['username'] as String,
      role:      json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':        id,
    'username':  username,
    'role':      role,
    'createdAt': createdAt.toIso8601String(),
  };
}

class AuthResponse {
  final String token;
  final String username;
  final String role;
  final DateTime expiration;

  AuthResponse({
    required this.token,
    required this.username,
    required this.role,
    required this.expiration,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token:      json['token'] as String,
      username:   json['username'] as String,
      role:       json['role'] as String,
      expiration: DateTime.parse(json['expiration'] as String),
    );
  }
}
