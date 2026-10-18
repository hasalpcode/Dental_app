import 'package:dental_app/core/features/payments/domain/entity/payment_gateway_entity.dart';

class PaymentInitiationModel {
  final int transactionId;
  final String invoiceToken;
  final String checkoutUrl;
  final String status;

  PaymentInitiationModel({
    required this.transactionId,
    required this.invoiceToken,
    required this.checkoutUrl,
    required this.status,
  });

  factory PaymentInitiationModel.fromJson(Map<String, dynamic> json) {
    return PaymentInitiationModel(
      transactionId: json['transactionId'],
      invoiceToken: json['invoiceToken'],
      checkoutUrl: json['checkoutUrl'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }

  PaymentInitiationEntity toEntity() {
    return PaymentInitiationEntity(
      transactionId: transactionId,
      invoiceToken: invoiceToken,
      checkoutUrl: checkoutUrl,
      status: status,
    );
  }
}

class PaymentStatusModel {
  final int transactionId;
  final String invoiceToken;
  final String status;
  final int? versementId;

  PaymentStatusModel({
    required this.transactionId,
    required this.invoiceToken,
    required this.status,
    this.versementId,
  });

  factory PaymentStatusModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatusModel(
      transactionId: json['transactionId'],
      invoiceToken: json['invoiceToken'],
      status: json['status'] ?? 'PENDING',
      versementId: json['versementId'],
    );
  }

  PaymentStatusEntity toEntity() {
    return PaymentStatusEntity(
      transactionId: transactionId,
      invoiceToken: invoiceToken,
      status: status,
      versementId: versementId,
    );
  }
}
