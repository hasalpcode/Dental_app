import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class CreateTenant {
  final SuperAdminRepository repository;
  CreateTenant(this.repository);

  Future<TenantEntity> call(String name, String subdomain) =>
      repository.createTenant(name, subdomain);
}
