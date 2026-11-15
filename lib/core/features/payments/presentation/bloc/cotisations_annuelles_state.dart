import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';

class CotisationsAnnuellesState {
  final bool isLoading;
  final List<PaymentEntity> versements;
  final String? error;

  const CotisationsAnnuellesState({
    this.isLoading = false,
    this.versements = const [],
    this.error,
  });

  /// Numéros de mois (1-12) pour lesquels un versement existe déjà.
  Set<int> get moisVerses {
    return versements
        .map((v) => int.tryParse(v.mois))
        .whereType<int>()
        .toSet();
  }

  CotisationsAnnuellesState copyWith({
    bool? isLoading,
    List<PaymentEntity>? versements,
    String? error,
  }) {
    return CotisationsAnnuellesState(
      isLoading: isLoading ?? this.isLoading,
      versements: versements ?? this.versements,
      error: error,
    );
  }
}
