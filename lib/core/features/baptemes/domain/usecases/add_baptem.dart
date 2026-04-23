import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class AddBaptism {
  final BaptismRepository repository;

  AddBaptism(this.repository);

  Future<Baptism> call(Baptism b) async => await repository.addBaptism(b);
}
