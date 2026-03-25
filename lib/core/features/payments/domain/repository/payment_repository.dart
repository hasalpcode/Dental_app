import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

abstract class PaymentRepository {
  List<PaymentEntity> getPayments();
  void addPayment(PaymentEntity payment);
  void updatePayment(PaymentEntity payment);
  void deletePayment(String id);
}
