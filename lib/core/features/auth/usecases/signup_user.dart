import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/auth/domain/repositories/auth_repository.dart';

class SignupUser {
  final AuthRepository repository;

  SignupUser(this.repository);

  Future<User> call({
    required String tenantName,
    required String subdomain,
    required String planId,
    required String username,
    required String email,
    required String password,
  }) {
    return repository.signup(
      tenantName: tenantName,
      subdomain: subdomain,
      planId: planId,
      username: username,
      email: email,
      password: password,
    );
  }
}
