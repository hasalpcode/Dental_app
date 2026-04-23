import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class UpdateBaptism {
  final BaptismRepository repository;

  UpdateBaptism(this.repository);

  Future<Baptism> call(Baptism b) async => await repository.updateBaptism(b);
}
