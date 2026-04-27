import 'package:dental_app/core/features/retrait/data/retrait_model.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/repository/retrait_repository.dart';

import 'retrait_remote_data_source.dart';

class RetraitRepositoryImpl implements RetraitRepository {
  final RetraitRemoteDataSource dataSource;

  RetraitRepositoryImpl(this.dataSource);

  @override
  Future<List<RetraitEntity>> getRetraits() async {
    final result = await dataSource.getRetraits();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<RetraitEntity> addRetrait(RetraitModel retrait) async {
    final result = await dataSource.addRetrait(retrait);
    return result.toEntity();
  }

  @override
  Future<RetraitEntity> updateRetrait(RetraitModel retrait) async {
    final result = await dataSource.updateRetrait(retrait);
    return result.toEntity();
  }

  @override
  Future<void> deleteRetrait(String id) {
    return dataSource.deleteRetrait(id);
  }
}
