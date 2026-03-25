import 'package:dental_app/core/features/members/domain/entity/member.dart';

abstract class MemberRepository {
  List<Member> getMembers();
  void addMember(Member member);
  void updateMember(Member member);
  void deleteMember(String id);
}
