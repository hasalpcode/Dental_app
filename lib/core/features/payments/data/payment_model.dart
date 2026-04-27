import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

class PaymentModel {
  final String? id;
  final List<int> membreIds;
  final String mois;
  final double montant;
  final DateTime? dateVersement;

  PaymentModel({
    this.id,
    required this.membreIds,
    required this.mois,
    required this.montant,
    this.dateVersement,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['versementId']?.toString() ?? json['id']?.toString(),
      membreIds: json['membreId'] != null
          ? [json['membreId'] as int]
          : (json['membreId'] != null ? List<int>.from(json['membreId']) : []),
      mois: json['mois'] ?? '',
      montant: (json['montant'] as num).toDouble(),
      dateVersement: json['dateVersement'] != null
          ? DateTime.parse(json['dateVersement'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "membreIds": membreIds,
      "mois": mois,
      "montant": montant,
      "dateVersement": dateVersement?.toIso8601String(),
    };
  }

  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      membreId: membreIds,
      mois: mois,
      montant: montant,
      dateVersement: dateVersement,
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity e) {
    return PaymentModel(
      id: e.id,
      membreIds: e.membreId,
      mois: e.mois,
      montant: e.montant,
      dateVersement: e.dateVersement,
    );
  }
}
