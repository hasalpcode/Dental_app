import 'package:dental_app/core/usecases/profile_widget.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String fullName;
  final String email;
  final VoidCallback? onLogout;

  const ProfilePage({
    super.key,
    required this.fullName,
    required this.email,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ProfileWidget(
        fullName: fullName,
        email: email,
        password: null,
        onLogout: onLogout,
      ),
    );
  }
}
