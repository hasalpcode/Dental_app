import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class GetProjects {
  final ProjectRepository repository;
  GetProjects(this.repository);

  List<ProjectEntity> call() => repository.getProjects();
}
