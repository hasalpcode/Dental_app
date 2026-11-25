import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/create_tenant.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/get_tenants.dart';
import 'package:dental_app/core/features/superadmin/domain/usecases/update_tenant_status.dart';
import 'super_admin_state.dart';

class SuperAdminCubit extends Cubit<SuperAdminState> {
  final GetTenants getTenantsUseCase;
  final CreateTenant createTenantUseCase;
  final UpdateTenantStatus updateTenantStatusUseCase;

  SuperAdminCubit(
    this.getTenantsUseCase,
    this.createTenantUseCase,
    this.updateTenantStatusUseCase,
  ) : super(const SuperAdminState());

  Future<void> loadTenants() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final tenants = await getTenantsUseCase();
      emit(state.copyWith(isLoading: false, tenants: tenants));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<bool> createTenant(String name, String subdomain) async {
    emit(state.copyWith(isMutating: true, error: null));
    try {
      await createTenantUseCase(name, subdomain);
      await loadTenants();
      emit(state.copyWith(isMutating: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isMutating: false, error: e.toString()));
      return false;
    }
  }

  Future<bool> toggleTenantStatus(String tenantId, bool suspend) async {
    emit(state.copyWith(isMutating: true, error: null));
    try {
      await updateTenantStatusUseCase(
          tenantId, suspend ? 'SUSPENDED' : 'ACTIVE');
      await loadTenants();
      emit(state.copyWith(isMutating: false));
      return true;
    } catch (e) {
      emit(state.copyWith(isMutating: false, error: e.toString()));
      return false;
    }
  }
}
