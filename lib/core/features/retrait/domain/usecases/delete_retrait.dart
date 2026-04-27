import 'package:dental_app/core/features/retrait/domain/repository/retrait_repository.dart';

class DeleteRetrait {
  final RetraitRepository repository;

  DeleteRetrait(this.repository);

  Future<void> call(String id) {
    return repository.deleteRetrait(id);
  }
}
