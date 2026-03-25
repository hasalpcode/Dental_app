import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

class DeletePayment {
  final PaymentRepository repository;
  DeletePayment(this.repository);

  void call(String id) => repository.deletePayment(id);
}
