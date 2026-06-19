import 'package:dental_app/core/features/bureaux/domain/entity/BureauEntity.dart';

abstract class BureauRepository {
  Future<List<BureauEntity>> getBureaus();
  Future<void> addBureau(BureauEntity bureau);
  Future<void> updateBureau(BureauEntity bureau);
  Future<void> deleteBureau(int bureauId);
}
