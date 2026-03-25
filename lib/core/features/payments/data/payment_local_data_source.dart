import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

class PaymentLocalDataSource {
  final List<PaymentEntity> _payments = [
    PaymentEntity(
        id: "1",
        memberName: "John Doe",
        memberId: "123",
        amount: 100.0,
        date: DateTime.now()),
  ];

  List<PaymentEntity> getPayments() => List.from(_payments);

  void addPayment(PaymentEntity payment) => _payments.add(payment);

  void updatePayment(PaymentEntity payment) {
    final index = _payments.indexWhere((p) => p.id == payment.id);
    if (index != -1) _payments[index] = payment;
  }

  void deletePayment(String id) {
    _payments.removeWhere((p) => p.id == id);
  }
}
