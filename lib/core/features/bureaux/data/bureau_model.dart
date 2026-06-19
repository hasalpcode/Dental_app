import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';

class BureauModel extends BureauEntity {
  BureauModel({
    required super.bureauId,
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

  Map<String, dynamic> toJson() => {
        'bureauId': bureauId,
        'name': name,
        'description': description,
      };

  factory BureauModel.fromEntity(BureauEntity e) => BureauModel(
        bureauId: e.bureauId,
        name: e.name,
        description: e.description,
      );
}
