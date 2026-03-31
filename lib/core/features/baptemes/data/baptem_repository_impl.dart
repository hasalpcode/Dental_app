import 'package:dental_app/core/features/baptemes/data/baptem_model.dart';
import 'package:dental_app/core/features/baptemes/data/data_source_local_baptem.dart';
import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';
import 'package:dental_app/core/features/baptemes/domain/repository/baptem_repository.dart';

class BaptismRepositoryImpl implements BaptismRepository {
  final BaptismLocalDataSource dataSource;

  BaptismRepositoryImpl(this.dataSource);

  @override
  List<Baptism> getBaptisms() {
    return dataSource.getBaptisms().map((e) => e.toEntity()).toList();
  }

  @override
  void addBaptism(Baptism baptism) {
    dataSource.addBaptism(
      BaptismModel.fromEntity(baptism),
    );
  }

  @override
  void updateBaptism(Baptism baptism) {
    dataSource.updateBaptism(
      BaptismModel.fromEntity(baptism),
    );
  }

  @override
  void deleteBaptism(String id) {
    dataSource.deleteBaptism(id);
  }

  @override
  Baptism getBaptismById(String id) {
    return dataSource.getBaptismById(id).toEntity();
  }
}
