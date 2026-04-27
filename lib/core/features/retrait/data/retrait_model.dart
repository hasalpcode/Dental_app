import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';

class RetraitModel {
  final int? retraitId;
  final int caissierId;
  final String motif;
  final double montant;
  final DateTime? dateRetrait;

  RetraitModel({
    this.retraitId,
    required this.caissierId,
    required this.motif,
    required this.montant,
    this.dateRetrait,
  });

  factory RetraitModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return RetraitModel(
      retraitId: parseInt(json['retraitId']),
      caissierId: parseInt(json['caissierId']) ?? 0,
      motif: json['motif'] ?? '',
      montant: (json['montant'] as num).toDouble(),
      dateRetrait: json['dateRetrait'] != null
          ? DateTime.parse(json['dateRetrait'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "retraitId": retraitId,
      "caissierId": caissierId,
      "motif": motif,
      "montant": montant,
      "dateRetrait": dateRetrait?.toIso8601String(),
    };
  }

  RetraitEntity toEntity() {
    return RetraitEntity(
      retraitId: retraitId,
      caissierId: caissierId,
      motif: motif,
      montant: montant,
      dateRetrait: dateRetrait,
    );
  }

  factory RetraitModel.fromEntity(RetraitEntity e) {
    return RetraitModel(
      retraitId: e.retraitId,
      caissierId: e.caissierId,
      motif: e.motif,
      montant: e.montant,
      dateRetrait: e.dateRetrait,
    );
  }
}
