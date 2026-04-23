import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

abstract class BaptismRepository {
  Future<List<Baptism>> getBaptisms();
  Future<Baptism> addBaptism(Baptism baptism);
  Future<Baptism> updateBaptism(Baptism baptism);
  Future<void> deleteBaptism(String id);
  Future<Baptism> getBaptismById(String id);
}
