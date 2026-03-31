import 'package:dental_app/core/features/baptemes/data/contribution_model.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

class BaptismModel {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final List<ContributionModel> contributions;

  BaptismModel({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.contributions,
  });

  Baptism toEntity() {
    return Baptism(
      id: id,
      title: title,
      date: date,
      location: location,
      contributions: contributions.map((e) => e.toEntity()).toList(),
    );
  }

  factory BaptismModel.fromEntity(Baptism b) {
    return BaptismModel(
      id: b.id,
      title: b.title,
      date: b.date,
      location: b.location,
      contributions:
          b.contributions.map((e) => ContributionModel.fromEntity(e)).toList(),
    );
  }
}
