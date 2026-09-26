import 'dart:convert';

import 'package:dental_app/core/features/auth/data/tenant_option_model.dart';
import 'package:dental_app/core/features/auth/data/user_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/helpers/user_storage.dart';

class AuthRemoteDataSource {
  final ApiClient client;

  AuthRemoteDataSource(this.client);

  /// Change le rôle d'un membre au sein du tenant courant (Membership.role
  /// — celui qui détermine réellement les droits, pas le rôle global
  /// historique de la table user).
  Future<void> updateUserRole(int userId, int roleId) async {
    final tenantId = await UserStorage.getTenantId();
    if (tenantId == null) throw Exception('Tenant introuvable');

    final response = await client.patch(
      '/user-service/memberships/tenant/$tenantId/user/$userId/role/$roleId',
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Erreur modification rôle: ${response.statusCode} - ${response.body}');
    }
  }

  /// Retrouve les caisses accessibles à ce numéro, avant toute connexion —
  /// permet de résoudre le sous-domaine sans le demander à l'utilisateur.
  Future<List<TenantOption>> resolveTenants(String email) async {
    final response = await client.post(
      '/user-service/auth/resolve-tenant',
      auth: false,
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TenantOption.fromJson(e)).toList();
    } else {
      throw Exception(
          'Erreur résolution caisse: ${response.statusCode} - ${response.body}');
    }
  }

  Future<UserModel> login(String email, String password) async {
    
    final response = await client.post(
      '/user-service/auth/login',
      auth: false,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Login failed: ${response.statusCode} - ${response.body}');
    }
  }

  /// Crée une nouvelle caisse (tenant) + son administrateur, et connecte
  /// immédiatement ce dernier — voir POST /auth/signup côté user-service.
  Future<UserModel> signup({
    required String tenantName,
    required String subdomain,
    required String planId,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      '/user-service/auth/signup',
      auth: false,
      body: {
        'tenantName': tenantName,
        'subdomain': subdomain,
        'planId': planId,
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Signup failed: ${response.statusCode} - ${response.body}');
    }
  }
}
