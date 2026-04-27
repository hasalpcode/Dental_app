import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:flutter/material.dart';
import 'retrait_tile.dart';

class RetraitList extends StatelessWidget {
  final List<RetraitEntity> retraits;
  final Map<int, Member> memberMap;
  final Function(RetraitEntity) onEdit;
  final Function(String) onDelete;

  const RetraitList({
    super.key,
    required this.retraits,
    required this.memberMap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: retraits.length,
      itemBuilder: (_, i) {
        final r = retraits[i];

        return RetraitTile(
          retrait: r,
          memberMap: memberMap,
          onEdit: () => onEdit(r),
          onDelete: () {
            final id = r.retraitId?.toString();
            if (id != null && id.isNotEmpty) {
              onDelete(id);
            }
          },
        );
      },
    );
  }
}
