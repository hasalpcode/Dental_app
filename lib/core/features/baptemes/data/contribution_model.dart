import 'package:dental_app/core/features/baptemes/domain/entity/contribution.dart';

class ContributionModel {
  final int membreId;
  final double montant;

  ContributionModel({
    required this.membreId,
    required this.montant,
  });

  Contribution toEntity() {
    return Contribution(
      membreId: membreId,
      montant: montant,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'montant': montant,
      'membreId': membreId,
    };
  }

  factory ContributionModel.fromEntity(Contribution c) {
    return ContributionModel(
      membreId: c.membreId,
      montant: c.montant,
    );
  }

  factory ContributionModel.fromJson(Map<String, dynamic> json) {
    final montantValue = json['montant'];
    final montant = montantValue is num
        ? montantValue.toDouble()
        : double.tryParse(montantValue?.toString() ?? '') ?? 0.0;

    int? membreId;
    if (json['membreId'] != null) {
      membreId = json['membreId'] is int
          ? json['membreId'] as int
          : int.tryParse(json['membreId'].toString());
    } else if (json['memberId'] != null) {
      membreId = json['memberId'] is int
          ? json['memberId'] as int
          : int.tryParse(json['memberId'].toString());
    } else if (json['member'] is Map<String, dynamic>) {
      final memberJson = json['member'] as Map<String, dynamic>;
      membreId = memberJson['memberId'] is int
          ? memberJson['memberId'] as int
          : int.tryParse(memberJson['memberId']?.toString() ?? '');
    }

    return ContributionModel(
      membreId: membreId ?? 0,
      montant: montant,
    );
  }
}
