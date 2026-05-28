import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/presentation/widgets/member_title.dart';
import 'package:flutter/material.dart';

class MembersList extends StatelessWidget {
  final List<Member> members;
  final Function(Member)? onEdit;
  final Function(int)? onDelete;
  final String searchQuery;

  const MembersList({
    super.key,
    required this.members,
    this.onEdit,
    this.onDelete,
    this.searchQuery = '',
  });

  List<Member> get filteredMembers {
    if (searchQuery.isEmpty) return members;
    final query = searchQuery.toLowerCase();
    return members
        .where((member) =>
            member.username.toLowerCase().contains(query) ||
            member.tel.toLowerCase().contains(query) ||
            (member.carteMembre?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayMembers = filteredMembers;

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;

      if (displayMembers.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucun membre trouvé'),
          ),
        );
      }

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
                itemCount: displayMembers.length,
                itemBuilder: (_, i) {
                  final member = displayMembers[i];
                  return MemberTile(
                    member: member,
                    onEdit: onEdit != null ? () => onEdit!(member) : null,
                    onDelete: onDelete != null
                        ? () => onDelete!(member.membreId!)
                        : null,
                  );
                },
              )
            : ListView.builder(
                itemCount: displayMembers.length,
                itemBuilder: (_, i) {
                  final member = displayMembers[i];
                  return MemberTile(
                    member: member,
                    onEdit: onEdit != null ? () => onEdit!(member) : null,
                    onDelete: onDelete != null
                        ? () => onDelete!(member.membreId!)
                        : null,
                  );
                },
              ),
      );
    });
  }
}
