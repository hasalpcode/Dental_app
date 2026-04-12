import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/presentation/widgets/member_title.dart';
import 'package:flutter/material.dart';

class MembersList extends StatelessWidget {
  final List<Member> members;
  final Function(Member) onEdit;
  final Function(int) onDelete;

  const MembersList({
    super.key,
    required this.members,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;

      return Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3.5,
                ),
                itemCount: members.length,
                itemBuilder: (_, i) {
                  final member = members[i];
                  return MemberTile(
                    member: member,
                    onEdit: () => onEdit(member),
                    onDelete: () => onDelete(member.membreId!),
                  );
                },
              )
            : ListView.builder(
                itemCount: members.length,
                itemBuilder: (_, i) {
                  final member = members[i];
                  return MemberTile(
                    member: member,
                    onEdit: () => onEdit(member),
                    onDelete: () => onDelete(member.membreId!),
                  );
                },
              ),
      );
    });
  }
}
