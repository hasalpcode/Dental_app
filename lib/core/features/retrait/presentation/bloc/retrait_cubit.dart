import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/add_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/delete_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/get_retraits.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/update_retrait.dart';
import 'retrait_state.dart';

class RetraitCubit extends Cubit<RetraitState> {
  final GetRetraits getRetraitsUseCase;
  final GetMembers getMembersUseCase;
  final AddRetrait addRetraitUseCase;
  final UpdateRetrait updateRetraitUseCase;
  final DeleteRetrait deleteRetraitUseCase;

  RetraitCubit(
    this.getRetraitsUseCase,
    this.getMembersUseCase,
    this.addRetraitUseCase,
    this.updateRetraitUseCase,
    this.deleteRetraitUseCase,
  ) : super(const RetraitState());

  Future<void> loadData({List<Member>? members}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        getRetraitsUseCase(),
        members != null ? Future.value(members) : getMembersUseCase(),
      ]);
      emit(state.copyWith(
        isLoading: false,
        retraits: results[0] as List<RetraitEntity>,
        members: results[1] as List<Member>,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addRetrait(RetraitEntity retrait) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addRetraitUseCase(retrait);
      await loadData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateRetrait(RetraitEntity retrait) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updateRetraitUseCase(retrait);
      await loadData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteRetrait(String id) async {
    emit(state.copyWith(isDeleting: true, error: null));
    try {
      await deleteRetraitUseCase(id);
      await loadData();
    } catch (e) {
      emit(state.copyWith(isDeleting: false, error: e.toString()));
    }
  }
}
