class PaymentEntity {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime date;

  PaymentEntity({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.date,
  });
}
