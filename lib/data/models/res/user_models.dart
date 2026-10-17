class UserModels {
  User? user;
  String? token;
  String? message;
  int? statusCode;

  UserModels({this.user, this.token, this.message, this.statusCode});

  factory UserModels.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final userJson = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : null;

    return UserModels(
      user: userJson == null ? null : User.fromJson(userJson),
      token: (json['token'] ??
              json['access_token'] ??
              data['token'] ??
              data['access_token'])
          ?.toString(),
      message: (json['message'] ?? data['message'])?.toString(),
      statusCode: statusCode,
    );
  }

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

class User {
  final int? id;
  final String? name;
  final String? shortName;
  final String? email;
  final String? username;
  final String? status;
  final String? avatar;
  final int? employeeId;
  final String? role;
  final String? avatarUrl;

  User({
    this.id,
    this.name,
    this.shortName,
    this.email,
    this.username,
    this.status,
    this.avatar,
    this.employeeId,
    this.role,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      shortName: json['short_name']?.toString(),
      email: json['email']?.toString(),
      username: json['username']?.toString(),
      status: json['status']?.toString(),
      avatar: json['avatar']?.toString(),
      employeeId: _toInt(json['employee_id']),
      role: json['role']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
