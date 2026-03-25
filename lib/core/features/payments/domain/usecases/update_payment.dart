import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

class UpdatePayment {
  final PaymentRepository repository;
  UpdatePayment(this.repository);

  void call(PaymentEntity payment) => repository.updatePayment(payment);
}
