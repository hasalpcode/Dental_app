import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/presentation/widgets/project_title.dart';
import 'package:flutter/material.dart';

class ProjectsList extends StatelessWidget {
  final List<ProjectEntity> projects;
  final Function(ProjectEntity) onEdit;
  final Function(int) onDelete;

  const ProjectsList({
    super.key,
    required this.projects,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
          onEdit: () => onEdit(p),
          onDelete: () {
            if (p.projectId != null) {
              onDelete(p.projectId!);
            }
          },
        );
      },
    );
  }
}
