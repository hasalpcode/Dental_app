class User {
  final int userId;
  final String username;
  final String email;
  final Role role;
  final DateTime dateInscription;
  final String? token;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.dateInscription,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        userId: json['userId'],
        username: json['username'] ?? '',
        email: json['email'] ?? '',
        role: Role.fromJson(json['role']),
        dateInscription: DateTime.parse(json['dateInscription']),
        token: json['token']);
  }
}

class Role {
  final int roleid;
  final String name;

  Role({required this.roleid, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      roleid: json['roleid'],
      name: json['name'] ?? '',
    );
  }
}
