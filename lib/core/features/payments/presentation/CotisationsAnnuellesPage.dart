import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_my_member.dart';
import 'package:dental_app/core/features/members/presentation/bloc/members_cubit.dart';
import 'package:dental_app/core/features/members/presentation/bloc/members_state.dart';
import 'package:dental_app/core/features/payments/data/payment_remote_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_versements_membre_annee.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/cotisations_annuelles_cubit.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/cotisations_annuelles_state.dart';
import 'package:dental_app/core/helpers/api_client.dart';
import 'package:dental_app/core/helpers/date_helpers.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

/// Vue annuelle "mois versés / non versés" d'un membre : par défaut le
/// membre connecté, avec en plus un sélecteur de membre pour un COMPTABLE
/// qui veut consulter la situation de n'importe qui.
class CotisationsAnnuellesPage extends StatefulWidget {
  const CotisationsAnnuellesPage({super.key});

  @override
  State<CotisationsAnnuellesPage> createState() =>
      _CotisationsAnnuellesPageState();
}

class _CotisationsAnnuellesPageState extends State<CotisationsAnnuellesPage> {
  late final CotisationsAnnuellesCubit cubit;

  bool _loadingMember = true;
  String? _memberError;

  Member? _selectedMember;
  int _selectedYear = DateTime.now().year;
  final List<int> _years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();

    final client = ApiClient.instance;
    final paymentRepo = PaymentRepositoryImpl(PaymentRemoteDataSource(client));
    cubit = CotisationsAnnuellesCubit(GetVersementsMembreAnnee(paymentRepo));

    _resolveMyMember();
  }

  Future<void> _resolveMyMember() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.userId;
    if (userId == null) {
      setState(() {
        _loadingMember = false;
        _memberError = 'Utilisateur non connecté';
      });
      return;
    }

    try {
      final memberRepo =
          MemberRepositoryImpl(MemberRemoteDataSource(ApiClient.instance));
      final member = await GetMyMember(memberRepo)(userId);

      if (auth.isComptable || auth.canModify) {
        final membersCubit = context.read<MembersCubit>();
        if (membersCubit.state.members.isEmpty) {
          await membersCubit.loadMembers();
        }
      }

      setState(() {
        _loadingMember = false;
        _selectedMember = member;
        if (member == null) {
          _memberError = "Aucune fiche membre n'est associée à votre compte."
              " Contactez votre comptable.";
        }
      });
      _reload();
    } catch (e) {
      setState(() {
        _loadingMember = false;
        _memberError = e.toString();
      });
    }
  }

  void _reload() {
    final membreId = _selectedMember?.membreId;
    if (membreId == null) return;
    cubit.load(membreId, _selectedYear);
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAdmin = auth.isComptable || auth.canModify;

    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: const CurvedAppBar(title: 'Suivi annuel des cotisations'),
        body: _loadingMember
            ? const Center(child: CircularProgressIndicator())
            : (_selectedMember == null && !isAdmin)
                ? _buildMemberError(_memberError!)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAdmin) ...[
                          _buildMemberPicker(),
                          const SizedBox(height: 15),
                        ],
                        _buildYearSelector(),
                        const SizedBox(height: 20),
                        if (_selectedMember != null)
                          Text(
                            _selectedMember!.displayName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          )
                        else if (isAdmin)
                          const Text(
                            'Sélectionnez un membre pour voir sa situation.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 15),
                        if (_selectedMember != null)
                          BlocBuilder<CotisationsAnnuellesCubit,
                              CotisationsAnnuellesState>(
                            builder: (context, state) {
                              if (state.isLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              if (state.error != null) {
                                return Text(state.error!,
                                    style:
                                        const TextStyle(color: Colors.red));
                              }
                              return _buildMonthsGrid(state.moisVerses);
                            },
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildMemberError(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message ?? 'Erreur', textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildMemberPicker() {
    return BlocBuilder<MembersCubit, MembersState>(
      builder: (context, state) {
        return Autocomplete<Member>(
          initialValue: TextEditingValue(
            text: _selectedMember?.displayName ?? '',
          ),
          displayStringForOption: (m) => m.displayName,
          optionsBuilder: (TextEditingValue value) {
            final query = value.text.trim().toLowerCase();
            if (query.isEmpty) return const Iterable<Member>.empty();
            return state.members.where((m) =>
                (m.carteMembre?.toLowerCase().contains(query) ?? false) ||
                m.username.toLowerCase().contains(query));
          },
          onSelected: (Member selection) {
            setState(() => _selectedMember = selection);
            _reload();
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: "Numéro de carte ou nom du membre",
                hintText: "Tapez pour rechercher...",
                prefixIcon: const Icon(Icons.badge_outlined),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(15),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 220, maxWidth: 320),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.person_outline,
                            color: Color(0xfff08024)),
                        title: Text(option.displayName),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildYearSelector() {
    return DropdownButton<int>(
      value: _selectedYear,
      items: _years
          .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => _selectedYear = v);
        _reload();
      },
    );
  }

  Widget _buildMonthsGrid(Set<int> moisVerses) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: List.generate(12, (i) {
        final month = i + 1;
        final paid = moisVerses.contains(month);
        return Container(
          decoration: BoxDecoration(
            color: paid ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: paid ? Colors.green : Colors.red.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                paid ? Icons.check_circle : Icons.cancel_outlined,
                color: paid ? Colors.green : Colors.red,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                monthNameFr(month),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: paid ? Colors.green[800] : Colors.red[700],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
