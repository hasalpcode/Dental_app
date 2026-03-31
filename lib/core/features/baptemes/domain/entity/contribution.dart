import 'package:dental_app/core/features/members/domain/entity/member.dart';

class Contribution {
  final Member member;
  final double amount;

  Contribution({
    required this.member,
    required this.amount,
  });
}
