import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/data_source_local.dart';
import 'package:dental_app/core/features/members/data/member_model.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/repository/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberRemoteDataSource dataSource;

  MemberRepositoryImpl(this.dataSource);

  @override
  Future<List<Member>> getMembers() async {
    return await dataSource.getMembers();
  }

  @override
  Future<Member> addMember(Member member) async {
    return await dataSource.addMember(
      MemberModel.fromEntity(member),
    );
  }

  @override
  Future<Member> updateMember(Member member) async {
    return await dataSource.updateMember(
      MemberModel.fromEntity(member),
    );
  }

  @override
  Future<void> deleteMember(int id) async {
    return await dataSource.deleteMember(id);
  }
}
