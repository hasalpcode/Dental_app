import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
}
