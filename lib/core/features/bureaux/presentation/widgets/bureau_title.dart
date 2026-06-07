import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:flutter/material.dart';

class BureauTile extends StatelessWidget {
  final BureauEntity project;
  final VoidCallback onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BureauTile({
    super.key,
    required this.project,
    required this.onDetails,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onDetails,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xff0b5260).withOpacity(0.15),
                    child: Text(
                      project.name[0],
                      style: const TextStyle(
                          fontSize: 22,
                          color: Color(0xff0b5260),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('ID: ${project.bureauId}',
                            style: const TextStyle(color: Colors.grey)),
                        Text("${project.description}",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              if (onEdit != null)
                IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, color: Colors.orange)),
              if (onDelete != null)
                IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          )
        ],
      ),
    );
  }
}
