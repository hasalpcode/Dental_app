import 'package:dental_app/core/features/payments/domain/entity/payment_gateway_entity.dart';

abstract class PaymentGatewayRepository {
  Future<PaymentInitiationEntity> initiateVersementPayment({
    required int membreId,
    required String mois,
    required double montant,
    required String provider,
    required String phoneNumber,
    String? customerName,
    String? customerEmail,
  });

  Future<PaymentStatusEntity> getPaymentStatus(String invoiceToken);
}
