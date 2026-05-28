import 'package:dental_app/core/features/payments/data/payment_model.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/repository/payment_repository.dart';

import 'payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource dataSource;

  PaymentRepositoryImpl(this.dataSource);

  @override
  Future<List<PaymentEntity>> getPayments() async {
    final result = await dataSource.getPayments();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addPayment(PaymentModel payment) {
    return dataSource.addPayment(payment);
  }

  @override
  Future<void> updatePayment(PaymentModel payment) {
    return dataSource.updatePayment(payment);
  }

  @override
  Future<void> deletePayment(String id) {
    return dataSource.deletePayment(id);
  }
}
