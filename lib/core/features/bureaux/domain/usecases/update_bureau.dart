import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/repositories/bureau_repository.dart';

class UpdateBureau {
  final BureauRepository repository;
  UpdateBureau(this.repository);

  void call(BureauEntity bureau) => repository.updateBureau(bureau);
}
