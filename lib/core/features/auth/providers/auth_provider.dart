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

  bool get canModify => user?.role.isAdmin ?? false;
  bool get isUser => user?.role.isUser ?? false;
  bool get isComptable => user?.role.isComptable ?? false;

  /// Restaure la session si un token valide est déjà stocké localement.
  Future<bool> tryAutoLogin() async {
    final token = await UserStorage.getToken();
    if (token == null || !UserStorage.isTokenValid(token)) {
      if (token != null) await UserStorage.clear();
      return false;
    }

    final storedUser = await UserStorage.getUser();
    if (storedUser == null) return false;

    user = storedUser;
    notifyListeners();
    return true;
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

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
