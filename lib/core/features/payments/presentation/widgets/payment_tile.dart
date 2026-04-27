import 'package:flutter/material.dart';
import 'package:dental_app/core/features/payments/domain/entity/payments_entity.dart';
import 'package:dental_app/core/features/members/domain/entity/member.dart';

class PaymentTile extends StatelessWidget {
  final PaymentEntity payment;
  final Map<int, Member> memberMap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.memberMap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final memberId = payment.membreId[0];

    final member = memberMap[memberId];

    final username = member?.username ?? "Unknown";

    final date = payment.dateVersement;

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
            backgroundColor: Colors.green.withOpacity(0.2),
            child: Text(username.isNotEmpty ? username[0] : "?"),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "${payment.montant} €",
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  date != null
                      ? "${date.day}/${date.month}/${date.year}"
                      : "No date",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          )
        ],
      ),
    );
  }
}
