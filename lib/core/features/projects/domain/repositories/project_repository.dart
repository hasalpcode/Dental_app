import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';

abstract class ProjectRepository {
  List<ProjectEntity> getProjects();
  void addProject(ProjectEntity project);
  void updateProject(ProjectEntity project);
  void deleteProject(String id);
}
