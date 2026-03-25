import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class UpdateMember {
  final MemberRepository repository;

  UpdateMember(this.repository);

  void call(Member member) {
    repository.updateMember(member);
  }
}
