import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class AddProject {
  final ProjectRepository repository;
  AddProject(this.repository);

  // void call(ProjectEntity project) => repository.addProject(project);
  Future<ProjectEntity> call(ProjectEntity project) async {
    return await repository.addProject(project);
  }
}
