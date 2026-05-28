import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:flutter/material.dart';
import 'payment_tile.dart';

class PaymentsList extends StatelessWidget {
  final List<PaymentEntity> payments;
  final Map<int, Member> memberMap;
  final Function(PaymentEntity) onEdit;
  final Function(String) onDelete;
  final String searchQuery;

  const PaymentsList({
    super.key,
    required this.payments,
    required this.memberMap,
    required this.onEdit,
    required this.onDelete,
    this.searchQuery = '',
  });

  List<PaymentEntity> get filteredPayments {
    if (searchQuery.isEmpty) return payments;
    final query = searchQuery.toLowerCase();
    return payments.where((payment) {
      final memberId = payment.membreId.isNotEmpty ? payment.membreId[0] : null;
      if (memberId == null) return false;

      final member = memberMap[memberId];
      if (member == null) return false;

      return member.username.toLowerCase().contains(query) ||
          (member.carteMembre?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayPayments = filteredPayments;

    if (displayPayments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            searchQuery.isEmpty
                ? 'Aucun paiement'
                : 'Aucun paiement trouvé pour "$searchQuery"',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayPayments.length,
      itemBuilder: (_, i) {
        final p = displayPayments[i];
        print("Building tile for payment: ${p.id}, membreId: ${p.membreId}");

        return PaymentTile(
          payment: p,
          memberMap: memberMap,
          onEdit: () => onEdit(p),

          // ✅ SAFE DELETE
          onDelete: () {
            final id = p.id;
            if (id != null && id.isNotEmpty) {
              onDelete(id);
            }
          },
        );
      },
    );
  }
}
