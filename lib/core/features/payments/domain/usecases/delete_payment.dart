import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

class DeletePayment {
  final PaymentRepository repository;

  DeletePayment(this.repository);

  Future<void> call(String id) {
    return repository.deletePayment(id);
  }
}
