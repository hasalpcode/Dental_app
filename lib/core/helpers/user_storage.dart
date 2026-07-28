import 'dart:convert';

import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  static const String _keyUser = 'user';
  static const String _keyToken = 'token';
  static const String _keySubdomain = 'tenant_subdomain';

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
      token: prefs.getString(_keyToken),
    );
  }

  /// Récupère le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      return jsonDecode(utf8.decode(base64Url.decode(normalized)));
    } catch (_) {
      return null;
    }
  }

  /// Vérifie si un token JWT est encore valide (non expiré)
  static bool isTokenValid(String token) {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return false;

    final exp = payload['exp'];
    if (exp == null) return true;

    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isBefore(expiry);
  }

  /// Tenant courant, lu depuis le claim `tenantId` du JWT stocké (posé par
  /// le backend au login/signup — pas besoin de le stocker séparément).
  static Future<String?> getTenantId() async {
    final token = await getToken();
    if (token == null) return null;
    final payload = _decodeJwtPayload(token);
    return payload?['tenantId'] as String?;
  }

  /// Supprime l'utilisateur (logout). Le sous-domaine est volontairement
  /// conservé : c'est l'identité de la caisse, pas de la session.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
    await prefs.remove(_keyToken);
  }

  /// Sous-domaine de la caisse (tenant), saisi une fois sur l'ecran de
  /// login puis memorise pour les connexions suivantes.
  static Future<void> saveSubdomain(String subdomain) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubdomain, subdomain);
  }

  static Future<String?> getSubdomain() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySubdomain);
  }
}
