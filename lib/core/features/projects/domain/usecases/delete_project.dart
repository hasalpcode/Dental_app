import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class DeleteProject {
  final ProjectRepository repository;
  DeleteProject(this.repository);

  void call(String id) => repository.deleteProject(id);
}
