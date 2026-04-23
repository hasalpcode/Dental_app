import 'package:dental_app/core/features/baptemes/data/baptem_model.dart';
import 'package:dental_app/core/features/baptemes/data/baptem_remote_data_source.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class BaptismRepositoryImpl implements BaptismRepository {
  final BaptismRemoteDataSource dataSource;

  BaptismRepositoryImpl(this.dataSource);

  @override
  Future<List<Baptism>> getBaptisms() async {
    final models = await dataSource.getBaptisms();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Baptism> addBaptism(Baptism baptism) async {
    final model = await dataSource.addBaptism(
      BaptismModel.fromEntity(baptism),
    );
    return model.toEntity();
  }

  @override
  Future<Baptism> updateBaptism(Baptism baptism) async {
    final model = await dataSource.updateBaptism(
      BaptismModel.fromEntity(baptism),
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteBaptism(String id) async {
    await dataSource.deleteBaptism(id);
  }

  @override
  Future<Baptism> getBaptismById(String id) async {
    final model = await dataSource.getBaptismById(id);
    return model.toEntity();
  }
}
