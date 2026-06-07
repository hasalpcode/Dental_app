import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/payments/data/payment_remote_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/usecases/add_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/delete_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_payments.dart';
import 'package:dental_app/core/features/payments/domain/usecases/update_payment.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/payments_cubit.dart';
import 'package:dental_app/core/features/payments/presentation/bloc/payments_state.dart';
import 'package:dental_app/core/features/payments/presentation/widgets/add_payment_modal.dart';
import 'package:dental_app/core/features/payments/presentation/widgets/payment_list.dart';
import 'package:dental_app/core/features/retrait/data/retrait_remote_data_source.dart';
import 'package:dental_app/core/features/retrait/data/retrait_repository_impl.dart';
import 'package:dental_app/core/features/retrait/domain/entity/retrait_entity.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/add_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/delete_retrait.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/get_retraits.dart';
import 'package:dental_app/core/features/retrait/domain/usecases/update_retrait.dart';
import 'package:dental_app/core/features/retrait/presentation/bloc/retrait_cubit.dart';
import 'package:dental_app/core/features/retrait/presentation/bloc/retrait_state.dart';
import 'package:dental_app/core/features/retrait/presentation/widgets/add_retrait_modal.dart';
import 'package:dental_app/core/features/retrait/presentation/widgets/retrait_list.dart';
import 'package:dental_app/core/features/auth/providers/auth_provider.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  // --- Versements ---
  late final PaymentsCubit paymentsCubit;

  // --- Retraits ---
  late final RetraitCubit retraitCubit;

  // --- UI state ---
  bool _showVersements = true;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final List<int> years = List.generate(5, (i) => DateTime.now().year - i);
  late final TextEditingController searchController;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    searchController = TextEditingController()
      ..addListener(() => setState(() => searchQuery = searchController.text));

    final client = http.Client();
    final memberRepo = MemberRepositoryImpl(MemberRemoteDataSource(client));
    final getMembers = GetMembers(memberRepo);

    final paymentRepo = PaymentRepositoryImpl(PaymentRemoteDataSource(client));
    paymentsCubit = PaymentsCubit(
      GetPayments(paymentRepo),
      getMembers,
      AddPayment(paymentRepo),
      UpdatePayment(paymentRepo),
      DeletePayment(paymentRepo),
    )..loadData();

    final retraitRepo = RetraitRepositoryImpl(RetraitRemoteDataSource(client));
    retraitCubit = RetraitCubit(
      GetRetraits(retraitRepo),
      getMembers,
      AddRetrait(retraitRepo),
      UpdateRetrait(retraitRepo),
      DeleteRetrait(retraitRepo),
    )..loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    paymentsCubit.close();
    retraitCubit.close();
    super.dispose();
  }

  // ---- Filtering ----

  List<PaymentEntity> get _filteredPayments {
    return paymentsCubit.state.payments.where((p) {
      final d = p.dateVersement;
      if (d == null) return false;
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList();
  }

  List<RetraitEntity> get _filteredRetraits {
    return retraitCubit.state.retraits.where((r) {
      final d = r.dateRetrait;
      if (d == null) return false;
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList();
  }

  // ---- Modals ----

  void _openAddPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPaymentModal(
        members: paymentsCubit.state.members,
        onSubmit: (p) async {
          await paymentsCubit.addPayment(p);
        },
      ),
    );
  }

  void _openEditPaymentModal(PaymentEntity payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPaymentModal(
        members: paymentsCubit.state.members,
        payment: payment,
        onSubmit: (p) async {
          await paymentsCubit.updatePayment(p);
        },
      ),
    );
  }

  void _openAddRetraitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRetraitModal(
        members: retraitCubit.state.members,
        onSubmit: (r) async {
          await retraitCubit.addRetrait(r);
        },
      ),
    );
  }

  void _openEditRetraitModal(RetraitEntity retrait) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddRetraitModal(
        members: retraitCubit.state.members,
        retrait: retrait,
        onSubmit: (r) async {
          await retraitCubit.updateRetrait(r);
        },
      ),
    );
  }

  // ---- Widgets helpers ----

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _toggleBtn('Versements', _showVersements, () {
              setState(() => _showVersements = true);
            }),
            _toggleBtn('Retraits', !_showVersements, () {
              setState(() => _showVersements = false);
            }),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.deepPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<int>(
              value: selectedMonth,
              isExpanded: true,
              items: List.generate(12, (i) => i + 1)
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text('Mois $m'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedMonth = v!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int>(
              value: selectedYear,
              isExpanded: true,
              items: years
                  .map((y) => DropdownMenuItem(
                        value: y,
                        child: Text('$y'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => selectedYear = v!),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par nom ou carte...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() => searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    final canModify =
        Provider.of<AuthProvider>(context, listen: false).canModify;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: paymentsCubit),
        BlocProvider.value(value: retraitCubit),
      ],
      child: Scaffold(
        appBar: const CurvedAppBar(title: 'Finance'),
        floatingActionButton: canModify
            ? FloatingActionButton(
                onPressed: _showVersements
                    ? _openAddPaymentModal
                    : _openAddRetraitModal,
                child: const Icon(Icons.add),
              )
            : null,
        body: Column(
          children: [
            _buildToggle(),
            _buildFilters(),
            _buildSearchBar(),
            Expanded(
              child: _showVersements
                  ? BlocBuilder<PaymentsCubit, PaymentsState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: paymentsCubit.loadData,
                              child: PaymentsList(
                                payments: _filteredPayments,
                                memberMap: state.memberMap,
                                searchQuery: searchQuery,
                                onEdit: canModify
                                    ? _openEditPaymentModal
                                    : null,
                                onDelete: canModify
                                    ? (id) async {
                                        final confirmed = await _confirmDelete(
                                            context, 'ce versement');
                                        if (confirmed) {
                                          await context
                                              .read<PaymentsCubit>()
                                              .deletePayment(id);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            if (state.isDeleting)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                          ],
                        );
                      },
                    )
                  : BlocBuilder<RetraitCubit, RetraitState>(
                      builder: (context, state) {
                        if (state.isLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Stack(
                          children: [
                            RefreshIndicator(
                              onRefresh: retraitCubit.loadData,
                              child: RetraitList(
                                retraits: _filteredRetraits,
                                memberMap: state.memberMap,
                                onEdit: canModify
                                    ? _openEditRetraitModal
                                    : null,
                                onDelete: canModify
                                    ? (id) async {
                                        final confirmed = await _confirmDelete(
                                            context, 'ce retrait');
                                        if (confirmed) {
                                          await context
                                              .read<RetraitCubit>()
                                              .deleteRetrait(id);
                                        }
                                      }
                                    : null,
                              ),
                            ),
                            if (state.isDeleting)
                              Container(
                                color: Colors.black26,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String label) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmer la suppression'),
            content: Text('Êtes-vous sûr de vouloir supprimer $label ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
