import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/presentation/widgets/baptem_title.dart';
import 'package:flutter/material.dart';

class BaptismsList extends StatelessWidget {
  final List<Baptism> baptisms;
  final Function(Baptism) onEdit;
  final Function(String) onDelete;

  const BaptismsList({
    super.key,
    required this.baptisms,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (baptisms.isEmpty) {
      return const Center(
        child: Text("Aucun baptême trouvé"),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: baptisms.length,
      itemBuilder: (_, i) {
        final b = baptisms[i];

        return BaptismTile(
          baptism: b,
          onEdit: () => onEdit(b),
          onDelete: () => onDelete(b.id),
        );
      },
    );
  }
}
