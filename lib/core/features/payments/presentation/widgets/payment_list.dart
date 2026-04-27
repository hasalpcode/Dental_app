import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';
import 'package:flutter/material.dart';
import 'payment_tile.dart';

class PaymentsList extends StatelessWidget {
  final List<PaymentEntity> payments;
  final Map<int, Member> memberMap;
  final Function(PaymentEntity) onEdit;
  final Function(String) onDelete;

  const PaymentsList({
    super.key,
    required this.payments,
    required this.memberMap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payments.length,
      itemBuilder: (_, i) {
        final p = payments[i];
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
