import 'package:dental_app/core/features/auth/data/tenant_option_model.dart';
import 'package:dental_app/core/features/auth/domain/repositories/auth_repository.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:flutter/material.dart';
import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/auth/usecases/login_user.dart';
import 'package:dental_app/core/features/auth/usecases/signup_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final LoginUser loginUser;
  final SignupUser signupUser;

  AuthProvider(this.authRepository, this.loginUser, this.signupUser);

  bool isLoading = false;
  User? user;
  String? error;

  /// Non vide quand plusieurs caisses correspondent au numéro saisi : l'UI
  /// doit alors proposer un choix avant de terminer la connexion.
  List<TenantOption>? tenantChoices;

  String? _pendingEmail;
  String? _pendingPassword;

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

  /// Le gateway exige un tenant résolu sur chaque requête, mais l'écran de
  /// login ne le connaît pas — on le retrouve d'abord via les Membership
  /// actifs du numéro saisi (voir POST /auth/resolve-tenant), avant de se
  /// connecter réellement.
  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    tenantChoices = null;
    notifyListeners();

    try {
      final options = await authRepository.resolveTenants(email);

      if (options.isEmpty) {
        error = "Aucune caisse trouvée pour ce numéro";
        return false;
      }

      if (options.length > 1) {
        tenantChoices = options;
        _pendingEmail = email;
        _pendingPassword = password;
        return false;
      }

      return await _loginWithSubdomain(options.first.subdomain, email, password);
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Termine la connexion après que l'utilisateur a choisi sa caisse parmi
  /// [tenantChoices].
  Future<bool> loginWithChosenTenant(TenantOption option) async {
    final email = _pendingEmail;
    final password = _pendingPassword;
    if (email == null || password == null) return false;

    isLoading = true;
    tenantChoices = null;
    notifyListeners();

    try {
      return await _loginWithSubdomain(option.subdomain, email, password);
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _loginWithSubdomain(
      String subdomain, String email, String password) async {
    await UserStorage.saveSubdomain(subdomain);
    user = await loginUser(email, password);
    error = null;
    if (user != null) {
      await UserStorage.saveUser(user!, user!.token!);
    }
    notifyListeners();
    return true;
  }

  Future<bool> signup({
    required String tenantName,
    required String subdomain,
    required String planId,
    required String username,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      user = await signupUser(
        tenantName: tenantName,
        subdomain: subdomain.trim(),
        planId: planId,
        username: username,
        email: email,
        password: password,
      );
      // Le tenant vient d'être créé avec ce sous-domaine : on le mémorise
      // pour toutes les requêtes suivantes (même mécanisme que login()).
      await UserStorage.saveSubdomain(subdomain.trim());
      if (user != null) {
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
