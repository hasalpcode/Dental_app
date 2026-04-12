import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class AddMember {
  final MemberRepository repository;

  AddMember(this.repository);

  Future<Member> call(Member member) async {
    return await repository.addMember(member);
  }
}
