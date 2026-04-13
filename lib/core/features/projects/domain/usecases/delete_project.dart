import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class DeleteProject {
  final ProjectRepository repository;
  DeleteProject(this.repository);

  Future<void> call(int id) async {
    await repository.deleteProject(id);
  }
}
