import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPayments();
  Future<PaymentEntity> addPayment(PaymentModel payment);
  Future<PaymentEntity> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String id);
}
