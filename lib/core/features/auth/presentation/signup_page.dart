import 'package:dental_app/core/features/auth/data/plan_model.dart';
import 'package:dental_app/core/features/auth/data/tenant_remote_data_source.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/usecases/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Création d'une nouvelle caisse (tenant) + de son administrateur —
/// POST /auth/signup côté user-service.
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final tenantNameController = TextEditingController();
  final subdomainController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _tenantDataSource = TenantRemoteDataSource(ApiClient.instance);
  late final Future<List<PlanModel>> _plansFuture;
  String? _selectedPlanId;

  @override
  void initState() {
    super.initState();
    _plansFuture = _tenantDataSource.getPlans();
  }

  @override
  void dispose() {
    tenantNameController.dispose();
    subdomainController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Créer une caisse")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: tenantNameController,
              decoration: const InputDecoration(
                labelText: "Nom de la caisse",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subdomainController,
              decoration: const InputDecoration(
                labelText: "Sous-domaine (ex: caisse-x)",
                helperText: "Minuscules, chiffres et tirets uniquement",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<PlanModel>>(
              future: _plansFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text(
                    "Erreur chargement des plans: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  );
                }
                final plans = snapshot.data ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedPlanId,
                  decoration: const InputDecoration(
                    labelText: "Plan",
                    border: OutlineInputBorder(),
                  ),
                  items: plans
                      .map((p) => DropdownMenuItem(
                            value: p.planId,
                            child: Text(
                                "${p.name} — ${p.maxMembers} membres max — ${p.pricePerMonth}/mois"),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPlanId = value),
                );
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Votre nom",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: const InputDecoration(
                labelText: "N° téléphone",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: const InputDecoration(
                labelText: "Mot de passe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (provider.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: provider.isLoading || _selectedPlanId == null
                  ? null
                  : () async {
                      final success = await provider.signup(
                        tenantName: tenantNameController.text,
                        subdomain: subdomainController.text,
                        planId: _selectedPlanId!,
                        username: usernameController.text,
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      if (success && context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainScreen()),
                        );
                      }
                    },
              child: provider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Créer ma caisse"),
            ),
          ],
        ),
      ),
    );
  }
}
