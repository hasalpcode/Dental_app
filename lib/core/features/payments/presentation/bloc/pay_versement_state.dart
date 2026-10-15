import 'package:dental_app/core/features/payments/domain/entity/payment_gateway_entity.dart';

enum PayVersementStep { form, waitingConfirmation, success, failed }

class PayVersementState {
  final PayVersementStep step;
  final bool isSubmitting;
  final bool isChecking;
  final String? error;
  final PaymentInitiationEntity? initiation;
  final PaymentStatusEntity? status;

  const PayVersementState({
    this.step = PayVersementStep.form,
    this.isSubmitting = false,
    this.isChecking = false,
    this.error,
    this.initiation,
    this.status,
  });

  PayVersementState copyWith({
    PayVersementStep? step,
    bool? isSubmitting,
    bool? isChecking,
    String? error,
    PaymentInitiationEntity? initiation,
    PaymentStatusEntity? status,
  }) {
    return PayVersementState(
      step: step ?? this.step,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isChecking: isChecking ?? this.isChecking,
      error: error,
      initiation: initiation ?? this.initiation,
      status: status ?? this.status,
    );
  }
}
