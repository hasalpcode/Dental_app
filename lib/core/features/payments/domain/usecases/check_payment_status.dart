import 'package:dental_app/core/features/payments/domain/entity/payment_gateway_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_gateway_repository.dart';

class CheckPaymentStatus {
  final PaymentGatewayRepository repository;

  CheckPaymentStatus(this.repository);

  Future<PaymentStatusEntity> call(String invoiceToken) {
    return repository.getPaymentStatus(invoiceToken);
  }
}
