import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/auth/presentation/login_page.dart';
import 'package:dental_app/core/helpers/user_storage.dart';
import 'package:dental_app/core/usecases/profile_page.dart';

class CurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? option;
  final Widget? leading;
  final String? userName;
  final VoidCallback? onProfile;
  final VoidCallback? onLogout;

  const CurvedAppBar({
    super.key,
    this.title,
    this.option,
    this.leading,
    this.userName,
    this.onProfile,
    this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff062d34), Color(0xff0b5260)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (leading != null) leading!,
                  if (leading != null) const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title ?? 'DÉNTAL',
                          style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      if (option != null)
                        Text(
                          option!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: const Color(0xfff08024),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                color: Colors.white,
                onSelected: (value) async {
                  if (value == 'profile') {
                    if (onProfile != null) {
                      onProfile?.call();
                    } else {
                      final auth =
                          Provider.of<AuthProvider>(context, listen: false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfilePage(
                            fullName: auth.user?.username ?? 'Utilisateur',
                            email: auth.user?.email ?? '',
                            onLogout: onLogout,
                          ),
                        ),
                      );
                    }
                  } else if (value == 'logout') {
                    if (onLogout != null) {
                      onLogout?.call();
                    } else {
                      await UserStorage.clear();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('Profil'),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Déconnexion'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
