import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/usecases/add_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/delete_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_payments.dart';
import 'package:dental_app/core/features/payments/domain/usecases/update_payment.dart';
import 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final GetPayments getPaymentsUseCase;
  final GetMembers getMembersUseCase;
  final AddPayment addPaymentUseCase;
  final UpdatePayment updatePaymentUseCase;
  final DeletePayment deletePaymentUseCase;

  PaymentsCubit(
    this.getPaymentsUseCase,
    this.getMembersUseCase,
    this.addPaymentUseCase,
    this.updatePaymentUseCase,
    this.deletePaymentUseCase,
  ) : super(const PaymentsState());

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final results = await Future.wait([
        getPaymentsUseCase(),
        getMembersUseCase(),
      ]);
      emit(state.copyWith(
        isLoading: false,
        payments: results[0] as List<PaymentEntity>,
        members: results[1] as List<Member>,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addPayment(PaymentEntity payment) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await addPaymentUseCase(payment);
      await loadData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updatePayment(PaymentEntity payment) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await updatePaymentUseCase(payment);
      await loadData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deletePayment(String id) async {
    emit(state.copyWith(isDeleting: true, error: null));
    try {
      await deletePaymentUseCase(id);
      emit(state.copyWith(
        isDeleting: false,
        payments: state.payments.where((p) => p.id != id).toList(),
      ));
    } catch (e) {
      emit(state.copyWith(isDeleting: false, error: e.toString()));
    }
  }
}
