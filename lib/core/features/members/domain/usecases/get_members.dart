import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class GetMembers {
  final MemberRepository repository;

  GetMembers(this.repository);

  Future<List<Member>> call() async {
    return await repository.getMembers();
  }
}
