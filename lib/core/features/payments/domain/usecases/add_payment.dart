import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

class AddPayment {
  final PaymentRepository repository;

  AddPayment(this.repository);

  Future<PaymentEntity> call(PaymentEntity payment) {
    return repository.addPayment(
      PaymentModel.fromEntity(payment),
    );
  }
}
