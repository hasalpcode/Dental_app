import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:flutter/material.dart';
import 'payment_tile.dart';

class PaymentsList extends StatelessWidget {
  final List<PaymentEntity> payments;
  final Function(PaymentEntity) onEdit;
  final Function(String) onDelete;

  const PaymentsList({
    super.key,
    required this.payments,
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
        return PaymentTile(
          payment: p,
          onEdit: () => onEdit(p),
          onDelete: () => onDelete(p.id),
        );
      },
    );
  }
}
