import 'package:dental_app/core/features/auth/data/auth_repository_impl.dart';
import 'package:dental_app/core/features/auth/data/remote_data_auth_source.dart';
import 'package:dental_app/core/features/auth/presentation/login_page.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/auth/usecases/login_user.dart';
import 'package:dental_app/core/usecases/HomePage.dart';
import 'package:dental_app/core/usecases/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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
                AuthRemoteDataSource(http.Client()),
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
      home: const LoginPage(),
    );
  }
}
