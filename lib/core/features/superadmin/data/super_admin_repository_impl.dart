import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/data/super_admin_remote_data_source.dart';
import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class SuperAdminRepositoryImpl implements SuperAdminRepository {
  final SuperAdminRemoteDataSource dataSource;
  SuperAdminRepositoryImpl(this.dataSource);

  @override
  Future<List<TenantEntity>> getTenants() => dataSource.getTenants();

  @override
  Future<TenantEntity> createTenant(String name, String subdomain) =>
      dataSource.createTenant(name, subdomain);

  @override
  Future<TenantEntity> updateTenantStatus(String tenantId, String status) =>
      dataSource.updateTenantStatus(tenantId, status);

  @override
  Future<User?> getAdmin(int userId) => dataSource.getAdmin(userId);

  @override
  Future<User> createTenantAdmin(
    String tenantId, {
    required String username,
    required String email,
    required String password,
  }) =>
      dataSource.createTenantAdmin(
        tenantId,
        username: username,
        email: email,
        password: password,
      );

  @override
  Future<User> assignTenantAdmin(String tenantId, int userId) =>
      dataSource.assignTenantAdmin(tenantId, userId);

  @override
  Future<void> updateAdminStatus(String tenantId, int userId, String status) =>
      dataSource.updateAdminStatus(tenantId, userId, status);
}
