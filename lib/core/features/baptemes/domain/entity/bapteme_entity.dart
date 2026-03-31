import 'package:dental_app/core/features/baptemes/domain/entity/contribution.dart';

class Baptism {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final List<Contribution> contributions;

  Baptism({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.contributions,
  });
}
