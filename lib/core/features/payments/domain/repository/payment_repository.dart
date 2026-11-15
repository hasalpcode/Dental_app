import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentEntity>> getPayments();
  Future<void> addPayment(PaymentModel payment);
  Future<void> updatePayment(PaymentModel payment);
  Future<void> deletePayment(String id);
  Future<List<PaymentEntity>> getVersementsForMembre(int membreId, int annee);
}
