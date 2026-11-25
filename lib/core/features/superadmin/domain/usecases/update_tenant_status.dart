import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class UpdateTenantStatus {
  final SuperAdminRepository repository;
  UpdateTenantStatus(this.repository);

  Future<TenantEntity> call(String tenantId, String status) =>
      repository.updateTenantStatus(tenantId, status);
}
