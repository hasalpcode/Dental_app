import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

/// Il n'existe pas d'endpoint "mon membre" côté backend : le lien entre le
/// User connecté et sa fiche Membre se fait uniquement via Member.userId,
/// donc on recupere la liste complete et on filtre côté client.
class GetMyMember {
  final MemberRepository repository;

  GetMyMember(this.repository);

  Future<Member?> call(int userId) async {
    final members = await repository.getMembers();
    for (final m in members) {
      if (m.userId == userId) return m;
    }
    return null;
  }
}
