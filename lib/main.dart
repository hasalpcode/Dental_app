import 'package:dental_app/core/features/auth/data/auth_repository_impl.dart';
import 'package:dental_app/core/features/auth/data/remote_data_auth_source.dart';
import 'package:dental_app/core/features/auth/presentation/login_page.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/auth/usecases/login_user.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/usecases/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

// POUR LA CONNEXION NGROK
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  // runApp(MyApp());
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            LoginUser(
              AuthRepositoryImpl(
                AuthRemoteDataSource(ApiClient.instance),
              ),
            ),
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Association Manager',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const AuthGate(),
    );
  }
}

/// Décide au démarrage si l'utilisateur doit atterrir sur l'accueil
/// (session encore valide) ou sur la page de connexion.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<bool> _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _autoLoginFuture =
        Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _autoLoginFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data == true ? const MainScreen() : const LoginPage();
      },
    );
  }
}
