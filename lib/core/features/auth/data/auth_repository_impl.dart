import 'package:dental_app/core/features/auth/data/remote_data_auth_source.dart';
import 'package:dental_app/core/features/auth/data/tenant_option_model.dart';
import 'package:dental_app/core/features/auth/data/user_model.dart';
import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<TenantOption>> resolveTenants(String email) {
    return remoteDataSource.resolveTenants(email);
  }

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);
    return _toUser(userModel);
  }

  @override
  Future<User> signup({
    required String tenantName,
    required String subdomain,
    required String planId,
    required String username,
    required String email,
    required String password,
  }) async {
    final userModel = await remoteDataSource.signup(
      tenantName: tenantName,
      subdomain: subdomain,
      planId: planId,
      username: username,
      email: email,
      password: password,
    );
    return _toUser(userModel);
  }

  User _toUser(UserModel userModel) {
    return User(
      userId: userModel.user.userId,
      username: userModel.user.username,
      email: userModel.user.email,
      role: userModel.user.role,
      dateInscription: userModel.user.dateInscription,
      token: userModel.token,
    );
  }
}
