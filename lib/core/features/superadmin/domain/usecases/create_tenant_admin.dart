import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class CreateTenantAdmin {
  final SuperAdminRepository repository;
  CreateTenantAdmin(this.repository);

  Future<User> call(
    String tenantId, {
    required String username,
    required String email,
    required String password,
  }) =>
      repository.createTenantAdmin(
        tenantId,
        username: username,
        email: email,
        password: password,
      );
}
