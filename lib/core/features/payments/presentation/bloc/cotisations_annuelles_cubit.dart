import 'package:bloc/bloc.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_versements_membre_annee.dart';
import 'cotisations_annuelles_state.dart';

class CotisationsAnnuellesCubit extends Cubit<CotisationsAnnuellesState> {
  final GetVersementsMembreAnnee getVersementsUseCase;

  CotisationsAnnuellesCubit(this.getVersementsUseCase)
      : super(const CotisationsAnnuellesState());

  Future<void> load(int membreId, int annee) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final versements = await getVersementsUseCase(membreId, annee);
      emit(state.copyWith(isLoading: false, versements: versements));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
