// import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';

// class ProjectLocalDataSource {
//   final List<ProjectEntity> _projects = [
//     ProjectEntity(
//       id: "1",
//       name: "Project 1",
//       description: "Description of Project 1",
//       bureauId: "Bureau1",
//     ),
//     ProjectEntity(
//       id: "2",
//       name: "Project 2",
//       description: "Description of Project 2",
//       bureauId: "Bureau2",
//     ),
//   ];

//   List<ProjectEntity> getProjects() => List.from(_projects);

//   void addProject(ProjectEntity project) => _projects.add(project);

//   void updateProject(ProjectEntity project) {
//     final index = _projects.indexWhere((p) => p.id == project.id);
//     if (index != -1) _projects[index] = project;
//   }

//   void deleteProject(String id) {
//     _projects.removeWhere((p) => p.id == id);
//   }
// }
