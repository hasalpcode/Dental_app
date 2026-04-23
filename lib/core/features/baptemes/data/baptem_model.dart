import 'package:dental_app/core/features/baptemes/data/contribution_model.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

class BaptismModel {
  final String id;
  final String nomComplet;
  final DateTime dateCreation;
  final String lieu;
  final List<ContributionModel> contributions;

  BaptismModel({
    required this.id,
    required this.nomComplet,
    required this.dateCreation,
    required this.lieu,
    required this.contributions,
  });

  Baptism toEntity() {
    return Baptism(
      id: id,
      nomComplet: nomComplet,
      dateCreation: dateCreation,
      lieu: lieu,
      contributions: contributions.map((e) => e.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nomComplet': nomComplet,
      'dateCreation': dateCreation.toIso8601String(),
      'lieu': lieu,
      'contributions': contributions.map((e) => e.toJson()).toList(),
    };
  }

  factory BaptismModel.fromEntity(Baptism b) {
    return BaptismModel(
      id: b.id,
      nomComplet: b.nomComplet,
      dateCreation: b.dateCreation,
      lieu: b.lieu,
      contributions:
          b.contributions.map((e) => ContributionModel.fromEntity(e)).toList(),
    );
  }

  factory BaptismModel.fromJson(Map<String, dynamic> json) {
    final String parsedId =
        json['id']?.toString() ?? json['birthId']?.toString() ?? '';
    final String nomComplet =
        json['nomComplet'] ?? json['name'] ?? json['title'] ?? '';
    final String lieu = json['lieu'] ?? json['place'] ?? json['location'] ?? '';
    final String dateString = json['dateCreation'] ??
        json['createdAt'] ??
        json['date'] ??
        json['birthDate'] ??
        '';
    final DateTime parsedDate = DateTime.tryParse(dateString) ?? DateTime.now();

    final contributionsJson = json['contributions'] as List<dynamic>? ?? [];

    return BaptismModel(
      id: parsedId,
      nomComplet: nomComplet,
      dateCreation: parsedDate,
      lieu: lieu,
      contributions: contributionsJson
          .map((e) => ContributionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
