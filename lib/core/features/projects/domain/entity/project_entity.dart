class ProjectEntity {
  int? projectId;
  String libelle;
  String? status;
  String? description;
  double? budget;
  int? bureauId;
  DateTime? dateCreation;

  ProjectEntity({
    this.projectId,
    required this.libelle,
    this.status,
    this.description,
    this.bureauId,
    this.budget,
    this.dateCreation,
  });
}
