import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/add_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/delete_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/domain/usecases/update_member.dart';
import 'members_state.dart';

class MembersCubit extends Cubit<MembersState> {
  final GetMembers getMembersUseCase;
  final AddMember addMemberUseCase;
  final UpdateMember updateMemberUseCase;
  final DeleteMember deleteMemberUseCase;

  MembersCubit(
    this.getMembersUseCase,
    this.addMemberUseCase,
    this.updateMemberUseCase,
    this.deleteMemberUseCase,
  ) : super(const MembersState());

  Future<void> loadMembers() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final fetchedMembers = await getMembersUseCase();
      emit(state.copyWith(isLoading: false, members: fetchedMembers));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addMember(Member member) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addMemberUseCase(member);
      await loadMembers();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateMember(Member member) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updateMemberUseCase(member);
      await loadMembers();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteMember(int id) async {
    emit(state.copyWith(isDeleting: true, error: null));
    try {
      await deleteMemberUseCase(id);
      await loadMembers();
    } catch (e) {
      emit(state.copyWith(isDeleting: false, error: e.toString()));
    }
  }
}
