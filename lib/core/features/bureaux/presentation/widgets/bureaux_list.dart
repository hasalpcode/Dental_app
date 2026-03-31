import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/presentation/widgets/bureau_title.dart';
import 'package:flutter/material.dart';

class BureauxList extends StatelessWidget {
  final List<BureauEntity> bureaux;
  final Function(BureauEntity) onEdit;
  final Function(String) onDelete;

  const BureauxList({
    super.key,
    required this.bureaux,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bureaux.length,
      itemBuilder: (_, i) {
        final p = bureaux[i];
        return BureauTile(
          project: p,
          onEdit: () => onEdit(p),
          onDelete: () => onDelete(p.bureauId),
        );
      },
    );
  }
}
