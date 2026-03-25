import 'package:dental_app/core/features/projects/data/project_local_data_source.dart';
import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource dataSource;

  ProjectRepositoryImpl(this.dataSource);

  @override
  List<ProjectEntity> getProjects() => dataSource.getProjects();

  @override
  void addProject(ProjectEntity project) => dataSource.addProject(project);

  @override
  void updateProject(ProjectEntity project) =>
      dataSource.updateProject(project);

  @override
  void deleteProject(String id) => dataSource.deleteProject(id);
}
