import 'package:dental_app/core/features/auth/data/remote_data_auth_source.dart';
import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login(String email, String password) async {
    final userModel = await remoteDataSource.login(email, password);

    // Mapping vers l'entité User
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
