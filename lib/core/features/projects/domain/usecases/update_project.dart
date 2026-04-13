import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class UpdateProject {
  final ProjectRepository repository;
  UpdateProject(this.repository);

  Future<ProjectEntity> call(ProjectEntity project) async {
    return await repository.updateProject(project);
  }
}
