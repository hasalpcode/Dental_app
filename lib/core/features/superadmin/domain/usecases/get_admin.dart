import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/repositories/super_admin_repository.dart';

class GetAdmin {
  final SuperAdminRepository repository;
  GetAdmin(this.repository);

  Future<User?> call(int userId) => repository.getAdmin(userId);
}
