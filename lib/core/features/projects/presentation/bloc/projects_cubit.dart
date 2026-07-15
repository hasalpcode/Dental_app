import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/usecases/add_project.dart';
import 'package:dental_app/core/features/projects/domain/usecases/delete_project.dart';
import 'package:dental_app/core/features/projects/domain/usecases/get_projects.dart';
import 'package:dental_app/core/features/projects/domain/usecases/update_project.dart';
import 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final GetProjects getProjectsUseCase;
  final AddProject addProjectUseCase;
  final UpdateProject updateProjectUseCase;
  final DeleteProject deleteProjectUseCase;

  ProjectsCubit(
    this.getProjectsUseCase,
    this.addProjectUseCase,
    this.updateProjectUseCase,
    this.deleteProjectUseCase,
  ) : super(const ProjectsState());

  Future<void> loadProjects() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final fetchedProjects = await getProjectsUseCase();
      emit(state.copyWith(isLoading: false, projects: fetchedProjects));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addProject(ProjectEntity project) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addProjectUseCase(project);
      await loadProjects();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateProject(ProjectEntity project) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updateProjectUseCase(project);
      await loadProjects();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteProject(int id) async {
    emit(state.copyWith(isDeleting: true, error: null));
    try {
      await deleteProjectUseCase(id);
      await loadProjects();
    } catch (e) {
      emit(state.copyWith(isDeleting: false, error: e.toString()));
      rethrow;
    }
  }
}
