import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';

abstract class SuperAdminRepository {
  Future<List<TenantEntity>> getTenants();

  Future<TenantEntity> createTenant(String name, String subdomain);

  Future<TenantEntity> updateTenantStatus(String tenantId, String status);

  /// null si le tenant n'a pas encore d'admin (ownerUserId absent).
  Future<User?> getAdmin(int userId);

  Future<User> createTenantAdmin(
    String tenantId, {
    required String username,
    required String email,
    required String password,
  });

  Future<User> assignTenantAdmin(String tenantId, int userId);

  Future<void> updateAdminStatus(String tenantId, int userId, String status);
}
