import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

class PaymentsState {
  final bool isLoading;
  final bool isDeleting;
  final List<PaymentEntity> payments;
  final List<Member> members;
  final String? error;

  const PaymentsState({
    this.isLoading = false,
    this.isDeleting = false,
    this.payments = const [],
    this.members = const [],
    this.error,
  });

  PaymentsState copyWith({
    bool? isLoading,
    bool? isDeleting,
    List<PaymentEntity>? payments,
    List<Member>? members,
    String? error,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      payments: payments ?? this.payments,
      members: members ?? this.members,
      error: error,
    );
  }

  Map<int, Member> get memberMap {
    return {
      for (final m in members)
        if (m.membreId != null) m.membreId!: m,
    };
  }
}
