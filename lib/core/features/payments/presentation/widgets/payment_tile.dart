import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:flutter/material.dart';

class PaymentTile extends StatelessWidget {
  final PaymentEntity payment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.green.withOpacity(0.2),
            child: Text(
              payment.memberName[0],
              style: const TextStyle(
                  fontSize: 22,
                  color: Colors.green,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.memberName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("${payment.amount.toStringAsFixed(2)} €",
                    style: const TextStyle(color: Colors.grey)),
                Text(
                    "${payment.date.day}/${payment.date.month}/${payment.date.year}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, color: Colors.orange)),
              IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red)),
            ],
          )
        ],
      ),
    );
  }
}
