import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/repository/retrait_repository.dart';

class GetRetraits {
  final RetraitRepository repository;

  GetRetraits(this.repository);

  Future<List<RetraitEntity>> call() {
    return repository.getRetraits();
  }
}
