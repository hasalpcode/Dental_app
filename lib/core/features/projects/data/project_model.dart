import 'package:dental_app/core/features/projects/domain/entity/project_entity.dart';

class ProjectModel extends ProjectEntity {
  ProjectModel({
    int? projectId,
    required String libelle,
    String? status,
    String? description,
    double? budget,
    int? bureauId,
    String? posteId,
    DateTime? dateCreation,
  }) : super(
          projectId: projectId,
          libelle: libelle,
          status: status,
          description: description,
          budget: budget,
          bureauId: bureauId,
          dateCreation: dateCreation,
        );

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['projectId']?.toInt() ?? null,
      libelle: json['libelle'].toString(),
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      budget: json['budget']?.toDouble() ?? null,
      bureauId: json['bureauId']?.toInt(),
      dateCreation: json['dateCreation'] != null
          ? DateTime.tryParse(json['dateCreation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'libelle': libelle,
      'status': status,
      'description': description,
      'budget': budget,
      'bureauId': bureauId,
      'dateCreation': dateCreation?.toIso8601String(),
    };
  }

  factory ProjectModel.fromEntity(ProjectEntity project) {
    return ProjectModel(
      projectId: project.projectId,
      libelle: project.libelle,
      status: project.status,
      description: project.description,
      budget: project.budget,
      bureauId: project.bureauId,
      dateCreation: project.dateCreation,
    );
  }
}
