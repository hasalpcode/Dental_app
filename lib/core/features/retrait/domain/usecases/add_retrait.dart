import 'package:dental_app/core/features/retrait/data/retrait_model.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/repository/retrait_repository.dart';

class AddRetrait {
  final RetraitRepository repository;

  AddRetrait(this.repository);

  Future<RetraitEntity> call(RetraitEntity retrait) {
    return repository.addRetrait(
      RetraitModel.fromEntity(retrait),
    );
  }
}
