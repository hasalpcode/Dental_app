import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

class GetVersementsMembreAnnee {
  final PaymentRepository repository;

  GetVersementsMembreAnnee(this.repository);

  Future<List<PaymentEntity>> call(int membreId, int annee) {
    return repository.getVersementsForMembre(membreId, annee);
  }
}
