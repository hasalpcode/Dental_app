import 'package:dental_app/core/features/members/domain/entity/member.dart';

class MembersState {
  final bool isLoading;
  final bool isDeleting;
  final List<Member> members;
  final String? error;

  const MembersState({
    this.isLoading = false,
    this.isDeleting = false,
    this.members = const [],
    this.error,
  });

  MembersState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<Member>? members,
    String? error,
  }) {
    return MembersState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      members: members ?? this.members,
      error: error,
    );
  }
}
