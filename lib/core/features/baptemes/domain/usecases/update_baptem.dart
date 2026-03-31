import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class UpdateBaptism {
  final BaptismRepository repository;

  UpdateBaptism(this.repository);

  void call(Baptism b) => repository.updateBaptism(b);
}
