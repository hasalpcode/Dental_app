class PaymentInitiationEntity {
  final int transactionId;
  final String invoiceToken;
  final String checkoutUrl;
  final String status;

  PaymentInitiationEntity({
    required this.transactionId,
    required this.invoiceToken,
    required this.checkoutUrl,
    required this.status,
  });
}

class PaymentStatusEntity {
  final int transactionId;
  final String invoiceToken;
  final String status;
  final int? versementId;

  PaymentStatusEntity({
    required this.transactionId,
    required this.invoiceToken,
    required this.status,
    this.versementId,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';
  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isFailed =>
      status.toUpperCase() == 'FAILED' || status.toUpperCase() == 'CANCELLED';
}
