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
    notifyListeners();

    try {
      user = await loginUser(email, password);
      error = null;
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
