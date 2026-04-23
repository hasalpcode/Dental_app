import 'package:dental_app/core/features/baptemes/domain/entity/contribution.dart';

class Baptism {
  final String id;
  final String nomComplet;
  final DateTime dateCreation;
  final String lieu;
  final List<Contribution> contributions;

  Baptism({
    required this.id,
    required this.nomComplet,
    required this.dateCreation,
    required this.lieu,
    required this.contributions,
  });
}
