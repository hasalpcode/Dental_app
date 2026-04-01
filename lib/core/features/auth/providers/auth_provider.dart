import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/auth/usecases/login_user.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUser loginUser;

  AuthProvider(this.loginUser);

  bool isLoading = false;
  User? user;
  String? error;

  Future<bool> login(String email, String password) async {
    isLoading = true;

    try {
      user = await loginUser(email, password);
      error = null;
      if (user != null) {
        // Stocke les infos
        await UserStorage.saveUser(user!, user!.token!);
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
