import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  final String fullName;
  final String email;
  final String? password;
  final VoidCallback? onLogout;

  const ProfileWidget({
    super.key,
    required this.fullName,
    required this.email,
    this.password,
    this.onLogout,
  });

  String get _maskedPassword {
    if (password == null || password!.isEmpty) return 'Aucun mot de passe';
    return '•' * password!.length;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profil utilisateur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person),
                title: const Text('Nom complet'),
                subtitle: Text(fullName),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(email.isNotEmpty ? email : 'Non renseigné'),
              ),
              if (password != null) ...[
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock),
                  title: const Text('Mot de passe'),
                  subtitle: Text(_maskedPassword),
                ),
              ],
              const SizedBox(height: 16),
              if (onLogout != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onLogout,
                    child: const Text('Se déconnecter'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
