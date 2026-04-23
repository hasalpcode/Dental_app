import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class GetBaptismById {
  final BaptismRepository repository;

  GetBaptismById(this.repository);

  Future<Baptism> call(String id) async => await repository.getBaptismById(id);
}
