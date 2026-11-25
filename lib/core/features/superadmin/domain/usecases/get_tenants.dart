import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class GetTenants {
  final SuperAdminRepository repository;
  GetTenants(this.repository);

  Future<List<TenantEntity>> call() => repository.getTenants();
}
