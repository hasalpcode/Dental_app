import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

class GetPayments {
  final PaymentRepository repository;

  GetPayments(this.repository);

  Future<List<PaymentEntity>> call() {
    return repository.getPayments();
  }
}
