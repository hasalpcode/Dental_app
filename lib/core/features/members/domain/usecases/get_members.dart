import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class GetMembers {
  final MemberRepository repository;

  GetMembers(this.repository);

  List<Member> call() {
    return repository.getMembers();
  }
}
