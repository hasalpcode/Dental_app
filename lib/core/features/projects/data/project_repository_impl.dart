import 'package:dental_app/core/features/projects/data/project_model.dart';
import 'package:dental_app/core/features/projects/data/project_remote_data_source.dart';
import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProjectEntity>> getProjects() async {
    return await remoteDataSource.getProjects();
  }

  @override
  Future<ProjectEntity> addProject(ProjectEntity project) async {
    return await remoteDataSource.addProject(
      ProjectModel.fromEntity(project),
    );
  }

  @override
  Future<ProjectEntity> updateProject(ProjectEntity project) async {
    return await remoteDataSource
        .updateProject(ProjectModel.fromEntity(project));
  }

  @override
  Future<void> deleteProject(int id) async {
    await remoteDataSource.deleteProject(id);
  }
}
