import 'package:dental_app/core/features/members/data/data_remote_source.dart';
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
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late final PaymentRepositoryImpl paymentRepository;
  late final MemberRepositoryImpl memberRepository;

  late final GetPayments getPayments;
  late final AddPayment addPayment;
  late final UpdatePayment updatePayment;
  late final DeletePayment deletePayment;

  late final GetMembers getMembers;
  late final PaymentsCubit paymentsCubit;
  late TextEditingController searchController;
  String searchQuery = '';

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  List<int> years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(() {
      setState(() => searchQuery = searchController.text);
    });

    final client = http.Client();

    paymentRepository = PaymentRepositoryImpl(
      PaymentRemoteDataSource(client),
    );

    memberRepository = MemberRepositoryImpl(
      MemberRemoteDataSource(client),
    );

    getPayments = GetPayments(paymentRepository);
    addPayment = AddPayment(paymentRepository);
    updatePayment = UpdatePayment(paymentRepository);
    deletePayment = DeletePayment(paymentRepository);

    getMembers = GetMembers(memberRepository);

    paymentsCubit = PaymentsCubit(
      getPayments,
      getMembers,
      addPayment,
      updatePayment,
      deletePayment,
    );

    paymentsCubit.loadData();
  }

  @override
  void dispose() {
    searchController.dispose();
    paymentsCubit.close();
    super.dispose();
  }

  Future<void> _loadData() async {
    await paymentsCubit.loadData();
  }

  List<PaymentEntity> get filteredPayments {
    return paymentsCubit.state.payments.where((p) {
      final d = p.dateVersement;
      if (d == null) return false;
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: paymentsCubit,
      child: BlocBuilder<PaymentsCubit, PaymentsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const CurvedAppBar(title: "Versements"),
            floatingActionButton: FloatingActionButton(
              onPressed: _openAddModal,
              child: const Icon(Icons.add),
            ),
            body: Stack(
              children: [
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
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
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<int>(
                                    value: selectedMonth,
                                    isExpanded: true,
                                    items: List.generate(12, (i) => i + 1)
                                        .map((m) => DropdownMenuItem(
                                              value: m,
                                              child: Text("Mois $m"),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedMonth = v!),
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
                                              child: Text("$y"),
                                            ))
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedYear = v!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: _loadData,
                              child: PaymentsList(
                                payments: filteredPayments,
                                memberMap: state.memberMap,
                                searchQuery: searchQuery,
                                onEdit: (p) => _openEditModal(p),
                                onDelete: (id) async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Confirmer la suppression'),
                                      content: const Text(
                                          'Êtes-vous sûr de vouloir supprimer ce paiement?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Annuler'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Supprimer'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmed ?? false) {
                                    await context
                                        .read<PaymentsCubit>()
                                        .deletePayment(id);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                if (state.isDeleting)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openAddModal() {
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

  void _openEditModal(PaymentEntity payment) {
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
}
