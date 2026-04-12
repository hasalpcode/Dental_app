import 'package:dental_app/core/features/members/domain/entity/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getMembers();
  Future<Member> addMember(Member member);
  Future<Member> updateMember(Member member);
  Future<void> deleteMember(int id);
}
