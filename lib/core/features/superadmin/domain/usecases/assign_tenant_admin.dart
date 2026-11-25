import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class AssignTenantAdmin {
  final SuperAdminRepository repository;
  AssignTenantAdmin(this.repository);

  Future<User> call(String tenantId, int userId) =>
      repository.assignTenantAdmin(tenantId, userId);
}
