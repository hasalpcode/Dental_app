import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';

abstract class BureauRepository {
  List<BureauEntity> getBureaus();
  void addBureau(BureauEntity bureau);
  void updateBureau(BureauEntity bureau);
  void deleteBureau(String bureauId);
}
