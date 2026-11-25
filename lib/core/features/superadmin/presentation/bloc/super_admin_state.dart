import 'package:dental_app/core/features/superadmin/domain/entity/tenant_entity.dart';

class SuperAdminState {
  final bool isLoading;
  final bool isMutating;
  final List<TenantEntity> tenants;
  final String? error;

  const SuperAdminState({
    this.isLoading = false,
    this.isMutating = false,
    this.tenants = const [],
    this.error,
  });

  SuperAdminState copyWith({
    bool? isLoading,
    bool? isMutating,
    List<TenantEntity>? tenants,
    String? error,
  }) {
    return SuperAdminState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      tenants: tenants ?? this.tenants,
      error: error,
    );
  }
}
