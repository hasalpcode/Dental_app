import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/presentation/widgets/project_title.dart';
import 'package:flutter/material.dart';

class ProjectsList extends StatelessWidget {
  final List<ProjectEntity> projects;
  final Function(ProjectEntity)? onEdit;
  final Function(int)? onDelete;
  final Function(ProjectEntity) onTap;

  const ProjectsList({
    super.key,
    required this.projects,
    this.onEdit,
    this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    for (var p in projects) {
      print("Project: ${p.libelle}, ID: ${p.projectId}");
    }
    if (projects.isEmpty) {
      return const Center(child: Text("Aucun projet"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (_, i) {
        final p = projects[i];

        return ProjectTile(
          project: p,
          onTap: () => onTap(p),
          onEdit: onEdit != null ? () => onEdit!(p) : null,
          onDelete: onDelete != null && p.projectId != null
              ? () => onDelete!(p.projectId!)
              : null,
        );
      },
    );
  }
}
