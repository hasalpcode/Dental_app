import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';

abstract class ProjectRepository {
  Future<List<ProjectEntity>> getProjects();
  Future<ProjectEntity> addProject(ProjectEntity project);
  Future<ProjectEntity> updateProject(ProjectEntity project);
  Future<void> deleteProject(int id);
}
