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
  Future<PaymentEntity> addPayment(PaymentModel payment) async {
    final result = await dataSource.addPayment(payment);
    return result.toEntity();
  }

  @override
  Future<PaymentEntity> updatePayment(PaymentModel payment) async {
    final result = await dataSource.updatePayment(payment);
    return result.toEntity();
  }

  @override
  Future<void> deletePayment(String id) {
    return dataSource.deletePayment(id);
  }
}
