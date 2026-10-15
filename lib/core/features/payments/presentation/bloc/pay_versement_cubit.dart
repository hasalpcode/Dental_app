import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/payments/domain/usecases/check_payment_status.dart';
import 'package:dental_app/core/features/payments/domain/usecases/initiate_versement_payment.dart';
import 'pay_versement_state.dart';

class PayVersementCubit extends Cubit<PayVersementState> {
  final InitiateVersementPayment initiateUseCase;
  final CheckPaymentStatus checkStatusUseCase;
  Timer? _pollTimer;

  PayVersementCubit(this.initiateUseCase, this.checkStatusUseCase)
      : super(const PayVersementState());

  Future<void> submit({
    required int membreId,
    required String mois,
    required double montant,
    required String provider,
    required String phoneNumber,
    String? customerName,
    String? customerEmail,
  }) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      final initiation = await initiateUseCase(
        membreId: membreId,
        mois: mois,
        montant: montant,
        provider: provider,
        phoneNumber: phoneNumber,
        customerName: customerName,
        customerEmail: customerEmail,
      );
      emit(state.copyWith(
        isSubmitting: false,
        step: PayVersementStep.waitingConfirmation,
        initiation: initiation,
      ));
      _startPolling(initiation.invoiceToken);
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }

  /// Le membre valide le paiement depuis l'appli Wave/Orange Money, hors de
  /// notre contrôle : on reinterroge le statut régulièrement plutôt que
  /// d'attendre un signal, le temps qu'il revienne sur l'appli.
  void _startPolling(String invoiceToken) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkNow(invoiceToken);
    });
  }

  Future<void> checkNow(String invoiceToken) async {
    if (state.isChecking) return;
    emit(state.copyWith(isChecking: true));
    try {
      final status = await checkStatusUseCase(invoiceToken);
      if (status.isCompleted) {
        _pollTimer?.cancel();
        emit(state.copyWith(
          isChecking: false,
          step: PayVersementStep.success,
          status: status,
        ));
      } else if (status.isFailed) {
        _pollTimer?.cancel();
        emit(state.copyWith(
          isChecking: false,
          step: PayVersementStep.failed,
          status: status,
        ));
      } else {
        emit(state.copyWith(isChecking: false, status: status));
      }
    } catch (e) {
      emit(state.copyWith(isChecking: false, error: e.toString()));
    }
  }

  void reset() {
    _pollTimer?.cancel();
    emit(const PayVersementState());
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
