import 'package:dental_app/core/features/baptemes/presentation/widgets/baptem_details.dart';
import 'package:flutter/material.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

class BaptismTile extends StatelessWidget {
  final Baptism baptism;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BaptismTile({
    super.key,
    required this.baptism,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.church, color: Colors.white),
        ),
        title: Text(
          baptism.nomComplet,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${baptism.lieu} • ${_formatDate(baptism.dateCreation)}",
        ),

        // 🔥 menu actions
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Modifier')),
            PopupMenuItem(value: 'delete', child: Text('Supprimer')),
          ],
        ),

        // 🔥 navigation détail
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BaptismDetailPage(baptismId: baptism.id),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
