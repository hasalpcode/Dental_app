import 'package:dental_app/core/features/retrait/data/retrait_model.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';

abstract class RetraitRepository {
  Future<List<RetraitEntity>> getRetraits();
  Future<RetraitEntity> addRetrait(RetraitModel retrait);
  Future<RetraitEntity> updateRetrait(RetraitModel retrait);
  Future<void> deleteRetrait(String id);
}
