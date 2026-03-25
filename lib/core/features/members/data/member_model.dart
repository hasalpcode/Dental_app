import 'package:dental_app/core/features/members/domain/entity/member.dart';

class MemberModel extends Member {
  MemberModel({
    required super.id,
    required super.name,
    required super.email,
  });

  factory MemberModel.fromEntity(Member member) {
    return MemberModel(
      id: member.id,
      name: member.name,
      email: member.email,
    );
  }
}
