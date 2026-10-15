import 'package:dental_app/core/features/payments/domain/entity/payment_gateway_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_gateway_repository.dart';

class InitiateVersementPayment {
  final PaymentGatewayRepository repository;

  InitiateVersementPayment(this.repository);

  Future<PaymentInitiationEntity> call({
    required int membreId,
    required String mois,
    required double montant,
    required String provider,
    required String phoneNumber,
    String? customerName,
    String? customerEmail,
  }) {
    return repository.initiateVersementPayment(
      membreId: membreId,
      mois: mois,
      montant: montant,
      provider: provider,
      phoneNumber: phoneNumber,
      customerName: customerName,
      customerEmail: customerEmail,
    );
  }
}
