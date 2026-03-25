import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

import 'payment_local_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentLocalDataSource dataSource;

  PaymentRepositoryImpl(this.dataSource);

  @override
  List<PaymentEntity> getPayments() => dataSource.getPayments();

  @override
  void addPayment(PaymentEntity payment) => dataSource.addPayment(payment);

  @override
  void updatePayment(PaymentEntity payment) =>
      dataSource.updatePayment(payment);

  @override
  void deletePayment(String id) => dataSource.deletePayment(id);
}
