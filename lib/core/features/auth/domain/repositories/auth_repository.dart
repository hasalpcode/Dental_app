import 'package:dental_app/core/features/auth/data/tenant_option_model.dart';
import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<List<TenantOption>> resolveTenants(String email);

  Future<User> login(String email, String password);

  Future<User> signup({
    required String tenantName,
    required String subdomain,
    required String planId,
    required String username,
    required String email,
    required String password,
  });
}
