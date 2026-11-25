import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/superadmin/presentation/super_admin_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _teal = Color(0xff0b5260);
const _tealDark = Color(0xff083d4a);

/// Connexion dediee a la console plateforme : pas de resolution de caisse
/// (le super admin n'appartient a aucun tenant), voir AuthProvider.loginAsSuperAdmin.
class SuperAdminLoginPage extends StatefulWidget {
  const SuperAdminLoginPage({super.key});

  @override
  State<SuperAdminLoginPage> createState() => _SuperAdminLoginPageState();
}

class _SuperAdminLoginPageState extends State<SuperAdminLoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthProvider provider) async {
    final ok =
        await provider.loginAsSuperAdmin(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (ok && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SuperAdminDashboardPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: _tealDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_outlined,
                    color: Colors.white, size: 56),
                const SizedBox(height: 12),
                const Text(
                  'Console plateforme',
                  style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          suffixIcon: IconButton(
                            icon: Icon(_obscure
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      if (provider.error != null) ...[
                        const SizedBox(height: 12),
                        Text(provider.error!,
                            style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              provider.isLoading ? null : () => _submit(provider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: provider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Se connecter'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.white70),
                  child: const Text('Retour'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
