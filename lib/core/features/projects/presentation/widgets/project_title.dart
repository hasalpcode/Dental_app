import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:flutter/material.dart';

class ProjectTile extends StatelessWidget {
  final ProjectEntity project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectTile({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = project.libelle;
    final description = project.description ?? '';
    final bureau = project.bureauId?.toString() ?? "N/A";
    final budget = project.budget != null
        ? "${project.budget!.toStringAsFixed(0)} €"
        : "No budget";

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
          // 🔹 Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.withOpacity(0.2),
            child: Text(
              title.isNotEmpty ? title[0].toUpperCase() : "?",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 🔹 Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bureau: $bureau",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  budget,
                  style: const TextStyle(color: Colors.grey),
                ),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // 🔹 Actions
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.orange),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          )
        ],
      ),
    );
  }
}
