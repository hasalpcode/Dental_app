import 'dart:convert';

import 'package:dental_app/core/features/auth/data/user_model.dart'
    show UserModel;
import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/data/tenant_model.dart';
import 'package:dental_app/core/helpers/api_client.dart';

/// Console plateforme : tenant-service (gestion des tenants) + user-service
/// (gestion des admins de chaque tenant), toutes deux appelees avec le JWT
/// super admin courant (X-Tenant-Subdomain = "admin" deja pose a la
/// connexion, voir AuthProvider.loginAsSuperAdmin).
class SuperAdminRemoteDataSource {
  final ApiClient client;
  SuperAdminRemoteDataSource(this.client);

  Future<List<TenantModel>> getTenants() async {
    final response = await client.get('/tenant-service/api/tenants');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => TenantModel.fromJson(e)).toList();
    }
    throw Exception(
        'Erreur récupération des tenants: ${response.statusCode} - ${response.body}');
  }

  Future<TenantModel> createTenant(String name, String subdomain) async {
    final response = await client.post(
      '/tenant-service/api/tenants',
      body: {'name': name, 'subdomain': subdomain},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return TenantModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
        'Erreur création du tenant: ${response.statusCode} - ${response.body}');
  }

  Future<TenantModel> updateTenantStatus(String tenantId, String status) async {
    final response = await client.patch(
      '/tenant-service/api/tenants/$tenantId/status',
      body: {'status': status},
    );
    if (response.statusCode == 200) {
      return TenantModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(
        'Erreur changement de statut: ${response.statusCode} - ${response.body}');
  }

  Future<User?> getAdmin(int userId) async {
    final response = await client.get('/user-service/users/$userId');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    if (response.statusCode == 404) return null;
    throw Exception(
        'Erreur récupération admin: ${response.statusCode} - ${response.body}');
  }

  Future<User> createTenantAdmin(
    String tenantId, {
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await client.post(
      '/user-service/super-admin/tenants/$tenantId/admin',
      body: {'username': username, 'email': email, 'password': password},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return UserModel.fromJson({
        'token': null,
        'user': jsonDecode(response.body),
      }).user;
    }
    throw Exception(
        "Erreur création de l'admin: ${response.statusCode} - ${response.body}");
  }

  Future<User> assignTenantAdmin(String tenantId, int userId) async {
    final response = await client.put(
      '/user-service/super-admin/tenants/$tenantId/admin/$userId',
    );
    if (response.statusCode == 200) {
      return UserModel.fromJson({
        'token': null,
        'user': jsonDecode(response.body),
      }).user;
    }
    throw Exception(
        "Erreur changement d'admin: ${response.statusCode} - ${response.body}");
  }

  Future<void> updateAdminStatus(
      String tenantId, int userId, String status) async {
    final response = await client.patch(
      '/user-service/super-admin/tenants/$tenantId/admin/$userId/status',
      body: {'status': status},
    );
    if (response.statusCode != 200) {
      throw Exception(
          "Erreur changement de statut admin: ${response.statusCode} - ${response.body}");
    }
  }
}
