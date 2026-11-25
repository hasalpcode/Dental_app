import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class UpdateAdminStatus {
  final SuperAdminRepository repository;
  UpdateAdminStatus(this.repository);

  Future<void> call(String tenantId, int userId, String status) =>
      repository.updateAdminStatus(tenantId, userId, status);
}
