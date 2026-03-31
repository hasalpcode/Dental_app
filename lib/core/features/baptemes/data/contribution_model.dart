import 'package:dental_app/core/features/baptemes/domain/entity/contribution.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';

class ContributionModel {
  final Member member;
  final double amount;

  ContributionModel({
    required this.member,
    required this.amount,
  });

  Contribution toEntity() {
    return Contribution(
      member: member,
      amount: amount,
    );
  }

  factory ContributionModel.fromEntity(Contribution c) {
    return ContributionModel(
      member: c.member,
      amount: c.amount,
    );
  }
}
