import 'package:dental_app/core/features/baptemes/data/baptem_model.dart';
import 'package:dental_app/core/features/baptemes/data/contribution_model.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';

class BaptismLocalDataSource {
  final List<BaptismModel> _baptisms = [
    BaptismModel(
      id: "1",
      title: "Baptême de Jean",
      date: DateTime(2024, 5, 10),
      location: "Paris",
      contributions: [
        ContributionModel(
          member: Member(
            userId: 2,
            username: "Alice",
            tel: "772552431",
            address: "456 Avenue de Lyon",
          ),
          amount: 50.0,
        ),
        ContributionModel(
          member: Member(
            userId: 1,
            username: "Bob",
            tel: "772552432",
            address: "123 Rue de Paris",
          ),
          amount: 30.0,
        ),
      ],
    ),
  ];

  // 🔹 GET ALL
  List<BaptismModel> getBaptisms() => _baptisms;

  // 🔹 ADD
  void addBaptism(BaptismModel b) => _baptisms.add(b);

  // 🔹 UPDATE
  void updateBaptism(BaptismModel b) {
    final index = _baptisms.indexWhere((e) => e.id == b.id);
    if (index != -1) {
      _baptisms[index] = b;
    }
  }

  // 🔹 DELETE
  void deleteBaptism(String id) {
    _baptisms.removeWhere((e) => e.id == id);
  }

  // 🔹 GET BY ID
  BaptismModel getBaptismById(String id) {
    return _baptisms.firstWhere((e) => e.id == id);
  }
}
