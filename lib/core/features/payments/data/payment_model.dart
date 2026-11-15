import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

class PaymentModel {
  final String? id;
  final List<int> membreIds;
  final String mois;
  final int? annee;
  final double montant;
  final DateTime? dateVersement;

  PaymentModel({
    this.id,
    required this.membreIds,
    required this.mois,
    this.annee,
    required this.montant,
    this.dateVersement,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['versementId']?.toString() ?? json['id']?.toString(),
      membreIds: json['membreId'] != null
          ? (json['membreId'] is List
              ? List<int>.from(json['membreId'])
              : [json['membreId'] as int])
          : [],
      mois: json['mois'] ?? '',
      annee: json['annee'] as int?,
      montant: (json['montant'] as num).toDouble(),
      dateVersement: json['dateVersement'] != null
          ? DateTime.parse(json['dateVersement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "membreIds": membreIds,
      "mois": mois,
      "annee": annee,
      "montant": montant,
      "dateVersement": dateVersement?.toIso8601String(),
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      membreId: membreIds,
      mois: mois,
      annee: annee,
      montant: montant,
      dateVersement: dateVersement,
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity e) {
    return PaymentModel(
      id: e.id,
      membreIds: e.membreId,
      mois: e.mois,
      annee: e.annee,
      montant: e.montant,
      dateVersement: e.dateVersement,
    );
  }
}
