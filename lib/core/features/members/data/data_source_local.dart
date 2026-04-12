import 'package:dental_app/core/features/members/data/member_model.dart';

class MemberLocalDataSource {
  final List<MemberModel> _members = [
    // MemberModel(id: "1", name: "John Doe", email: "john@mail.com"),
  ];

  List<MemberModel> getMembers() => _members;

  void addMember(MemberModel member) => _members.add(member);

  void updateMember(MemberModel member) {
    final index = _members.indexWhere((m) => m.userId == member.userId);
    _members[index] = member;
  }

  void deleteMember(String userId) {
    _members.removeWhere((m) => m.userId == userId);
  }
}
