import 'package:dental_app/core/features/projects/data/project_local_data_source.dart';
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

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final ProjectRepositoryImpl repository;
  late final GetProjects getProjects;
  late final AddProject addProject;
  late final UpdateProject updateProject;
  late final DeleteProject deleteProject;

  late List<ProjectEntity> projects;

  List<ProjectEntity> get filteredProjects {
    return projects;
  }

  @override
  void initState() {
    super.initState();
    final dataSource = ProjectLocalDataSource();
    repository = ProjectRepositoryImpl(dataSource);

    getProjects = GetProjects(repository);
    addProject = AddProject(repository);
    updateProject = UpdateProject(repository);
    deleteProject = DeleteProject(repository);

    projects = getProjects();
  }

  void _refresh() {
    setState(() => projects = getProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Projects"),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔹 Filtre mois / année

          // 🔹 Liste filtrée
          Expanded(
            child: ProjectsList(
              projects: filteredProjects,
              onEdit: _openEditModal,
              onDelete: (id) {
                deleteProject(id);
                _refresh();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Modal ajout
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectModal(
        project: null,
        bureaus: ["Bureau A", "Bureau B", "Bureau C"],
        onSubmit: (p) {
          addProject(p);
          _refresh();
        },
      ),
    );
  }

  // 🔹 Modal édition
  void _openEditModal(ProjectEntity Project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddProjectModal(
        project: Project,
        bureaus: ["Bureau A", "Bureau B", "Bureau C"],
        onSubmit: (p) {
          updateProject(p);
          _refresh();
        },
      ),
    );
  }
}
