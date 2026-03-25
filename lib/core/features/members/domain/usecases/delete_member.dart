import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class DeleteMember {
  final MemberRepository repository;

  DeleteMember(this.repository);

  void call(String id) {
    repository.deleteMember(id);
  }
}
