import 'package:dental_app/core/features/members/data/data_source_local.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/add_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/delete_member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/domain/usecases/update_member.dart';
import 'package:dental_app/core/features/members/presentation/widgets/add_member_modal.dart';
import 'package:dental_app/core/features/members/presentation/widgets/member_list.dart';
import 'package:dental_app/core/features/members/presentation/widgets/member_title.dart';
import 'package:flutter/material.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  late final MemberRepositoryImpl repository;
  late final GetMembers getMembers;
  late final AddMember addMember;
  late final UpdateMember updateMember;
  late final DeleteMember deleteMember;

  List<Member> members = [];

  @override
  void initState() {
    super.initState();
    final dataSource = MemberLocalDataSource();
    repository = MemberRepositoryImpl(dataSource);

    getMembers = GetMembers(repository);
    addMember = AddMember(repository);
    updateMember = UpdateMember(repository);
    deleteMember = DeleteMember(repository);

    members = getMembers();
  }

  void _refresh() {
    setState(() {
      members = getMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Members"),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: MembersList(
        members: members,
        onEdit: _openEditModal,
        onDelete: (id) {
          deleteMember(id);
          _refresh();
        },
      ),
    );
  }

  /// 🔹 Modal stylé et centré pour ajout
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberModal(
        onSubmit: (m) {
          addMember(m);
          _refresh();
        },
      ),
    );
  }

  /// 🔹 Modal stylé et centré pour modification
  void _openEditModal(Member member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddMemberModal(
        member: member,
        onSubmit: (m) {
          updateMember(m);
          _refresh();
        },
      ),
    );
  }
}
