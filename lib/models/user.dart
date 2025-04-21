class User {
  final String id;
  final String username;
  final String email;
  final String? name;
  final String? avatar;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.name,
    this.avatar,
    required this.role,
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? name,
    String? avatar,
    String? role,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      role: json['role'] ?? 'Reader',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'avatar': avatar,
      'role': role,
    };
  }
}
