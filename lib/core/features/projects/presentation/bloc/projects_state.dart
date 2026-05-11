import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';

class ProjectsState {
  final bool isLoading;
  final bool isDeleting;
  final List<ProjectEntity> projects;
  final String? error;

  const ProjectsState({
    this.isLoading = false,
    this.isDeleting = false,
    this.projects = const [],
    this.error,
  });

  ProjectsState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<ProjectEntity>? projects,
    String? error,
  }) {
    return ProjectsState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      projects: projects ?? this.projects,
      error: error,
    );
  }
}
