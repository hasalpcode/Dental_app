import 'package:dental_app/core/features/projects/data/project_remote_data_source.dart';
import 'package:dental_app/core/features/projects/data/project_repository_impl.dart';
import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/usecases/add_project.dart';
import 'package:dental_app/core/features/projects/domain/usecases/delete_project.dart';
import 'package:dental_app/core/features/projects/domain/usecases/get_projects.dart';
import 'package:dental_app/core/features/projects/domain/usecases/update_project.dart';
import 'package:dental_app/core/features/projects/presentation/bloc/projects_cubit.dart';
import 'package:dental_app/core/features/projects/presentation/bloc/projects_state.dart';
import 'package:dental_app/core/features/projects/presentation/widgets/add_project_modal.dart';
import 'package:dental_app/core/features/projects/presentation/widgets/projects_list.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/projects/presentation/ProjectDetailPage.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectRepositoryImpl repository;
  late final GetProjects getProjectsUseCase;
  late final AddProject addProjectUseCase;
  late final UpdateProject updateProjectUseCase;
  late final DeleteProject deleteProjectUseCase;
  late final ProjectsCubit projectsCubit;

  @override
  void initState() {
    super.initState();

    final dataSource = ProjectRemoteDataSource();
    repository = ProjectRepositoryImpl(dataSource);

    getProjectsUseCase = GetProjects(repository);
    addProjectUseCase = AddProject(repository);
    updateProjectUseCase = UpdateProject(repository);
    deleteProjectUseCase = DeleteProject(repository);

    projectsCubit = ProjectsCubit(
      getProjectsUseCase,
      addProjectUseCase,
      updateProjectUseCase,
      deleteProjectUseCase,
    );

    projectsCubit.loadProjects();
  }

  @override
  void dispose() {
    projectsCubit.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    await projectsCubit.loadProjects();
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectModal(
        bureaus: [],
        onSubmit: (p) async {
          try {
            await projectsCubit.addProject(p);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur ajout projet: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _openEditModal(ProjectEntity project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectModal(
        project: project,
        bureaus: [],
        onSubmit: (p) async {
          try {
            await projectsCubit.updateProject(p);
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur modification projet: $e')),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canModify =
        Provider.of<AuthProvider>(context, listen: false).canModify;

    return BlocProvider.value(
      value: projectsCubit,
      child: BlocBuilder<ProjectsCubit, ProjectsState>(
        builder: (context, state) {
          for (var p in state.projects) {
            print("Project: ${p.libelle}, ID: ${p.projectId}");
          }
          return Scaffold(
            appBar: const CurvedAppBar(title: "Projets"),
            floatingActionButton: canModify
                ? FloatingActionButton(
                    onPressed: _openAddModal,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.add),
                  )
                : null,
            body: Stack(
              children: [
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.projects.isEmpty
                        ? const Center(child: Text("Aucun projet trouvé"))
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: ProjectsList(
                              projects: state.projects,
                              onTap: (p) => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProjectDetailPage(project: p),
                                ),
                              ),
                              onEdit: canModify ? _openEditModal : null,
                              onDelete: canModify
                                  ? (id) async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Confirmer la suppression'),
                                          content: const Text(
                                              'Êtes-vous sûr de vouloir supprimer ce projet?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Supprimer'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmed ?? false) {
                                        await context
                                            .read<ProjectsCubit>()
                                            .deleteProject(id);
                                      }
                                    }
                                  : null,
                            ),
                          ),
                if (state.isDeleting)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
