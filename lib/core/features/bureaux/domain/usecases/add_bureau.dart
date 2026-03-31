import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/repositories/bureau_repository.dart';

class AddBureau {
  final BureauRepository repository;
  AddBureau(this.repository);

  void call(BureauEntity bureau) => repository.addBureau(bureau);
}
