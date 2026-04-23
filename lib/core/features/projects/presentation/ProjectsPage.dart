import 'package:dental_app/core/features/projects/data/project_remote_data_source.dart';
import 'package:dental_app/core/features/projects/data/project_repository_impl.dart';
import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';
import 'package:dental_app/core/features/projects/domain/usecases/add_project.dart';
import 'package:dental_app/core/features/projects/domain/usecases/delete_project.dart';
import 'package:dental_app/core/features/projects/domain/usecases/get_projects.dart';
import 'package:dental_app/core/features/projects/domain/usecases/update_project.dart';
import 'package:dental_app/core/features/projects/presentation/widgets/add_project_modal.dart';
import 'package:dental_app/core/features/projects/presentation/widgets/projects_list.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  List<ProjectEntity> projects = [];
  bool isLoading = true;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();

    final client = http.Client();

    final dataSource = ProjectRemoteDataSource();
    repository = ProjectRepositoryImpl(dataSource);

    getProjectsUseCase = GetProjects(repository);
    addProjectUseCase = AddProject(repository);
    updateProjectUseCase = UpdateProject(repository);
    deleteProjectUseCase = DeleteProject(repository);

    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => isLoading = true);

    try {
      final fetchedProjects = await getProjectsUseCase();

      setState(() {
        projects = fetchedProjects;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur récupération projets: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _refresh() async {
    await _loadProjects();
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
            await addProjectUseCase(p);
            await _refresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur ajout projet: $e')),
            );
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
            await updateProjectUseCase(p);
            await _refresh();
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erreur modification projet: $e')),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Projects"), // ✅ FIX
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : projects.isEmpty
                  ? const Center(child: Text("Aucun projet trouvé"))
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ProjectsList(
                        projects: projects,
                        onEdit: _openEditModal,
                        onDelete: (id) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirmer la suppression'),
                              content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer ce projet?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Supprimer'),
                                ),
                              ],
                            ),
                          );

                          if (confirmed ?? false) {
                            setState(() => isDeleting = true);
                            try {
                              await deleteProjectUseCase(id);
                              await _refresh();
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Erreur suppression: $e')),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => isDeleting = false);
                              }
                            }
                          }
                        },
                      ),
                    ),
          if (isDeleting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
