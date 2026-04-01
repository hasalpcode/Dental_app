import 'dart:convert';

import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';

  static Future<void> saveUser(User user, String token) async {
    final prefs = await SharedPreferences.getInstance();

    // Stocke l'utilisateur en JSON
    final userJson = jsonEncode({
      'userId': user.userId,
      'username': user.username,
      'email': user.email,
      'role': {
        'roleid': user.role.roleid,
        'name': user.role.name,
      },
      'dateInscription': user.dateInscription.toIso8601String(),
    });

    await prefs.setString(_keyUser, userJson);
    await prefs.setString(_keyToken, token);
  }

  /// Récupère l'utilisateur
  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_keyUser);
    if (userJson == null) return null;

    final Map<String, dynamic> json = jsonDecode(userJson);

    return User(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      role: Role(
        roleid: json['role']['roleid'],
        name: json['role']['name'],
      ),
      dateInscription: DateTime.parse(json['dateInscription']),
    );
  }

  /// Récupère le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Supprime l'utilisateur (logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyToken);
  }
}
