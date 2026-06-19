import 'package:dental_app/core/features/bureaux/data/bureau_model.dart';
import 'package:dental_app/core/features/bureaux/data/bureau_remote_data_source.dart';
import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';
import 'package:dental_app/core/features/bureaux/domain/repositories/bureau_repository.dart';

class BureauRepositoryImpl implements BureauRepository {
  final BureauRemoteDataSource dataSource;

  BureauRepositoryImpl(this.dataSource);

  @override
  Future<List<BureauEntity>> getBureaus() => dataSource.getBureaux();

  @override
  Future<void> addBureau(BureauEntity bureau) =>
      dataSource.addBureau(BureauModel.fromEntity(bureau));

  @override
  Future<void> updateBureau(BureauEntity bureau) =>
      dataSource.updateBureau(BureauModel.fromEntity(bureau));

  @override
  Future<void> deleteBureau(int bureauId) => dataSource.deleteBureau(bureauId);
}
