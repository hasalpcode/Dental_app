import 'package:dental_app/core/features/members/data/data_remote_source.dart';
import 'package:dental_app/core/features/payments/data/payment_remote_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/usecases/add_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/delete_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_payments.dart';
import 'package:dental_app/core/features/payments/domain/usecases/update_payment.dart';
import 'package:dental_app/core/features/payments/presentation/widgets/add_payment_modal.dart';
import 'package:dental_app/core/features/payments/presentation/widgets/payment_list.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:dental_app/core/features/members/domain/usecases/get_members.dart';
import 'package:dental_app/core/features/members/data/member_repository_impl.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';
import 'package:flutter/material.dart';
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

  List<PaymentEntity> payments = [];
  List<Member> members = [];

  Map<int, Member> memberMap = {};

  bool isLoading = true;
  bool isDeleting = false;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  List<int> years = List.generate(5, (i) => DateTime.now().year - i);

  @override
  void initState() {
    super.initState();

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

    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final results = await Future.wait([
        getPayments(),
        getMembers(),
      ]);

      payments = results[0] as List<PaymentEntity>;
      members = results[1] as List<Member>;
      print("Members==>: $members");

      // ✅ FIX IMPORTANT
      memberMap = {
        for (final m in members)
          if (m.membreId != null) m.membreId!: m,
      };
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      setState(() => isLoading = false);
      print("Membersmap==>: $memberMap");
      print(
          "Payments==>: ${payments.map((p) => 'id=${p.id}, membreId=${p.membreId}').toList()}");
    }
  }

  List<PaymentEntity> get filteredPayments {
    return payments.where((p) {
      final d = p.dateVersement;
      if (d == null) return false;
      return d.month == selectedMonth && d.year == selectedYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Payments"),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
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
                          memberMap: memberMap,
                          onEdit: (p) async {
                            await updatePayment(p);
                            await _loadData();
                          },
                          onDelete: (id) async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmer la suppression'),
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
                              setState(() => isDeleting = true);
                              try {
                                await deletePayment(id);
                                await _loadData();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Erreur suppression: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => isDeleting = false);
                                }
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          if (isDeleting)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPaymentModal(
        members: members.map((e) => e.username).toList(),
        onSubmit: (p) async {
          await addPayment(p);
          await _loadData();
        },
      ),
    );
  }
}
