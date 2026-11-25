import 'package:dental_app/core/features/auth/domain/entities/user_entity.dart';
import 'package:dental_app/core/features/superadmin/data/super_admin_remote_data_source.dart';
import 'package:dental_app/core/features/superadmin/data/super_admin_repository_impl.dart';
import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/assign_tenant_admin.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/create_tenant_admin.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/get_admin.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/update_admin_status.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/update_tenant_status.dart';
import 'package:dental_app/core/features/superadmin/presentation/widgets/create_admin_modal.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';

const _teal = Color(0xff0b5260);

class TenantDetailPage extends StatefulWidget {
  final TenantEntity tenant;
  const TenantDetailPage({super.key, required this.tenant});

  @override
  State<TenantDetailPage> createState() => _TenantDetailPageState();
}

class _TenantDetailPageState extends State<TenantDetailPage> {
  late final SuperAdminRepositoryImpl repository;
  late final GetAdmin getAdmin;
  late final CreateTenantAdmin createTenantAdmin;
  late final AssignTenantAdmin assignTenantAdmin;
  late final UpdateAdminStatus updateAdminStatus;
  late final UpdateTenantStatus updateTenantStatus;

  late TenantEntity tenant;
  User? admin;
  bool isLoading = true;
  bool isMutating = false;
  String? error;

  @override
  void initState() {
    super.initState();
    tenant = widget.tenant;
    repository =
        SuperAdminRepositoryImpl(SuperAdminRemoteDataSource(ApiClient.instance));
    getAdmin = GetAdmin(repository);
    createTenantAdmin = CreateTenantAdmin(repository);
    assignTenantAdmin = AssignTenantAdmin(repository);
    updateAdminStatus = UpdateAdminStatus(repository);
    updateTenantStatus = UpdateTenantStatus(repository);
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final ownerId = tenant.ownerUserId;
      admin = ownerId == null ? null : await getAdmin(ownerId);
    } catch (e) {
      error = e.toString();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      isMutating = true;
      error = null;
    });
    try {
      await action();
      await _loadAdmin();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => isMutating = false);
    }
  }

  Future<void> _toggleTenantStatus() async {
    final suspend = tenant.isActive;
    await _run(() async {
      final updated = await updateTenantStatus(
          tenant.tenantId, suspend ? 'SUSPENDED' : 'ACTIVE');
      if (mounted) setState(() => tenant = updated);
    });
  }

  void _openCreateAdminModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateAdminModal(
        onSubmit: (username, email, password) => _run(() async {
          await createTenantAdmin(
            tenant.tenantId,
            username: username,
            email: email,
            password: password,
          );
        }),
      ),
    );
  }

  Future<void> _openAssignAdminDialog() async {
    final ctrl = TextEditingController();
    final userId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Changer l\'admin'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'ID de l\'utilisateur existant',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Valider')),
        ],
      ),
    );
    if (userId == null || userId.trim().isEmpty) return;
    final parsed = int.tryParse(userId.trim());
    if (parsed == null) return;
    await _run(() async {
      await assignTenantAdmin(tenant.tenantId, parsed);
    });
  }

  Future<void> _suspendAdmin() async {
    final currentAdmin = admin;
    if (currentAdmin == null) return;
    await _run(() async {
      await updateAdminStatus(tenant.tenantId, currentAdmin.userId, 'REVOKED');
    });
  }

  Future<void> _reactivateAdmin() async {
    final currentAdmin = admin;
    if (currentAdmin == null) return;
    await _run(() async {
      await updateAdminStatus(tenant.tenantId, currentAdmin.userId, 'ACTIVE');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CurvedAppBar(title: tenant.name, option: tenant.subdomain),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionCard(
                title: 'Caisse',
                children: [
                  _infoRow('Statut', tenant.status),
                  _infoRow('Sous-domaine', tenant.subdomain),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: isMutating ? null : _toggleTenantStatus,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: tenant.isActive ? Colors.red : Colors.green,
                      ),
                      child: Text(tenant.isActive
                          ? 'Suspendre la caisse'
                          : 'Réactiver la caisse'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Administrateur',
                children: [
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (admin == null) ...[
                    const Text('Aucun administrateur pour cette caisse'),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isMutating ? null : _openCreateAdminModal,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _teal, foregroundColor: Colors.white),
                        child: const Text('Créer un admin'),
                      ),
                    ),
                  ] else ...[
                    _infoRow('Nom', admin!.username),
                    _infoRow('Email', admin!.email),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isMutating ? null : _openAssignAdminDialog,
                            child: const Text('Changer'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isMutating ? null : _suspendAdmin,
                            style:
                                OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Suspendre'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: isMutating ? null : _reactivateAdmin,
                        child: const Text('Réactiver le membership'),
                      ),
                    ),
                  ],
                ],
              ),
              if (error != null) ...[
                const SizedBox(height: 16),
                Text(error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
          if (isMutating)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label : ', style: TextStyle(color: Colors.grey.shade600)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
