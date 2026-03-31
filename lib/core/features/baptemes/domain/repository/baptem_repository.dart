import 'package:dental_app/core/features/baptemes/domain/entity/bapteme_entity.dart';

abstract class BaptismRepository {
  List<Baptism> getBaptisms();
  void addBaptism(Baptism baptism);
  void updateBaptism(Baptism baptism);
  void deleteBaptism(String id);
  Baptism getBaptismById(String id);
}
