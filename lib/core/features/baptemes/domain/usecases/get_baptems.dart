import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class GetBaptisms {
  final BaptismRepository repository;

  GetBaptisms(this.repository);

  Future<List<Baptism>> call() async => await repository.getBaptisms();
}
