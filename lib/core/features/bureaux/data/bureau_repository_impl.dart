import 'package:dental_app/core/features/bureaux/data/bureau_local_data_source.dart';
import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/repositories/bureau_repository.dart';

class BureauRepositoryImpl implements BureauRepository {
  final BureauLocalDataSource dataSource;

  BureauRepositoryImpl(this.dataSource);

  @override
  List<BureauEntity> getBureaus() => dataSource.getBureaus();

  @override
  void addBureau(BureauEntity bureau) => dataSource.addBureau(bureau);

  @override
  void updateBureau(BureauEntity bureau) => dataSource.updateBureau(bureau);

  @override
  void deleteBureau(String bureauId) => dataSource.deleteBureau(bureauId);
}
