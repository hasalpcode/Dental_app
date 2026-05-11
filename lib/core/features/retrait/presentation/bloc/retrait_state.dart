import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';

class RetraitState {
  final bool isLoading;
  final bool isDeleting;
  final List<RetraitEntity> retraits;
  final List<Member> members;
  final String? error;

  const RetraitState({
    this.isLoading = false,
    this.isDeleting = false,
    this.retraits = const [],
    this.members = const [],
    this.error,
  });

  RetraitState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<RetraitEntity>? retraits,
    List<Member>? members,
    String? error,
  }) {
    return RetraitState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      retraits: retraits ?? this.retraits,
      members: members ?? this.members,
      error: error,
    );
  }

  Map<int, Member> get memberMap {
    return {
      for (final m in members)
        if (m.membreId != null) m.membreId!: m,
    };
  }
}
