import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/repositories/bureau_repository.dart';

class GetBureaux {
  final BureauRepository repository;
  GetBureaux(this.repository);

  List<BureauEntity> call() => repository.getBureaus();
}
