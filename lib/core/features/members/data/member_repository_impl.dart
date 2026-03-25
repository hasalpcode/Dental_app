import 'package:dental_app/core/features/members/data/data_source_local.dart';
import 'package:dental_app/core/features/members/data/member_model.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberLocalDataSource dataSource;

  MemberRepositoryImpl(this.dataSource);

  @override
  List<Member> getMembers() {
    return dataSource.getMembers();
  }

  @override
  void addMember(Member member) {
    dataSource.addMember(MemberModel.fromEntity(member));
  }

  @override
  void updateMember(Member member) {
    dataSource.updateMember(MemberModel.fromEntity(member));
  }

  @override
  void deleteMember(String id) {
    dataSource.deleteMember(id);
  }
}
