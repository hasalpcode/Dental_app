import 'package:dental_app/core/features/superadmin/data/super_admin_remote_data_source.dart';
import 'package:dental_app/core/features/superadmin/data/super_admin_repository_impl.dart';
import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/create_tenant.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/get_tenants.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/update_tenant_status.dart';
import 'package:dental_app/core/features/superadmin/presentation/bloc/super_admin_cubit.dart';
import 'package:dental_app/core/features/superadmin/presentation/bloc/super_admin_state.dart';
import 'package:dental_app/core/features/superadmin/presentation/tenant_detail_page.dart';
import 'package:dental_app/core/features/superadmin/presentation/widgets/create_tenant_modal.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _teal = Color(0xff0b5260);

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repository =
        SuperAdminRepositoryImpl(SuperAdminRemoteDataSource(ApiClient.instance));

    return BlocProvider(
      create: (_) => SuperAdminCubit(
        GetTenants(repository),
        CreateTenant(repository),
        UpdateTenantStatus(repository),
      )..loadTenants(),
      child: const _SuperAdminDashboardView(),
    );
  }
}

class _SuperAdminDashboardView extends StatelessWidget {
  const _SuperAdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(
        title: 'Console plateforme',
        option: 'Gestion des caisses',
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _teal,
        onPressed: () => _openCreateModal(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocBuilder<SuperAdminCubit, SuperAdminState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<SuperAdminCubit>().loadTenants(),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _teal, foregroundColor: Colors.white),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (state.tenants.isEmpty) {
            return const Center(child: Text('Aucune caisse pour le moment'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<SuperAdminCubit>().loadTenants(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.tenants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _TenantTile(tenant: state.tenants[i]),
            ),
          );
        },
      ),
    );
  }

  void _openCreateModal(BuildContext context) {
    final cubit = context.read<SuperAdminCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateTenantModal(
        onSubmit: (name, subdomain) => cubit.createTenant(name, subdomain),
      ),
    );
  }
}

class _TenantTile extends StatelessWidget {
  final TenantEntity tenant;
  const _TenantTile({required this.tenant});

  Color get _statusColor {
    switch (tenant.status) {
      case 'ACTIVE':
        return Colors.green;
      case 'SUSPENDED':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TenantDetailPage(tenant: tenant)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _teal.withOpacity(0.1),
                child: const Icon(Icons.domain_outlined, color: _teal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tenant.name,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(tenant.subdomain,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tenant.status,
                  style: TextStyle(
                      color: _statusColor, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
