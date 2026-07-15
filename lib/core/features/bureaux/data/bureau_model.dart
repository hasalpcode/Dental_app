import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';

class BureauModel extends BureauEntity {
  BureauModel({
     super.bureauId,
    required super.name,
    required super.description,
  });

  factory BureauModel.fromJson(Map<String, dynamic> json) {
    return BureauModel(
      bureauId: json['bureauId'] ?? json['id'] ?? 0,
      name: json['name'] ?? json['nom'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'description': description,
    };
    // Le bureauId n'est envoyé que pour une modification : à la création,
    // c'est le backend qui l'attribue.
    if (bureauId != null) {
      json['bureauId'] = bureauId;
    }
    return json;
  }

  factory BureauModel.fromEntity(BureauEntity e) => BureauModel(
        bureauId: e.bureauId,
        name: e.name,
        description: e.description,
      );
}
