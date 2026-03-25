import 'package:dental_app/core/features/payments/data/payment_local_data_source.dart';
import 'package:dental_app/core/features/payments/data/payment_repository_impl.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/payments/domain/usecases/add_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/delete_payment.dart';
import 'package:dental_app/core/features/payments/domain/usecases/get_payments.dart';
import 'package:dental_app/core/features/payments/domain/usecases/update_payment.dart';
import 'package:dental_app/core/features/payments/presentation/widgets/add_payment_modal.dart';
import 'package:dental_app/core/features/payments/presentation/widgets/payment_list.dart';
import 'package:flutter/material.dart';
import 'package:dental_app/core/usecases/curved_appbar.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  late final PaymentRepositoryImpl repository;
  late final GetPayments getPayments;
  late final AddPayment addPayment;
  late final UpdatePayment updatePayment;
  late final DeletePayment deletePayment;

  List<PaymentEntity> payments = [];
  final List<String> members = ["John", "Alice", "Bob", "Emma"]; // exemple

  // 🔹 Filtre mois et année
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<int> years =
      List.generate(5, (i) => DateTime.now().year - i); // 5 dernières années

  @override
  void initState() {
    super.initState();
    final dataSource = PaymentLocalDataSource();
    repository = PaymentRepositoryImpl(dataSource);

    getPayments = GetPayments(repository);
    addPayment = AddPayment(repository);
    updatePayment = UpdatePayment(repository);
    deletePayment = DeletePayment(repository);

    payments = getPayments();
  }

  void _refresh() {
    setState(() => payments = getPayments());
  }

  // 🔹 Liste filtrée par mois et année
  List<PaymentEntity> get filteredPayments {
    return payments
        .where(
            (p) => p.date.month == selectedMonth && p.date.year == selectedYear)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CurvedAppBar(title: "Payments"),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddModal,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // 🔹 Filtre mois / année
          Padding(
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
                              child: Text("Mois $m"),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedMonth = v);
                    },
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
                    onChanged: (v) {
                      if (v != null) setState(() => selectedYear = v);
                    },
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Liste filtrée
          Expanded(
            child: PaymentsList(
              payments: filteredPayments,
              onEdit: _openEditModal,
              onDelete: (id) {
                deletePayment(id);
                _refresh();
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Modal ajout
  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPaymentModal(
        members: members,
        onSubmit: (p) {
          addPayment(p);
          _refresh();
        },
      ),
    );
  }

  // 🔹 Modal édition
  void _openEditModal(PaymentEntity payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPaymentModal(
        payment: payment,
        members: members,
        onSubmit: (p) {
          updatePayment(p);
          _refresh();
        },
      ),
    );
  }
}
