import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String token;
  final User user;

  UserModel({required this.token, required this.user});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}
